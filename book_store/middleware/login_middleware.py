from django.shortcuts import redirect


class LoginMiddleware(object):
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            if request.session['user_id'] is not None:
                return self.get_response(request)
        except Exception:
            pass
        if 'login' in request.path or 'signup' in request.path:
            return self.get_response(request)
        return redirect('/login/not logged in')
