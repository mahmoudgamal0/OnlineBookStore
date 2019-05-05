from django.shortcuts import render, redirect
from django.db import connection
from .forms import RawInsertModifyBookForm


def get_publishers_categories():
    with connection.cursor() as cursor:
        cursor.callproc('get_categories')
        categories = cursor.fetchall()
    with connection.cursor() as cursor:
        cursor.callproc('get_publishers')
        publishers = cursor.fetchall()
    return [publishers, categories]


def insert_book(request, *args, **kwargs):

    [publishers, categories] = get_publishers_categories()
    errors = []
    if request.method == 'POST':
        form = RawInsertModifyBookForm(request.POST)
        form.set_choices(publishers, categories)
        if form.is_valid():
            data = form.cleaned_data
            with connection.cursor() as cursor:
                try:
                    cursor.callproc('add_book', data.values())
                except Exception as e:
                    errors = e

    if errors:
        pass
    else:
        form = RawInsertModifyBookForm()
        form.set_choices(publishers, categories)

    context = {
        'title': 'Insert a new Book',
        'form': form,
        'auth': request.session['is_manager'],
        'errors': errors
    }

    return render(request, 'book_insert.html', context)


def modify_book(request, ISBN, *args, **kwargs):
    [publishers, categories] = get_publishers_categories()

    if request.method == 'POST':
        if 'cancel' in request.POST:
            return redirect('../../search/m/ISBN/'+ISBN)

        form = RawInsertModifyBookForm(request.POST)
        form.set_choices(publishers, categories)

        if form.is_valid():
            data = form.cleaned_data
            with connection.cursor() as cursor:
                modified_attr = list(data.values())
                modified_attr.insert(0, ISBN)
                cursor.callproc('modify_book', modified_attr)
            new_ISBN = modified_attr[1]
            return redirect('../../search/m/ISBN/'+new_ISBN)
    else:
        with connection.cursor() as cursor:
            cursor.callproc('get_book', [ISBN])
            book = cursor.fetchall()

        form = RawInsertModifyBookForm()
        form.set_choices(publishers, categories)
        form.set_form_data(book[0])

        context = {
            'title': 'Insert a new Book',
            'form': form,
            'auth': request.session['is_manager']
        }

        return render(request, 'book_modify.html', context)


def book_orders(request, *args, **kwargs):

    if request.method == 'POST':
        confirmed_orders = list(filter(lambda x: request.POST[x] == 'on', request.POST.keys()))
        confirmed_orders = tuple(map(lambda x: int(x), confirmed_orders))
        with connection.cursor() as cursor:
            if len(confirmed_orders) == 1:
                cursor.execute("DELETE FROM BOOKSTORE.Mng_Order WHERE order_id = {0}".format(confirmed_orders[0]))
            else:
                cursor.execute("DELETE FROM BOOKSTORE.Mng_Order WHERE order_id IN {0}".format(confirmed_orders))

    with connection.cursor() as cursor:
        cursor.callproc('get_manager_orders')
        orders = cursor.fetchall()

    context = {
        'title': 'Book Orders',
        'orders': orders,
        'auth': request.session['is_manager']
    }

    return render(request, 'book_orders.html', context)


def promote_user(request, *args, **kwargs):

    context = {
        'title': 'Site Users',
        'users': [],
        'auth': request.session['is_manager']
    }

    if request.method == 'POST':
        users_to_promote = list(filter(lambda x: request.POST[x] == 'on', request.POST.keys()))
        users_to_promote = tuple(map(lambda x: int(x), users_to_promote))
        with connection.cursor() as cursor:
            for user in users_to_promote:
                cursor.callproc('promote_user_by_id', [user])

    if 'search' in request.GET:
        with connection.cursor() as cursor:
            cursor.callproc('get_users_by_username', ['%'+request.GET.get('search_field')+'%'])
            context['users'] = cursor.fetchall()

    return render(request, 'user_promote.html', context)


def sales(request, *args, **kwargs):

    with connection.cursor() as cursor:
        cursor.callproc('get_top_ten_books')
        books = cursor.fetchall()
    with connection.cursor() as cursor:
        cursor.callproc('get_top_five_users')
        users = cursor.fetchall()
    with connection.cursor() as cursor:
        cursor.callproc('get_sales_month')
        book_sales = cursor.fetchall()

    context = {
        'title': 'Sales Report',
        'books': books,
        'users': users,
        'sales': book_sales,
        'auth': request.session['is_manager'],
        'errors': []
    }

    return render(request, 'manager_sales.html', context)
