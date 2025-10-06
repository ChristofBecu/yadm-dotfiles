#!/bin/bash

 while true; do
    clip=$(xclip -o -selection clipboard 2>/dev/null)

    maxlen=40
    if [[ -z "$clip" ]]; then
        echo "📋" > /tmp/clipboard_status
        
    else
        if (( ${#clip} > maxlen )); then
            clip="${clip:0:maxlen}..."
        fi

        clip="${clip//$'\n'/}"

        echo "📋 $clip" > "/tmp/clipboard_status"
    fi
    sleep 2
done


