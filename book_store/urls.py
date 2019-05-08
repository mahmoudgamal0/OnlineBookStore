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
from book_model import views as uview

from manager import views as mview
from search import views as sview
from carts import views as cview
from checkout import views as checkview


urlpatterns = [
    # path('admin/', admin.site.urls),
    # re_path(r'home/(?P<msg_err>[A-Za-z\s]+)?', uview.home_get),
    # path('next/', uview.next),

    # User Operations
    path('', uview.home),
    path('signup', uview.signup),
    re_path(r'login/(?P<msg_err>[A-Za-z\s]+)?', uview.login),
    path('logout/', uview.logout),
    path('update_user', uview.update_user),


    # Manager Operations
    path('manager/insert', mview.insert_book),
    path('manager/modify/<slug:ISBN>', mview.modify_book),
    path('manager/orders', mview.book_orders),
    path('manager/users', mview.promote_user),
    path('manager/sales', mview.sales),

    # Search Operations
    path('search', sview.search_base),
    path('search/ISBN/<slug:ISBN>', sview.search_book_ISBN),
    path('search/title/<slug:title>', sview.search_book_title),
    path('search/author/<slug:author>', sview.search_book_author),
    path('search/publisher/<slug:publisher>', sview.search_book_publisher),
    path('search/category/<int:category>', sview.search_book_category),

    # cart operation
    path('cart/add_book', cview.add_book),
    path('cart/remove_book', cview.remove_book),
    path('cart/cart', cview.get_cart),
    path('cart/update', cview.update),

    # Checkout Operations
    path('checkout', checkview.checkout),

]
