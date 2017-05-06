# -*- coding: utf-8 -*-

"""Import CSV data to PostgreSQL database

Make sure you got PostgreSQL service running
Create some database and set some owner (user) to it
Set FILE_PATH, DB_NAME, DB_USER.
Run!
"""

import psycopg2
import sys
import csv
import logging
from datetime import datetime
from astropy.table import Table
import operator

_logger = logging.getLogger("csv import")
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

LIMIT = 1000  # limit for amount
FILE_PATH = './import.csv'  # file to import
DB_NAME = "ms"
DB_USER = "ra"

def create_db():
    #  Create PostgreSQL database and table
    try:
        conn = psycopg2.connect("dbname="+DB_NAME+" user="+DB_USER)
    except:
        print "I am unable to connect to the database."
        raise
    cursor = conn.cursor()
    cursor.execute("""CREATE TABLE A (
                id SERIAL CONSTRAINT firstkey PRIMARY KEY, 
                code char(20), 
                post_date date, 
                amount  integer NOT NULL CHECK (amount > 0))""")
    cursor.execute("INSERT INTO A (code, post_date, amount) VALUES ('A-1', '2017-10-10', 50)")
    cursor.execute("INSERT INTO A (code, post_date, amount) VALUES ('A-2', '2017-10-10', 50)")
    cursor.execute("INSERT INTO A (code, post_date, amount) VALUES ('A-3', '2017-10-10', 50)")
    return cursor

def import_data():
    with open(FILE_PATH, 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=';', quotechar='"')
        try:  # check if file is csv
            header_line = next(reader)  # skip header line
        except csv.Error:
            raise
        numerated_reader = [row + [str(k+2)] for k, row in enumerate(reader)]  # add lines index for exceptions
        sorted_reader = sorted(numerated_reader, key=operator.itemgetter(0, 1, 2))  # sort by code, date, amount. Sort by amount helps to take more lines
        c_list = []  # result list
        cumulative = 0  # cumulative total to filter lines
        for ind, row in enumerate(sorted_reader):
            res = row_is_fine(row[3], row)
            if not res:
                continue
            amount, date = res
            if ind:
                if sorted_reader[ind][0] == sorted_reader[ind-1][0] and sorted_reader[ind][1] == sorted_reader[ind-1][1]:
                    cumulative += amount
                else:
                    cumulative = amount
            else:
                cumulative = amount  # first csv line
            if cumulative < LIMIT:
                c_list.append({
                    'code': row[0].strip(),
                    'date':  date,
                    'amount': amount,
                    'cumulative': cumulative})
    return c_list

def row_is_fine(ind, row):
    try:  # check if amount is decimal
        amount = int(row[2].strip())
        if amount <= 0:
            _logger.warning("Line %s. Field 'amount' is not positive", ind)
            return False
    except:
        _logger.warning("Line %s. Field 'amount' is not decimal", ind)
        return False
    try:  # check if date is fine
        date = datetime.strptime(row[1].strip(), "%d%m%Y").strftime("%Y-%m-%d")
    except:
        _logger.warning("Line %s. Field 'post_date' got wrong date format", ind)
        return False
    if len(row[0].strip()) == 0:  # check code
        _logger.warning("Line %s. Field 'code' is empty", ind)
        return False
    return amount, date

def upload_data(c_list):
    if len(c_list):
        cursor.executemany("""INSERT INTO A(code,post_date,amount) VALUES (%(code)s, %(date)s, %(amount)s)""", c_list)

def show_table(cursor):
    cursor.execute("SELECT * FROM A")
    rows = cursor.fetchall()
    print_nice_table(rows)

def print_nice_table(src):
    t = Table(names=('id', 'code', 'date', 'amount'), dtype=('S20', 'S20', 'S20', 'S20'))
    for row in src:
        t.add_row([str(r).strip() for r in row])
    print t

if __name__ == "__main__":
    cursor = create_db()
    _logger.info("Table 'A' before insert:")
    show_table(cursor)
    c_list = import_data()
    upload_data(c_list)
    _logger.info("Table 'A' after insert:")
    show_table(cursor)
