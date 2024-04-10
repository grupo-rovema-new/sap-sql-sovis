import os
from hdbcli import dbapi

conn = dbapi.connect(
    address=os.environ["ADDRESS"],
    port=os.environ["PORT"],
    user=os.environ["USER"],
    password=os.environ["PASSWORD"],
    databaseName=os.environ["DATABASENAME"],
    instanceNumber=os.environ["INSTANCENUMBER"],
    currentSchema=os.environ["CURRENTSCHEMA"]
)

cursor = conn.cursor()

cursor.execute("SELECT * FROM OINV LIMIT 5")
for row in cursor:
    print(row)

cursor.close()

