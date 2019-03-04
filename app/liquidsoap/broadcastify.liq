#!/usr/bin/liquidsoap
HOST="changeme"
MOUNT="/changme"
PASSWORD="changeme"
NAME="broadcastify"
STREAMID="broadcastify"
DESCRIPTION=""
RECORDER_QUEUE=input.http("http://my.icecast.server/broadcastify")
%include "/home/radio/trunk-player/src_files/stream.liq"
