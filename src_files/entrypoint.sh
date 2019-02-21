#!/bin/bash

################
## LiquidSoap ##
################

# Create sym links for liquid soap streaming
for file in `ls /app/liquidsoap/`; do
  ln -sf /app/liquidsoap/${file} /etc/liquidsoap/${file}
done

# Start liquidsoap
/etc/init.d/liquidsoap start

####################
## Trunk Recorder ##
####################

# Start trunk recorder
/opt/recorder/recorder --config=/app/config/config.json >> /logs/recorder 2>&1 &


##################
## Trunk Player ##
##################

if [ "$START_TRUNK_PLAYER" = true ]; then

# Local settings setup
  envsubst < /settings_local.py > /opt/player/trunk_player/settings_local.py##
# Custom createsuperuser command for auto create superuser
  cp /create_superuser_with_password.py /opt/player/radio/management/commands/createsuperuser2.py##
# psql setup
  echo "${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASSWORD}" > ~/.pgpass
  chmod 0600 ~/.pgpass
  psql -h postgres -U trunk_player_user -d trunk_player -f /setup_postgres.sql##
# Change to virtualenv
  cd /opt/player || return##
# Make sure migrate has been ran
  python3 ./manage.py migrate

# Create initial django superuser, this will run everytime, however it only creates the user, if it already exists it just errors and continues on...
  python3 ./manage.py createsuperuser2 --username ${DJANGO_ADMIN} --password ${DJANGO_PASS} --noinput --email ${DJANGO_EMAIL} >> /dev/null 2>&1

# Start trunk player and requirements
  redis-server >> /logs/player 2>&1 &
  daphne trunk_player.asgi:channel_layer --port 7055 --bind 127.0.0.1 >> /logs/player 2>&1 &
  python3 ./manage.py runworker >> /logs/player 2>&1 &
  python3 ./manage.py runworker >> /logs/player 2>&1 &
  python3 ./manage.py add_transmission_worker >> /logs/player 2>&1 &
  python3 ./manage.py add_transmission_worker >> /logs/player 2>&1 &
  python3 ./manage.py runserver 0.0.0.0:8000 >> /logs/player 2>&1 &
fi

#####################
## docker logs out ##
#####################

# Wait a couple seconds for all logs to start
sleep 2

# Tail logs that go to stdout(docker logs -f container)
if [ "$1" = "test" ]; then
  # If no command was passed(docker run container), just tail the logs...
  tail -f -n +1 /logs/*
else
  # If a command was passed(docker run -it container /bin/bash), start tailing the logs in the background and then run command
  tail -f -n +1 /logs/* &
  exec "$@"
fi
