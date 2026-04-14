# HP Ubuntu Prep Kit

> **by VibeCodingLabs** — Prep any Ubuntu laptop for resale in minutes.

Interactive CLI tool with animated figlet banners, color menus, and step-by-step modules to make a used HP (or any Ubuntu laptop) **secure, clean, and beautiful** for a non-technical buyer.

---

## Features

| Module | What it does |
|--------|-------------|
| **System Info** | Specs, CPU vuln flags, mitigation status |
| **System Update** | `apt full-upgrade` + firmware via `fwupdmgr` |
| **Security Hardening** | UFW firewall, auto-updates, ClamAV, Spectre/Meltdown check |
| **Privacy Wipe** | Shell history, SSH keys, browser data, `.env` files |
| **Beautify Desktop** | Papirus icons, wallpapers, dark mode, fonts |
| **Create Buyer Account** | New user with forced password change on first login |
| **Full Prep** | Runs all of the above in sequence |

---

## Quick Start

```bash
git clone https://github.com/VibeCodingLabs/hp-prep-kit.git
cd hp-prep-kit
chmod +x prep.sh
./prep.sh
```

Dependencies (auto-installed on first run):
- `figlet` — big ASCII banners
- `lolcat` — rainbow color output
- `toilet` — styled font banners

---

## Usage

Launch the interactive menu:

```bash
./prep.sh
```

---

## OEM Reinstall (Recommended before selling)

For a fully clean slate, boot from Ubuntu live USB and choose **"Install Ubuntu (OEM mode)"**. This lets the buyer create their own account on first boot. Run this kit on the new install before handing off.

---

## Security Notes

- All destructive operations (privacy wipe, user deletion) require explicit `[y]` confirmation
- The script never exfiltrates data — review `prep.sh` before running
- `set -euo pipefail` enforced — fails fast on errors
- All paths are quoted — no glob injection

---

## License

MIT — use freely, credit appreciated.

**VibeCodingLabs** | Phoenix, AZ
