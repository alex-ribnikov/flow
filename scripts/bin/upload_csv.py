#!/usr/bin/env python3

import os
import sys
import argparse
import datetime
import csv
import datetime
import json
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.dialects.postgresql import DATERANGE
from sqlalchemy import create_engine, MetaData, Table, Column, String, Float, Integer, select, text, ForeignKey, UniqueConstraint, PrimaryKeyConstraint, DateTime, update, inspect
from sqlalchemy.orm import relationship
from sqlalchemy.exc import IntegrityError, ProgrammingError
from tenacity import retry, stop_after_attempt, wait_fixed
from base import Base
from git import Repo

STAGES = ['init', 'compile', 'cts', 'cts_only', 'route', 'place', 'chip_finish']

# ------------------------
def get_parser():
    """ Parser Module """
    parser = argparse.ArgumentParser()
    parser_description = "Backend Postgres service"
    parser.add_argument('-csv_file', help='Full path csv file', type=str, required=True)
    #parser.add_argument('-table_name', help='table name in DB to insert data to', type=str, required=True, default='pnr_cor_summary')
    parser.add_argument('-preview', help='preview CSV converted into list of Jsons',type=bool, required=False, default=False)
    parser.add_argument('-stage', help='STAGE name(%s)' % ','.join(STAGES),type=str, required=True, default='')
    parser.add_argument('-group', help='Uploading group CSV in addition to stage one', action='store_true')

    return parser

def validateArgs(args):
    """ Validate args """

    if not os.path.isfile(args.csv_file):
        print('no such file %s:' % args.csv_file)
        raise FileNotFoundError
    
    if args.stage == '':
        print('stage name cannot be empty')
        raise
    
    if args.stage not in STAGES:
        print('Error: stage must be one of %s\nexit status: 1' % ','.join(STAGES))
        sys.exit(1)
        
if __name__ == "__main__":
    
    
    # Pasrse Args
    parser = get_parser()
    args = parser.parse_args()
    validateArgs(args)
    
    c = Base(args.stage, args.csv_file, args.group)
    c.get_csv_headers()
    
    # Convert CSV 
    data = c.convert_csv_dict()
    
    if args.preview: 
        for k in data:
            print(k)
        exit(0)
    
    # Init conn to DB
    # c.create_table_if_not_exists('hw', args.stage)
    
    # Insert data into the table
    c.insert_db()



