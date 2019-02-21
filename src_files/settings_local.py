# Local devel Settings
import os
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOCAL_SETTINGS = True

TIME_ZONE = '${TZ}'

DEBUG = True

ALLOWED_HOSTS = []

BASE_DIR = '/opt/player'

# Make this unique, and don't share it with anybody.
# You can use http://www.miniwebtool.com/django-secret-key-generator/
# to create one.
SECRET_KEY = '${SECRET_KEY}'

# Added line to prevent CSRF verification errors with Django
SECURE_PROXY_SSL_HEADER = ()

# Name for site
SITE_TITLE = '${SITE_TITLE}'
SITE_EMAIL = '${SITE_EMAIL}'
DEFAULT_FROM_EMAIL = '${DEFAULT_FROM_EMAIL}'

# Set this to the location of your audio files
AUDIO_URL_BASE = '${AUDIO_URL_BASE}'

# Allow TalkGroup access restrictions
ACCESS_TG_RESTRICT = False

# Postgres database setup
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': '${DB_NAME}', # Database Name
        'USER': '${DB_USER}', # Database User Name
        'PASSWORD': '${DB_PASSWORD}', # Database User Password
        'HOST': '${DB_HOST}',
        'PORT': '',
    }
}
