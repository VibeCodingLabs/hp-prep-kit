#!/usr/bin/env bash
# rotate_wallpapers_xfce.sh
# Deploy via autostart .desktop so it runs INSIDE the XFCE user session.
# xfconf-query only works with a live xfce4-desktop process — never run from cron or systemd directly.
set -euo pipefail

WALL_DIR="$HOME/.local/share/backgrounds/wallpapers"
mkdir -p "$WALL_DIR"

# 10 direct Unsplash 4K B-roll images (stable photo IDs, not /featured/ which redirects unreliably)
URLS=(
  "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1464207687429-7505649dae38?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1495567720989-cebfcc6b1e9b?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1417863050-5ca2e4d4390b?w=2560&h=1440&fit=crop"
  "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=2560&h=1440&fit=crop"
)

# Download images that are missing
i=1
for url in "${URLS[@]}"; do
  out="$WALL_DIR/wallpaper_${i}.jpg"
  if [[ ! -f "$out" ]]; then
    echo "[wallpaper-rotate] Downloading $i/10..."
    curl -sSL --max-time 30 -o "$out" "$url" || echo "[wallpaper-rotate] Warning: failed to download wallpaper $i"
  fi
  ((i++))
done

INTERVAL=180  # 3 minutes

# Rotation loop — runs inside a live XFCE session via autostart, so xfconf-query works
while true; do
  for img in "$WALL_DIR"/wallpaper_*.jpg; do
    [[ -f "$img" ]] || continue

    # Get all workspace last-image properties dynamically (handles any number of monitors/workspaces)
    mapfile -t props < <(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep '/last-image' || true)

    if [[ ${#props[@]} -gt 0 ]]; then
      for prop in "${props[@]}"; do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$img" 2>/dev/null || true
      done
    else
      # Fallback for standard single-monitor Xubuntu
      xfconf-query -c xfce4-desktop \
        -p /backdrop/screen0/monitor0/workspace0/last-image \
        -s "$img" 2>/dev/null || true
    fi

    sleep "$INTERVAL"
  done
done
