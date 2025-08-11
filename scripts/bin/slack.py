

import requests
from slack_bolt import App
import os

# Slack 
slack_token = os.environ.get('SLACK_TOKEN')
#slack_channel = os.environ.get('SLACK_CHANNEL')
app = App(token=slack_token)


class Slack:
    
    def __init__(self, username):
        
        self.username = username
        self.ldap = "ldap-api.k8s.nextsilicon.com"
        
    def getSlackUid(self, ):
        print('getting slack id for user %s' % self.username)
        
        url = 'https://%s/info/%s' % (self.ldap, self.username)
        mail = ""
        uid = ""
        try:
            response = requests.get(url).json()
            mail = response["email"]
            name = response["name"]
        except Exception as e:
            print('Failed to get email for unix user %s, err: %s' % (self.username, e))
            return ''

        url = 'https://%s/slack_id/%s' % (self.ldap, mail)
        try:
            response = requests.get(url)
            uid = response.text
        except Exception as e:
            print("Failed to get slack uid for email %s, err: %s" % (mail, e))
        return uid, mail, name


    # Send a direct message
    def send_direct_message(self, user_id, message):
        
        try:
            app.client.chat_postMessage(channel=user_id, text=message)
            print('Message sent to %s' % user_id)
            app.client.chat_postMessage(channel='U01RQ1PN068', text=message)
            print('Message sent to avner')
        except Exception as e:
            print('Error sending message: %s' % e)
