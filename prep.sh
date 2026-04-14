#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          HP PREP KIT  v4  —  VibeCodingLabs                ║
# ║   Xfce-compatible  ·  Animated  ·  macOS-inspired TUI     ║
# ║   Seller Seal  ·  Test Mode  ·  Wallpaper Rotator          ║
# ╚══════════════════════════════════════════════════════════════╝
# NOTE: No top-level set -euo pipefail — errors handled per-command
# with || true or explicit checks so the menu never dies silently.

export TERM="${TERM:-xterm-256color}"
COLS=$(tput cols 2>/dev/null || echo 80)

C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_WHITE='\033[38;5;255m'
C_SILVER='\033[38;5;251m'
C_GRAY='\033[38;5;242m'
C_DARKGRAY='\033[38;5;238m'
C_BLUE='\033[38;5;33m'
C_CYAN='\033[38;5;51m'
C_TEAL='\033[38;5;43m'
C_MINT='\033[38;5;121m'
C_GREEN='\033[38;5;82m'
C_LIME='\033[38;5;154m'
C_PURPLE='\033[38;5;135m'
C_VIOLET='\033[38;5;141m'
C_PINK='\033[38;5;213m'
C_RED='\033[38;5;196m'
C_ORANGE='\033[38;5;214m'
C_YELLOW='\033[38;5;226m'
C_GOLD='\033[38;5;220m'
BG_CARD='\033[48;5;236m'

hide_cursor()  { tput civis 2>/dev/null || true; }
show_cursor()  { tput cnorm 2>/dev/null || true; }
clear_screen() { tput clear 2>/dev/null || clear; }

trap 'show_cursor; printf "${C_RESET}"' EXIT INT TERM

# ─── spinner ─────────────────────────────────────────────────────
spin_run() {
  local msg="$1"; shift
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local colors=("$C_BLUE" "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_GREEN" "$C_LIME" "$C_YELLOW" "$C_GOLD" "$C_ORANGE" "$C_PINK" "$C_PURPLE" "$C_VIOLET")
  local i=0 ci=0 pid
  hide_cursor
  ("$@") >/tmp/hp_prep_out 2>&1 &
  pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    local frame="${frames[$((i % ${#frames[@]}))]}"
    local color="${colors[$((ci % ${#colors[@]}))]}"
    printf "\r  ${color}${frame}${C_RESET}  ${C_WHITE}${msg}${C_RESET}${C_GRAY}...${C_RESET}   "
    sleep 0.08
    i=$((i+1))
    [[ $((i % 3)) -eq 0 ]] && ci=$((ci+1))
  done
  wait "$pid" || true
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    printf "\r  ${C_GREEN}✓${C_RESET}  ${C_WHITE}${msg}${C_RESET}                    \n"
  else
    printf "\r  ${C_RED}✗${C_RESET}  ${C_WHITE}${msg}${C_RESET} ${C_DIM}(exit ${rc})${C_RESET}\n"
    head -5 /tmp/hp_prep_out 2>/dev/null | sed 's/^/      /' || true
  fi
  show_cursor
  return $rc
}

# ─── progress bar ─────────────────────────────────────────────────
progress_bar() {
  local pct="${1:-0}" label="${2:-}" width=40
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar="" j ratio
  for ((j=0; j<filled; j++)); do
    ratio=$(( j * 100 / width ))
    if   (( ratio < 33 )); then bar+="${C_BLUE}█${C_RESET}"
    elif (( ratio < 66 )); then bar+="${C_CYAN}█${C_RESET}"
    else                        bar+="${C_MINT}█${C_RESET}"
    fi
  done
  for ((j=0; j<empty; j++)); do bar+="${C_DARKGRAY}░${C_RESET}"; done
  printf "  [%s] ${C_SILVER}%s%%${C_RESET}  ${C_DIM}%s${C_RESET}\n" "$bar" "$pct" "$label"
}

animated_progress_bar() {
  local label="${1:-Working}" secs="${2:-2}"
  local steps=40 i pct
  hide_cursor
  for ((i=0; i<=steps; i++)); do
    pct=$(( i * 100 / steps ))
    printf "\r"
    progress_bar "$pct" "$label"
    sleep 0.05
  done
  show_cursor
  printf "\n"
}

typewrite() {
  local text="$1" delay="${2:-0.02}" i
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:$i:1}"
    sleep "$delay"
  done
  printf "\n"
}

hrule() {
  local char="${1:--}" width=$(( COLS > 72 ? 72 : COLS ))
  local line="" i ci
  local colors=("$C_BLUE" "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_GREEN" "$C_LIME" "$C_YELLOW" "$C_GOLD" "$C_ORANGE" "$C_PINK" "$C_PURPLE" "$C_VIOLET" "$C_BLUE")
  local nc=${#colors[@]}
  for ((i=0; i<width; i++)); do
    ci=$(( i * nc / width ))
    line+="${colors[$ci]}${char}${C_RESET}"
  done
  printf "%b\n" "$line"
}

glass_card() {
  local title="$1"; shift
  local body=("$@")
  local w=60
  local pad=$(( (COLS - w) / 2 ))
  [[ $pad -lt 0 ]] && pad=0
  local indent
  indent=$(printf '%*s' "$pad" '')
  printf "\n"
  printf "%b\n" "${indent}${C_DARKGRAY}╭$(printf '─%.0s' $(seq 1 $((w-2))))╮${C_RESET}"
  printf "%b\n" "${indent}${C_DARKGRAY}│${C_RESET}${BG_CARD}  ${C_CYAN}${C_BOLD}${title}$(printf '%*s' $((w-4-${#title})) '')${C_RESET}${C_DARKGRAY}  │${C_RESET}"
  printf "%b\n" "${indent}${C_DARKGRAY}├$(printf '─%.0s' $(seq 1 $((w-2))))┤${C_RESET}"
  for line in "${body[@]}"; do
    local stripped vlen padding
    stripped=$(printf "%b" "$line" | sed 's/\x1B\[[0-9;]*m//g')
    vlen=${#stripped}
    padding=$(( w - 4 - vlen ))
    [[ $padding -lt 0 ]] && padding=0
    printf "%b\n" "${indent}${C_DARKGRAY}│${C_RESET}${BG_CARD}  ${line}$(printf '%*s' "$padding" '')${C_RESET}${C_DARKGRAY}  │${C_RESET}"
  done
  printf "%b\n" "${indent}${C_DARKGRAY}╰$(printf '─%.0s' $(seq 1 $((w-2))))╯${C_RESET}"
  printf "\n"
}

toast() {
  local type="$1" msg="$2"
  case "$type" in
    ok)   local icon="✓" color="$C_GREEN"  label="Done"    ;;
    warn) local icon="⚠" color="$C_YELLOW" label="Warning" ;;
    err)  local icon="✗" color="$C_RED"    label="Error"   ;;
    info) local icon="ℹ" color="$C_CYAN"   label="Info"    ;;
    *)    local icon="·" color="$C_WHITE"  label=""        ;;
  esac
  printf "  %b%b%b  %b%b  %b%b%b\n" "$color" "$C_BOLD" "$icon" "$label" "$C_RESET" "$C_SILVER" "$msg" "$C_RESET"
}

check_deps() {
  local missing=()
  for cmd in figlet lolcat toilet bc; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    printf "  %b Installing display tools: %s%b\n" "$C_YELLOW" "${missing[*]}" "$C_RESET"
    sudo apt-get install -y figlet lolcat toilet bc 2>/dev/null || true
  fi
}

confirm() {
  local msg="$1"
  printf "\n  %b◆%b  %b%s%b %b[y/N]%b  " "$C_GOLD" "$C_RESET" "$C_WHITE" "$msg" "$C_RESET" "$C_DIM" "$C_RESET"
  local ans
  read -r ans
  [[ "${ans,,}" == "y" ]]
}

press_enter() {
  printf "\n"
  hrule "·"
  printf "  %bPress ENTER to return to menu...%b" "$C_DIM" "$C_RESET"
  read -r
}

detect_de() {
  if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
    printf "%s" "${XDG_CURRENT_DESKTOP,,}"
  elif command -v xfce4-session &>/dev/null; then
    printf "xfce"
  elif command -v gnome-shell &>/dev/null; then
    printf "gnome"
  else
    printf "unknown"
  fi
}

# ─── BANNER ──────────────────────────────────────────────────────
draw_main_banner() {
  clear_screen
  printf "\n"
  if command -v figlet &>/dev/null; then
    hide_cursor
    for bc in "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_GREEN"; do
      clear_screen; printf "\n"
      while IFS= read -r line; do
        printf "%b%s%b\n" "$bc" "  $line" "$C_RESET"
      done < <(figlet -f banner3 "VIBECODINGLABS" 2>/dev/null || figlet "VIBECODINGLABS")
      sleep 0.12
    done
    clear_screen; printf "\n"
    if command -v lolcat &>/dev/null; then
      figlet -f banner3 "VIBECODINGLABS" 2>/dev/null | sed 's/^/  /' | lolcat -a -d 1 -s 60 2>/dev/null || \
        figlet -f banner3 "VIBECODINGLABS" 2>/dev/null | sed 's/^/  /' | lolcat 2>/dev/null || \
        figlet "VIBECODINGLABS" | sed 's/^/  /'
    else
      while IFS= read -r line; do
        printf "%b%s%b\n" "$C_CYAN" "  $line" "$C_RESET"
      done < <(figlet -f banner3 "VIBECODINGLABS" 2>/dev/null || figlet "VIBECODINGLABS")
    fi
    show_cursor
  else
    hide_cursor
    for bc in "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_CYAN"; do
      clear_screen; printf "\n"
      printf "%b%b\n" "$bc" "$C_BOLD"
      printf ' ##  ##  ####  ####   ####    ####   ####   ####  ####  ##  ##   ####     ##       ###   ####   ####\n'
      printf ' ##  ## ##  ## ##  ## ##      ##  ## ##  ## ##  ## ##  ## ####  ##  ##    ##      ##  ## ##  ## ##\n'
      printf ' ##  ## ##  ## ######  ###    ##      ##  ## ##  ## ######  ## ## ##  ##  ##      ###### ######  ###\n'
      printf '  ####  ##  ## ##  ##    ##   ##  ##  ##  ## ##  ## ##  ##  ## ## ##  ##  ##      ##  ## ##  ##    ##\n'
      printf '   ##    ####  ##  ## ####     ####   ####   ####  ##  ##  ## ##  ####   ######  ##  ## ##  ## ####\n'
      printf "%b\n" "$C_RESET"
      sleep 0.12
    done
    show_cursor
  fi
  printf "\n"
  if command -v toilet &>/dev/null && command -v lolcat &>/dev/null; then
    toilet -f future "  HP Prep Kit  v4" 2>/dev/null | lolcat 2>/dev/null || \
      printf "  %b%b✦  HP Prep Kit  v4  — VibeCodingLabs  ✦%b\n" "$C_PURPLE" "$C_BOLD" "$C_RESET"
  else
    printf "  %b%b✦  HP Prep Kit  v4  — VibeCodingLabs  ✦%b\n" "$C_PURPLE" "$C_BOLD" "$C_RESET"
  fi
  printf "\n"
  hrule "─"
  printf "\n  "
  typewrite "Ubuntu Laptop Prep Kit  ·  Secure  ·  Beautiful  ·  Ready to Sell" 0.013
  printf "\n"
  hrule "─"
  printf "\n"
}

section_banner() {
  local title="$1" icon="${2:-▶}"
  printf "\n"
  hrule "─"
  printf "\n"
  if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
    figlet -f banner3 "  $title" 2>/dev/null | lolcat -a -d 1 -s 80 2>/dev/null || \
      figlet "  $title" 2>/dev/null | lolcat 2>/dev/null || \
      printf "  %b%b%s  %s%b\n" "$C_CYAN" "$C_BOLD" "$icon" "$title" "$C_RESET"
  elif command -v figlet &>/dev/null; then
    while IFS= read -r line; do
      printf "%b%s%b\n" "$C_CYAN" "$line" "$C_RESET"
    done < <(figlet -f small "  $title" 2>/dev/null || figlet "  $title")
  else
    printf "  %b%b%s  %s%b\n" "$C_CYAN" "$C_BOLD" "$icon" "$title" "$C_RESET"
  fi
  printf "\n"
  hrule "─"
  printf "\n"
}

# ─── module: system info ─────────────────────────────────────────
module_sysinfo() {
  section_banner "SYSINFO"
  local cpu_model cpu_cores mem_total disk_info os_ver kernel de
  cpu_model=$(lscpu 2>/dev/null | awk -F: '/Model name/{gsub(/^[ \t]+/,"",$2); print $2; exit}' || echo "Unknown")
  cpu_cores=$(nproc 2>/dev/null || echo "?")
  mem_total=$(free -h 2>/dev/null | awk '/^Mem:/{print $2}' || echo "?")
  disk_info=$(df -h / 2>/dev/null | awk 'NR==2{print $3 " used / " $2 " total (" $5 ")"}'  || echo "?")
  os_ver=$(lsb_release -sd 2>/dev/null | tr -d '"' || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"' || echo "Unknown")
  kernel=$(uname -r 2>/dev/null || echo "?")
  de=$(detect_de)
  glass_card "  Hardware Overview" \
    "CPU    ${cpu_model}" \
    "Cores  ${cpu_cores} logical processors" \
    "RAM    ${mem_total} total" \
    "Disk   ${disk_info}" \
    "OS     ${os_ver}" \
    "Kernel ${kernel}" \
    "DE     ${de}"
  printf "  %b%bCPU Vulnerabilities%b\n\n" "$C_GOLD" "$C_BOLD" "$C_RESET"
  if [[ -d /sys/devices/system/cpu/vulnerabilities ]]; then
    for f in /sys/devices/system/cpu/vulnerabilities/*; do
      local vname status
      vname=$(basename "$f")
      status=$(cat "$f" 2>/dev/null || echo "unknown")
      if printf "%s" "$status" | grep -qi "not affected\|mitigated"; then
        printf "  %b✓%b  %b%s%b  %b%s%b\n" "$C_GREEN" "$C_RESET" "$C_DIM" "$vname" "$C_RESET" "$C_GREEN" "$status" "$C_RESET"
      elif printf "%s" "$status" | grep -qi "vulnerable"; then
        printf "  %b✗%b  %b%s%b  %b%b%s%b\n" "$C_RED" "$C_RESET" "$C_WHITE" "$vname" "$C_RESET" "$C_RED" "$C_BOLD" "$status" "$C_RESET"
      else
        printf "  %b◌%b  %b%s%b  %b%s%b\n" "$C_YELLOW" "$C_RESET" "$C_DIM" "$vname" "$C_RESET" "$C_YELLOW" "$status" "$C_RESET"
      fi
    done
  else
    local bugs
    bugs=$(grep -m1 "^bugs" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || true)
    if [[ -n "${bugs:-}" ]]; then
      printf "  %b⚠%b  Hardware flags: %b%s%b\n" "$C_YELLOW" "$C_RESET" "$C_ORANGE" "$bugs" "$C_RESET"
    else
      toast ok "No vulnerability flags detected."
    fi
  fi
  printf "\n  %b%bGPU%b\n\n" "$C_GOLD" "$C_BOLD" "$C_RESET"
  if lspci 2>/dev/null | grep -qiE "vga|3d|display"; then
    lspci 2>/dev/null | grep -iE "vga|3d|display" | while IFS= read -r line; do
      printf "  %b▪%b  %b%s%b\n" "$C_VIOLET" "$C_RESET" "$C_SILVER" "$line" "$C_RESET"
    done
  else
    printf "  %bNo GPU detected via lspci%b\n" "$C_DIM" "$C_RESET"
  fi
  press_enter
}

# ─── module: system update ───────────────────────────────────────
module_system_update() {
  section_banner "UPDATE"
  toast info "Refreshing package index..."
  spin_run "Fetching package lists" sudo apt-get update -qq || true
  toast info "Upgrading all packages..."
  spin_run "Upgrading packages" sudo apt-get full-upgrade -y -qq || true
  spin_run "Removing unused packages" sudo apt-get autoremove -y -qq || true
  spin_run "Cleaning package cache"   sudo apt-get autoclean -y     || true
  toast info "Checking firmware updates (fwupd)..."
  if ! command -v fwupdmgr &>/dev/null; then
    spin_run "Installing fwupd" sudo apt-get install -y fwupd -qq || true
  fi
  spin_run "Refreshing firmware metadata" sudo fwupdmgr refresh --force 2>/dev/null || true
  spin_run "Applying firmware updates"    sudo fwupdmgr update -y   2>/dev/null || \
    toast warn "No firmware updates available or BIOS update skipped."
  printf "\n"
  toast ok "System is fully up to date."
  press_enter
}

# ─── module: security hardening ──────────────────────────────────
module_security_harden() {
  section_banner "SECURITY"
  toast info "Configuring firewall..."
  spin_run "Enabling UFW"                   sudo ufw --force enable               || true
  spin_run "Setting default deny inbound"   sudo ufw default deny incoming        || true
  spin_run "Setting default allow outbound" sudo ufw default allow outgoing       || true
  toast ok "Firewall active."
  spin_run "Installing unattended-upgrades" sudo apt-get install -y unattended-upgrades apt-listchanges -qq || true
  sudo dpkg-reconfigure --priority=low unattended-upgrades 2>/dev/null || true
  toast ok "Auto security updates enabled."
  spin_run "Locking root account" sudo passwd -l root 2>/dev/null || toast warn "Could not lock root."
  spin_run "Installing ClamAV"         sudo apt-get install -y clamav clamav-daemon -qq || true
  spin_run "Updating virus definitions" sudo freshclam 2>/dev/null || toast warn "freshclam failed — run manually later."
  toast ok "ClamAV installed."
  toast info "Auditing Spectre/Meltdown mitigations..."
  if ! command -v spectre-meltdown-checker &>/dev/null; then
    spin_run "Installing spectre-meltdown-checker" \
      sudo apt-get install -y spectre-meltdown-checker -qq 2>/dev/null || true
  fi
  if command -v spectre-meltdown-checker &>/dev/null; then
    printf "\n"
    sudo spectre-meltdown-checker --quiet 2>/dev/null || toast warn "Some mitigations may be incomplete."
    toast ok "Spectre/Meltdown audit complete."
  else
    toast warn "Check /sys/devices/system/cpu/vulnerabilities/ manually."
  fi
  press_enter
}

# ─── module: privacy wipe ────────────────────────────────────────
module_privacy_wipe() {
  section_banner "PRIVACY"
  glass_card "  Privacy Wipe" \
    "Removes your personal data only." \
    "OS and apps stay intact." \
    "" \
    "Covers: shell history, SSH/GPG keys," \
    "browser data, .env files, trash, cache."
  confirm "Proceed with privacy wipe?" || { toast info "Skipped."; press_enter; return; }
  printf "\n"
  spin_run "Clearing shell history" \
    bash -c "history -c 2>/dev/null; rm -f ~/.bash_history ~/.zsh_history ~/.local/share/recently-used.xbel 2>/dev/null; true"
  if confirm "Remove ~/.ssh (SSH keys)?"; then
    spin_run "Wiping SSH keys" bash -c "rm -rf ~/.ssh 2>/dev/null; true"
  fi
  if confirm "Remove ~/.gnupg (GPG keys)?"; then
    spin_run "Wiping GPG keys" bash -c "rm -rf ~/.gnupg 2>/dev/null; true"
  fi
  spin_run "Clearing Firefox data" \
    bash -c "rm -rf ~/.mozilla/firefox/*.default*/sessionstore* ~/.mozilla/firefox/*.default*/cookies.sqlite ~/.mozilla/firefox/*.default*/places.sqlite ~/.mozilla/firefox/*.default*/formhistory.sqlite 2>/dev/null; true"
  spin_run "Clearing Chrome/Chromium data" \
    bash -c "rm -rf ~/.config/google-chrome/Default/Cookies ~/.config/google-chrome/Default/History ~/.config/chromium/Default/Cookies ~/.config/chromium/Default/History 2>/dev/null; true"
  spin_run "Emptying thumbnail cache" bash -c "rm -rf ~/.cache/thumbnails/* 2>/dev/null; true"
  spin_run "Emptying trash"           bash -c "rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/* 2>/dev/null; true"
  toast info "Scanning for .env / secret files (depth 3)..."
  local found=0
  while IFS= read -r -d '' f; do
    toast warn "Found: $f"
    confirm "Delete $f?" && rm -f "$f" 2>/dev/null && toast ok "Deleted: $f" || true
    found=1
  done < <(find ~ -maxdepth 3 \( -name "*.env" -o -name ".env.*" -o -name "*.pem" -o -name "id_rsa" \) -print0 2>/dev/null || true)
  [[ $found -eq 0 ]] && toast ok "No secret files found."
  animated_progress_bar "Finalizing wipe" 1
  toast ok "Privacy wipe complete."
  press_enter
}

# ─── module: beautify ─────────────────────────────────────────────
module_beautify() {
  section_banner "BEAUTIFY"
  local de
  de=$(detect_de)
  toast info "Detected DE: ${de}"
  spin_run "Installing Papirus icon theme" \
    bash -c "sudo add-apt-repository -y ppa:papirus/papirus 2>/dev/null; sudo apt-get update -qq 2>/dev/null; sudo apt-get install -y papirus-icon-theme -qq 2>/dev/null; true"
  if printf "%s" "$de" | grep -qi "xfce"; then
    toast info "Applying Xfce theme settings..."
    spin_run "Setting icon theme"          bash -c "xfconf-query -c xsettings -p /Net/IconThemeName -s 'Papirus' 2>/dev/null; true"
    spin_run "Setting dark GTK theme"      bash -c "xfconf-query -c xsettings -p /Net/ThemeName -s 'Greybird-dark' 2>/dev/null || xfconf-query -c xsettings -p /Net/ThemeName -s 'Greybird' 2>/dev/null; true"
    spin_run "Setting dark window borders" bash -c "xfconf-query -c xfwm4 -p /general/theme -s 'Greybird-dark' 2>/dev/null || xfconf-query -c xfwm4 -p /general/theme -s 'Greybird' 2>/dev/null; true"
    spin_run "Setting Monospace font"      bash -c "xfconf-query -c xsettings -p /Gtk/FontName -s 'Monospace 11' 2>/dev/null; true"
    spin_run "Installing extra wallpapers" bash -c "sudo apt-get install -y xfce4-goodies xubuntu-wallpapers -qq 2>/dev/null; true"
    local wp
    wp=$(find /usr/share/xfce4/backdrops /usr/share/backgrounds -name '*.jpg' -o -name '*.png' 2>/dev/null | shuf | head -1 || true)
    if [[ -n "${wp:-}" ]]; then
      xfconf-query -c xfce4-desktop --list 2>/dev/null | grep 'last-image' | while read -r prop; do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$wp" 2>/dev/null || true
      done
      toast ok "Wallpaper: ${wp}"
    fi
    toast ok "Xfce desktop beautified."
  elif printf "%s" "$de" | grep -qi "gnome"; then
    toast info "Applying GNOME theme settings..."
    spin_run "Installing GNOME Tweaks"    sudo apt-get install -y gnome-tweaks gnome-shell-extensions -qq  || true
    spin_run "Setting Papirus icons"      bash -c "gsettings set org.gnome.desktop.interface icon-theme 'Papirus' 2>/dev/null; true"
    spin_run "Enabling dark mode"         bash -c "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null; true"
    spin_run "Showing battery percentage" bash -c "gsettings set org.gnome.desktop.interface show-battery-percentage true 2>/dev/null; true"
    spin_run "Setting font"               bash -c "gsettings set org.gnome.desktop.interface font-name 'Cantarell 11' 2>/dev/null; true"
    local wp
    wp=$(find /usr/share/backgrounds -name '*.jpg' -o -name '*.png' 2>/dev/null | shuf | head -1 || true)
    if [[ -n "${wp:-}" ]]; then
      gsettings set org.gnome.desktop.background picture-uri      "file://$wp" 2>/dev/null || true
      gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp" 2>/dev/null || true
      toast ok "Wallpaper: $wp"
    fi
    toast ok "GNOME desktop beautified."
  else
    toast warn "Unknown DE (${de}) — applied Papirus icons only."
  fi
  animated_progress_bar "Applying theme" 2
  press_enter
}

# ─── module: create buyer user ───────────────────────────────────
module_new_user() {
  section_banner "NEW USER"
  glass_card "  Create Buyer Account" \
    "Creates a clean sudo user for the new owner." \
    "Password expires on first login."
  confirm "Create a new buyer account?" || { toast info "Skipped."; press_enter; return; }
  printf "  %bUsername:%b  " "$C_CYAN" "$C_RESET"
  local newuser
  read -r newuser
  printf "  %bPassword:%b  " "$C_CYAN" "$C_RESET"
  local newpass
  read -rs newpass
  printf "\n"
  if sudo useradd -m -s /bin/bash -G sudo "$newuser" 2>/dev/null; then
    printf "%s:%s" "$newuser" "$newpass" | sudo chpasswd 2>/dev/null || true
    sudo passwd --expire "$newuser" 2>/dev/null || true
    toast ok "User '${newuser}' created — password expires on first login."
  else
    toast warn "User '${newuser}' may already exist or useradd failed."
  fi
  press_enter
}

# ─── module: seller seal ─────────────────────────────────────────
# Deploys a wallpaper rotator (cron), arms a firstboot cleanup
# service, and optionally locks seller accounts.
module_seller_seal() {
  section_banner "SEAL"
  glass_card "  Seller Seal" \
    "Prepares the laptop for handoff to buyer:" \
    "  · Wallpaper rotation service (cron)" \
    "  · Firstboot cleanup service (systemd)" \
    "  · Optional: disable seller accounts" \
    "  · Seal flag written to /etc/hp-prep-sealed"
  confirm "Arm the seller seal?" || { toast info "Skipped."; press_enter; return; }

  # 1. Wallpaper rotator script
  toast info "Installing wallpaper rotator..."
  sudo tee /usr/local/bin/wallpaper-rotate.sh >/dev/null <<'WPEOF'
#!/usr/bin/env bash
# Wallpaper rotator — picks a random wallpaper every 30 min
export DISPLAY=":0"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

de() {
  if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then echo "${XDG_CURRENT_DESKTOP,,}";
  elif command -v xfce4-session &>/dev/null; then echo "xfce";
  elif command -v gnome-shell &>/dev/null; then echo "gnome";
  else echo "unknown"; fi
}

DE=$(de)
wp=$(find /usr/share/xfce4/backdrops /usr/share/backgrounds -name '*.jpg' -o -name '*.png' 2>/dev/null | shuf | head -1)
[[ -z "$wp" ]] && exit 0

if [[ "$DE" == *xfce* ]]; then
  xfconf-query -c xfce4-desktop --list 2>/dev/null | grep 'last-image' | while read -r prop; do
    xfconf-query -c xfce4-desktop -p "$prop" -s "$wp" 2>/dev/null || true
  done
elif [[ "$DE" == *gnome* ]]; then
  gsettings set org.gnome.desktop.background picture-uri      "file://$wp" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp" 2>/dev/null || true
fi
WPEOF
  sudo chmod +x /usr/local/bin/wallpaper-rotate.sh 2>/dev/null || true
  # Install cron job for all non-root users
  (crontab -l 2>/dev/null; echo "*/30 * * * * /usr/local/bin/wallpaper-rotate.sh") | sort -u | crontab - 2>/dev/null || true
  toast ok "Wallpaper rotator installed (every 30 min)."

  # 2. Firstboot cleanup systemd service
  toast info "Installing firstboot cleanup service..."
  sudo tee /etc/systemd/system/hp-prep-firstboot.service >/dev/null <<'SVCEOF'
[Unit]
Description=HP Prep Kit — Buyer Firstboot Cleanup
ConditionPathExists=/etc/hp-prep-sealed
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/hp-prep-firstboot.sh

[Install]
WantedBy=multi-user.target
SVCEOF

  sudo tee /usr/local/bin/hp-prep-firstboot.sh >/dev/null <<'FBEOF'
#!/usr/bin/env bash
# Runs once on buyer first boot — removes seal flag and seller artifacts
rm -f /etc/hp-prep-sealed 2>/dev/null
systemctl disable hp-prep-firstboot.service 2>/dev/null || true
# Remove seller users (comma-separated in /etc/hp-prep-seller-users)
if [[ -f /etc/hp-prep-seller-users ]]; then
  while IFS= read -r u; do
    [[ -z "$u" ]] && continue
    userdel -r "$u" 2>/dev/null || true
  done < /etc/hp-prep-seller-users
  rm -f /etc/hp-prep-seller-users
fi
exec /bin/true
FBEOF
  sudo chmod +x /usr/local/bin/hp-prep-firstboot.sh 2>/dev/null || true
  sudo systemctl daemon-reload 2>/dev/null || true
  sudo systemctl enable hp-prep-firstboot.service 2>/dev/null || true
  toast ok "Firstboot cleanup service armed."

  # 3. Record seller accounts
  local seller_users
  seller_users=$(who 2>/dev/null | awk '{print $1}' | sort -u | tr '\n' ',' | sed 's/,$//') || true
  if [[ -n "${seller_users:-}" ]]; then
    toast info "Seller accounts detected: ${seller_users}"
    confirm "Record these accounts for firstboot removal? (${seller_users})" && \
      printf "%s\n" "${seller_users//,/$'\n'}" | sudo tee /etc/hp-prep-seller-users >/dev/null 2>&1 || true
  fi

  # 4. Write seal flag
  sudo touch /etc/hp-prep-sealed 2>/dev/null || true
  printf "  %b%bSTATUS: SEALED%b\n" "$C_GREEN" "$C_BOLD" "$C_RESET"
  toast ok "Laptop is sealed for buyer handoff."
  press_enter
}

# ─── module: test mode ────────────────────────────────────────────
module_test_mode() {
  section_banner "TEST"
  glass_card "  Test Mode" \
    "Validates the full prep environment:" \
    "  · xfconf-query (Xfce config tool)" \
    "  · User accounts (buyer + seller)" \
    "  · Sudo access" \
    "  · Wallpaper rotator" \
    "  · Seal flag" \
    "  · CPU vulnerability mitigations"
  printf "\n"

  local pass=0 fail=0

  _check() {
    local label="$1" result="$2"
    if [[ "$result" == "ok" ]]; then
      toast ok "$label"
      pass=$((pass+1))
    else
      toast err "$label  — ${result}"
      fail=$((fail+1))
    fi
  }

  # xfconf-query
  if command -v xfconf-query &>/dev/null; then
    _check "xfconf-query present" "ok"
  else
    _check "xfconf-query present" "NOT FOUND — run Beautify or install xfce4"
  fi

  # wallpaper rotator
  if [[ -x /usr/local/bin/wallpaper-rotate.sh ]]; then
    _check "Wallpaper rotator script" "ok"
  else
    _check "Wallpaper rotator script" "NOT FOUND — run Seller Seal first"
  fi

  # cron entry
  if crontab -l 2>/dev/null | grep -q "wallpaper-rotate.sh"; then
    _check "Wallpaper cron entry" "ok"
  else
    _check "Wallpaper cron entry" "NOT FOUND — run Seller Seal first"
  fi

  # firstboot service
  if systemctl list-unit-files 2>/dev/null | grep -q "hp-prep-firstboot"; then
    _check "Firstboot cleanup service" "ok"
  else
    _check "Firstboot cleanup service" "NOT FOUND — run Seller Seal first"
  fi

  # seal flag
  if [[ -f /etc/hp-prep-sealed ]]; then
    _check "Seal flag (/etc/hp-prep-sealed)" "ok — SEALED"
  else
    _check "Seal flag (/etc/hp-prep-sealed)" "NOT PRESENT — run Seller Seal to arm"
  fi

  # sudo access
  if sudo -n true 2>/dev/null; then
    _check "Sudo access (passwordless)" "ok"
  else
    _check "Sudo access" "ok (password required — normal)"
    pass=$((pass+1))
  fi

  # user accounts
  printf "\n  %b%bUser Accounts:%b\n" "$C_GOLD" "$C_BOLD" "$C_RESET"
  while IFS=: read -r username _ uid _; do
    if (( uid >= 1000 && uid < 65534 )); then
      local groups
      groups=$(groups "$username" 2>/dev/null | tr '\n' ' ' || echo "?")
      printf "  %b·%b  %b%s%b  %b(uid=%s)%b  %b%s%b\n" \
        "$C_CYAN" "$C_RESET" "$C_WHITE" "$username" "$C_RESET" \
        "$C_DIM" "$uid" "$C_RESET" "$C_GRAY" "$groups" "$C_RESET"
    fi
  done < /etc/passwd

  # CPU vulnerability summary
  printf "\n  %b%bCPU Mitigations:%b\n" "$C_GOLD" "$C_BOLD" "$C_RESET"
  local vuln=0
  if [[ -d /sys/devices/system/cpu/vulnerabilities ]]; then
    for f in /sys/devices/system/cpu/vulnerabilities/*; do
      local vname status
      vname=$(basename "$f")
      status=$(cat "$f" 2>/dev/null || echo "unknown")
      if printf "%s" "$status" | grep -qi "vulnerable"; then
        printf "  %b✗%b  %b%s%b  %b%s%b\n" "$C_RED" "$C_RESET" "$C_WHITE" "$vname" "$C_RESET" "$C_RED" "$status" "$C_RESET"
        vuln=$((vuln+1))
      elif printf "%s" "$status" | grep -qi "not affected\|mitigated"; then
        printf "  %b✓%b  %b%s%b\n" "$C_GREEN" "$C_RESET" "$C_DIM" "$vname" "$C_RESET"
      fi
    done
  else
    toast warn "Cannot read /sys/devices/system/cpu/vulnerabilities"
  fi

  printf "\n"
  hrule "─"
  printf "\n  %b%bTest Results:%b  %b%d passed%b  %b%d failed%b" \
    "$C_BOLD" "$C_WHITE" "$C_RESET" \
    "$C_GREEN" "$pass" "$C_RESET" \
    "$C_RED" "$fail" "$C_RESET"
  if (( vuln > 0 )); then
    printf "  %b%d unmitigated CPU vuln(s)%b" "$C_YELLOW" "$vuln" "$C_RESET"
  fi
  printf "\n\n"
  press_enter
}

# ─── module: full prep ───────────────────────────────────────────
module_full_run() {
  section_banner "FULL PREP"
  glass_card "  Full Prep Sequence" \
    "Runs ALL modules in order:" \
    "  1  System Update" \
    "  2  Security Hardening" \
    "  3  Privacy Wipe" \
    "  4  Beautify Desktop" \
    "  5  Create Buyer User" \
    "  6  Seller Seal" \
    "  7  Test Mode (verification)"
  confirm "Run full prep sequence now?" || { toast info "Cancelled."; press_enter; return; }
  module_system_update
  module_security_harden
  module_privacy_wipe
  module_beautify
  module_new_user
  module_seller_seal
  module_test_mode
  section_banner "DONE"
  printf "\n"
  printf "  %b%b" "$C_GREEN" "$C_BOLD"
  typewrite "  ✦  This HP is fully prepped and ready for its new owner.  ✦" 0.02
  printf "%b\n\n" "$C_RESET"
  hrule "="
  press_enter
}

# ─── main menu ───────────────────────────────────────────────────
main_menu() {
  check_deps
  while true; do
    draw_main_banner
    local pad="  "
    printf "%b%b%b  Select a module:%b\n\n" "$pad" "$C_BOLD" "$C_WHITE" "$C_RESET"
    printf "%b%b                                                            %b\n" "$pad" "$BG_CARD" "$C_RESET"
    printf "%b%b  %b%b[1]%b%b  %bSystem Info         %bspecs · vulns · mitigations    %b%b\n" "$pad" "$BG_CARD" "$C_GREEN"  "$C_BOLD" "$C_RESET" "$BG_CARD" "$C_WHITE" "$C_GRAY" "$C_RESET" "$BG_CARD"
    printf "%b%b  %b%b[2]%b%b  %bSystem Update       %bapt full-upgrade + firmware    %b%b\n" "$pad" "$BG_CARD" "$C_CYAN"   "$C_BOLD" "$C_RESET" "$BG_CARD" "$C_WHITE" "$C_GRAY" "$C_RESET" "$BG_CARD"
    printf "%b%b  %b%b[3]%b%b  %bSecurity Hardening  %bUFW · ClamAV · Meltdown audit  %b%b\n" "$pad" "$BG_CARD" "$C_PURPLE" "$C_BOLD" "$C_RESET" "$BG_CARD" "$C_WHITE" "$C_GRAY" "$C_RESET" "$BG_CARD"
    printf "%b%b  %b%b[4]%b%b  %bPrivacy Wipe        %bhistory · SSH · browser · env  %b%b\n" "$pad" "$BG_CARD" "$C_YELLOW" "$C_BOLD" "$C_RESET" "$BG_CARD" "$C_WHITE" "$C_GRAY" "$C_RESET" "$BG_CARD"
    printf "%b%b  %b%b[5]%b%b  %bBeautify Desktop    %bXfce/GNOME · Papirus icons     %b%b\n" "$pad" "$BG_CARD" "$C_PINK"   "$C_BOLD" "$C_RESET" "$BG_CARD" "$C_WHITE" "$C_GRAY" "$C_RESET" "$BG_CARD"
    printf "%b%b  %b%b[6]%b%b  %bCreate Buyer User   %bnew account · force pw change  %b%b\n" "$pad" "$BG_CARD" "$C_SILVER" "$C_BOLD" "$C_RESET" "$BG_CARD" "$C_WHITE" "$C_GRAY" "$C_RESET" "$BG_CARD"
    printf "%b%b  %b%b[7]%b%b  %bSeller Seal         %bwallpaper rotator · firstboot  %b%b\n" "$pad" "$BG_CARD" "$C_ORANGE" "$C_BOLD" "$C_RESET" "$BG_CARD" "$C_WHITE" "$C_GRAY" "$C_RESET" "$BG_CARD"
    printf "%b%b  %b%b[8]%b%b  %bTest Mode           %bverify all systems             %b%b\n" "$pad" "$BG_CARD" "$C_TEAL"   "$C_BOLD" "$C_RESET" "$BG_CARD" "$C_WHITE" "$C_GRAY" "$C_RESET" "$BG_CARD"
    printf "%b%b                                                            %b\n" "$pad" "$BG_CARD" "$C_RESET"
    printf "\n"
    printf "%b  %b%b[A]%b  %b%bFULL PREP%b — All Modules  %b← recommended%b\n" "$pad" "$C_ORANGE" "$C_BOLD" "$C_RESET" "$C_BOLD" "$C_WHITE" "$C_RESET" "$C_DIM" "$C_RESET"
    printf "\n"
    printf "%b  %b[Q]  Quit%b\n" "$pad" "$C_DIM" "$C_RESET"
    printf "\n"
    hrule "-"
    printf "\n  %b◆%b  %b%bChoice:%b  " "$C_GOLD" "$C_RESET" "$C_BOLD" "$C_WHITE" "$C_RESET"
    local choice
    read -r choice
    case "${choice,,}" in
      1) module_sysinfo         ;;
      2) module_system_update   ;;
      3) module_security_harden ;;
      4) module_privacy_wipe    ;;
      5) module_beautify        ;;
      6) module_new_user        ;;
      7) module_seller_seal     ;;
      8) module_test_mode       ;;
      a) module_full_run        ;;
      q)
        clear_screen
        printf "\n"
        if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
          figlet -f banner3 "Goodbye!" 2>/dev/null | lolcat 2>/dev/null || \
            figlet "Goodbye!" | lolcat 2>/dev/null || printf "  %b%bGoodbye!%b\n" "$C_CYAN" "$C_BOLD" "$C_RESET"
        else
          printf "  %b%bGoodbye!%b\n" "$C_CYAN" "$C_BOLD" "$C_RESET"
        fi
        printf "\n  %bVibeCodingLabs · Phoenix, AZ%b\n\n" "$C_DIM" "$C_RESET"
        show_cursor
        exit 0
        ;;
      *)
        toast warn "Invalid option — press 1-8, A, or Q."
        sleep 1
        ;;
    esac
  done
}

if [[ $EUID -ne 0 ]]; then
  printf "  %b Note: Some modules require sudo — you will be prompted as needed.%b\n" "\033[1;33m" "\033[0m"
  sleep 1
fi

main_menu
