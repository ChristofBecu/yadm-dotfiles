#!/bin/bash
# filepath: ~/.config/i3/scripts/i3status-clipboard.sh

readonly STATUS_FILE="/tmp/clipboard_status"
readonly MAX_LENGTH=40
readonly SLEEP_INTERVAL=2

previous_hash=""

clipboard_changed() {
    local current_hash=$(xclip -o -selection clipboard 2>/dev/null | md5sum)
    [[ "$current_hash" != "$previous_hash" ]] && previous_hash="$current_hash" && return 0
    return 1
}

get_clipboard_status() {
    local targets=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null)
    
    case "$targets" in
        *image*) echo "📋 🖼️" ;;
        *application*) echo "📋 📎" ;;
        *)
            local clip=$(xclip -o -selection clipboard 2>/dev/null)
            [[ -z "$clip" ]] && echo "📋" && return
            
            clip="${clip//$'\n'/ }"
            echo "📋 ${clip:0:$MAX_LENGTH}$([[ ${#clip} -gt $MAX_LENGTH ]] && echo "...")"
            ;;
    esac
}

while true; do
    clipboard_changed && get_clipboard_status > "$STATUS_FILE"
    sleep "$SLEEP_INTERVAL"
done