from flask import Flask
import pymysql
import os
import json

secret_json = os.getenv("RDS_SECRET")
if secret_json:
    creds = json.loads(secret_json)
    rds_username = creds["username"]
    rds_password = creds["password"]
else:
    rds_username = os.getenv("username")
    rds_password = os.getenv("password")

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

