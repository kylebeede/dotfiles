#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Setting up GitHub Notifier..."

# Install dependencies
echo "Installing Python dependencies..."
pip3 install rumps requests python-dotenv

# Set up token using keychain
echo "Setting up authentication..."
read -s -p "Enter your GitHub Enterprise Token: " token
echo
security add-generic-password -s github-enterprise-notifier -a "$USER" -w "$token" -U
echo "Token saved to keychain"

# Create plist from template
echo "Setting up LaunchAgent..."
PLIST_TEMPLATE="$SCRIPT_DIR/com.faithlife.github-notifier.plist.template"
PLIST_DEST="$HOME/Library/LaunchAgents/com.faithlife.github-notifier.plist"

# Replace REPO_PATH in plist with actual path
sed "s|REPO_PATH|$SCRIPT_DIR|g" "$PLIST_TEMPLATE" > "$SCRIPT_DIR/com.faithlife.github-notifier.plist"

# Symlink the plist
ln -sf "$SCRIPT_DIR/com.faithlife.github-notifier.plist" "$PLIST_DEST"

# Load the agent
launchctl unload "$PLIST_DEST" 2>/dev/null
launchctl load "$PLIST_DEST"

echo "Setup complete! GitHub Notifier is now running."
echo "Logs available at:"
echo "   - /tmp/github-notifier.out"
echo "   - /tmp/github-notifier.err"
