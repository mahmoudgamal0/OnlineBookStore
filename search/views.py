from django.shortcuts import render, redirect
from django.db import connection


def search_base(request, auth, *args, **kwargs):
    context = {
        'title': 'search for Books',
        'books': []
    }

    print(auth)

    if 'search' in request.GET or 'selector' in request.GET:
        if 'selector' in request.GET:
            return redirect("{0}/category/{1}".format(auth, int(request.GET.get('selector'))))
        return redirect("{0}/{1}/{2}".format(auth, request.GET['group'], request.GET.get('search_field')))

    return render(request, get_view_to_render(auth), context)


def search_book_ISBN(request, auth, ISBN, *args, **kwargs):
    return search_book(request, auth, 'get_book', [ISBN])


def search_book_title(request, auth, title, *args, **kwargs):
    return search_book(request, auth, 'get_books_by_title', ['%'+title+'%'])


def search_book_author(request, auth, author, *args, **kwargs):
    return search_book(request, auth, 'get_books_by_author', ['%'+author+'%'])


def search_book_publisher(request, auth, publisher, *args, **kwargs):
    return search_book(request, auth, 'get_books_by_publisher', ['%'+publisher+'%'])


def search_book_category(request, auth, category, *args, **kwargs):
    return search_book(request, auth, 'get_books_by_category', [category])


def search_book(request, auth, procedure, args):
    with connection.cursor() as cursor:
        cursor.callproc(procedure, args)
        books = cursor.fetchall()

    selected_index = 0
    if type(args[0]) == int:
        selected_index = args[0]

    context = {
        'title': 'search for Books',
        'books': books,
        'selected_index': selected_index
    }

    return render(request, get_view_to_render(auth), context)


def get_view_to_render(auth):
    if auth == 'm':
        return 'book_search.html'
    return 'book_search_user.html'