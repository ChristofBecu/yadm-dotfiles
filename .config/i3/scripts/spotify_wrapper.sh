#!/usr/bin/env bash

/usr/bin/spotify "$@" &

# The notification of spotify to dunst is not longer reliable.
# Therefore, we use a loop to update the status of spotify every 2 seconds.

# SPOTIFY_PID=$!

# # Wait for Spotify to exit
# wait $SPOTIFY_PID

# # Update status after Spotify closes
# ~/.config/i3/scripts/spotify_log.sh

# Fork the process to run the logging script in the background
(
    # Initial run
    ~/.config/i3/scripts/spotify_log.sh

    # Then update every 2 seconds
    while true; do
        sleep 2
        ~/.config/i3/scripts/spotify_log.sh
    done
) &