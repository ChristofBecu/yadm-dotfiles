#!/bin/bash

MON=eDP
OTHER=HDMI-A-0

# Check if eDP is currently active
if xrandr --listactivemonitors | grep -q "$MON"; then
    # eDP is active → turn it off
    xrandr --output "$MON" --off
else
    # eDP is not active → turn it back on to the left of HDMI-A-0
    xrandr --output "$MON" --auto --left-of "$OTHER"
fi

