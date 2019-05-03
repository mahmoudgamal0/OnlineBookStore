"""book_store URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path,re_path
from book_model import views

from manager import views as mview


urlpatterns = [
    path('admin/', admin.site.urls),
    # User operations
    re_path(r'home/(?P<msg_err>[A-Za-z\s]+)?', views.home_get),
    path('next/', views.next),
    path('signup/', views.signup),
    re_path(r'login/(?P<msg_err>[A-Za-z\s]+)?', views.login),
    path('logout/', views.logout),
    path('update_user/', views.update_user),



    # Manager Operations
    path('manager/insert', mview.insert_book),
    path('manager/modify/<slug:ISBN>', mview.modify_book),
    path('manager/search', mview.search_base),
    path('manager/search/ISBN/<slug:ISBN>', mview.search_book_ISBN),
    path('manager/search/title/<slug:title>', mview.search_book_title),
    path('manager/search/author/<slug:author>', mview.search_book_author),
    path('manager/search/publisher/<slug:publisher>', mview.search_book_publisher),
    path('manager/search/category/<int:category>', mview.search_book_category),
    path('manager/orders', mview.book_orders)
>>>>>>> manager_ops
]
