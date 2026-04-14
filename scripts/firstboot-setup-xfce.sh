#!/usr/bin/env bash
# firstboot-setup-xfce.sh
# One-time first-boot account wizard for Xubuntu / Ubuntu 20.04 + LightDM.
# Install to /usr/local/sbin/firstboot-setup-xfce.sh and enable via systemd (see systemd/firstboot-setup.service).
set -euo pipefail

MARK_FILE="/etc/hp-prep/firstboot-done"
REMOVE_PREP_FLAG="/etc/hp-prep/remove-prep-user"
PREP_USER="prep"  # change to your seller account name if different
ROTATE_SRC="/usr/local/share/hp-prep/rotate_wallpapers_xfce.sh"
AUTOSTART_TEMPLATE="/usr/local/share/hp-prep/wallpaper-rotate.desktop"

# Exit if already ran
[[ -f "$MARK_FILE" ]] && exit 0
mkdir -p /etc/hp-prep

# ── Graphical prompt (zenity) ──────────────────────────────────────
prompt_graphical() {
  command -v zenity >/dev/null 2>&1 || return 1
  # Try each DISPLAY until we find an active X session
  for d in :0 :1 :2; do
    export DISPLAY="$d"
    if zenity --entry --title="Test" --text="" --timeout=2 >/dev/null 2>&1; then
      FULLNAME=$(zenity --entry \
        --title="Welcome to your new laptop" \
        --text="Enter your full name:" \
        --width=400) || return 1
      USERNAME=$(zenity --entry \
        --title="Choose a username" \
        --text="Username (lowercase letters and numbers only):" \
        --width=400) || return 1
      PASSWORD=$(zenity --password \
        --title="Choose a password" \
        --text="Choose a password for your account:" \
        --width=400) || return 1
      PASSWORD2=$(zenity --password \
        --title="Confirm password" \
        --text="Confirm your password:" \
        --width=400) || return 1
      if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
        zenity --error \
          --title="Password mismatch" \
          --text="Passwords did not match. Please reboot and try again." || true
        return 1
      fi
      printf '%s::%s::%s' "$FULLNAME" "$USERNAME" "$PASSWORD"
      return 0
    fi
  done
  return 1
}

# ── Console fallback (TTY) ─────────────────────────────────────────
prompt_console() {
  echo "=== HP Prep Kit: First-Boot Setup ==="
  echo ""
  read -rp "Full name: " FULLNAME
  while true; do
    read -rp "Username: " USERNAME
    [[ -n "$USERNAME" ]] && break
    echo "Username cannot be empty."
  done
  while true; do
    stty -echo
    read -rp "Password: " PASSWORD; echo
    read -rp "Confirm password: " PASSWORD2; echo
    stty echo
    [[ "$PASSWORD" == "$PASSWORD2" ]] && break
    echo "Passwords do not match. Try again."
  done
  printf '%s::%s::%s' "$FULLNAME" "$USERNAME" "$PASSWORD"
}

# ── Create the buyer's account and deploy wallpaper rotator ───────
create_user_and_setup() {
  local fullname="$1" username="$2" password="$3"

  if id -u "$username" >/dev/null 2>&1; then
    echo "Error: user '$username' already exists." >&2
    return 1
  fi

  useradd -m -s /bin/bash -c "$fullname" "$username"
  echo "${username}:${password}" | chpasswd
  # Force buyer to change password on first login
  passwd --expire "$username" || true

  # Add to sudo group so they can administer the machine
  usermod -aG sudo "$username" || true

  # Deploy wallpaper rotator into buyer's home
  USER_HOME=$(eval echo "~${username}")
  mkdir -p \
    "${USER_HOME}/.local/bin" \
    "${USER_HOME}/.config/autostart" \
    "${USER_HOME}/.local/share/backgrounds/wallpapers"

  cp -a "$ROTATE_SRC"         "${USER_HOME}/.local/bin/rotate_wallpapers_xfce.sh"
  cp -a "$AUTOSTART_TEMPLATE" "${USER_HOME}/.config/autostart/wallpaper-rotate.desktop"

  # Fix ownership and permissions
  chown -R "${username}:${username}" "${USER_HOME}/.local" "${USER_HOME}/.config"
  chmod +x "${USER_HOME}/.local/bin/rotate_wallpapers_xfce.sh"

  # Optionally remove seller's prep account (only if flag file exists — set before shipping)
  if [[ -f "$REMOVE_PREP_FLAG" ]]; then
    if [[ "$PREP_USER" != "$username" ]] && id -u "$PREP_USER" >/dev/null 2>&1; then
      deluser --remove-home "$PREP_USER" 2>/dev/null || true
    fi
  fi

  # Mark done so this never runs again
  touch "$MARK_FILE"
  echo "[firstboot] Account '$username' created successfully."
}

# ── Main ───────────────────────────────────────────────────────────
result=""
if result=$(prompt_graphical 2>/dev/null); then
  IFS='::' read -r FULLNAME USERNAME PASSWORD <<< "$result"
  create_user_and_setup "$FULLNAME" "$USERNAME" "$PASSWORD" && exit 0
  exit 1
elif [[ -t 0 ]] || [[ -t 1 ]]; then
  result=$(prompt_console)
  IFS='::' read -r FULLNAME USERNAME PASSWORD <<< "$result"
  create_user_and_setup "$FULLNAME" "$USERNAME" "$PASSWORD" && exit 0
  exit 1
else
  echo "[firstboot] No display or TTY available. Run /usr/local/sbin/firstboot-setup-xfce.sh manually." \
    | tee -a /var/log/hp-prep-firstboot.log
  exit 1
fi
