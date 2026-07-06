#!/bin/bash

current_im=$(fcitx5-remote -n 2>/dev/null)

case "$current_im" in
"keyboard-us")
    echo '{"text": "EN", "tooltip": "English (US)", "class": "keyboard-us"}'
    ;;
"keyboard-ru")
    echo '{"text": "RU", "tooltip": "Russian (RU)", "class": "keyboard-ru"}'
    ;;
"mozc")
    echo '{"text": "JP", "tooltip": "Mozc", "class": "mozc"}'
    ;;
*)
    echo "{\"text\": \"?\", \"tooltip\": \"$current_im\", \"class\": \"unknown\"}"
    ;;
esac
