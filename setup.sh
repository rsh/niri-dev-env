#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Setting up niri-dev environment..."

# Check if niri directory already exists
if [ -d "niri" ]; then
    echo "niri/ directory already exists."
    read -p "Do you want to remove it and clone fresh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing niri/ directory..."
        rm -rf niri
    else
        echo "Keeping existing niri/ directory."
        echo "Skipping clone step."
        SKIP_CLONE=1
    fi
fi

# Clone niri if needed
if [ -z "$SKIP_CLONE" ]; then
    echo "Cloning niri repository..."
    git clone https://github.com/YaLTeR/niri.git
    echo "✓ Cloned niri"
fi

# Build niri
echo "Building niri in release mode..."
cd niri
cargo build --release
cd ..
echo "✓ Built niri"

# Generate GDM session file with correct path
echo "Generating niri-dev.desktop with correct paths..."
cat > niri-dev.desktop <<EOF
[Desktop Entry]
Name=Niri (Dev)
Comment=A scrollable-tiling Wayland compositor (Development Version)
Exec=$SCRIPT_DIR/niri-dev-session
Type=Application
DesktopNames=niri
EOF
echo "✓ Generated niri-dev.desktop"

# Install GDM session file
echo ""
echo "To complete setup, install the GDM session file:"
echo "  sudo cp niri-dev.desktop /usr/share/wayland-sessions/"
echo ""
echo "Setup complete! See README-DEV.md for usage instructions."
