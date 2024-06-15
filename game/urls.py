from django.urls import path

from .views import *


app_name = 'game'


urlpatterns = [
    path('stories/', StoryListView.as_view(), name='story_list'),
    path('stories/<int:story_id>/', StoryDetailView.as_view(), name='story_detail'),
    path('stories/<int:story_id>/write/', ChapterWriteView.as_view(), name='story_write'),
    path('register/', HumanRegisterView.as_view(), name='register'),
    path('login/', HumanLoginView.as_view(), name='login'),
    path('login/success/', HumanLoginSuccessView.as_view(), name='login_success'),
    path('login/<str:access_token>/', HumanAuthenticateView.as_view(), name='authenticate'),
    path('logout/', HumanLogoutView.as_view(), name='logout'),
]
