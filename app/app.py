from flask import Flask
import pymysql
import json
import os

raw_secret = os.getenv("RDS_SECRET")

if raw_secret:
    # FIX: remove CRLF and trim whitespace
    cleaned = raw_secret.strip().replace("\r", "").replace("\n", "")

    # Load JSON safely
    creds = json.loads(cleaned)
    rds_username = creds["username"]
    rds_password = creds["password"]
else:
    rds_username = None
    rds_password = None



app = Flask(__name__)

RDS_HOST = os.getenv("RDS_HOST")
rds_username = os.getenv("username")
rds_password = os.getenv("password")
RDS_DB = "testdb"

@app.route("/")
def hello():
    try:
        conn = pymysql.connect(
            host=RDS_HOST,
            user=rds_username,
            password=rds_password,
            database=RDS_DB
        )
        cursor = conn.cursor()
        cursor.execute("SELECT 'RDS Connected!'")
        result = cursor.fetchone()
        return f"Hello World from ECS → RDS! Message: {result[0]}"
    except Exception as e:
        return f"Error connecting to RDS: {str(e)}"

app.run(host="0.0.0.0", port=3000)

