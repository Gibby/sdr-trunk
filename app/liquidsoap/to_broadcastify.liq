#!/usr/bin/liquidsoap
HOST="audio#.broadcastify.com"
MOUNT="changeme"
PASSWORD="changeme"
NAME="to_broadcastify"
STREAMID="to_broadcastify"
DESCRIPTION=""
RECORDER_QUEUE=input.http("http://icecast/broadcastify")
%include "/home/radio/trunk-player/src_files/stream.liq"
