import os
import sys
import re
from kubernetes import client, config
import xml.etree.ElementTree as ET
import slack_notifications as slack
import datetime
import json
import requests
from slack_sdk import WebClient
import argparse
from slack_bolt import App
from slack_sdk.errors import SlackApiError
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from slack import Slack
from emails import Email

      
def get_parser():
    """ Parser Module """
    parser = argparse.ArgumentParser()
    parser_description = "Backend Postgres service"
    parser.add_argument('-username', help='username', type=str, required=False)
    parser.add_argument('-threshold', help='username', type=int, required=False, default=48)
    parser.add_argument('-slack', help='Alert within a Slack message', action='store_true', default=False)
    parser.add_argument('-email', help='Alert within a Slack message', action='store_true', default=False)

    return parser

def get_username(podname):
  if podname.startswith('nextk8s-ex'):
    pattern = "nextk8s-(ex.+?)-+"
  else:
    pattern = "nextk8s-(.+?)-+"
  result = re.match(pattern, podname)
  if result:
    username = result.groups()[0]
  else:
    return ''
  return username


def get_pod_names(namespace, args, only_include_jnlp=True):
    if os.getenv('KUBERNETES_SERVICE_HOST'):
      config.load_incluster_config()
    else:
      config.load_config()
    cpu = 0
    memory = 0
    pods = []
    users = {}
    
    users_pods = {}
    v1 = client.CoreV1Api()
    ret = v1.list_namespaced_pod(namespace, watch=False)
    pod_num = 1
    current_time = datetime.datetime.utcnow()
    for item in ret.items:
      if item.metadata.name.startswith('nextk8s') and not item.metadata.name.startswith('nextk8s-jenext'): 
        if 'xterm' in item.spec.containers[0].command[-1].split('&&')[-1] or 'xfce4-terminal' in item.spec.containers[0].command[-1].split('&&')[-1]:
          if '-e' not in item.spec.containers[0].command[-1].split('&&')[-1]:
            creation_timestamp = item.metadata.creation_timestamp
            age = current_time - creation_timestamp.replace(tzinfo=None)
            age_hours = round(age.seconds/3600)
            cpu+=int(item.spec.containers[0].env[0].value)
            memory+=int(item.spec.containers[0].env[1].value.split("Gi")[0])
            print("%s.  pod name: %s, status: %s, cpu: %s, memory: %s, command: %s, age: %s hours" % (pod_num, item.metadata.name, item.status.phase, item.spec.containers[0].env[0].value, item.spec.containers[0].env[1].value, item.spec.containers[0].command[-1].split('&&')[-1], age_hours))
            pod_num+=1
            if age_hours > args.threshold:
              _username = get_username(item.metadata.name)
              users = {_username: {'pod': item.metadata.name, 'age': age_hours}}
              pods.append(users)
    
    print("total cores: ", cpu)
    print("total Memory: ", memory, "Gi")
    
    # initialize each user with an empty list
    for pod in pods:
      for user in pod:
        users_pods[user] = []
        
    # Fill in user's list of pods older than threshold
    for pod in pods:
      for user in pod:
        users_pods[user].append(pod[user])
    
    # Alerting user for it's interactive pods via Slack/Mail
    for user in users_pods:
      
      # Creating Slack instance
      if args.slack or args.email:
        slack = Slack(user)
        uid, recipient_email, name = slack.getSlackUid()
      
      # Creating Email instance
        email = Email(recipient_email)
        print(name, uid, email)
        message = 'Hi %s\nPlease, note that you have a running pods:\n' % name
        for pod in users_pods[user]:
              message += '%s more than %s hours\n' % (pod['pod'], pod['age'])
        
        message+= '\nKindly, delete it and free K8s resources.\nThanks\nDevops team'
        # print(message)
        
        if recipient_email and email:
          print('sending an email to user %s with an email %s' % (user, recipient_email))
          print(message)
          email.send_email(recipient_email, 'Note: Old intearctive pods alert!!!', message)
        
        if uid and args.slack:
          print('sending a slack message to user %s, uid: %s' % (user, uid))
          slack.send_direct_message(uid, message)
          print(message)



parser = get_parser()
args = parser.parse_args()
get_pod_names("hw", args)