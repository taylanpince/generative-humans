from django.urls import path

from .views import HumanRegisterView, HumanLoginView, HumanLogoutView, StoryListView


app_name = 'game'


urlpatterns = [
    path('', StoryListView.as_view(), name='story_list'),
    path('register/', HumanRegisterView.as_view(), name='register'),
    path('login/', HumanLoginView.as_view(), name='login'),
    path('logout/', HumanLogoutView.as_view(), name='logout'),
]
