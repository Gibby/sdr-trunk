gibby/sdr-trunk
===================
[![](https://images.microbadger.com/badges/image/gibby/sdr-trunk.svg)](https://microbadger.com/images/gibby/sdr-trunk "Get your own image badge on microbadger.com")

# Description

This project runs trunk-recorder and trunk-player in a container with a link to a postgres container.

I have attempted to keep the image size down by:
* Building trunk-recorder in a different container. [https://hub.docker.com/r/gibby/trunk-recorder](https://hub.docker.com/r/gibby/trunk-recorder)
* Copying over only the build artifacts
* Installing only the extra libraries that are dynamically linked
  * Hopefully I can get static linking to work and it will further cut down the image size.

## Status
* trunk-recorder
  * Should be 100%
  * Encoding and uploading to:
    * broadcastify
    * icecast
  * .wav files are deleted after being converted to .mp3
  * .mp3 and .json files are not kept on container restart
* trunk-player
  * Working:
    * Initializes the postgres database
    * Sets up the django superuser
    * Exposes website on port 8000
    * Starts redis-server
    * Starts daphne
    * Starts add_transmission_worker x2
    * Starts runworker x2
    * Serving local audio files
  * Not working:
    * No Social Logins yet
    * Email doesn't work yet, so when a user signs up they get an error but if they go back to login they can login.
    * Serving audio files with s3
      * Might be added
    * Auto importing talk groups from the csv file that is used with trunk-recorder
      * Will hopefully be added
      * trunk-player and trunk-recorder don't use the same columns..... :(
      * Seems to be a length limit on the csv also

## How-to use

* /app/config has example of config.json and talk_groups.csv for my system. the talk_groups.csv is just a copy paste from https://www.radioreference.com/apps/db/
  * the csv has 2 extra columns, Priority and Streams List
  * If you add layer as a location for stream list, it will send it to trunk-player
  * All other names go to a liquidsoap stream

* The docker-compose.yml includes a postgres database that can be used, or comment out and use your own.

* Copy docker-compose.template.yml to docker-compose.yml

* Global variables:
  * POSTGRES_USER: - Username for postgres database
  * POSTGRES_PASSWORD: - Password for postgres database
  * POSTGRES_DB: - DB name for postgres database
  * POSTGRES_HOST: - Hostname for the db (Use postgres if using the link from the db service in docker-compose)
  * POSTGRES_PORT: - Port number to use to connect to the postgres host.

* postgres:
  * volumes:
    * postgres_data - where the database files are saved

* trunk-recorder:
  * volumes:
    * config - should have config.json and talk_groups.csv in it
    * liquidsoap - should have your stream names in it
    * /dev/bus/usb:/dev/bus/usb - **leave as is**
  * environment variables:
    * ENCODING_LOGGING_LEVEL: Log level of encode_upload.py, either INFO or DEBUG


* trunk-player options:
  * volumes
    * audio_files - Location of local audio files if being used
  * environment variables:
    * START_TRUNK_PLAYER - Should trunk_player be used, must be double quoted
    * LOCAL_AUDIO_FILES: - Should trunk_player use local audio files, must be double quoted
    * AUDIO_URL_BASE: - Location of audio files
    * ALLOWED_HOSTS: - Django allowed hosts
    * DJANGO_ADMIN: - Initial admin account
    * DJANGO_PASS: - Initial admin account password
    * DJANGO_EMAIL: - Initial admin account email
    * SECRET_KEY: - Get key from https://www.miniwebtool.com/django-secret-key-generator/ must be double quoted
    * SITE_TITLE: - Title of your side
    * SITE_EMAIL: - Site email address
    * DEFAULT_FROM_EMAIL: - Default from address
    * TZ: - Timezone


# Thanks to
* trunk-recorder from [https://github.com/robotastic/trunk-recorder](https://github.com/robotastic/trunk-recorder)
* trunk-player from [https://github.com/ScanOC/trunk-player](https://github.com/ScanOC/trunk-player)
