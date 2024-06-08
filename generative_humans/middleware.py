from django.http import HttpResponse


def health_check(get_response):
    def middleware(request):
        if request.META['PATH_INFO'] == '/ping/':
            return HttpResponse('pong!')

        response = get_response(request)
        return response

    return middleware
