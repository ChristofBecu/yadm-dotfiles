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

/usr/bin/spotifycli --status > ~/logs/spotify.log
