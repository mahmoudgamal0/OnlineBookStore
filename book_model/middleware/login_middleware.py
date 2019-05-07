from django.shortcuts import redirect


class LoginMiddleware(object):
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.session['user_id']:
            return self.get_response(request)
        elif 'login' in request.path or 'signup' in request.path:
            return self.get_response(request)
        else:
            return redirect('/login/not logged in')
