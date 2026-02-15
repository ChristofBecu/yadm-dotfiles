#!/bin/bash

# File to store the current state
STATE_FILE="/tmp/screen_power_state"

# Check if dpms is currently enabled
if [ ! -f "$STATE_FILE" ]; then
    # Initialize state file based on current dpms status
    if xset q | grep -q "DPMS is Enabled"; then
        echo "enabled" > "$STATE_FILE"
    else
        echo "disabled" > "$STATE_FILE"
    fi
fi

CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" = "enabled" ]; then
    # Disable screen power management
    xset s off
    xset -dpms
    xset s noblank
    echo "disabled" > "$STATE_FILE"
    notify-send "Screen Power Management" "Disabled - Screen will not turn off" -t 2000
else
    # Enable screen power management
    xset s on
    xset +dpms
    xset s blank
    echo "enabled" > "$STATE_FILE"
    notify-send "Screen Power Management" "Enabled - Screen will turn off when idle" -t 2000
fi