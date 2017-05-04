# -*- coding: utf-8 -*-

import psycopg2
import csv
from datetime import datetime
from astropy.table import Table


def create_db():
    try:
        conn = psycopg2.connect("dbname='ms' user='ra'")
    except:
        print "I am unable to connect to the database."
    cur = conn.cursor()
    cur.execute("""CREATE TABLE A (
                id SERIAL CONSTRAINT firstkey PRIMARY KEY, 
                code char(20), 
                post_date date, 
                amount  integer NOT NULL CHECK (amount > 0))""")
    cur.execute("INSERT INTO A (code, post_date, amount) VALUES ('A-11', '2017-10-10', 102)")
    cur.execute("INSERT INTO A (code, post_date, amount) VALUES ('A-22', '2017-10-10', 101)")
    cur.execute("INSERT INTO A (code, post_date, amount) VALUES ('A-33', '2017-10-10', 105)")
    return cur

def import_data():
    filename = './import.csv'
    with open(filename, 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=';', quotechar='"')
        first_line = next(reader)  # skip first
        c_list = []
        for ind, row in enumerate(reader):
            c_list.append({
                'code': row[0].strip(),
                'date':  datetime.strptime(row[1].strip(), "%d%m%Y").strftime("%Y-%m-%d"),
                'amount': int(row[2].strip())})
    return c_list

def upload_data(c_list):
    if len(c_list):
        cur.executemany("""INSERT INTO A(code,post_date,amount) VALUES (%(code)s, %(date)s, %(amount)s)""", c_list)

def show_table(cur):
    cur.execute("SELECT * FROM A")
    rows = cur.fetchall()
    print_nice_table(rows)

def print_nice_table(src):
    t = Table(names=('id', 'code', 'date', 'amount'), dtype=('S20', 'S20', 'S20', 'S20'))
    for row in src:
        t.add_row([str(r).strip() for r in row])
    print t

cur = create_db()
print "\n Table 'A' before insert:"
show_table(cur)
c_list = import_data()
upload_data(c_list)
print "\n Table 'A' after insert:"
show_table(cur)
