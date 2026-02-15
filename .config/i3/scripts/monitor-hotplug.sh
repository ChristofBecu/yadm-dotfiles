#!/bin/bash
# Reload i3 and move workspaces when monitor state changes

LOGFILE="/tmp/monitor-hotplug.log"
echo "$(date): Monitor hotplug detected" >> "$LOGFILE"

sleep 1  # Wait for xrandr to stabilize

# Check if external monitor is connected
if xrandr | grep "^HDMI-A-0 connected" > /dev/null; then
    echo "$(date): HDMI-A-0 connected, moving workspaces to external" >> "$LOGFILE"
    # External monitor connected - move workspaces 1-7 to HDMI
    for ws in "1:Term" "2:Code" 3 4 5 6 "7:PDF"; do
        i3-msg "workspace $ws, move workspace to output HDMI-A-0" 2>/dev/null
    done
else
    echo "$(date): HDMI-A-0 disconnected, moving workspaces to laptop" >> "$LOGFILE"
    # External monitor disconnected - move all workspaces to laptop
    for ws in "1:Term" "2:Code" 3 4 5 6 "7:PDF"; do
        i3-msg "workspace $ws, move workspace to output eDP" 2>/dev/null
    done
fi

i3-msg reload
echo "$(date): i3 reloaded" >> "$LOGFILE"