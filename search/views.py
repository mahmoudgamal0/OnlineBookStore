from django.shortcuts import render, redirect
from django.db import connection


def search_base(request, *args, **kwargs):
    context = {
        'title': 'search for Books',
        'books': [],
        'auth': request.session['is_manager']
    }

    if 'search' in request.GET or 'selector' in request.GET:
        if 'search' in request.GET:
            return redirect("search/{0}/{1}".format(request.GET['group'], request.GET.get('search_field')))
        return redirect("search/category/{0}".format(int(request.GET.get('selector'))))

    return render(request, get_view_to_render(request), context)


def search_book_ISBN(request, ISBN, *args, **kwargs):
    return search_book(request, 'get_book', [ISBN])


def search_book_title(request, title, *args, **kwargs):
    return search_book(request, 'get_books_by_title', ['%' + title + '%'])


def search_book_author(request, author, *args, **kwargs):
    return search_book(request, 'get_books_by_author', ['%' + author + '%'])


def search_book_publisher(request, publisher, *args, **kwargs):
    return search_book(request, 'get_books_by_publisher', ['%' + publisher + '%'])


def search_book_category(request, category, *args, **kwargs):
    return search_book(request, 'get_books_by_category', [category])


def search_book(request, procedure, args):
    errors = []
    with connection.cursor() as cursor:
        try:
            cursor.callproc(procedure, args)
            books = cursor.fetchall()
        except Exception as e:
            errors = e

    selected_index = 0
    if type(args[0]) == int:
        selected_index = args[0]

    context = {
        'title': 'search for Books',
        'books': books,
        'selected_index': selected_index,
        'auth': request.session['is_manager'],
        'errors': errors
    }

    return render(request, get_view_to_render(request), context)


def get_view_to_render(request):
    if request.session['is_manager']:
        return 'book_search.html'
    return 'book_search_user.html'
