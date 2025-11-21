#!/usr/bin/env bash

logfile=~/logs/mocp.log
cached_artist=""
cached_song=""
cached_total=""
last_state=""

format_output() {
    echo "$1 - $2 [$3/-$4]$5"
}

while true; do
    if ! pgrep -x "mocp" > /dev/null; then
        echo " MOCP  ✖ " > "$logfile"
        sleep 2
        continue
    fi

    state=$(mocp -Q %state 2>/dev/null)
    current=$(mocp -Q %ct 2>/dev/null)
    
    # Only query song info when starting (00:00) or state changes
    if [ "$current" = "00:00" ] || [ "$state" != "$last_state" ]; then
        artist=$(mocp -Q %artist 2>/dev/null)
        song=$(mocp -Q %song 2>/dev/null)
        total=$(mocp -Q %tt 2>/dev/null)
        
        # Only update cache if we got valid data
        if [ -n "$artist" ] && [ -n "$song" ]; then
            cached_artist="$artist"
            cached_song="$song"
            cached_total="$total"
        fi
        last_state="$state"
    fi
    
    case "$state" in
        PLAY)  icon="   ▶ " ;;
        PAUSE) icon="  ▮▮ " ;;
        *)     echo " MOCP  ✖ " > "$logfile"; sleep 1; continue ;;
    esac
    
    left=$(mocp -Q %tl 2>/dev/null)
    
    # Only write if we have valid cached data and current time
    if [ -n "$cached_artist" ] && [ -n "$cached_song" ] && [ -n "$current" ] && [ -n "$left" ]; then
        format_output "$cached_artist" "$cached_song" "$current" "$left" "$icon" > "$logfile"
    fi
    
    sleep 0.5
done