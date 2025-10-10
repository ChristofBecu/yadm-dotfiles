#!/bin/sh

# Get the file URI from clipboard
file_uri=$(xclip -selection clipboard -o -target text/uri-list 2>/dev/null)

if [ -z "$file_uri" ]; then
    notify-send "Paste Error" "No file in clipboard"
    exit 1
fi

# Remove file:// prefix
source_file=$(echo "$file_uri" | sed 's|^file://||')

# Check if file exists
if [ ! -e "$source_file" ]; then
    notify-send "Paste Error" "File does not exist: $source_file"
    exit 1
fi

# Wait a moment and get the focused window
# This allows you to switch to the target terminal after pressing the keybinding
sleep 0.3
window_id=$(xdotool getactivewindow)

# Type the cp command into the terminal and press Enter
xdotool type --window "$window_id" --clearmodifiers "cp \"$source_file\" ./"
xdotool key --window "$window_id" Return