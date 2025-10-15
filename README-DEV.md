# Niri Development Setup

This directory contains a development setup for niri that allows you to test changes without affecting your stable niri installation.

## Initial Setup

If you're setting up this repo for the first time:

```bash
./setup.sh
```

This will:
1. Clone the niri repository
2. Build niri in release mode
3. Provide instructions for installing the GDM session file

## Setup Overview

This setup provides two ways to run niri-dev:
1. **Via GDM** - Full session you can select at login
2. **Nested** - Quick testing inside your current niri session

## Directory Structure

```
/home/rayhan/dev/3p/niri-dev/
├── niri/                    # Git repo with niri source code (clone via setup.sh)
│   └── target/release/niri  # Built development binary
├── setup.sh                 # Setup script to clone and build niri
├── niri-dev-session         # Session launcher for GDM
├── niri-dev-nested          # Script to run niri-dev nested
├── niri-dev.desktop         # GDM session file
├── niri-nested-config.kdl   # Config with Ctrl+Alt keybindings for nested testing
└── README-DEV.md            # This file
```

## External System Changes

The following files were installed outside this repository:

### 1. GDM Session File

**File:** `/usr/share/wayland-sessions/niri-dev.desktop`

**Content:**
```desktop
[Desktop Entry]
Name=Niri (Dev)
Comment=A scrollable-tiling Wayland compositor (Development Version)
Exec=/home/rayhan/dev/3p/niri-dev/niri-dev-session
Type=Application
DesktopNames=niri
```

**Installation command:**
```bash
sudo cp /home/rayhan/dev/3p/niri-dev/niri-dev.desktop /usr/share/wayland-sessions/
```

**What it does:** Makes "Niri (Dev)" appear as a session option in GDM login screen.

## Usage

### Option 1: Full Session via GDM

1. Build your changes:
   ```bash
   cd /home/rayhan/dev/3p/niri-dev/niri
   cargo build --release
   ```

2. Log out from your current session

3. At the GDM login screen, click the gear icon and select **"Niri (Dev)"**

4. Log in - you'll be running your development version

### Option 2: Nested Testing (Quick Tests)

Run niri-dev as a window inside your current niri session:

```bash
# With custom config that uses Ctrl+Alt instead of Super (recommended)
/home/rayhan/dev/3p/niri-dev/niri-dev-nested /home/rayhan/dev/3p/niri-dev/niri-nested-config.kdl

# Or without arguments to use your default config
/home/rayhan/dev/3p/niri-dev/niri-dev-nested
```

**Note:** A special config file `niri-nested-config.kdl` is provided that uses **Ctrl+Alt** instead of **Super** for all keybindings, so they won't conflict with the outer niri session.

This is useful for quick testing but won't test full session management features.

Press `Ctrl+C` in the terminal to exit the nested session.

## Development Workflow

1. Make changes to niri source code in `niri/`
2. Build: `cd niri && cargo build --release`
3. Test nested: `../niri-dev-nested` (for quick checks)
4. Test full session: Log out and select "Niri (Dev)" in GDM (for complete testing)

## Binary Locations

- **Production niri:** `/usr/local/bin/niri`
- **Development niri:** `/home/rayhan/dev/3p/niri-dev/niri/target/release/niri`

The two installations are completely independent and won't interfere with each other.

## Configuration

Both niri and niri-dev will use the same config file: `~/.config/niri/config.kdl`

If you want separate configs for testing, you can modify `niri-dev-session` to set a different `XDG_CONFIG_HOME` or pass a custom config path.

## Troubleshooting

### "Niri (Dev)" doesn't appear in GDM

- Check that the desktop file is installed:
  ```bash
  ls -l /usr/share/wayland-sessions/niri-dev.desktop
  ```
- If missing, reinstall it:
  ```bash
  sudo cp /home/rayhan/dev/3p/niri-dev/niri-dev.desktop /usr/share/wayland-sessions/
  ```

### Dev binary not found error

Build the development version:
```bash
cd /home/rayhan/dev/3p/niri-dev/niri
cargo build --release
```

### Keybindings don't work in nested mode (Super+T, etc.)

**This is expected behavior.** The outer niri session captures keybindings first, so they never reach the nested niri-dev.

**Solutions:**

1. **Use the provided nested config** (easiest):
   ```bash
   /home/rayhan/dev/3p/niri-dev/niri-dev-nested /home/rayhan/dev/3p/niri-dev/niri-nested-config.kdl
   ```
   This config uses **Ctrl+Alt** instead of **Super** for all keybindings. For example:
   - `Ctrl+Alt+T` opens a terminal (instead of `Super+T`)
   - `Ctrl+Alt+Q` closes window (instead of `Super+Q`)
   - `Ctrl+Alt+H/J/K/L` for navigation (instead of `Super+H/J/K/L`)

2. **Use the full GDM session** - This is recommended for testing keybindings exactly as they'll work in production

3. **Click inside the nested window** - Some keybindings may work if the nested window has focus, but Super key combinations will still be captured by the outer compositor

### Nested session crashes immediately

Some features may not work in nested mode. Use the GDM session for full testing.

## Cleanup

To remove the development setup:

1. Remove GDM session file:
   ```bash
   sudo rm /usr/share/wayland-sessions/niri-dev.desktop
   ```

2. Remove this directory:
   ```bash
   rm -rf /home/rayhan/dev/3p/niri-dev
   ```

## How GDM Integration Works

GDM (GNOME Display Manager) reads `.desktop` files from `/usr/share/wayland-sessions/` and displays them as session options at login. Each desktop file specifies:
- **Name:** What appears in the session selector
- **Exec:** The command/script to run when that session is selected
- **Type:** Always "Application" for session files

When you select "Niri (Dev)" and log in:
1. GDM executes `/home/rayhan/dev/3p/niri-dev/niri-dev-session`
2. That script runs the development niri binary with `--session` flag
3. Niri starts as your full compositor/window manager for that session
