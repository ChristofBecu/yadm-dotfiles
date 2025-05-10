#!/usr/bin/env bash

/usr/bin/spotify "$@" &
SPOTIFY_PID=$!

# Wait for Spotify to exit
wait $SPOTIFY_PID

# Update status after Spotify closes
~/.config/i3/scripts/spotify_log.sh