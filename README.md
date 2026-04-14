# HP Ubuntu Prep Kit v2

> **by VibeCodingLabs** — macOS-inspired interactive TUI for prepping Ubuntu laptops for resale.

[![bash](https://img.shields.io/badge/shell-bash-blue?style=flat-square)](https://www.gnu.org/software/bash/)
[![ubuntu](https://img.shields.io/badge/Ubuntu-24.04%2B-orange?style=flat-square&logo=ubuntu)](https://ubuntu.com)
[![license](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)

---

## What's New in v2

- **macOS-style UX** — frosted glass cards, gradient rules, toast notifications
- **Animated spinners** — braille/circle spinner with rainbow color cycling per operation
- **Animated progress bars** — gradient blue→cyan→green fill with percentage
- **Rotating logo** — banner color-cycles through cyan/teal/mint/green on startup
- **Typewriter effect** — taglines and completion messages animate letter by letter
- **Fade-in transitions** — section headers fade in with dim→silver→white steps
- **figlet + lolcat + toilet** — huge animated ASCII banners, auto-installed
- **Gradient horizontal rules** — dividers that shift colors across the terminal width
- **Glass card panels** — bordered info boxes for hardware overview and module descriptions

---

## Modules

| # | Module | What it does |
|---|--------|-------------|
| 1 | **System Info** | CPU, RAM, disk, GPU, per-vulnerability mitigation status |
| 2 | **System Update** | `apt full-upgrade` + `fwupdmgr` firmware with animated progress |
| 3 | **Security Hardening** | UFW, auto-updates, ClamAV, Spectre/Meltdown check |
| 4 | **Privacy Wipe** | Shell history, SSH/GPG, Firefox/Chrome, .env scanner |
| 5 | **Beautify Desktop** | Papirus icons, wallpapers, dark mode, battery % |
| 6 | **Create Buyer Account** | New user, forced password expire on first login |
| **A** | **Full Prep** | Runs all modules in sequence |

---

## Quick Start

```bash
git clone https://github.com/VibeCodingLabs/hp-prep-kit.git
cd hp-prep-kit
chmod +x prep.sh
./prep.sh
```

Auto-installs on first run: `figlet` · `lolcat` · `toilet` · `bc`

---

## Requirements

- Ubuntu 22.04+ / Debian 12+ with GNOME desktop
- `bash` 4.x+
- Terminal with 256-color support (GNOME Terminal, Kitty, Alacritty, WezTerm)

---

## OEM Install (Recommended)

For a 100% clean handoff, boot Ubuntu live USB → **"Install Ubuntu (OEM mode)"** → run this kit after install. Buyer sets their own account on first boot.

---

## Security

- `set -euo pipefail` — hard fail on errors
- All destructive ops gate on explicit `[y]` confirmation
- All paths quoted — no glob injection
- Never exfiltrates data — audit `prep.sh` yourself

---

## License

MIT — VibeCodingLabs · Phoenix, AZ
