#!/usr/bin/env bash

logfile=~/logs/mocp.log

format_output() {
    local artist="$1"
    local song="$2"
    local current="$3"
    local left="$4"
    local icon="$5"
    echo "${artist} - ${song} [${current}/-${left}]${icon}"
}

while true; do
    if ! pgrep -x "mocp" > /dev/null; then
        echo " MOCP  ✖ " > "$logfile"
    else
        state=$(mocp -Q %state 2>/dev/null)
        case "$state" in
            PLAY)
                icon="   ▶ "
                ;;
            PAUSE)
                icon="  ▮▮ "
                ;;
            *)
                echo " MOCP  ✖ " > "$logfile"
                sleep 1
                continue
                ;;
        esac
        artist=$(mocp -Q %artist 2>/dev/null)
        song=$(mocp -Q %song 2>/dev/null)
        current=$(mocp -Q %ct 2>/dev/null)
        left=$(mocp -Q %tl 2>/dev/null)
        format_output "$artist" "$song" "$current" "$left" "$icon" > "$logfile"
    fi
    sleep 1
done