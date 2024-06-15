import os

from generative_humans.settings.base import *

DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'gh_db',
        'USER': 'gh_dbu',
        'PASSWORD': os.environ.get('DATABASE_PASSWORD', ''),
        'HOST': 'db',
        'PORT': '5432',
    }
}

DEFAULT_FILE_STORAGE = "django.core.files.storage.FileSystemStorage"

ALLOWED_HOSTS += ['localhost', 'd17e-37-222-98-84.ngrok-free.app']