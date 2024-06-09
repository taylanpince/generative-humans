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

STATIC_URL = '/staticfiles/'
STATIC_ROOT = '/efs/staticfiles/'

DEFAULT_FILE_STORAGE = "storages.backends.s3boto3.S3Boto3Storage"

AWS_ACCESS_KEY_ID = os.environ.get("AWS_ACCESS_KEY_ID", default="")
AWS_SECRET_ACCESS_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY", default="")
AWS_STORAGE_BUCKET_NAME = os.environ.get("AWS_STORAGE_BUCKET_NAME", default="")
AWS_S3_REGION_NAME = os.environ.get("AWS_S3_REGION_NAME", default="")
AWS_S3_ENDPOINT_URL = os.environ.get("AWS_S3_ENDPOINT_URL", default="")
AWS_S3_FILE_OVERWRITE = False
