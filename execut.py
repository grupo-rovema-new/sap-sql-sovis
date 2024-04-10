import os
from hdbcli import dbapi
import glob 
 
def createConnection():
    return dbapi.connect(
        address=os.environ["ADDRESS"],
        port=os.environ["PORT"],
        user=os.environ["USER"],
        password=os.environ["PASSWORD"],
        databaseName=os.environ["DATABASENAME"],
        instanceNumber=os.environ["INSTANCENUMBER"],
        currentSchema=os.environ["CURRENTSCHEMA"])
  
conn = createConnection()
cursor = conn.cursor()

for filename in glob.iglob('src/**/BpCpfCnpj.sql', recursive = True): 
    with open(filename, 'r') as file:
        data = file.read().replace('\n', '')
        cursor.execute(data)

cursor.close()

