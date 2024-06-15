from django.middleware.csrf import rotate_token
from django.utils.deprecation import MiddlewareMixin
from django.shortcuts import redirect

from .models import Human
from django.views import View


ACCESS_TOKEN_KEY = '_auth_human_access_token'


def login_human(request, human):
    if human is None:
        human = request.human

    if ACCESS_TOKEN_KEY in request.session:
        if request.session[ACCESS_TOKEN_KEY] != human.access_token:
            # To avoid reusing another recipient's session, create a new, empty
            # session if the existing session corresponds to a different
            # authenticated recipient.
            request.session.flush()
    else:
        request.session.cycle_key()

    request.session[ACCESS_TOKEN_KEY] = human.access_token

    if hasattr(request, 'human'):
        request.human = human

    rotate_token(request)


def logout_human(request):
    """
    Remove the authenticated human's access_token from the request and flush their session data.
    """
    request.session.flush()
    if hasattr(request, 'human_access_token'):
        request.human_access_token = None
    if hasattr(request, 'human'):
        request.human = None


def get_human_session(request):
    return request.session[ACCESS_TOKEN_KEY]


def get_human_info(request):
    try:
        human_access_token = get_human_session(request)
    except KeyError:
        return None

    try:
        human = Human.objects.get(access_token=human_access_token)
    except Human.DoesNotExist:
        logout_human(request)
        return None

    return human


class HumanAuthenticationMiddleware(MiddlewareMixin):
    def process_request(self, request):
        assert hasattr(request, 'session'), (
            "The Django authentication middleware requires session middleware "
            "to be installed. Edit your MIDDLEWARE setting to insert "
            "'django.contrib.sessions.middleware.SessionMiddleware' before "
            "'unwrapit.recipients.auth.middleware.RecipientAuthenticationMiddleware'."
        )
        request.human = get_human_info(request)


class HumanRequiredMixin(View):
    def dispatch(self, request, *args, **kwargs):
        if hasattr(request, 'human') and request.human is not None:
            return super().dispatch(request, *args, **kwargs)
        return redirect('game:login')


class HumanAuthenticatedCheckMixin(View):
    def dispatch(self, request, *args, **kwargs):
        if not hasattr(request, 'human') or request.human is None:
            return super().dispatch(request, *args, **kwargs)
        return redirect('game:story_list')
