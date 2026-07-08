#!/bin/bash

SELECTED=$(wpctl status | awk '/Sinks:/ {flag=1; next} /Sources:/ {flag=0} flag' | grep -E '[0-9]+\.' | sed -E 's/^[ │*]*[0-9]+\.\s*//' | rofi -dmenu -p "   Output:" -theme-str 'window {width: 30%; font: "Sans 11"; border-radius: 8px;}')

if [ -z "$SELECTED" ]; then
    exit 0
fi

REAL_ID=$(wpctl status | awk -v name="$SELECTED" '/Sinks:/ {flag=1; next} /Sources:/ {flag=0} flag { if (index($0, name) > 0) { print $0 } }' | grep -oE '[0-9]+\.' | head -n1 | tr -d '.')

if [ ! -z "$REAL_ID" ]; then
    wpctl set-default "$REAL_ID"
fi
