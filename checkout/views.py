from django.shortcuts import render, redirect
from django.db import connection
from .forms import RawVisaForm
import datetime


def checkout(request, *args, **kwargs):
    errors = []

    if request.method == 'POST':
        form = RawVisaForm(request.POST)

        if form.is_valid():
            data = list(form.cleaned_data.values())
            if request.POST['submit'] == 'Insert':
                with connection.cursor() as cursor:
                    cursor.callproc('add_user_credit', [int(request.session['user_id']), data[0], data[1]])
            else:
                with connection.cursor() as cursor:
                    cursor.callproc('update_user_credit', [int(request.session['user_id']), data[0], data[1]])
            return redirect('/search')

        errors = form.errors

    with connection.cursor() as cursor:
        cursor.callproc('check_user_credit', [int(request.session['user_id'])])
        credit = cursor.fetchall()

    form = RawVisaForm()

    context = {
        'title': '',
        'auth': request.session['is_manager'],
        'form': form,
        'value': 'Insert',
        'errors': errors
    }

    if credit:
        if datetime.datetime.now().date() < credit[0][2]:
            with connection.cursor() as cursor:
                cursor.callproc('cart_checkout', [int(request.session['card_id']), int(request.session['user_id'])])
            return redirect('/search')
        else:
            form.set_form_data(credit[0][1:])
            context['value'] = 'Update'
    return render(request, 'credit_info.html', context)
