#!/usr/bin/env bash
# ============================================================
# HP Ubuntu Prep Kit — by VibeCodingLabs
# Interactive CLI tool to prep Ubuntu laptops for resale
# ============================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Dependency check ─────────────────────────────────────────
check_deps() {
  local missing=()
  for cmd in figlet lolcat toilet; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Installing display tools: ${missing[*]}${RESET}"
    sudo apt-get install -y figlet lolcat toilet 2>/dev/null || true
  fi
}

# ── Banners ──────────────────────────────────────────────────
banner_main() {
  clear
  if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
    figlet -f big "HP  PREP  KIT" | lolcat
    echo ""
    toilet -f future "  VibeCodingLabs" | lolcat
  else
    echo -e "${CYAN}"
    cat << 'ASCII'
  ██╗  ██╗██████╗     ██████╗ ██████╗ ███████╗██████╗ 
  ██║  ██║██╔══██╗    ██╔══██╗██╔══██╗██╔════╝██╔══██╗
  ███████║██████╔╝    ██████╔╝██████╔╝█████╗  ██████╔╝
  ██╔══██║██╔═══╝     ██╔═══╝ ██╔══██╗██╔══╝  ██╔═══╝ 
  ██║  ██║██║         ██║     ██║  ██║███████╗██║     
  ╚═╝  ╚═╝╚═╝         ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝     
ASCII
    echo -e "${RESET}"
    echo -e "${MAGENTA}        ★  VibeCodingLabs  ★  Ubuntu Laptop Prep Kit${RESET}"
  fi
  echo ""
  echo -e "${DIM}────────────────────────────────────────────────────────────${RESET}"
  echo -e "${WHITE}  Prep your HP Ubuntu laptop for resale — secure, clean, beautiful${RESET}"
  echo -e "${DIM}────────────────────────────────────────────────────────────${RESET}"
  echo ""
}

banner_section() {
  local title="$1"
  echo ""
  echo -e "${DIM}────────────────────────────────────────────────────${RESET}"
  if command -v figlet &>/dev/null; then
    figlet -f small "$title" | lolcat 2>/dev/null || echo -e "${CYAN}[ $title ]${RESET}"
  else
    echo -e "${CYAN}${BOLD}  ▶  $title${RESET}"
  fi
  echo -e "${DIM}────────────────────────────────────────────────────${RESET}"
  echo ""
}

# ── Helpers ──────────────────────────────────────────────────
log_ok()   { echo -e "  ${GREEN}✔${RESET}  $1"; }
log_warn() { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
log_info() { echo -e "  ${CYAN}→${RESET}  $1"; }
log_err()  { echo -e "  ${RED}✘${RESET}  $1"; }

confirm() {
  local msg="$1"
  echo -ne "  ${YELLOW}?${RESET}  ${msg} ${DIM}[y/N]${RESET} "
  read -r ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

press_enter() {
  echo ""
  echo -ne "  ${DIM}Press ENTER to continue...${RESET}"
  read -r
}

# ── Modules ──────────────────────────────────────────────────

module_system_update() {
  banner_section "UPDATE"
  log_info "Running full system update & upgrade..."
  sudo apt-get update -qq
  sudo apt-get full-upgrade -y
  sudo apt-get autoremove -y
  sudo apt-get autoclean -y
  log_ok "System fully updated."

  log_info "Updating firmware (fwupd)..."
  if command -v fwupdmgr &>/dev/null; then
    sudo fwupdmgr refresh --force 2>/dev/null || true
    sudo fwupdmgr update -y 2>/dev/null || log_warn "No firmware updates or BIOS update skipped."
    log_ok "Firmware update complete."
  else
    sudo apt-get install -y fwupd 2>/dev/null
    sudo fwupdmgr update -y 2>/dev/null || true
  fi
  press_enter
}

module_security_harden() {
  banner_section "SECURITY"
  log_info "Enabling UFW firewall..."
  sudo ufw --force enable
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  log_ok "Firewall enabled (deny incoming, allow outgoing)."

  log_info "Setting up automatic security updates..."
  sudo apt-get install -y unattended-upgrades apt-listchanges -qq
  sudo dpkg-reconfigure --priority=low unattended-upgrades
  log_ok "Auto security updates configured."

  log_info "Locking root account..."
  sudo passwd -l root 2>/dev/null && log_ok "Root account locked." || log_warn "Could not lock root."

  log_info "Installing ClamAV antivirus..."
  sudo apt-get install -y clamav clamav-daemon -qq
  sudo freshclam 2>/dev/null || true
  log_ok "ClamAV installed & virus definitions updated."

  log_info "Checking Spectre/Meltdown mitigations..."
  if ! command -v spectre-meltdown-checker &>/dev/null; then
    sudo apt-get install -y spectre-meltdown-checker -qq 2>/dev/null || true
  fi
  if command -v spectre-meltdown-checker &>/dev/null; then
    sudo spectre-meltdown-checker --quiet 2>/dev/null \
      || log_warn "Some CVE mitigations may not be fully active — review output above."
    log_ok "Spectre/Meltdown check complete."
  else
    log_warn "spectre-meltdown-checker unavailable — check /sys/devices/system/cpu/vulnerabilities/ manually."
  fi
  press_enter
}

module_privacy_wipe() {
  banner_section "PRIVACY"
  log_warn "This removes YOUR personal data. The OS stays intact."
  confirm "Proceed with privacy wipe?" || { log_info "Skipped."; press_enter; return; }

  log_info "Clearing bash/zsh history..."
  history -c 2>/dev/null || true
  rm -f ~/.bash_history ~/.zsh_history ~/.local/share/recently-used.xbel
  log_ok "Shell history cleared."

  if confirm "Remove ~/.ssh directory? (removes all SSH keys)"; then
    rm -rf ~/.ssh && log_ok "SSH keys removed."
  fi

  if confirm "Remove ~/.gnupg directory? (removes all GPG keys)"; then
    rm -rf ~/.gnupg && log_ok "GPG keys removed."
  fi

  log_info "Clearing Firefox data..."
  rm -rf ~/.mozilla/firefox/*.default*/sessionstore* \
         ~/.mozilla/firefox/*.default*/cookies.sqlite \
         ~/.mozilla/firefox/*.default*/places.sqlite \
         ~/.mozilla/firefox/*.default*/formhistory.sqlite 2>/dev/null || true
  log_ok "Firefox data cleared."

  log_info "Clearing Chrome/Chromium data..."
  rm -rf ~/.config/google-chrome/Default/Cookies \
         ~/.config/google-chrome/Default/History \
         ~/.config/chromium/Default/Cookies \
         ~/.config/chromium/Default/History 2>/dev/null || true
  log_ok "Chrome/Chromium data cleared."

  log_info "Clearing thumbnail cache & trash..."
  rm -rf ~/.cache/thumbnails/* \
         ~/.local/share/Trash/files/* \
         ~/.local/share/Trash/info/* 2>/dev/null || true
  log_ok "Cache and trash cleared."

  log_info "Scanning for .env / secret files (depth 3)..."
  local found=0
  while IFS= read -r -d '' f; do
    log_warn "Found secret file: $f"
    confirm "Delete $f?" && rm -f "$f" && log_ok "Deleted."
    found=1
  done < <(find ~ -maxdepth 3 \( -name "*.env" -o -name ".env.*" -o -name "*.pem" -o -name "id_rsa" \) -print0 2>/dev/null)
  [[ $found -eq 0 ]] && log_ok "No obvious secret files found."

  press_enter
}

module_beautify() {
  banner_section "BEAUTIFY"
  log_info "Installing GNOME Tweaks and extensions support..."
  sudo apt-get install -y gnome-tweaks gnome-shell-extensions -qq
  log_ok "GNOME Tweaks installed."

  log_info "Adding Papirus icon PPA and installing..."
  sudo add-apt-repository -y ppa:papirus/papirus 2>/dev/null || true
  sudo apt-get update -qq
  sudo apt-get install -y papirus-icon-theme -qq
  log_ok "Papirus icons installed."

  log_info "Installing extra Ubuntu wallpapers..."
  sudo apt-get install -y gnome-backgrounds ubuntu-wallpapers* -qq 2>/dev/null || true
  log_ok "Wallpaper packs installed."

  log_info "Applying Papirus icon theme..."
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus' 2>/dev/null \
    && log_ok "Papirus icons applied." \
    || log_warn "Set manually via GNOME Tweaks → Appearance."

  log_info "Enabling dark mode..."
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null \
    && log_ok "Dark mode enabled." \
    || log_warn "Dark mode not available on this GNOME version."

  log_info "Setting default wallpaper..."
  local wp
  wp=$(find /usr/share/backgrounds -name "*.jpg" -o -name "*.png" 2>/dev/null | shuf | head -1)
  if [[ -n "${wp:-}" ]]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$wp" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp" 2>/dev/null || true
    log_ok "Wallpaper set: $wp"
  fi

  log_info "Showing battery percentage in status bar..."
  gsettings set org.gnome.desktop.interface show-battery-percentage true 2>/dev/null || true

  log_info "Setting clean font (Cantarell 11)..."
  gsettings set org.gnome.desktop.interface font-name 'Cantarell 11' 2>/dev/null || true
  log_ok "Desktop beautification complete."

  press_enter
}

module_new_user() {
  banner_section "NEW USER"
  log_info "Create a clean buyer account."
  echo ""
  if confirm "Create a new user for the buyer?"; then
    echo -ne "  Enter username: "
    read -r newuser
    echo -ne "  Enter password: "
    read -rs newpass
    echo ""
    sudo useradd -m -s /bin/bash -G sudo "$newuser" 2>/dev/null \
      || { log_warn "User '$newuser' may already exist."; press_enter; return; }
    echo "$newuser:$newpass" | sudo chpasswd
    sudo passwd --expire "$newuser" 2>/dev/null || true
    log_ok "User '$newuser' created. Password expires on first login — buyer sets their own."
  else
    log_info "Skipped."
  fi
  press_enter
}

module_sysinfo() {
  banner_section "SYS INFO"
  echo -e "${BOLD}  CPU${RESET}"
  lscpu | grep -E "Model name|Socket|Thread|Core|CPU MHz|Virtualization" | sed 's/^/    /'
  echo ""
  echo -e "${BOLD}  Memory${RESET}"
  free -h | sed 's/^/    /'
  echo ""
  echo -e "${BOLD}  Storage${RESET}"
  df -h --output=source,size,used,avail,pcent,target 2>/dev/null | grep -v tmpfs | sed 's/^/    /'
  echo ""
  echo -e "${BOLD}  GPU${RESET}"
  lspci 2>/dev/null | grep -iE "vga|3d|display" | sed 's/^/    /' || echo "    (none detected via lspci)"
  echo ""
  echo -e "${BOLD}  CPU Vulnerability Flags (hardware-level)${RESET}"
  grep -m1 "^bugs" /proc/cpuinfo | sed 's/^/    /' || echo "    (none)"
  echo ""
  if [[ -d /sys/devices/system/cpu/vulnerabilities ]]; then
    echo -e "${BOLD}  Kernel Mitigation Status${RESET}"
    grep . /sys/devices/system/cpu/vulnerabilities/* 2>/dev/null \
      | sed 's|.*/||; s/:/:\t/; s/^/    /'
    echo ""
  fi
  echo -e "${BOLD}  OS${RESET}"
  lsb_release -a 2>/dev/null | grep -v "^No LSB" | sed 's/^/    /'
  echo ""
  echo -e "${BOLD}  Kernel${RESET}"
  uname -r | sed 's/^/    /'
  press_enter
}

module_full_run() {
  banner_section "FULL PREP"
  log_warn "Runs ALL modules: Update → Security → Privacy → Beautify"
  confirm "Run full prep sequence?" || { log_info "Cancelled."; press_enter; return; }
  module_system_update
  module_security_harden
  module_privacy_wipe
  module_beautify
  banner_section "DONE"
  echo -e "  ${GREEN}${BOLD}✔  HP Prep Kit complete! This machine is ready for its new owner.${RESET}"
  echo ""
  press_enter
}

# ── Main Menu ────────────────────────────────────────────────
main_menu() {
  check_deps
  while true; do
    banner_main
    echo -e "  ${BOLD}Select a module:${RESET}"
    echo ""
    echo -e "  ${GREEN}[1]${RESET}  System Info          ${DIM}specs, CPU bugs, disk, RAM, mitigations${RESET}"
    echo -e "  ${CYAN}[2]${RESET}  System Update        ${DIM}apt full-upgrade + firmware (fwupd)${RESET}"
    echo -e "  ${MAGENTA}[3]${RESET}  Security Hardening   ${DIM}UFW, auto-updates, ClamAV, Meltdown check${RESET}"
    echo -e "  ${YELLOW}[4]${RESET}  Privacy Wipe         ${DIM}history, SSH, browser data, .env files${RESET}"
    echo -e "  ${BLUE}[5]${RESET}  Beautify Desktop     ${DIM}Papirus icons, wallpapers, dark mode${RESET}"
    echo -e "  ${WHITE}[6]${RESET}  Create Buyer Account ${DIM}new user, force password change on login${RESET}"
    echo ""
    echo -e "  ${RED}[A]${RESET}  ${BOLD}FULL PREP — Run All Modules${RESET}  ${DIM}← recommended${RESET}"
    echo ""
    echo -e "  ${DIM}[Q]  Quit${RESET}"
    echo ""
    echo -ne "  ${BOLD}Choice:${RESET} "
    read -r choice
    case "${choice,,}" in
      1) module_sysinfo ;;
      2) module_system_update ;;
      3) module_security_harden ;;
      4) module_privacy_wipe ;;
      5) module_beautify ;;
      6) module_new_user ;;
      a) module_full_run ;;
      q) echo -e "\n  ${DIM}Goodbye — VibeCodingLabs${RESET}\n"; exit 0 ;;
      *) echo -e "\n  ${RED}Invalid option.${RESET}"; sleep 1 ;;
    esac
  done
}

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[1;33mNote: Some modules require sudo — you may be prompted for your password.\033[0m"
fi

main_menu
