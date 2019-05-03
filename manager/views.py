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

    if request.method == 'POST':
        form = RawInsertModifyBookForm(request.POST)
        form.set_choices(publishers, categories)
        if form.is_valid():
            data = form.cleaned_data
            with connection.cursor() as cursor:
                cursor.callproc('add_book', data.values())

    form = RawInsertModifyBookForm()
    form.set_choices(publishers, categories)

    context = {
        'title': 'Insert a new Book',
        'form': form
    }

    return render(request, 'book_insert.html', context)


def modify_book(request, ISBN, *args, **kwargs):
    [publishers, categories] = get_publishers_categories()

    if request.method == 'POST':
        if 'cancel' in request.POST:
            return redirect('../search/'+ISBN)

        form = RawInsertModifyBookForm(request.POST)
        form.set_choices(publishers, categories)

        if form.is_valid():
            data = form.cleaned_data
            with connection.cursor() as cursor:
                modified_attr = list(data.values())
                modified_attr.insert(0, ISBN)
                cursor.callproc('modify_book', modified_attr)
            new_ISBN = modified_attr[1]
            return redirect('../search/ISBN/'+new_ISBN)
    else:
        with connection.cursor() as cursor:
            cursor.callproc('get_book', [ISBN])
            book = cursor.fetchall()

        form = RawInsertModifyBookForm()
        form.set_choices(publishers, categories)
        form.set_form_data(book[0])

        context = {
            'title': 'Insert a new Book',
            'form': form
        }

        return render(request, 'book_modify.html', context)


def search_base(request, *args, **kwargs):
    context = {
        'title': 'Search for Books',
        'books': []
    }

    if 'search' or 'selector' in request.GET:
        if 'selector' in request.GET:
            return redirect("search/category/{0}".format(int(request.GET.get('selector'))))
        return redirect("search/{0}/{1}".format(request.GET['group'], request.GET.get('search_field')))

    return render(request, 'book_search.html', context)


def search_book_ISBN(request, ISBN, *args, **kwargs):
    return search_book(request, 'get_book', [ISBN])


def search_book_title(request, title, *args, **kwargs):
    return search_book(request, 'get_books_by_title', ['%'+title+'%'])


def search_book_author(request, author, *args, **kwargs):
    return search_book(request, 'get_books_by_author', ['%'+author+'%'])


def search_book_publisher(request, publisher, *args, **kwargs):
    return search_book(request, 'get_books_by_publisher', ['%'+publisher+'%'])


def search_book_category(request, category, *args, **kwargs):
    return search_book(request, 'get_books_by_category', [category])


def search_book(request, procedure, args):
    with connection.cursor() as cursor:
        cursor.callproc(procedure, args)
        books = cursor.fetchall()

    selected_index = 0
    if type(args[0]) == int:
        selected_index = args[0]

    print(selected_index)
    context = {
        'title': 'Search for Books',
        'books': books,
        'selected_index': selected_index
    }
    return render(request, 'book_search.html', context)


def book_orders(request, *args, **kwargs):

    if request.method == 'POST':
        confirmed_orders = list(filter(lambda x: request.POST[x] == 'on', request.POST.keys()))
        confirmed_orders = tuple(map(lambda x: int(x), confirmed_orders))
        with connection.cursor() as cursor:
            cursor.execute("UPDATE BOOKSTORE.Mng_Order SET confirmation = 1 WHERE order_id IN {0}"
                           .format(confirmed_orders))

    with connection.cursor() as cursor:
        cursor.callproc('get_manager_orders')
        orders = cursor.fetchall()

    context = {
        'title': 'Book Orders',
        'orders': orders
    }

    return render(request, 'book_orders.html', context)
