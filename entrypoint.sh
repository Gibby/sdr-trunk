#!/bin/bash

#####################
## create logs dir ##
#####################
mkdir -p logs
chmod 0777 logs

################
## LiquidSoap ##
################

# Create sym links for liquid soap streaming
find "$(pwd)/liquidsoap/" -type f -name "*.liq" -exec ln -sf {} /etc/liquidsoap/ \;

# Start liquidsoap
/etc/init.d/liquidsoap start

####################
## Trunk Recorder ##
####################

# Start trunk recorder
cp src_files/encode_upload.py ./
./recorder --config=config/config.json >> logs/recorder 2>&1 &


##################
## Trunk Player ##
##################

if [ "$START_TRUNK_PLAYER" = true ]; then

# Local settings setup
  envsubst < src_files/settings_local.py > trunk_player/settings_local.py

# Check if doing local audio files
  if [ "$LOCAL_AUDIO_FILES" = true ]; then
    cp audio_files.orig/* audio_files/
    echo "Staring up NGINX..."
    ln -sf "$(pwd)/trunk_player/trunk_player.nginx.sample" /etc/nginx/sites-enabled/trunk_player.nginx
    rm /etc/nginx/sites-enabled/default
    /etc/init.d/nginx restart
    python3 ./manage.py collectstatic --noinput
  fi

# Copy over some of out custom commands
  cp src_files/create_superuser_with_password.py radio/management/commands/createsuperuser2.py >> logs/player_setup 2>&1
  cp src_files/import_talkgroups2.py radio/management/commands/import_talkgroups2.py >> logs/player_setup 2>&1

# psql setup
  echo "${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASSWORD}" > ~/.pgpass
  chmod 0600 ~/.pgpass
  psql -h postgres -U trunk_player_user -d trunk_player -f /setup_postgres.sql >> logs/player_setup 2>&1

# Make sure migrate has been ran
  python3 ./manage.py migrate >> logs/player_setup 2>&1

# Create initial django superuser, this will run everytime, however it only creates the user, if it already exists it just errors and continues on...
  python3 ./manage.py createsuperuser2 --username ${DJANGO_ADMIN} --password ${DJANGO_PASS} --noinput --email ${DJANGO_EMAIL} >> logs/player_admin_setup 2>&1

# Import talk groups from the csv file that the recorder uses
  python3 ./manage.py import_talkgroups2 --truncate config/talk_groups.csv >> logs/player_setup 2>&1

# Start trunk player and requirements
  redis-server >> logs/player_redis 2>&1 &
  daphne trunk_player.asgi:channel_layer --port 7055 --bind 127.0.0.1 >> logs/player_daphne 2>&1 &
  python3 ./manage.py runworker >> logs/player_runworker 2>&1 &
  python3 ./manage.py runworker >> logs/player_runworker 2>&1 &
  python3 ./manage.py add_transmission_worker >> logs/player_trans_worker 2>&1 &
  python3 ./manage.py add_transmission_worker >> logs/player_trans_worker 2>&1 &
  python3 ./manage.py runserver --nothreading 0.0.0.0:8000 >> logs/player 2>&1 &
fi



#####################
## docker logs out ##
#####################

# Wait a couple seconds for all logs to start
sleep 2

# Tail logs that go to stdout(docker logs -f container)
if [ "$1" = "test" ]; then
  # If no command was passed(docker run container), just tail the logs...
  tail -f -n +1 logs/*
else
  # If a command was passed(docker run -it container /bin/bash), start tailing the logs in the background and then run command
  tail -f -n +1 logs/* &
  exec "$@"
fi
