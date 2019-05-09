from django.shortcuts import render, redirect
from django.db import connection
import mysql.connector

def connect():
    mydb = mysql.connector.connect(
        host="localhost",
        user="root",
        passwd="",
        db="bookstore"
    )
    cur = mydb.cursor()
    return mydb, cur


# # Create your views here.
# def home_get(request,msg_err = None):
#     mydb, cur = connect()
#     cur = connection.cursor()
#     cur.execute("SELECT * FROM Users")
#     test_data = cur.fetchall()
#     try:
#         session_id = request.session['user_id']
#     except Exception:
#         return render(request, 'home.html', {'data': test_data, 'error': msg_err})
#     mydb.close()
#     return render(request,'home.html', {'data': test_data,'session_id': session_id, 'error': msg_err})

#
# def next(request):
#     x = request.session["use"]
#     request.session["use"] = "0"
#     return HttpResponse("x"+x)

def home(request):
    return redirect('/search')


def signup(request):
    if(request.method == 'GET'):
        return render(request,'signup.html',{'title': 'Signup'})
    elif(request.method == 'POST'):
        data = []
        data.append(request.POST.get('user_name'))
        data.append(request.POST.get('password'))
        data.append(request.POST.get('last_name'))
        data.append(request.POST.get('first_name'))
        data.append(request.POST.get('email'))
        # hash password
        data.append(request.POST.get('phone'))
        data.append(request.POST.get('shipping_address'))
        sql = call_procedure('register_user', data, ['@x','@a'])
        try:
            mydb, cur = connect()
            cur.execute(sql)
        except mysql.connector.Error as err:
            mydb.close()
            return render(request,'signup.html', {'title': 'Signup', 'errors': err.msg})
        cur.execute('select @x')
        session_data = {}
        session_data['user_id'] = cur.fetchall()[0][0]
        cur.execute('select @a')
        session_data['card_id'] = cur.fetchall()[0][0]
        mydb.commit()
        mydb.close()
        request.session['user_id'] = session_data['user_id']
        request.session['card_id'] = session_data['card_id']
        return redirect('/search')


def login(request,msg_err = None):
    if (request.method == 'GET'):
        return render(request, 'login.html', {'title': 'Login', 'errors': msg_err})
    elif (request.method == 'POST'):
        data = {}
        data['email'] = request.POST.get('email')
        data['password'] = request.POST.get('password')
        sql = call_procedure('login_user_by_email', [data['email'], data['password']],['@x','@a'])
        try:
            mydb, cur = connect()
            cur.execute(sql)
        except mysql.connector.Error as err:
            mydb.close()
            return render(request,'login.html', {'title': 'Login', 'errors': err.msg})
        cur.execute("select @x")
        request.session['user_id'] = cur.fetchall()[0][0]
        r = request.session['user_id']
        cur.execute("select @a")
        request.session['card_id'] = cur.fetchall()[0][0]
        try:
            cur.execute('call is_manager('+str(request.session['user_id'])+')')
            request.session['is_manager'] = True
        except mysql.connector.Error as err:
            request.session['is_manager'] = False
        mydb.commit()
        mydb.close()
        return redirect('/search')


def update_user(request):
    data = {'title': 'Update User Info', 'auth': request.session['is_manager']}

    if (request.method == 'GET'):
        # get data into hash an send it
        sql = "select * from Users where "+"user_id = "+str(request.session['user_id'])+";"
        try:
            mydb, cur = connect()
            cur.execute(sql)
            d = cur.fetchall()
            data['user_name'] = d[0][1]
            data['password'] = d[0][2]
            data['lname'] = d[0][3]
            data['fname'] = d[0][4]
            data['email'] = d[0][5]
            data['phone'] = d[0][6]
            data['shipping_address'] = d[0][7]
            mydb.close()
        except mysql.connector.Error as err:
            return render(request, 'login.html', {'title': 'Login', 'errors': err.msg})

        return render(request, 'update.html', data)
    elif (request.method == 'POST'):
        mydb, cur = connect()
        updated_data = []
        updated_data.append(str(request.session['user_id']))
        updated_data.append(request.POST.get('user_name'))
        updated_data.append(request.POST.get('password'))
        updated_data.append(request.POST.get('last_name'))
        updated_data.append(request.POST.get('first_name'))
        updated_data.append(request.POST.get('email'))
        updated_data.append(request.POST.get('phone'))
        updated_data.append(request.POST.get('shipping_address'))
        sql = call_procedure('update_user_info', updated_data)
        cur.execute(sql)
        mydb.commit()
        mydb.close()
        return redirect('/search')


def logout(request):
    # logic before logout

    cart_id = request.session['card_id']
    if(cart_id == None):
        return redirect('/login/not logged in')
    sql = call_procedure('cart_empty', [str(cart_id)])
    mydb, cur = connect()
    cur.execute(sql)
    sql = call_procedure('cart_remove', [str(cart_id)])
    cur.execute(sql)
    mydb.commit()
    mydb.close()
    request.session['user_id'] = None
    request.session['card_id'] = None
    return redirect('/')


def call_procedure(procedure_name,pram = None,out_pram = None):
    sql = "CALL "+procedure_name+"("
    if(pram != None):
        for i in range(len(pram)):
            sql += "'"
            sql += pram[i]
            sql += "'"
            if(i != len(pram) - 1 or out_pram != None):
                sql += ","

    if(out_pram != None):

        for i in range(len(out_pram)):
            sql += out_pram[i]
            if (i != len(out_pram) - 1):
                sql += ","

    sql += ");"
    return sql
