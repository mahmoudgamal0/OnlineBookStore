from django.http import HttpResponse
from django.shortcuts import render, redirect


# Create your views here.
def add_book(request):
    if(request.method == 'POST'):
        return HttpResponse("")