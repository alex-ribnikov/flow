#!/usr/bin/env python3

import os
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

# ----- Globals
    
csv_headers = {'Time': 'time|Time', 'Date': 'date|Date', 'Block_name': 'block_name|String', 'Source': 'source|String',\
               'Version': 'version|String', 'Run': 'run|String', 'stage': 'stage|String', 'X(um)': 'xum|Float',\
               'Y(um)': 'yum|Float', 'Area': 'area|Float', 'Leaf_Cell_Area': 'leaf_cell_area|Float',\
               'Utilization': 'util_percent|Float', 'Cell_count': 'cell_count|Integer', 'Buf/inv': 'buf_inv|Integer',\
               'Logic': 'logic|Integer', 'Flops': 'flops|Integer', 'Bits': 'bits|Integer', 'Removed_seq': 'removed_seq|Integer',\
               'num_of_ports': 'num_of_ports|Integer', '%svt': 'svt_percent|Float', '%lvtll': 'lvtll_percent|Float',\
               '%lvt': 'lvt_percent|Float', '%ulvtll': 'ulvtll_percent|Float', '%ulvt': 'ulvt_percent|Float', '%en': 'en_percent|Float', 'internal': 'internal|Float',\
               'switching': 'switching|Float', 'dynamic': 'dynamic|Float', 'leakage': 'leakage|Float', 'total': 'total|Float', 'Bank_ratio': 'bank_ratio|Float',\
               '2_mulibit': 'two_mulibit|Float', '4_mulibit': 'four_mulibit|Float', '6_multibit': 'six_mulibit|Float', '8_mulibit': 'height_mulibit|Float',\
               'Total WNS(ps)': 'total_wns_ps|Float', 'Total TNS(ps)': 'total_tns_ps|Float',\
               'Total FEP': 'total_fep|Float', 'R2R WNS(ps)': 'r2r_wns_ps|Float', 'R2R TNS(ps)': 'r2r_tns_ps|Float', 'R2R FEP': 'r2r_fep|Float',\
               'Hold WNS(ns)': 'hold_wns_ps|Float', 'Hold TNS(ps)': 'hold_tns_ps|Float', 'Hold FEP': 'hold_fep|Float', 'V': 'v_percent|Float', 'H': 'h_percent|Float',\
               'num_of_shorts': 'num_of_shorts_percent|Float','DRC_Total': 'drc_total|Float', 'Run_time': 'run_time|Duration', 'CPU': 'cpu_requested|Float',\
               'Mem': 'memory_requested|Float', 'Comment': 'comment|String'}


local_POSTGRES_HOST = "hw-postgresql.hw.k8s.nextsilicon.com"
k8s_POSTGRES_HOST = "hw-postgresql.hw.svc.cluster.local."
POSTGRES_USER = os.environ['POSTGRES_USER']
POSTGRES_PASSWORD = os.environ['POSTGRES_PASSWORD'] 
DB_NAME = os.environ['DB_NAME']
DATE = datetime.datetime.now().strftime("%Y-%m-%d")
TIME = datetime.datetime.now().strftime("%H:%M:%S %p")

# ------------------------
def get_parser():
    """ Parser Module """

    parser = argparse.ArgumentParser()
    parser_description = "Backend Postgres service"
    parser.add_argument('-csv_file', help='Full path csv file', type=str, required=True)
    parser.add_argument('-table_name', help='table name in DB to insert data to', type=str, required=False, default='pnr_cor_summary')
    parser.add_argument('-preview', help='preview CSV converted into list of Jsons',type=bool, required=False, default=False)
    # parser.add_argument('-memory', help='set resource memory(Gi)',type=str,required=False, default='0')
    # parser.add_argument('-dummy', help='NOT applying changes in K8s Queue', action='store_true')
    # parser.add_argument('-set', help='Set K8s Queue configuration', action='store_true')
    # parser.add_argument('-get', help='Get K8s Queue configuration', action='store_true')

    return parser

# ------------------------

# ---- Functions
@retry(stop=stop_after_attempt(3), wait=wait_fixed(1))
def create_engine_with_retry(connection_string):
    return create_engine(connection_string)

# ----
def check_if_table_exists(engine, table_name):
    if not inspect(engine).has_table(table_name): 
        return False
    return True

def insert_db(engine, data, results):

    try:
        with engine.connect() as connection:
            for record in data:
                # Use the insert statement
                # print('printtttttt - ', record)
                stmt = insert(results).values(**record)
                stmt = stmt.on_conflict_do_nothing(constraint="uq_datetime_source")  # Replace with appropriate unique constraint
                connection.execute(stmt)
                connection.commit()
    except:
        raise
    print("Data inserted successfully")
    

def define_table(table_name, metadata):
    results = Table(
    table_name, 
    metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime),
    Column('time', DateTime, default=datetime.datetime), Column('block_name', String), Column('source', String), Column('version', String),
    Column('run', String), Column('stage', String), Column('xum', Float), Column('yum', Float), Column('area', Float), Column('leaf_cell_area', Float),
    Column('util_percent', Float), Column('cell_count', Integer), Column('buf_inv', Integer), Column('logic', Integer), Column('flops', Integer),
    Column('bits', Integer), Column('removed_seq', Integer), Column('num_of_ports', Integer), Column('svt_percent', Float),
    Column('lvtll_percent', Float), Column('lvt_percent', Float), Column('ulvtll_percent', Float), Column('ulvt_percent', Float), 
    Column('en_percent', Float), Column('internal', Float), Column('switching', Float), Column('dynamic', Float), Column('leakage', Float), 
    Column('total', Float), Column('bank_ratio', Float), Column('two_mulibit', Float), Column('four_mulibit', Float), Column('six_mulibit', Float), Column('height_mulibit', Float),
    Column('total_wns_ps', Float), Column('total_tns_ps', Float), Column('total_fep', Float), Column('r2r_wns_ps', Float),
    Column('r2r_tns_ps', Float), Column('r2r_fep', Float), Column('hold_wns_ps', Float), Column('hold_tns_ps', Float),
    Column('hold_fep', Float), Column('v_percent', Float), Column('h_percent', Float), Column('num_of_shorts_percent', Float),
    Column('drc_total', Float), Column('run_time', Float), Column('cpu_requested', Float), Column('memory_requested', Float),
    Column('comment', String), UniqueConstraint('date', 'time', 'source', name='uq_datetime_source'), )    
    #Column('start_time', DateTime), Column('end_time', DateTime), Column('timestamp', DateTime),
    #Column('grafana_log_link', String))
    
    return results

# ----
def create_table(username_='', table_name=''):
    
    print('Creating table %s on DB %s' % (table_name, DB_NAME))
    POSTGRES_HOST = local_POSTGRES_HOST
    # Create a connection to the database
    engine = create_engine_with_retry(f'postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}/{DB_NAME}?application_name={username_}')
    if not check_if_table_exists(engine, table_name):
        try:

            # Create a MetaData instance
            metadata = MetaData()
            define_table(table_name, metadata)
            metadata.create_all(engine)
        except Exception as e:
            raise e
    
    else: 
        print('table %s already exists, skipping' % table_name)
    
    return engine

def convert_csv_dict(csv_file): 
    # read csv file to a list of dictionaries
    date_format = '%b %d %Y'
    time_format = '%I:%M:%S %p'
    duration_format = '%H:%M:%S'
    csvListDicts = [] 
    with open(csv_file, 'r') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            _dict = {}
            for k in row:
                print(csv_headers[k])
                new_val = None
                if row[k] == 'NA':
                    continue

                match csv_headers[k].split('|')[1]:
                    
                    case 'String':
                        new_val = str(row[k])

                    case 'Float':
                        if len(row[k].split('%')) > 1:
                            new_val = float(row[k].split('%')[0])
                        else:
                            new_val = float(row[k])
                        
                        
                    case 'Date':
                        new_val = datetime.datetime.strptime(row[k], date_format)
                       # new_val = datetime.datetime(date_obj)
                                          
                    case 'Duration':
                        duration = row[k].split(':')
                        new_val = datetime.timedelta(hours=int(duration[0]), minutes=int(duration[1]), seconds=int(duration[2])).total_seconds()
                        print(type(new_val))
                        
                    case 'Time':
                        new_val = datetime.datetime.strptime(row[k], time_format)
                        #new_val = datetime.datetime(time_obj)
                        
                _dict[csv_headers[k].split('|')[0]] = new_val
            csvListDicts.append(_dict)
    for row in csvListDicts:
        print(row)
    return csvListDicts

def validateArgs(args):
    """ Validate args """

    if not os.path.isfile(args.csv_file):
        print('no such file %s:' % args.csv_file)
        raise FileNotFoundError
        
if __name__ == "__main__":
    
    # Pasrse Args
    parser = get_parser()
    args = parser.parse_args()
    validateArgs(args)
    
    # Convert CSV 
    data = convert_csv_dict(args.csv_file)
    if args.preview: 
        for k in data:
            print(k)
        exit(0)
    # Init conn to DB
    engine = create_table('hw', args.table_name)
    
    metadata = MetaData()
    results = define_table(args.table_name, metadata)
    
    # Insert data into the table
    insert_db(engine, data, results)



