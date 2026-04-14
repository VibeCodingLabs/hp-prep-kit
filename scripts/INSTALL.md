# HP Prep Kit — First-Boot & Wallpaper Rotator Install Guide

Target: **Xubuntu 20.04 LTS · XFCE · LightDM · HP Stream 14-cb0XX**

---

## Why `gsettings` didn't work

`gsettings` controls **GNOME** settings. Xubuntu uses **XFCE**, which stores
desktop config in `xfconf`. The correct command is `xfconf-query`. Also,
`xfconf-query` only works **inside a logged-in XFCE session** — running it from
cron or a root systemd unit silently fails because there is no live `xfce4-desktop`
process to receive the change.

**Fix:** deploy the rotation script via an autostart `.desktop` entry so it starts
inside the buyer's session automatically at login.

---

## File Map

| Repo path | Install destination |
|---|---|
| `scripts/rotate_wallpapers_xfce.sh` | `/usr/local/share/hp-prep/rotate_wallpapers_xfce.sh` |
| `scripts/wallpaper-rotate.desktop` | `/usr/local/share/hp-prep/wallpaper-rotate.desktop` |
| `scripts/firstboot-setup-xfce.sh` | `/usr/local/sbin/firstboot-setup-xfce.sh` |
| `systemd/firstboot-setup.service` | `/etc/systemd/system/firstboot-setup.service` |
| `lightdm/lightdm-gtk-greeter.conf` | `/etc/lightdm/lightdm-gtk-greeter.conf.d/50-hp-prep.conf` |

---

## Install (run on seller machine after `git pull`)

```bash
# 1. Copy support files
sudo mkdir -p /usr/local/share/hp-prep
sudo cp scripts/rotate_wallpapers_xfce.sh /usr/local/share/hp-prep/
sudo cp scripts/wallpaper-rotate.desktop  /usr/local/share/hp-prep/
sudo chmod +x /usr/local/share/hp-prep/rotate_wallpapers_xfce.sh

# 2. Install first-boot script
sudo cp scripts/firstboot-setup-xfce.sh /usr/local/sbin/firstboot-setup-xfce.sh
sudo chmod +x /usr/local/sbin/firstboot-setup-xfce.sh

# 3. Install and enable systemd unit
sudo cp systemd/firstboot-setup.service /etc/systemd/system/firstboot-setup.service
sudo systemctl daemon-reload
sudo systemctl enable firstboot-setup.service

# 4. Optional: LightDM login screen wallpaper
sudo mkdir -p /etc/lightdm/lightdm-gtk-greeter.conf.d
sudo cp lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.d/50-hp-prep.conf
# Copy your chosen greeter background image:
sudo cp /path/to/your-login-bg.jpg /usr/share/backgrounds/hp-prep-greeter.jpg
```

---

## Optional: auto-remove seller account after buyer creates theirs

Create this flag **before shipping** the device. The firstboot script checks for it.

```bash
sudo mkdir -p /etc/hp-prep
sudo touch /etc/hp-prep/remove-prep-user
# Edit firstboot-setup-xfce.sh PREP_USER variable to match your seller account name
```

---

## How it works

### First-boot setup
1. `firstboot-setup.service` fires at `graphical.target` on first boot.
2. If a display is available: shows a **zenity GUI** asking for full name / username / password.
3. Falls back to a **console (TTY) prompt** if no graphical session.
4. Creates the buyer's sudo account and forces password change at first login.
5. Copies `rotate_wallpapers_xfce.sh` and `wallpaper-rotate.desktop` into the new user's home.
6. Optionally removes the seller `prep` account (only if `/etc/hp-prep/remove-prep-user` exists).
7. Writes `/etc/hp-prep/firstboot-done` so the service **never runs again**.

### Wallpaper rotation
1. XFCE autostart fires `~/.local/bin/rotate_wallpapers_xfce.sh` at login.
2. Script downloads 10 Unsplash 4K B-roll images on first run (skips if cached).
3. Uses `xfconf-query` (correct XFCE tool — NOT `gsettings`) to set all monitor/workspace backdrop properties.
4. Dynamically detects all `/last-image` properties to handle multi-monitor setups.
5. Cycles wallpapers every 180 seconds.

### LightDM greeter
- Set `background=` in the greeter config to any image in `/usr/share/backgrounds/`.
- `user-background=false` prevents individual user wallpapers from overriding the login screen.
- Restart LightDM to apply (this will end the current session):
  ```bash
  sudo systemctl restart lightdm
  ```
