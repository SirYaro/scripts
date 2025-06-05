#!/bin/bash

#set -x

PLAYER='/usr/bin/strawberry'
PLAYER_CMD='--load'
PLAYER_PLAY_CMD='--play'
MUSIC_HOME='/home/${USER}/Muzyka'
MUSIC_SUBDIRS="$(echo ./{{A..L},Ł,{M..Z}}/)"    # DIRS TO SCAN LOCATED UNDER THE $MUSIC_HOME, EX: MUSIC_SUBDIRS="./DIR1 ./DIR2 ./DIR3"

function f_add_album()
{
    f_getStatus
    cd "$MUSIC_HOME"
    ALBUM_PATH=`find ${MUSIC_SUBDIR} -name "*.flac" -o -name "*.mp3" | sed 's/[^/]*$//' | sort | uniq | shuf | head -1`

    echo -ne "\n${MUSIC_HOME}/${ALBUM_PATH}\n"
    ${PLAYER} ${PLAYER_CMD} "${MUSIC_HOME}/${ALBUM_PATH}"
    sleep 1
    ${PLAYER} ${PLAYER_PLAY_CMD}
    sleep 1
    f_getStatus
}

function f_getStatus()
{
    echo -ne $(qdbus org.mpris.MediaPlayer2.strawberry /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlaybackStatus)
    f_getTitle
}

function f_getTitle()
{
    qdbus org.mpris.MediaPlayer2.strawberry /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Metadata | grep -e 'artist' -e 'title'|awk '{$1=""; print $0}'|sed -e 'N;s/\n/ -/'
}

f_getStatus
x=always; while x=always;
do
    if [ "$(f_getStatus)" = "Stopped" ]; then
        echo ""
        f_add_album
    else
        echo -ne "."
    fi
    
    sleep 15
done
