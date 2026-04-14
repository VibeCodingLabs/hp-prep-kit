#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          HP PREP KIT  v3  —  VibeCodingLabs                ║
# ║   Xfce-compatible  ·  Animated  ·  macOS-inspired TUI     ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

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

trap 'show_cursor; echo -e "${C_RESET}"' EXIT INT TERM

# ─── spinner: runs entire duration of a command ─────────────────
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

  wait "$pid"
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

# ─── gradient progress bar (uses echo -e, no printf %b) ─────────
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
  echo -e "  [${bar}] ${C_SILVER}${pct}%${C_RESET}  ${C_DIM}${label}${C_RESET}"
}

animated_progress_bar() {
  local label="${1:-Working}" secs="${2:-2}"
  local steps=40 i pct
  hide_cursor
  for ((i=0; i<=steps; i++)); do
    pct=$(( i * 100 / steps ))
    printf "\r"
    progress_bar "$pct" "$label"
    sleep "$(echo "scale=4; $secs/$steps" | bc 2>/dev/null || echo 0.05)"
  done
  show_cursor
  echo ""
}

typewrite() {
  local text="$1" delay="${2:-0.02}" i
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:$i:1}"
    sleep "$delay"
  done
  echo ""
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
  echo -e "$line"
}

glass_card() {
  local title="$1"; shift
  local body=("$@")
  local w=60
  local pad=$(( (COLS - w) / 2 ))
  [[ $pad -lt 0 ]] && pad=0
  local indent
  indent=$(printf '%*s' "$pad" '')

  echo ""
  echo -e "${indent}${C_DARKGRAY}╭$(printf '─%.0s' $(seq 1 $((w-2))))╮${C_RESET}"
  echo -e "${indent}${C_DARKGRAY}│${C_RESET}${BG_CARD}  ${C_CYAN}${C_BOLD}${title}$(printf '%*s' $((w-4-${#title})) '')${C_RESET}${C_DARKGRAY}  │${C_RESET}"
  echo -e "${indent}${C_DARKGRAY}├$(printf '─%.0s' $(seq 1 $((w-2))))┤${C_RESET}"
  for line in "${body[@]}"; do
    local stripped vlen padding
    stripped=$(echo "$line" | sed 's/\x1B\[[0-9;]*m//g')
    vlen=${#stripped}
    padding=$(( w - 4 - vlen ))
    [[ $padding -lt 0 ]] && padding=0
    echo -e "${indent}${C_DARKGRAY}│${C_RESET}${BG_CARD}  ${line}$(printf '%*s' "$padding" '')${C_RESET}${C_DARKGRAY}  │${C_RESET}"
  done
  echo -e "${indent}${C_DARKGRAY}╰$(printf '─%.0s' $(seq 1 $((w-2))))╯${C_RESET}"
  echo ""
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
  echo -e "  ${color}${C_BOLD}${icon}  ${label}${C_RESET}  ${C_SILVER}${msg}${C_RESET}"
}

check_deps() {
  local missing=()
  for cmd in figlet lolcat toilet bc; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "  ${C_YELLOW}Installing display tools: ${missing[*]}${C_RESET}"
    sudo apt-get install -y figlet lolcat toilet bc 2>/dev/null || true
  fi
}

confirm() {
  local msg="$1"
  echo ""
  echo -ne "  ${C_GOLD}◆${C_RESET}  ${C_WHITE}${msg}${C_RESET} ${C_DIM}[y/N]${C_RESET}  "
  read -r ans
  [[ "${ans,,}" == "y" ]]
}

press_enter() {
  echo ""
  hrule "·"
  echo -ne "  ${C_DIM}Press ENTER to return to menu...${C_RESET}"
  read -r
}

# ─── detect desktop environment ─────────────────────────────────
detect_de() {
  if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
    echo "${XDG_CURRENT_DESKTOP,,}"
  elif command -v xfce4-session &>/dev/null; then
    echo "xfce"
  elif command -v gnome-shell &>/dev/null; then
    echo "gnome"
  else
    echo "unknown"
  fi
}

# ─── BANNER — figlet "banner3" font (solid block letters) ────────
# stays on screen; spinner runs BELOW it during operations
draw_main_banner() {
  clear_screen
  echo ""

  if command -v figlet &>/dev/null; then
    hide_cursor
    # Rotating color intro (4 frames)
    for bc in "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_GREEN"; do
      clear_screen; echo ""
      figlet -f banner3 "VIBECODINGLABS" 2>/dev/null | \
        sed "s/^/  /" | while IFS= read -r line; do
          echo -e "${bc}${line}${C_RESET}"
        done
      sleep 0.12
    done
    # Final render — lolcat rainbow, stays permanently
    clear_screen; echo ""
    if command -v lolcat &>/dev/null; then
      figlet -f banner3 "VIBECODINGLABS" 2>/dev/null | \
        sed "s/^/  /" | lolcat -a -d 1 -s 60 2>/dev/null || \
        figlet -f banner3 "VIBECODINGLABS" 2>/dev/null | \
        sed "s/^/  /" | lolcat
    else
      figlet -f banner3 "VIBECODINGLABS" 2>/dev/null | \
        sed "s/^/  /" | while IFS= read -r line; do
          echo -e "${C_CYAN}${line}${C_RESET}"
        done
    fi
    show_cursor
  else
    # Fallback solid block-letter ASCII art
    hide_cursor
    for bc in "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_CYAN"; do
      clear_screen; echo ""
      echo -e "${bc}${C_BOLD}"
      echo ' ##  ##  ####  ####   ####    ####   ####   ####  ####  ##  ##   ####     ##       ###   ####   ####'
      echo ' ##  ## ##  ## ##  ## ##      ##  ## ##  ## ##  ## ##  ## ####  ##  ##    ##      ##  ## ##  ## ##'
      echo ' ##  ## ##  ## ######  ###    ##      ##  ## ##  ## ######  ## ## ##  ##  ##      ###### ######  ###'
      echo '  ####  ##  ## ##  ##    ##   ##  ##  ##  ## ##  ## ##  ##  ## ## ##  ##  ##      ##  ## ##  ##    ##'
      echo '   ##    ####  ##  ## ####     ####   ####   ####  ##  ##  ## ##  ####   ######  ##  ## ##  ## ####'
      echo -e "${C_RESET}"
      sleep 0.12
    done
    show_cursor
  fi

  echo ""
  if command -v toilet &>/dev/null && command -v lolcat &>/dev/null; then
    toilet -f future "  HP Prep Kit  v3" | lolcat
  else
    echo -e "  ${C_PURPLE}${C_BOLD}✦  HP Prep Kit  v3  —  VibeCodingLabs  ✦${C_RESET}"
  fi
  echo ""
  hrule "─"
  echo ""
  printf "  "
  typewrite "Ubuntu Laptop Prep Kit  ·  Secure  ·  Beautiful  ·  Ready to Sell" 0.013
  echo ""
  hrule "─"
  echo ""
}

# ─── section banner ──────────────────────────────────────────────
section_banner() {
  local title="$1" icon="${2:-▶}"
  echo ""
  hrule "─"
  echo ""
  if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
    figlet -f banner3 "  $title" 2>/dev/null | lolcat -a -d 1 -s 80 2>/dev/null || \
      figlet -f banner3 "  $title" 2>/dev/null | lolcat
  elif command -v figlet &>/dev/null; then
    figlet -f small "  $title" | while IFS= read -r line; do
      echo -e "${C_CYAN}${line}${C_RESET}"
    done
  else
    echo -e "  ${C_CYAN}${C_BOLD}${icon}  ${title}${C_RESET}"
  fi
  echo ""
  hrule "─"
  echo ""
}

# ─── module: sys info ────────────────────────────────────────────
module_sysinfo() {
  section_banner "SYSINFO"
  local cpu_model cpu_cores mem_total disk_info os_ver kernel de
  cpu_model=$(lscpu 2>/dev/null | awk -F: '/Model name/{gsub(/^[ \t]+/,"",$2); print $2; exit}')
  cpu_cores=$(nproc 2>/dev/null || echo "?")
  mem_total=$(free -h 2>/dev/null | awk '/^Mem:/{print $2}')
  disk_info=$(df -h / 2>/dev/null | awk 'NR==2{print $3 " used / " $2 " total (" $5 ")"}')
  os_ver=$(lsb_release -sd 2>/dev/null | tr -d '"')
  kernel=$(uname -r 2>/dev/null)
  de=$(detect_de)

  glass_card "  Hardware Overview" \
    "CPU    ${cpu_model}" \
    "Cores  ${cpu_cores} logical processors" \
    "RAM    ${mem_total} total" \
    "Disk   ${disk_info}" \
    "OS     ${os_ver}" \
    "Kernel ${kernel}" \
    "DE     ${de}"

  echo -e "  ${C_GOLD}${C_BOLD}CPU Vulnerabilities${C_RESET}"
  echo ""
  if [[ -d /sys/devices/system/cpu/vulnerabilities ]]; then
    for f in /sys/devices/system/cpu/vulnerabilities/*; do
      local vname status
      vname=$(basename "$f")
      status=$(cat "$f" 2>/dev/null || echo "unknown")
      if echo "$status" | grep -qi "not affected\|mitigated"; then
        echo -e "  ${C_GREEN}✓${C_RESET}  ${C_DIM}${vname}${C_RESET}  ${C_GREEN}${status}${C_RESET}"
      elif echo "$status" | grep -qi "vulnerable"; then
        echo -e "  ${C_RED}✗${C_RESET}  ${C_WHITE}${vname}${C_RESET}  ${C_RED}${C_BOLD}${status}${C_RESET}"
      else
        echo -e "  ${C_YELLOW}◌${C_RESET}  ${C_DIM}${vname}${C_RESET}  ${C_YELLOW}${status}${C_RESET}"
      fi
    done
  else
    local bugs
    bugs=$(grep -m1 "^bugs" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs)
    [[ -n "$bugs" ]] && echo -e "  ${C_YELLOW}⚠${C_RESET}  Hardware flags: ${C_ORANGE}${bugs}${C_RESET}" \
      || toast ok "No vulnerability flags detected."
  fi

  echo ""
  echo -e "  ${C_GOLD}${C_BOLD}GPU${C_RESET}"
  echo ""
  if lspci 2>/dev/null | grep -qiE "vga|3d|display"; then
    lspci 2>/dev/null | grep -iE "vga|3d|display" | while IFS= read -r line; do
      echo -e "  ${C_VIOLET}▪${C_RESET}  ${C_SILVER}${line}${C_RESET}"
    done
  else
    echo -e "  ${C_DIM}No GPU detected via lspci${C_RESET}"
  fi

  press_enter
}

# ─── module: system update ───────────────────────────────────────
module_system_update() {
  section_banner "UPDATE"
  toast info "Refreshing package index..."
  spin_run "Fetching package lists" sudo apt-get update -qq
  toast info "Upgrading all packages..."
  animated_progress_bar "Upgrading packages" 3 &
  local bar_pid=$!
  sudo apt-get full-upgrade -y -qq 2>/dev/null
  kill "$bar_pid" 2>/dev/null || true
  wait "$bar_pid" 2>/dev/null || true
  toast ok "All packages upgraded."
  spin_run "Removing unused packages" sudo apt-get autoremove -y -qq
  spin_run "Cleaning package cache"   sudo apt-get autoclean -y
  toast info "Checking firmware updates (fwupd)..."
  if ! command -v fwupdmgr &>/dev/null; then
    spin_run "Installing fwupd" sudo apt-get install -y fwupd -qq
  fi
  spin_run "Refreshing firmware metadata" sudo fwupdmgr refresh --force
  spin_run "Applying firmware updates"    sudo fwupdmgr update -y || \
    toast warn "No firmware updates or BIOS update skipped."
  echo ""
  toast ok "System is fully up to date."
  press_enter
}

# ─── module: security hardening ──────────────────────────────────
module_security_harden() {
  section_banner "SECURITY"
  toast info "Configuring firewall..."
  spin_run "Enabling UFW"                   sudo ufw --force enable
  spin_run "Setting default deny inbound"   sudo ufw default deny incoming
  spin_run "Setting default allow outbound" sudo ufw default allow outgoing
  toast ok "Firewall active."
  spin_run "Installing unattended-upgrades" sudo apt-get install -y unattended-upgrades apt-listchanges -qq
  sudo dpkg-reconfigure --priority=low unattended-upgrades
  toast ok "Auto security updates enabled."
  spin_run "Locking root account" sudo passwd -l root || toast warn "Could not lock root."
  spin_run "Installing ClamAV"         sudo apt-get install -y clamav clamav-daemon -qq
  spin_run "Updating virus definitions" sudo freshclam || toast warn "freshclam failed."
  toast ok "ClamAV installed and updated."
  toast info "Auditing Spectre/Meltdown mitigations..."
  if ! command -v spectre-meltdown-checker &>/dev/null; then
    spin_run "Installing spectre-meltdown-checker" \
      sudo apt-get install -y spectre-meltdown-checker -qq || true
  fi
  if command -v spectre-meltdown-checker &>/dev/null; then
    echo ""
    sudo spectre-meltdown-checker --quiet 2>/dev/null \
      || toast warn "Some mitigations may be incomplete."
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
    "This removes your personal data." \
    "The OS and apps stay intact." \
    "" \
    "Covers: shell history, SSH/GPG keys," \
    "browser data, .env files, trash, cache."
  confirm "Proceed with privacy wipe?" || { toast info "Skipped."; press_enter; return; }
  echo ""
  spin_run "Clearing shell history" bash -c "history -c 2>/dev/null; rm -f ~/.bash_history ~/.zsh_history ~/.local/share/recently-used.xbel"
  if confirm "Remove ~/.ssh (SSH keys)?"; then
    spin_run "Wiping SSH keys" rm -rf ~/.ssh
  fi
  if confirm "Remove ~/.gnupg (GPG keys)?"; then
    spin_run "Wiping GPG keys" rm -rf ~/.gnupg
  fi
  spin_run "Clearing Firefox data"    bash -c "rm -rf ~/.mozilla/firefox/*.default*/sessionstore* ~/.mozilla/firefox/*.default*/cookies.sqlite ~/.mozilla/firefox/*.default*/places.sqlite ~/.mozilla/firefox/*.default*/formhistory.sqlite 2>/dev/null || true"
  spin_run "Clearing Chrome data"     bash -c "rm -rf ~/.config/google-chrome/Default/Cookies ~/.config/google-chrome/Default/History ~/.config/chromium/Default/Cookies ~/.config/chromium/Default/History 2>/dev/null || true"
  spin_run "Emptying thumbnail cache" bash -c "rm -rf ~/.cache/thumbnails/* 2>/dev/null || true"
  spin_run "Emptying trash"           bash -c "rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/* 2>/dev/null || true"
  toast info "Scanning for .env / secret files (depth 3)..."
  local found=0
  while IFS= read -r -d '' f; do
    toast warn "Found: $f"
    confirm "Delete $f?" && rm -f "$f" && toast ok "Deleted: $f"
    found=1
  done < <(find ~ -maxdepth 3 \( -name "*.env" -o -name ".env.*" -o -name "*.pem" -o -name "id_rsa" \) -print0 2>/dev/null)
  [[ $found -eq 0 ]] && toast ok "No secret files found."
  animated_progress_bar "Finalizing wipe" 1
  toast ok "Privacy wipe complete."
  press_enter
}

# ─── module: beautify — Xfce + GNOME auto-detected ───────────────
module_beautify() {
  section_banner "BEAUTIFY"
  local de
  de=$(detect_de)
  toast info "Detected DE: ${de}"

  spin_run "Installing Papirus icon theme" \
    bash -c "sudo add-apt-repository -y ppa:papirus/papirus 2>/dev/null; sudo apt-get update -qq; sudo apt-get install -y papirus-icon-theme -qq"

  if echo "$de" | grep -qi "xfce"; then
    toast info "Applying Xfce theme settings..."
    spin_run "Setting icon theme (Papirus)"    bash -c "xfconf-query -c xsettings -p /Net/IconThemeName -s 'Papirus' 2>/dev/null || true"
    spin_run "Setting dark GTK theme"          bash -c "xfconf-query -c xsettings -p /Net/ThemeName -s 'Greybird-dark' 2>/dev/null || xfconf-query -c xsettings -p /Net/ThemeName -s 'Greybird' 2>/dev/null || true"
    spin_run "Setting dark window decorations" bash -c "xfconf-query -c xfwm4 -p /general/theme -s 'Greybird-dark' 2>/dev/null || xfconf-query -c xfwm4 -p /general/theme -s 'Greybird' 2>/dev/null || true"
    spin_run "Setting Monospace font"          bash -c "xfconf-query -c xsettings -p /Gtk/FontName -s 'Monospace 11' 2>/dev/null || true"
    spin_run "Installing extra wallpapers"     bash -c "sudo apt-get install -y xfce4-goodies xubuntu-wallpapers* -qq 2>/dev/null || true"
    local wp
    wp=$(find /usr/share/xfce4/backdrops /usr/share/backgrounds -name "*.jpg" -o -name "*.png" 2>/dev/null | shuf | head -1 || true)
    if [[ -n "${wp:-}" ]]; then
      spin_run "Setting wallpaper" bash -c "
        xfconf-query -c xfce4-desktop --list 2>/dev/null | grep 'last-image' | while read -r prop; do
          xfconf-query -c xfce4-desktop -p \"\$prop\" -s \"${wp}\" 2>/dev/null || true
        done
      "
      toast ok "Wallpaper: ${wp}"
    fi
    toast ok "Xfce desktop beautified."

  elif echo "$de" | grep -qi "gnome"; then
    toast info "Applying GNOME theme settings..."
    spin_run "Installing GNOME Tweaks"    sudo apt-get install -y gnome-tweaks gnome-shell-extensions -qq
    spin_run "Setting Papirus icons"      gsettings set org.gnome.desktop.interface icon-theme 'Papirus' || true
    spin_run "Enabling dark mode"         gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
    spin_run "Showing battery percentage" gsettings set org.gnome.desktop.interface show-battery-percentage true || true
    spin_run "Setting font"               gsettings set org.gnome.desktop.interface font-name 'Cantarell 11' || true
    local wp
    wp=$(find /usr/share/backgrounds -name "*.jpg" -o -name "*.png" 2>/dev/null | shuf | head -1 || true)
    if [[ -n "${wp:-}" ]]; then
      gsettings set org.gnome.desktop.background picture-uri "file://$wp" 2>/dev/null || true
      gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp" 2>/dev/null || true
      toast ok "Wallpaper: $wp"
    fi
    toast ok "GNOME desktop beautified."

  else
    toast warn "Unknown DE (${de}) — applied Papirus icons only."
    toast info "Set theme manually via your DE settings panel."
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
  echo -ne "  ${C_CYAN}Username:${C_RESET}  "
  read -r newuser
  echo -ne "  ${C_CYAN}Password:${C_RESET}  "
  read -rs newpass
  echo ""
  sudo useradd -m -s /bin/bash -G sudo "$newuser" 2>/dev/null \
    || { toast warn "User '$newuser' may already exist."; press_enter; return; }
  echo "$newuser:$newpass" | sudo chpasswd
  sudo passwd --expire "$newuser" 2>/dev/null || true
  toast ok "User '${newuser}' created — password expires on first login."
  press_enter
}

# ─── module: full prep ───────────────────────────────────────────
module_full_run() {
  section_banner "FULL PREP"
  glass_card "  Full Prep Sequence" \
    "Runs all modules in order:" \
    "  1  System Update" \
    "  2  Security Hardening" \
    "  3  Privacy Wipe" \
    "  4  Beautify Desktop"
  confirm "Run full prep sequence now?" || { toast info "Cancelled."; press_enter; return; }
  module_system_update
  module_security_harden
  module_privacy_wipe
  module_beautify
  section_banner "DONE"
  echo ""
  echo -e "  ${C_GREEN}${C_BOLD}"
  typewrite "  ✦  This HP is fully prepped and ready for its new owner.  ✦" 0.02
  echo -e "${C_RESET}"
  echo ""
  hrule "="
  press_enter
}

# ─── main menu ───────────────────────────────────────────────────
main_menu() {
  check_deps
  while true; do
    draw_main_banner
    local pad="  "
    echo -e "${pad}${C_BOLD}${C_WHITE}  Select a module:${C_RESET}"
    echo ""
    echo -e "${pad}${BG_CARD}                                                        ${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_GREEN}${C_BOLD}[1]${C_RESET}${BG_CARD}  ${C_WHITE}System Info         ${C_GRAY}specs · vulns · mitigations     ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_CYAN}${C_BOLD}[2]${C_RESET}${BG_CARD}  ${C_WHITE}System Update       ${C_GRAY}apt full-upgrade + firmware     ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_PURPLE}${C_BOLD}[3]${C_RESET}${BG_CARD}  ${C_WHITE}Security Hardening  ${C_GRAY}UFW · ClamAV · Meltdown audit   ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_YELLOW}${C_BOLD}[4]${C_RESET}${BG_CARD}  ${C_WHITE}Privacy Wipe        ${C_GRAY}history · SSH · browser · env   ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_PINK}${C_BOLD}[5]${C_RESET}${BG_CARD}  ${C_WHITE}Beautify Desktop    ${C_GRAY}Xfce/GNOME auto-detect · Papirus${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_SILVER}${C_BOLD}[6]${C_RESET}${BG_CARD}  ${C_WHITE}Create Buyer User   ${C_GRAY}new account · force pw change   ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}                                                        ${C_RESET}"
    echo ""
    echo -e "${pad}  ${C_ORANGE}${C_BOLD}[A]${C_RESET}  ${C_BOLD}${C_WHITE}FULL PREP${C_RESET} — Run All Modules  ${C_DIM}← recommended${C_RESET}"
    echo ""
    echo -e "${pad}  ${C_DIM}[Q]  Quit${C_RESET}"
    echo ""
    hrule "-"
    echo ""
    echo -ne "  ${C_GOLD}◆${C_RESET}  ${C_BOLD}Choice:${C_RESET}  "
    read -r choice
    case "${choice,,}" in
      1) module_sysinfo ;;
      2) module_system_update ;;
      3) module_security_harden ;;
      4) module_privacy_wipe ;;
      5) module_beautify ;;
      6) module_new_user ;;
      a) module_full_run ;;
      q)
        clear_screen
        echo ""
        if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
          figlet -f banner3 "Goodbye!" 2>/dev/null | lolcat || \
            figlet -f small "Goodbye!" | lolcat
        else
          echo -e "  ${C_CYAN}${C_BOLD}Goodbye!${C_RESET}"
        fi
        echo ""
        echo -e "  ${C_DIM}VibeCodingLabs · Phoenix, AZ${C_RESET}"
        echo ""
        show_cursor
        exit 0
        ;;
      *)
        toast warn "Invalid option — press 1-6, A, or Q."
        sleep 1
        ;;
    esac
  done
}

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[1;33m  Note: Some modules require sudo — you will be prompted as needed.\033[0m"
  sleep 1
fi

main_menu
