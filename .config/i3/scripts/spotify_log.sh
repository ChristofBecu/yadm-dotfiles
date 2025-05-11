#!/usr/bin/env bash

# This script is triggered by dunst when a notification is received from Spotify.
# https://github.com/dunst-project/dunst
# In dunstrc, the following is added to the rules:
#   [spotify]
#   appname = Spotify
#   urgency = normal
#   script = ~/.config/i3/scripts/spotify_log.sh

# In order to retrieve the metadata, spotifycli has to be installed.
# https://github.com/pwittchen/spotify-cli-linux
# --status (artist - song) is saved in a log file.

# i3status is reading the log file to display the current status of Spotify in the i3status bar.

if ! pgrep -x "spotify" > /dev/null; then
    # Spotify is not running
    echo "   ✖ " > ~/logs/spotify.log
    exit 0
else
    PLAYBACK_STATUS=$(spotifycli --playbackstatus 2>/dev/null)
    TRACK_INFO="$(/usr/bin/spotifycli --status) ($(/usr/bin/spotifycli --album))"

    if [ "$PLAYBACK_STATUS" = "▶" ]; then
        PLAYBACK_STATUS="   ▶ "
    elif [ "$PLAYBACK_STATUS" = "▮▮" ]; then
        PLAYBACK_STATUS="  ▮▮ "
    fi

    echo "${TRACK_INFO} ${PLAYBACK_STATUS}" > ~/logs/spotify.log
fi
