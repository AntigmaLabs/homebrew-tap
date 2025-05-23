#!/bin/bash

INSTALL_DIR="/usr/local/bin"
TMP_DIR=$(mktemp -d)
OS="$(uname -s)"

echo "=============================================="
echo "🚀 Initiating Ante Binary Installation 🚀"
echo "==============================================\n"

# Ensure GitHub CLI is installed
if ! command -v gh &>/dev/null; then
    echo "⚠️  GitHub CLI missing! Installing now... 🍺"
    brew install gh || { echo "❌ GitHub CLI installation failed!"; exit 1; }
fi

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
    echo "⚠️  jq missing! Installing now... 🍺"
    brew install jq || { echo "❌ jq installation failed!"; exit 1; }
fi

# Authenticate user via GitHub
if ! gh auth status &>/dev/null; then
    echo "🔑 Please authenticate with GitHub first..."
    gh auth login || { echo "❌ Authentication failed!"; exit 1; }
fi

# Get authenticated username
GH_USER=$(gh api user | jq -r '.login')
echo "🔹 Logged in as: \033[1;32m$GH_USER\033[0m"

# Fetch the latest Ante release URL
RELEASE_API="repos/AntigmaLabs/node/releases/latest"
case "$OS" in
  Darwin)
    echo "Detected macOS"
    browser_download_url=$(gh api "$RELEASE_API" | jq -r '.assets[] | select(.name | match("antex-mac")) | .browser_download_url')
    ;;
  Linux)
    echo "Detected Linux"
    browser_download_url=$(gh api "$RELEASE_API" | jq -r '.assets[] | select(.name | match("antex-linux")) | .browser_download_url')
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

if [ -z "$browser_download_url" ]; then
    echo "❌ No Ante release found."
    exit 1
fi

echo "⬇️  Downloading latest Ante from:\n📦 \033[4m$browser_download_url\033[0m"
curl -# -L -o "$TMP_DIR/ante" "$browser_download_url" || { echo "❌ Download failed!"; exit 1; }

# Make executable
chmod +x "$TMP_DIR/ante"

# Install binary
echo "🔧 Installing Ante to \033[1m$INSTALL_DIR\033[0m..."
sudo cp "$TMP_DIR/ante" "$INSTALL_DIR/ante" || { echo "❌ Installation failed!"; exit 1; }

# Clean up temporary files
rm -rf "$TMP_DIR"

# Installation check
if command -v ante &>/dev/null; then
    echo "\n🎉 \033[1;32mAnte installed successfully!\033[0m 🎉"
    ante --version
else
    echo "❌ Ante installation failed!"
    exit 1
fi

echo "\n=============================================="
echo "✨ Installation process completed! ✨"
echo "=============================================="
