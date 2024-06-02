import os

from generative_humans.settings.base import *

DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'gh_db',
        'USER': 'gh_dbu',
        'PASSWORD': 'gt3M0o7!RdrmCehi6*skY',
        'HOST': 'db',
        'PORT': '5432',
    }
}
