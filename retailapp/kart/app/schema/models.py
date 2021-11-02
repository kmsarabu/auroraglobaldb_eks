import psycopg2
from psycopg2.extras import RealDictCursor
import os
import json

def connect(type="writer"):
    rds_rw_host = os.environ['DATABASE_HOST']
    rds_ro_host = os.environ['DATABASE_RO_HOST']
    db_user = os.environ['DATABASE_USER']
    password = os.environ['DATABASE_PASSWORD']
    db_name = os.environ['DATABASE_DB_NAME']
    port = os.environ['DATABASE_PORT']
    rds_host = rds_rw_host if type == "writer" else rds_ro_host
    print ("x-{}-x-{}-x-{}-x-{}".format(rds_host, db_user, db_name, port))
    return psycopg2.connect(sslmode="require", host=rds_host, user=db_user, password=password, dbname=db_name, connect_timeout=10000, port=port, keepalives_interval=30)

class Kart:
    def __init__(self):
        pass

    def set(self, key, value):
        with connect("writer") as dbconn:
            with dbconn.cursor(cursor_factory=RealDictCursor) as cur:
                try:
                    print ("KRISHNA KRISHNA in Kart inserting values {}, {}".format(key, value))
                    sqlstmt = "insert into SessionStore(key, value) values(%s, %s) on conflict(key) do update set value = EXCLUDED.value"
                    cur.execute(sqlstmt, (key, json.dumps(value),))
                    dbconn.commit()
                    msg = "Added successfully KRISHNA KRISHNA KRISHNA"
                except Exception as e:
                    print (e)
                    dbconn.rollback()
                    msg = "Error Occurred"

    def get(self, key):
        print ("Extracting kart info for kart item {}".format(key))
        sqlstmt = "select value from SessionStore where key='{}'".format(key)
        with connect("reader") as dbconn:
            with dbconn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sqlstmt)
                r = cur.fetchone()
                print (r)
                return dict(r).get('value') if r else []

    def delete(self, key):
        sqlstmt = "delete from SessionStore where key='{}'".format(key)
        with connect("writer") as dbconn:
            with dbconn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sqlstmt)
                dbconn.commit()


