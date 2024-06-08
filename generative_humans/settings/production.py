import os

from generative_humans.settings.base import *

DEBUG = False

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DATABASE_DB_NAME', ''),
        'USER': os.environ.get('DATABASE_USERNAME', ''),
        'PASSWORD': os.environ.get('DATABASE_PASSWORD', ''),
        'HOST': os.environ.get('DATABASE_HOSTNAME', ''),
        'PORT': '5432',
    }
}
