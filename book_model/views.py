from django.shortcuts import render
import mysql.connector
# Create your views here.
def home_get(request,*arg,**karg):
    mydb = mysql.connector.connect(
        host="localhost",
        user="root",
        passwd="MUH@mmed3592481",
        db="sys"
    )

    cur = mydb.cursor();
    cur.execute("SELECT * FROM sys_config")
    test_data = cur.fetchall()

    return render(request,'home.html', {'data': test_data})