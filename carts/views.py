from django.http import HttpResponse
from django.shortcuts import render, redirect
from django.db import connection
from book_model.views import connect, call_procedure

# Create your views here.
def add_book(request):
    if(request.method == 'POST'):
        data = []
        try:
            cart_id = request.session['card_id']
        except Exception as e:
            return HttpResponse("user not logged in")
        data.append(str(cart_id))
        data.append(request.POST.get('ISBN'))
        data.append(str(1))
        sql = call_procedure('cart_include_book', data)
        db, cur = connect()
        cur.execute(sql)
        db.commit()
        db.close()
        return HttpResponse("success")

def remove_book(request):
    if (request.method == 'POST'):
        data = []
        try:
            cart_id = request.session['card_id']
        except Exception as e:
            return HttpResponse("user not logged in")
        data.append(str(cart_id))
        data.append(request.POST.get('ISBN'))
        sql = call_procedure('cart_exclude_book', data)
        db, cur = connect()
        cur.execute(sql)
        db.commit()
        db.close()
        return HttpResponse("success")

def get_cart(request):

    cart_id = request.session['card_id']
    user_id = request.session['user_id']
    if(cart_id == None or user_id == None):
        return redirect('/login/not logged in')

    carts = []
    sql = call_procedure('view_cart', [str(cart_id)])
    print(sql)
    cur = connection.cursor()
    cur.execute(sql)
    carts = cur.fetchall()

    return render(request, 'cart.html', {'carts': carts})
