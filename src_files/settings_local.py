# Local devel Settings
import os
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOCAL_SETTINGS = True

TIME_ZONE = '${TZ}'

DATA_UPLOAD_MAX_NUMBER_FIELDS = 10240

DEBUG = ${DEBUG}

ALLOWED_HOSTS = ${ALLOWED_HOSTS}

BASE_DIR = '/home/radio/trunk-player'

ALLOW_GOOGLE_SIGNIN = ${ALLOW_GOOGLE_SIGNIN}

# Disable this check
DATA_UPLOAD_MAX_NUMBER_FIELDS = None

# Email Settings
EMAIL_HOST = '${EMAIL_HOST}'
EMAIL_PORT = '${EMAIL_PORT}'
EMAIL_HOST_USER = '${EMAIL_HOST_USER}'
EMAIL_HOST_PASSWORD = '${EMAIL_HOST_PASSWORD}'
EMAIL_USE_TLS = '${EMAIL_USE_TLS}'

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
        'NAME': '${POSTGRES_DB}', # Database Name
        'USER': '${POSTGRES_USER}', # Database User Name
        'PASSWORD': '${POSTGRES_PASSWORD}', # Database User Password
        'HOST': '${POSTGRES_HOST}',
        'PORT': '${POSTGRES_PORT}',
    }
}
