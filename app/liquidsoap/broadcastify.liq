#!/usr/bin/liquidsoap
HOST="icecast"
MOUNT="/broadcastify"
PASSWORD="changeme"
NAME="broadcastify"
STREAMID="broadcastify"
DESCRIPTION=""
RECORDER_QUEUE=request.queue()
%include "/home/radio/trunk-player/src_files/stream.liq"
