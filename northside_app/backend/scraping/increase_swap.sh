#!/bin/bash

echo "=== Raspberry Pi Memory Optimization ==="
echo "Current memory status:"
free -h

echo ""
echo "Checking current swap..."
swapon --show

echo ""
echo "Setting up larger swap file for web scraping..."

# Stop current swap
sudo dphys-swapfile swapoff

# Backup current config
sudo cp /etc/dphys-swapfile /etc/dphys-swapfile.backup

# Set swap to 1GB (1024MB)
echo "Setting swap size to 1GB..."
sudo sed -i 's/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile

# If the line doesn't exist, add it
if ! grep -q "CONF_SWAPSIZE" /etc/dphys-swapfile; then
    echo "CONF_SWAPSIZE=1024" | sudo tee -a /etc/dphys-swapfile
fi

# Recreate swap file
echo "Creating new swap file..."
sudo dphys-swapfile setup

# Enable swap
echo "Enabling swap..."
sudo dphys-swapfile swapon

echo ""
echo "New memory status:"
free -h

echo ""
echo "New swap status:"
swapon --show

echo ""
echo "=== Memory optimization complete! ==="
echo "You should now have more virtual memory available."
echo "Try running the scraping scripts again."
