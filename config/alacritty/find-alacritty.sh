#!/bin/bash

# Check if Alacritty is already running
if pgrep -x "Alacritty" > /dev/null; then
    # Alacritty is running, let's focus on it
    osascript -e 'tell application "Alacritty" to activate'
else
    # Alacritty is not running, let's open a new instance
    open -a Alacritty
fi

