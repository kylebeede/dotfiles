#!/usr/bin/env bash
#
# Installs the specific .NET SDK version required

set -e

# Define the SDK version needed
DOTNET_SDK_VERSION="8.0.406"
DOTNET_INSTALL_DIR="/usr/local/share/dotnet"

echo "    › Installing .NET SDK $DOTNET_SDK_VERSION"

# Download the dotnet-install script
curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh

# Check if dotnet is already installed
if [ -d "$DOTNET_INSTALL_DIR" ]; then
  echo "    › .NET installation directory already exists at $DOTNET_INSTALL_DIR"
  
  # Check if the specific SDK version is already installed
  if dotnet --list-sdks | grep -q "$DOTNET_SDK_VERSION"; then
    echo "    › .NET SDK $DOTNET_SDK_VERSION is already installed"
    exit 0
  fi
fi

# Install the SDK with sudo
echo "    › Installing .NET SDK $DOTNET_SDK_VERSION (may require password for sudo)"
sudo /tmp/dotnet-install.sh --version $DOTNET_SDK_VERSION --install-dir $DOTNET_INSTALL_DIR

# Fix permissions
echo "    › Setting permissions for .NET installation"
sudo chown -R $(whoami) $DOTNET_INSTALL_DIR

# Clean up
rm /tmp/dotnet-install.sh

echo "    › .NET SDK $DOTNET_SDK_VERSION installation complete"
