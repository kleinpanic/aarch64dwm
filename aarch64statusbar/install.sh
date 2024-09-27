#!/usr/bin/env bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# DWM dependency check (uncomment if necessary)
# if ! pgrep -x "dwm" > /dev/null; then
#     echo "DWM is not running. Please ensure that DWM is installed and is your window manager."
#     exit 1
# fi

# Check for the status2D dependency
if command_exists dwm; then
    echo "DWM is installed. Make sure you have the status2D patch applied for proper rendering."
fi 

# Required packages list
required_packages=("grep" "gawk" "procps" "coreutils" "lm-sensors" "network-manager" "x11-xserver-utils")

# Install required packages
for pkg in "${required_packages[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "Package $pkg is not installed. Installing..."
        sudo apt update
        sudo apt install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Failed to install $pkg. Please install it manually, or its equivalent, and edit the source code."
            exit 1
        fi
    else 
        echo "Package $pkg is already installed."
    fi 
done 

# Copy statusbar.sh to /usr/local/bin and make it executable
sudo cp statusbar.sh /usr/local/bin/statusbar
sudo chmod +x /usr/local/bin/statusbar

# Create the directory and copy colorvars.sh
PREFIX="$HOME/.local/share/statusbar"
mkdir -p "$PREFIX"
cp colorvars.sh "$PREFIX"

# Setup the systemd service
SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"
cp statusbar.service "$SERVICE_DIR"

# Enable and restart the service
systemctl --user enable statusbar.service
systemctl --user restart statusbar.service

echo "Installation completed successfully. The statusbar is installed and the service has been enabled and restarted."
