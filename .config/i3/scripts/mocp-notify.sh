#!/usr/bin/env bash

# Get current MOC info
STATE=$(mocp -Q %state 2>/dev/null)

if [ "$STATE" = "PLAY" ] || [ "$STATE" = "PAUSE" ]; then
    ARTIST=$(mocp -Q %artist 2>/dev/null)
    TITLE=$(mocp -Q %song 2>/dev/null)
    
    # Send notification
    notify-send -u low -t 3000 "🎵 MOC" "$ARTIST - $TITLE"
fi