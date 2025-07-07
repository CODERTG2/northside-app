#!/bin/bash

# Open Xcode Preview Script
# This script opens the iOS project in Xcode for previews

set -e

echo "📱 Opening Xcode project for previews..."

# Navigate to the iOS project directory
cd ~/Documents/GitHub/northside-app/northside_app/ios

# Open the Xcode workspace
if [ -d "Runner.xcworkspace" ]; then
    echo "✅ Opening Runner.xcworkspace in Xcode..."
    open Runner.xcworkspace
else
    echo "❌ Runner.xcworkspace not found"
    echo "Please run './setup_xcode_previews.sh' first"
    exit 1
fi

echo "✅ Xcode opened successfully!"
echo ""
echo "💡 Tips for using Xcode previews:"
echo "1. Make sure to run './run_flutter.sh' in a separate terminal"
echo "2. The Flutter app needs to be running for previews to work"
echo "3. Use the PreviewHelper.swift file for your preview implementations"
