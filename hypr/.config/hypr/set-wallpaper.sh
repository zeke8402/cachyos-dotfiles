#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "usage: $0 /path/to/wallpaper" >&2
    exit 1
fi

wallpaper="$(realpath "$1")"

if [ ! -f "$wallpaper" ]; then
    echo "wallpaper not found: $wallpaper" >&2
    exit 1
fi

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
current_link="$config_dir/current-wallpaper"

mkdir -p "$config_dir"
ln -sfn "$wallpaper" "$current_link"

if pgrep -x hyprpaper >/dev/null 2>&1; then
    hyprctl hyprpaper unload all || true
    hyprctl hyprpaper preload "$wallpaper"
    hyprctl hyprpaper wallpaper ",$wallpaper"
else
    hyprpaper >/dev/null 2>&1 &
    sleep 0.5
    hyprctl hyprpaper unload all || true
    hyprctl hyprpaper preload "$wallpaper"
    hyprctl hyprpaper wallpaper ",$wallpaper"
fi

wallust run "$wallpaper"
