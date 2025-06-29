#!/bin/bash

echo "Setting up web scraping environment for Raspberry Pi..."

# Update system
sudo apt update

# Install Firefox ESR (Extended Support Release - more stable on Pi)
echo "Installing Firefox ESR..."
sudo apt install -y firefox-esr

# Download and install geckodriver for ARM
echo "Installing geckodriver for ARM..."
GECKODRIVER_VERSION="0.33.0"

# Detect architecture
ARCH=$(uname -m)
if [[ $ARCH == "armv7l" ]]; then
    GECKODRIVER_ARCH="linux-arm7hf"
elif [[ $ARCH == "aarch64" ]]; then
    GECKODRIVER_ARCH="linux-aarch64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Download geckodriver
wget -O geckodriver.tar.gz "https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-${GECKODRIVER_ARCH}.tar.gz"

# Extract and install
tar -xzf geckodriver.tar.gz
sudo mv geckodriver /usr/local/bin/
sudo chmod +x /usr/local/bin/geckodriver
rm geckodriver.tar.gz

# Verify installation
echo "Verifying installation..."
firefox-esr --version
geckodriver --version

# Install Python packages
echo "Installing Python packages..."
pip3 install selenium beautifulsoup4 requests

echo "Setup complete!"
echo "Test with: python3 scraping_test_pi.py"
