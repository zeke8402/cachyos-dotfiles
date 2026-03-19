#!/usr/bin/env bash
# theme-apply.sh — applies a theme to all non-QML consumers
# Usage: theme-apply.sh <theme-id>
# Called by ThemeSwitcher.qml after the QML side has already updated live.

set -euo pipefail

THEME_ID="${1:-cogitator}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/../themes"
THEME_DIR="$THEMES_DIR/$THEME_ID"

if [[ ! -d "$THEME_DIR" ]]; then
    echo "theme-apply: unknown theme '$THEME_ID'" >&2
    exit 1
fi

THEME_JSON="$THEME_DIR/theme.json"

# ── 1. Persist active theme JSON ──────────────────────────────────────────
mkdir -p "$HOME/.config/theme"
cp "$THEME_JSON" "$HOME/.config/theme/active.json"

# ── 2. Kitty — live color reload across all running windows ───────────────
if [[ -f "$THEME_DIR/kitty.conf" ]]; then
    cp "$THEME_DIR/kitty.conf" "$HOME/.config/kitty/current-theme.conf"
    # Reload all running kitty instances
    if command -v kitty &>/dev/null; then
        kitty @ --to unix:/tmp/kitty set-colors --all "$HOME/.config/kitty/current-theme.conf" 2>/dev/null || true
    fi
fi

# ── 3. Hyprland — live border colors via IPC (no reload needed) ───────────
if command -v hyprctl &>/dev/null; then
    ACTIVE=$(jq -r '.hyprland.activeBorder // "rgba(cc4400ff)"'   "$THEME_JSON")
    INACTIVE=$(jq -r '.hyprland.inactiveBorder // "rgba(3a1000aa)"' "$THEME_JSON")
    SANCTIONED=$(jq -r '.hyprland.sanctionedBorder // "rgba(39ff14ff)"' "$THEME_JSON")

    hyprctl keyword general:col.active_border   "$ACTIVE"   2>/dev/null || true
    hyprctl keyword general:col.inactive_border "$INACTIVE" 2>/dev/null || true

    # Update sanctioned app window rules
    for app in kitty dolphin rofi; do
        hyprctl keyword "windowrule:border-$app:border_color" "$SANCTIONED" 2>/dev/null || true
    done
fi

# ── 4. Wallpaper ──────────────────────────────────────────────────────────
# Look for wallpaper in the theme dir (any common format)
WALLPAPER=""
for ext in jpg jpeg png webp; do
    if [[ -f "$THEME_DIR/wallpaper.$ext" ]]; then
        WALLPAPER="$THEME_DIR/wallpaper.$ext"
        break
    fi
done

if [[ -n "$WALLPAPER" ]]; then
    if command -v swww &>/dev/null; then
        swww img "$WALLPAPER" --transition-type fade --transition-duration 1 2>/dev/null || true
    elif command -v waypaper &>/dev/null; then
        ln -sf "$WALLPAPER" "$HOME/.config/theme/active-wallpaper"
        waypaper --restore 2>/dev/null || true
    fi
fi

echo "theme-apply: applied '$THEME_ID'"
