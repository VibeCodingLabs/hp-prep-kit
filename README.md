# 🔥 HP Prep Kit — v4

**VibeCodingLabs** · Ubuntu laptop prep tool with animated TUI, macOS-inspired UI, and full seller/buyer workflow.

## Quick Start

```bash
git clone https://github.com/VibeCodingLabs/hp-prep-kit.git
cd hp-prep-kit
chmod +x prep.sh
./prep.sh
```

## Menu

| Key | Module | Description |
|-----|--------|-------------|
| `1` | System Info | CPU, RAM, disk, GPU, vulnerability status |
| `2` | System Update | `apt full-upgrade` + firmware updates |
| `3` | Security Hardening | UFW, ClamAV, auto-updates, Meltdown audit |
| `4` | Privacy Wipe | Shell history, SSH/GPG, browser data, `.env` files |
| `5` | Beautify Desktop | Xfce/GNOME auto-detect, Papirus icons, dark theme |
| `6` | Create Buyer User | New sudo account, force password change on first login |
| `7` | **Seller Seal** | Wallpaper rotator (cron), firstboot cleanup service, seal flag |
| `8` | **Test Mode** | Verify all systems, accounts, mitigations |
| `A` | **FULL PREP** | Runs all modules in sequence |
| `Q` | Quit | |

## Seller Workflow

1. Run **[A] Full Prep** — does everything in order
2. Or run individual modules then **[7] Seller Seal** to arm handoff
3. Run **[8] Test Mode** to verify everything passed
4. Hand off laptop — buyer account has expired password, firstboot service cleans up seller accounts

## Requirements

- Ubuntu 18.04+ (tested on 20.04 LTS Xfce)
- `sudo` access
- Internet connection for package installs

## What Gets Installed

- `figlet` `lolcat` `toilet` `bc` — TUI display tools
- `papirus-icon-theme` — desktop icons
- `clamav` `ufw` `unattended-upgrades` — security
- `fwupd` — firmware updates
- `/usr/local/bin/wallpaper-rotate.sh` — wallpaper rotator
- `/etc/systemd/system/hp-prep-firstboot.service` — buyer firstboot cleanup

## Error Handling

All commands use `|| true` — no single failure kills the script. Errors are shown inline with ✗ toast notifications.

---

*VibeCodingLabs · Phoenix, AZ*
