#!/bin/bash

get_spotify_metadata() {
    gdbus call --session \
        --dest org.mpris.MediaPlayer2.spotify \
        --object-path /org/mpris/MediaPlayer2 \
        --method org.freedesktop.DBus.Properties.Get \
        org.mpris.MediaPlayer2.Player Metadata
        
}

get_spotify_title() {
    get_spotify_metadata | jq -r '.[1]["xesam:title"]'
}

get_spotify_artist() {
    get_spotify_metadata | jq -r '.[1]["xesam:artist"][0]'
}

# Example usage:
title=$(get_spotify_title)
artist=$(get_spotify_artist)
echo "Now playing: $title by $artist"
