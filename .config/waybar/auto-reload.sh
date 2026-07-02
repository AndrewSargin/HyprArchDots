while inotifywait -r -e close_write ~/.config/waybar; do killall -SIGUSR2 waybar; done
