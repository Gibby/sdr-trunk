set("tag.encodings",["UTF-8","ISO-8859-1"])

# Configure Logging
set("log.file",true)
set("log.level",4)
set("log.stdout",false)
set("log.syslog",false)
set("log.syslog.program","liquidsoap-#{STREAMID}")
set("log.file.path","/home/radio/trunk-player/logs/liquidsoap")

# Streaming clock setting. https://www.liquidsoap.info/doc-1.3.6/settings.html
# Trying to fix broadcastify resetting every 60 seconds... this should make it reset once a day instead
set("root.max_latency",1440.)

# create a socket to send commands to this instance of liquidsoap
set("server.socket",true)
set("server.socket.path","<sysrundir>/#{STREAMID}")
set("server.socket.permissions",511)
# This creates a 1 second silence period generated programmatically (no disk reads)
silence = blank(duration=1.)

# This pulls the alpha tag out of the wav file
def append_title(m) =
	[("title","Scanning...")]
end

silence = map_metadata(append_title, silence)

recorder_queue = RECORDER_QUEUE
recorder_queue = server.insert_metadata(id="S4",recorder_queue)

# If there is anything in the queue, play it.  If not, play the silence defined above repeatedly:
stream = fallback(track_sensitive=false, [recorder_queue, silence])

title = '$(if $(title),"$(title)","Scanning...")'
stream = rewrite_metadata([("title", title)], stream)

output.icecast(%mp3(stereo=false, bitrate=16, samplerate=22050),
  host=HOST, port=80, password=PASSWORD, genre="Scanner",
  description=DESCRIPTION, mount=MOUNT,  name=NAME, user="source", stream)
