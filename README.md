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
    * Sending emails like at user signup
    * Auto importing talk groups from the same csv file as recorder.
  * Not working:
    * No Social Logins yet
    * Serving audio files with s3
      * Might be added

## Extra To-Do's:
* Might split out the sdr container to 2 containers, 1 for the recorder and 1 for the player.

## How-to use

* /app/config has example of config.json and talk_groups.csv for my system. the talk_groups.csv is just a copy paste from https://www.radioreference.com/apps/db/
  * the csv has 2 extra columns, Priority(0-100), Streams List(Pipe separated list of stream names)
    * Stream names that start with player will be sent to trunk-player. You also need to define the system_id in trunk-player. So a stream name of player0, goes to player and system_id 0.
    * All other stream names go to liquidsoap
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
    * ALLOW_GOOGLE_SIGNIN: - Should google signups/signins be allowed **NOTE:** Currently does not work
    * DEBUG: - Should Django be ran in debug mode, do **NOT** set to True in a public site.
    * EMAIL_HOST: - Email host to send email through
    * EMAIL_PORT: - Email host port
    * EMAIL_HOST_USER: - Email host user **NOTE:** Have not tested anonymous or no user/pass
    * EMAIL_HOST_PASSWORD: - Email host password
    * EMAIL_USE_TLS: - Should TLS or SSL be used when connecting to EMAIL_HOST


# Thanks to
* trunk-recorder from [https://github.com/robotastic/trunk-recorder](https://github.com/robotastic/trunk-recorder)
* trunk-player from [https://github.com/ScanOC/trunk-player](https://github.com/ScanOC/trunk-player)
