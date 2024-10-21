#!/bin/bash
set -e

# Variables (Update as needed)
SERVICE_TOKEN=""
OP_VAULT="="
RPI_CONNECT_ITEM="rpi-connect"
RPI_CONNECT_SERVICE_NAME="rpi-connect"
OP_CLI_VERSION="https://downloads.1password.com/linux/beta/1password-cli-latest.deb"
OP_DESKTOP_BETA_URL="https://downloads.1password.com/linux/beta/1password-latest.deb"

# Update and upgrade system
echo "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

# Function to show a progress bar
progress_bar() {
  local duration=$1
  local interval=0.2
  local elapsed=0
  while [ $elapsed -lt $duration ]; do
    echo -n "."
    sleep $interval
    elapsed=$(echo "$elapsed + $interval" | bc)
  done
  echo
}

# Install 1Password CLI
echo "Installing 1Password CLI..."
if ! wget $OP_CLI_VERSION -O 1password-cli.deb; then
  echo "Download failed. Attempting to find 1Password CLI in repository..."
  sudo apt install -y 1password-cli
else
  sudo dpkg -i 1password-cli.deb
  sudo apt install -f -y
fi

# Authenticate 1Password CLI using Service Token
echo "Authenticating 1Password CLI..."
eval $(echo "$SERVICE_TOKEN" | op signin --raw)

# Install 1Password Desktop Beta
echo "Installing 1Password Desktop Beta..."
if ! wget $OP_DESKTOP_BETA_URL -O 1password-beta.deb; then
  echo "Download failed. Attempting to find 1Password Desktop Beta in repository..."
  sudo apt install -y 1password
else
  sudo dpkg -i 1password-beta.deb
  sudo apt install -f -y
fi

# Install Raspberry Pi Connect Software
echo "Installing Raspberry Pi Connect Software..."
sudo apt install -y rpi-connect

# Retrieve Raspberry Pi Connect credentials from 1Password CLI
echo "Fetching Raspberry Pi Connect Credentials from 1Password..."
USERNAME=$(op item get "$RPI_CONNECT_ITEM" --vault "$OP_VAULT" --fields username)
PASSWORD=$(op item get "$RPI_CONNECT_ITEM" --vault "$OP_VAULT" --fields password)

# Configure and authenticate Raspberry Pi Connect
echo "Configuring Raspberry Pi Connect..."
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  echo "Failed to fetch credentials from 1Password. Exiting..."
  exit 1
fi
sudo rpi-connect set-credentials --username "$USERNAME" --password "$PASSWORD"
if ! rpi-connect signin; then
  echo "Failed to sign in to Raspberry Pi Connect. Exiting..."
  exit 1
fi

# Enable linger to keep the remote shell always available
echo "Enabling linger for the current user..."
sudo loginctl enable-linger $(whoami)

# Manually start the rpi-connect service
echo "Starting the rpi-connect service..."
systemctl --user start rpi-connect

# Enable Raspberry Pi Connect service to start on boot
echo "Setting up Raspberry Pi Connect service to start on boot..."
sudo systemctl enable $RPI_CONNECT_SERVICE_NAME
sudo systemctl start $RPI_CONNECT_SERVICE_NAME

echo "Setup completed."
