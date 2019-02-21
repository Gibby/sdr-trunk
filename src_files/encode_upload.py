#!/usr/bin/env python3
import socket
import sys
import os
import shutil
from subprocess import call
from subprocess import PIPE, run

import logging

logger = logging.getLogger('streamthis:')
logger.setLevel(logging.os.environ['ENCODING_LOGGING_LEVEL'])
handler = logging.StreamHandler(sys.stdout)
formatter = logging.Formatter('streamthis: %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

CSV_FILE="/home/radio/trunk-player/config/talk_groups.csv"
FILE_TO_ENCODE=sys.argv[1]
logger.debug("file to encode: %s", FILE_TO_ENCODE)

WAV_FILE=os.path.basename(FILE_TO_ENCODE)
logger.debug("WAV_FILE: %s", WAV_FILE)

DIRECTORY=os.path.dirname(FILE_TO_ENCODE)
logger.debug("DIRECTORY: %s", DIRECTORY)

a = WAV_FILE.split('.wav')
FILENAME = a[0]
logger.debug("FILENAME: %s", FILENAME)

MP3_FILE="{0}/{1}.mp3".format(DIRECTORY, FILENAME).rstrip()
logger.debug("MP3_FILE: %s", MP3_FILE)

JSON_FILE="{0}/{1}.json".format(DIRECTORY, FILENAME).rstrip()
logger.debug("JSON_FILE: %s", JSON_FILE)

a = FILENAME.split('-')
TALKGROUP = a[0]
logger.debug("TALKGROUP: %s", TALKGROUP)

command = ['/bin/grep', TALKGROUP, CSV_FILE]
result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True)
#print(result.returncode, result.stdout, result.stderr)
csvline = result.stdout
logger.debug("csvline: %s", csvline)
a = csvline.split(',')
ALPHA, STREAM_LIST = a[2], a[8]

logger.debug("ALPHA: %s", ALPHA)
logger.debug("STREAM_LIST: %s", STREAM_LIST)

if (STREAM_LIST.strip() == ''):
    logger.info("No Stream for [%s] %s", TALKGROUP, ALPHA)
    quit(0)

call(["/usr/bin/lame", "--quiet", "-m", "m", "-b", "16", "--resample", "8", "--tt", "{0}".format(ALPHA), FILE_TO_ENCODE])

if os.path.exists(FILE_TO_ENCODE):
    os.remove(FILE_TO_ENCODE)

streams = STREAM_LIST.split('|')
servers = []

for stream in streams:
    logger.debug(">>>>> %s, %s is in the list", stream.rstrip(), TALKGROUP)
    if (stream.rstrip() == 'player'):
        if os.environ.get('START_TRUNK_PLAYER')=='true':
            if os.environ.get('LOCAL_AUDIO_FILES')=='true':
                shutil.copy2(MP3_FILE, '/home/radio/trunk-player/audio_files/')
                shutil.copy2(JSON_FILE, '/home/radio/trunk-player/audio_files/')
                os.chdir('/home/radio/trunk-player/')
                call(["/usr/bin/python3", "/home/radio/trunk-player/manage.py", "add_transmission", FILENAME])
    else:
        stream_address = "/var/run/liquidsoap/{0}".format(stream)
        logger.debug("[%s], matched for %s sending to: %s", TALKGROUP, stream.rstrip(), stream_address)
        servers.append(stream_address.rstrip())

if len(servers) < 1:
    logger.error("Talkgroup [%s] did not have any streams in the list: %s", TALKGROUP, STREAM_LIST)
    exit(1)

for server_address in servers:
    logger.debug("address: %s", server_address)
    # Create a UDS socket
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    try:
        logger.debug('Opening connection to: %s', server_address)
        sock.connect(server_address)
    except socket.error as msg:
        sys.exit(1)

    try:
        # Send data
        logger.info('%s %s %s', TALKGROUP, "sending to: ", server_address)
        logger.debug('queue.push {0}\n\r'.format(MP3_FILE))
        message = 'queue.push {0}\n\r'.format(MP3_FILE)
        sock.sendall(message.encode('utf-8'))

        amount_received = 0
        amount_expected = len(message)

        data = sock.recv(16)
        amount_received += len(data)

    finally:
        match = 0
        sock.close()
