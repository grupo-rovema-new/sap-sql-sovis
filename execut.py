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
  



def runPath(cursor,path): 
    for filename in glob.iglob(path, recursive = True): 
        with open(filename, 'r') as file:
            data = file.read()
            print(filename)
            cursor.execute(data)

conn = createConnection()
cursor = conn.cursor()
runPath(cursor,'src/views/util/**/*.sql')
runPath(cursor,'src/views/comercial/**/*.sql')
cursor.close()
