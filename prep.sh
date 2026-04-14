#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          HP PREP KIT  v2  —  VibeCodingLabs                ║
# ║     macOS-inspired TUI  ·  Animated  ·  Beautiful          ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

export TERM="${TERM:-xterm-256color}"
COLS=$(tput cols 2>/dev/null || echo 80)

C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_ITALIC='\033[3m'
C_UNDER='\033[4m'

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
C_ROSE='\033[38;5;204m'
C_RED='\033[38;5;196m'
C_ORANGE='\033[38;5;214m'
C_YELLOW='\033[38;5;226m'
C_GOLD='\033[38;5;220m'

BG_DARK='\033[48;5;234m'
BG_CARD='\033[48;5;236m'
BG_ACCENT='\033[48;5;17m'
BG_GREEN='\033[48;5;22m'
BG_RED='\033[48;5;52m'

hide_cursor()  { tput civis 2>/dev/null || true; }
show_cursor()  { tput cnorm 2>/dev/null || true; }
save_pos()     { tput sc   2>/dev/null || true; }
restore_pos()  { tput rc   2>/dev/null || true; }
clear_line()   { tput el   2>/dev/null || true; }
move_up()      { tput cuu "${1:-1}" 2>/dev/null || true; }
clear_screen() { tput clear 2>/dev/null || clear; }

trap 'show_cursor; echo -e "${C_RESET}"' EXIT INT TERM

SPIN_BRAILLE=('\u280b' '\u2819' '\u2839' '\u2838' '\u283c' '\u2834' '\u2826' '\u2827' '\u2807' '\u280f')
SPIN_CIRCLE=('\u25d0' '\u25d3' '\u25d1' '\u25d2')

spin_run() {
  local msg="$1"; shift
  local frames=("${SPIN_BRAILLE[@]}")
  local colors=("$C_BLUE" "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_GREEN" "$C_LIME" "$C_YELLOW" "$C_GOLD" "$C_ORANGE" "$C_PINK" "$C_PURPLE" "$C_VIOLET")
  local i=0 ci=0 pid

  hide_cursor
  ("$@") &>/tmp/hp_prep_spin_out 2>&1 &
  pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    local frame="${frames[$((i % ${#frames[@]}))]}"
    local color="${colors[$((ci % ${#colors[@]}))]}"
    printf "\r  ${color}${frame}${C_RESET}  ${C_WHITE}${msg}${C_RESET}${C_GRAY}...${C_RESET}"
    sleep 0.08
    i=$((i+1))
    [[ $((i % 3)) -eq 0 ]] && ci=$((ci+1))
  done

  wait "$pid"
  local exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    printf "\r  ${C_GREEN}\u2713${C_RESET}  ${C_WHITE}${msg}${C_RESET}$(printf '%*s' 20 '')\n"
  else
    printf "\r  ${C_RED}\u2717${C_RESET}  ${C_WHITE}${msg}${C_RESET} ${C_DIM}(exit ${exit_code})${C_RESET}\n"
    head -5 /tmp/hp_prep_spin_out 2>/dev/null | sed 's/^/      /' || true
  fi
  show_cursor
  return $exit_code
}

progress_bar() {
  local pct="${1:-0}" label="${2:-}" width=40
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  for ((j=0; j<filled; j++)); do
    local ratio=$(( j * 100 / width ))
    if   (( ratio < 33 )); then bar+="${C_BLUE}\u2588${C_RESET}"
    elif (( ratio < 66 )); then bar+="${C_CYAN}\u2588${C_RESET}"
    else                        bar+="${C_MINT}\u2588${C_RESET}"
    fi
  done
  for ((j=0; j<empty; j++)); do bar+="${C_DARKGRAY}\u2591${C_RESET}"; done
  printf "  [%s] ${C_SILVER}%3d%%${C_RESET}  ${C_DIM}%s${C_RESET}\n" "$bar" "$pct" "$label"
}

animated_progress_bar() {
  local label="${1:-Working}" secs="${2:-2}"
  local steps=40
  hide_cursor
  for ((i=0; i<=steps; i++)); do
    local pct=$(( i * 100 / steps ))
    printf "\r"
    progress_bar "$pct" "$label"
    sleep "$(echo "scale=4; $secs/$steps" | bc 2>/dev/null || echo 0.05)"
  done
  show_cursor
  echo ""
}

typewrite() {
  local text="$1" delay="${2:-0.02}"
  local i
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:$i:1}"
    sleep "$delay"
  done
  echo ""
}

fadein_line() {
  local text="$1"
  printf "${C_DARKGRAY}%s${C_RESET}\r" "$text"; sleep 0.05
  printf "${C_GRAY}%s${C_RESET}\r"     "$text"; sleep 0.05
  printf "${C_SILVER}%s${C_RESET}\r"   "$text"; sleep 0.05
  printf "${C_WHITE}%s${C_RESET}\n"    "$text"
}

hrule() {
  local char="${1:\u2500}" width=$(( COLS > 72 ? 72 : COLS ))
  local line=""
  local colors=("$C_BLUE" "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_GREEN" "$C_LIME" "$C_YELLOW" "$C_GOLD" "$C_ORANGE" "$C_PINK" "$C_PURPLE" "$C_VIOLET" "$C_BLUE")
  local nc=${#colors[@]}
  for ((i=0; i<width; i++)); do
    local ci=$(( i * nc / width ))
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
  local indent=$(printf '%*s' "$pad" '')

  echo ""
  echo -e "${indent}${C_DARKGRAY}\u256d$(printf '\u2500%.0s' $(seq 1 $((w-2))))\u256e${C_RESET}"
  echo -e "${indent}${C_DARKGRAY}\u2502${C_RESET}${BG_CARD}  ${C_CYAN}${C_BOLD}${title}$(printf '%*s' $((w-4-${#title})) '')${C_RESET}${C_DARKGRAY}  \u2502${C_RESET}"
  echo -e "${indent}${C_DARKGRAY}\u251c$(printf '\u2500%.0s' $(seq 1 $((w-2))))\u2524${C_RESET}"
  for line in "${body[@]}"; do
    local stripped; stripped=$(echo -e "$line" | sed 's/\x1B\[[0-9;]*m//g')
    local visible_len=${#stripped}
    local padding=$(( w - 4 - visible_len ))
    [[ $padding -lt 0 ]] && padding=0
    echo -e "${indent}${C_DARKGRAY}\u2502${C_RESET}${BG_CARD}  ${line}$(printf '%*s' "$padding" '')${C_RESET}${C_DARKGRAY}  \u2502${C_RESET}"
  done
  echo -e "${indent}${C_DARKGRAY}\u2570$(printf '\u2500%.0s' $(seq 1 $((w-2))))\u256f${C_RESET}"
  echo ""
}

toast() {
  local type="$1" msg="$2"
  case "$type" in
    ok)   local icon="\u2713" color="$C_GREEN"  label="Done"    ;;
    warn) local icon="\u26a0" color="$C_YELLOW" label="Warning" ;;
    err)  local icon="\u2717" color="$C_RED"    label="Error"   ;;
    info) local icon="\u2139" color="$C_CYAN"   label="Info"    ;;
    *)    local icon="\u00b7" color="$C_WHITE"  label=""        ;;
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
  echo -ne "  ${C_GOLD}\u25c6${C_RESET}  ${C_WHITE}${msg}${C_RESET} ${C_DIM}[y/N]${C_RESET}  "
  read -r ans
  [[ "${ans,,}" == "y" ]]
}

press_enter() {
  echo ""
  hrule "\u00b7"
  echo -ne "  ${C_DIM}Press ENTER to return to menu...${C_RESET}"
  read -r
}

draw_main_banner() {
  clear_screen
  if command -v figlet &>/dev/null; then
    hide_cursor
    local banner_colors=("$C_CYAN" "$C_TEAL" "$C_MINT" "$C_GREEN" "$C_CYAN")
    for bc in "${banner_colors[@]}"; do
      clear_screen
      echo ""
      figlet -f big "HP  PREP  KIT" | sed "s/^/  /" | while IFS= read -r line; do
        echo -e "${bc}${line}${C_RESET}"
      done
      if command -v toilet &>/dev/null; then
        toilet -f future "  VibeCodingLabs" | while IFS= read -r line; do
          echo -e "${C_PURPLE}${line}${C_RESET}"
        done
      fi
      sleep 0.1
    done
    clear_screen
    echo ""
    if command -v lolcat &>/dev/null; then
      figlet -f big "HP  PREP  KIT" | sed "s/^/  /" | lolcat -a -d 1 -s 50 2>/dev/null || \
        figlet -f big "HP  PREP  KIT" | sed "s/^/  /" | lolcat
    else
      figlet -f big "HP  PREP  KIT" | sed "s/^/  /" | while IFS= read -r line; do
        echo -e "${C_CYAN}${line}${C_RESET}"
      done
    fi
    echo ""
    if command -v toilet &>/dev/null && command -v lolcat &>/dev/null; then
      toilet -f future "  \u2726  VibeCodingLabs  \u2726" | lolcat
    else
      echo -e "${C_PURPLE}${C_BOLD}  \u2726  VibeCodingLabs  \u2726${C_RESET}"
    fi
    show_cursor
  else
    echo ""
    hide_cursor
    for bc in "$C_CYAN" "$C_TEAL" "$C_MINT" "$C_CYAN"; do
      clear_screen
      echo ""
      echo -e "${bc}${C_BOLD}"
      cat << 'ASCIIART'
  \u2588\u2588\u2557  \u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2588\u2588\u2557     \u2588\u2588\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2588\u2588\u2557
  \u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557    \u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2550\u2550\u255d\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557
  \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255d    \u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255d\u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255d\u2588\u2588\u2588\u2588\u2588\u2557  \u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255d
  \u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2551\u2588\u2588\u2554\u2550\u2550\u2550\u255d     \u2588\u2588\u2554\u2550\u2550\u2550\u255d \u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u255d  \u2588\u2588\u2554\u2550\u2550\u2550\u255d
  \u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2551         \u2588\u2588\u2551     \u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2551
  \u255a\u2550\u255d  \u255a\u2550\u255d\u255a\u2550\u255d         \u255a\u2550\u255d     \u255a\u2550\u255d  \u255a\u2550\u255d\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u255d\u255a\u2550\u255d
ASCIIART
      echo -e "${C_RESET}"
      sleep 0.1
    done
    show_cursor
    echo -e "${C_PURPLE}${C_BOLD}  \u2726  VibeCodingLabs  \u2726  Ubuntu Laptop Prep Kit${C_RESET}"
  fi
  echo ""
  hrule "\u2500"
  echo ""
  printf "  "
  typewrite "${C_SILVER}Ubuntu Laptop Prep Kit  \u00b7  Secure  \u00b7  Beautiful  \u00b7  Ready to Sell${C_RESET}" 0.015
  echo ""
  hrule "\u2500"
  echo ""
}

section_banner() {
  local title="$1" icon="${2:\u25b6}"
  echo ""
  hrule "\u254c"
  echo ""
  if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
    figlet -f small "  $title" | lolcat -a -d 1 -s 80 2>/dev/null || \
      figlet -f small "  $title" | lolcat
  elif command -v figlet &>/dev/null; then
    figlet -f small "  $title" | while IFS= read -r line; do
      echo -e "${C_CYAN}${line}${C_RESET}"
    done
  else
    echo -e "  ${C_CYAN}${C_BOLD}${icon}  ${title}${C_RESET}"
  fi
  echo ""
  hrule "\u254c"
  echo ""
}

module_sysinfo() {
  section_banner "SYS INFO"
  local cpu_model cpu_cores mem_total disk_info os_ver kernel
  cpu_model=$(lscpu 2>/dev/null | awk -F: '/Model name/{gsub(/^[ \t]+/,"",$2); print $2; exit}')
  cpu_cores=$(nproc 2>/dev/null || echo "?")
  mem_total=$(free -h 2>/dev/null | awk '/^Mem:/{print $2}')
  disk_info=$(df -h / 2>/dev/null | awk 'NR==2{print $3 " used / " $2 " total (" $5 ")"}')
  os_ver=$(lsb_release -sd 2>/dev/null | tr -d '"')
  kernel=$(uname -r 2>/dev/null)

  glass_card "  Hardware Overview" \
    "${C_CYAN}CPU   ${C_RESET}${C_WHITE}${cpu_model}${C_RESET}" \
    "${C_CYAN}Cores ${C_RESET}${C_WHITE}${cpu_cores} logical processors${C_RESET}" \
    "${C_CYAN}RAM   ${C_RESET}${C_WHITE}${mem_total} total${C_RESET}" \
    "${C_CYAN}Disk  ${C_RESET}${C_WHITE}${disk_info}${C_RESET}" \
    "${C_CYAN}OS    ${C_RESET}${C_WHITE}${os_ver}${C_RESET}" \
    "${C_CYAN}Kern  ${C_RESET}${C_WHITE}${kernel}${C_RESET}"

  echo -e "  ${C_GOLD}${C_BOLD}  CPU Vulnerabilities${C_RESET}"
  echo ""
  if [[ -d /sys/devices/system/cpu/vulnerabilities ]]; then
    for f in /sys/devices/system/cpu/vulnerabilities/*; do
      local vuln_name status
      vuln_name=$(basename "$f")
      status=$(cat "$f" 2>/dev/null || echo "unknown")
      if echo "$status" | grep -qi "not affected\|mitigated"; then
        echo -e "  ${C_GREEN}\u2713${C_RESET}  ${C_DIM}${vuln_name}${C_RESET}  ${C_GREEN}${status}${C_RESET}"
      elif echo "$status" | grep -qi "vulnerable"; then
        echo -e "  ${C_RED}\u2717${C_RESET}  ${C_WHITE}${vuln_name}${C_RESET}  ${C_RED}${C_BOLD}${status}${C_RESET}"
      else
        echo -e "  ${C_YELLOW}\u25cc${C_RESET}  ${C_DIM}${vuln_name}${C_RESET}  ${C_YELLOW}${status}${C_RESET}"
      fi
    done
  else
    local bugs
    bugs=$(grep -m1 "^bugs" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs)
    [[ -n "$bugs" ]] && echo -e "  ${C_YELLOW}\u26a0${C_RESET}  ${C_WHITE}Hardware flags: ${C_ORANGE}${bugs}${C_RESET}" \
      || toast ok "No vulnerability flags detected."
  fi

  echo ""
  echo -e "  ${C_GOLD}${C_BOLD}  GPU${C_RESET}"
  echo ""
  lspci 2>/dev/null | grep -iE "vga|3d|display" | while IFS= read -r line; do
    echo -e "  ${C_VIOLET}\u25aa${C_RESET}  ${C_SILVER}${line}${C_RESET}"
  done || echo -e "  ${C_DIM}  No GPU detected via lspci${C_RESET}"

  press_enter
}

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
    toast warn "No firmware updates available or BIOS update skipped."
  echo ""
  toast ok "System is fully up to date."
  press_enter
}

module_security_harden() {
  section_banner "SECURITY"
  toast info "Configuring firewall..."
  spin_run "Enabling UFW"                  sudo ufw --force enable
  spin_run "Setting default deny inbound"  sudo ufw default deny incoming
  spin_run "Setting default allow outbound" sudo ufw default allow outgoing
  toast ok "Firewall active."
  toast info "Configuring automatic security updates..."
  spin_run "Installing unattended-upgrades" sudo apt-get install -y unattended-upgrades apt-listchanges -qq
  sudo dpkg-reconfigure --priority=low unattended-upgrades
  toast ok "Auto security updates enabled."
  spin_run "Locking root account" sudo passwd -l root || toast warn "Could not lock root."
  toast info "Installing ClamAV antivirus..."
  spin_run "Installing ClamAV"         sudo apt-get install -y clamav clamav-daemon -qq
  spin_run "Updating virus definitions" sudo freshclam || toast warn "freshclam failed."
  toast ok "ClamAV installed and updated."
  toast info "Auditing Spectre/Meltdown mitigations..."
  if ! command -v spectre-meltdown-checker &>/dev/null; then
    spin_run "Installing spectre-meltdown-checker" \
      sudo apt-get install -y spectre-meltdown-checker -qq || true
  fi
  echo ""
  if command -v spectre-meltdown-checker &>/dev/null; then
    sudo spectre-meltdown-checker --quiet 2>/dev/null \
      || toast warn "Some mitigations incomplete."
    toast ok "Spectre/Meltdown audit complete."
  else
    toast warn "spectre-meltdown-checker not in repos. Check /sys/devices/system/cpu/vulnerabilities/ manually."
  fi
  press_enter
}

module_privacy_wipe() {
  section_banner "PRIVACY"
  glass_card "  Privacy Wipe" \
    "${C_YELLOW}This removes your personal data.${C_RESET}" \
    "${C_DIM}The OS and installed apps stay intact.${C_RESET}" \
    "" \
    "${C_DIM}Covers: shell history, SSH/GPG keys,${C_RESET}" \
    "${C_DIM}browser data, .env files, trash, cache.${C_RESET}"
  confirm "Proceed with privacy wipe?" || { toast info "Skipped."; press_enter; return; }
  echo ""
  spin_run "Clearing shell history" bash -c "history -c 2>/dev/null; rm -f ~/.bash_history ~/.zsh_history ~/.local/share/recently-used.xbel"
  if confirm "Remove ~/.ssh (SSH keys)?"; then
    spin_run "Wiping SSH keys" rm -rf ~/.ssh
  fi
  if confirm "Remove ~/.gnupg (GPG keys)?"; then
    spin_run "Wiping GPG keys" rm -rf ~/.gnupg
  fi
  spin_run "Clearing Firefox data"  bash -c "rm -rf ~/.mozilla/firefox/*.default*/sessionstore* ~/.mozilla/firefox/*.default*/cookies.sqlite ~/.mozilla/firefox/*.default*/places.sqlite ~/.mozilla/firefox/*.default*/formhistory.sqlite 2>/dev/null || true"
  spin_run "Clearing Chrome data"   bash -c "rm -rf ~/.config/google-chrome/Default/Cookies ~/.config/google-chrome/Default/History ~/.config/chromium/Default/Cookies ~/.config/chromium/Default/History 2>/dev/null || true"
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

module_beautify() {
  section_banner "BEAUTIFY"
  spin_run "Installing GNOME Tweaks"       sudo apt-get install -y gnome-tweaks gnome-shell-extensions -qq
  spin_run "Adding Papirus PPA"            sudo add-apt-repository -y ppa:papirus/papirus || true
  spin_run "Refreshing package index"      sudo apt-get update -qq
  spin_run "Installing Papirus icons"      sudo apt-get install -y papirus-icon-theme -qq
  spin_run "Installing wallpaper packs"    bash -c "sudo apt-get install -y gnome-backgrounds ubuntu-wallpapers* -qq 2>/dev/null || true"
  toast info "Applying desktop settings..."
  spin_run "Setting Papirus icons"    gsettings set org.gnome.desktop.interface icon-theme 'Papirus' || true
  spin_run "Enabling dark mode"       gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
  spin_run "Showing battery %"        gsettings set org.gnome.desktop.interface show-battery-percentage true || true
  spin_run "Setting font"             gsettings set org.gnome.desktop.interface font-name 'Cantarell 11' || true
  toast info "Setting wallpaper..."
  local wp
  wp=$(find /usr/share/backgrounds -name "*.jpg" -o -name "*.png" 2>/dev/null | shuf | head -1)
  if [[ -n "${wp:-}" ]]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$wp" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp" 2>/dev/null || true
    toast ok "Wallpaper: $wp"
  else
    toast warn "No wallpapers found."
  fi
  animated_progress_bar "Applying theme" 2
  toast ok "Desktop beautification complete."
  press_enter
}

module_new_user() {
  section_banner "NEW USER"
  glass_card "  Create Buyer Account" \
    "${C_DIM}Creates a clean sudo user for the new owner.${C_RESET}" \
    "${C_DIM}Password expires on first login so they${C_RESET}" \
    "${C_DIM}can set their own on first boot.${C_RESET}"
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
  toast ok "User '${newuser}' created \u2014 password expires on first login."
  press_enter
}

module_full_run() {
  section_banner "FULL PREP"
  glass_card "  Full Prep Sequence" \
    "${C_DIM}Runs all modules in order:${C_RESET}" \
    "" \
    "  ${C_CYAN}1${C_RESET}  System Update" \
    "  ${C_CYAN}2${C_RESET}  Security Hardening" \
    "  ${C_CYAN}3${C_RESET}  Privacy Wipe" \
    "  ${C_CYAN}4${C_RESET}  Beautify Desktop"
  confirm "Run full prep sequence now?" || { toast info "Cancelled."; press_enter; return; }
  module_system_update
  module_security_harden
  module_privacy_wipe
  module_beautify
  section_banner "COMPLETE"
  echo ""
  echo -e "  ${C_GREEN}${C_BOLD}"
  typewrite "  \u2726  This HP is fully prepped and ready for its new owner.  \u2726" 0.02
  echo -e "${C_RESET}"
  echo ""
  hrule "\u2550"
  press_enter
}

main_menu() {
  check_deps
  while true; do
    draw_main_banner
    local pad="  "
    echo -e "${pad}${C_BOLD}${C_WHITE}  Select a module:${C_RESET}"
    echo ""
    echo -e "${pad}${BG_CARD}                                                    ${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_GREEN}${C_BOLD}[1]${C_RESET}${BG_CARD}  ${C_WHITE}System Info         ${C_GRAY}specs \u00b7 vulns \u00b7 mitigations  ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_CYAN}${C_BOLD}[2]${C_RESET}${BG_CARD}  ${C_WHITE}System Update       ${C_GRAY}apt full-upgrade + firmware   ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_PURPLE}${C_BOLD}[3]${C_RESET}${BG_CARD}  ${C_WHITE}Security Hardening  ${C_GRAY}UFW \u00b7 ClamAV \u00b7 Meltdown      ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_YELLOW}${C_BOLD}[4]${C_RESET}${BG_CARD}  ${C_WHITE}Privacy Wipe        ${C_GRAY}history \u00b7 SSH \u00b7 browser \u00b7 .env ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_PINK}${C_BOLD}[5]${C_RESET}${BG_CARD}  ${C_WHITE}Beautify Desktop    ${C_GRAY}Papirus \u00b7 wallpaper \u00b7 dark    ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}  ${C_SILVER}${C_BOLD}[6]${C_RESET}${BG_CARD}  ${C_WHITE}Create Buyer User   ${C_GRAY}new account \u00b7 force pw change ${C_RESET}${BG_CARD}${C_RESET}"
    echo -e "${pad}${BG_CARD}                                                    ${C_RESET}"
    echo ""
    echo -e "${pad}  ${C_ORANGE}${C_BOLD}[A]${C_RESET}  ${C_BOLD}${C_WHITE}FULL PREP${C_RESET} \u2014 Run All Modules  ${C_DIM}\u2190 recommended${C_RESET}"
    echo ""
    echo -e "${pad}  ${C_DIM}[Q]  Quit${C_RESET}"
    echo ""
    hrule "\u2500"
    echo ""
    echo -ne "  ${C_GOLD}\u25c6${C_RESET}  ${C_BOLD}Choice:${C_RESET}  "
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
          figlet -f small "  Goodbye!" | lolcat
        else
          echo -e "  ${C_CYAN}${C_BOLD}Goodbye!${C_RESET}"
        fi
        echo ""
        echo -e "  ${C_DIM}VibeCodingLabs \u00b7 Phoenix, AZ${C_RESET}"
        echo ""
        show_cursor
        exit 0
        ;;
      *)
        toast warn "Invalid option \u2014 press 1-6, A, or Q."
        sleep 1
        ;;
    esac
  done
}

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[1;33m  Note: Some modules require sudo \u2014 you will be prompted as needed.\033[0m"
  sleep 1
fi

main_menu
