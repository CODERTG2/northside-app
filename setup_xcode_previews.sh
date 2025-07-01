#!/bin/bash

# Xcode Preview Setup Script for Northside App
# This script sets up Xcode previews for Flutter development

set -e

echo "🚀 Setting up Xcode previews for Northside App..."

# Navigate to the Flutter project directory
cd ~/Documents/GitHub/northside-app/northside_app

# Ensure Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Clean and get dependencies
echo "📦 Getting Flutter dependencies..."
flutter clean
flutter pub get

# Ensure iOS dependencies are up to date
echo "📱 Setting up iOS dependencies..."
cd ios
pod install --repo-update
cd ..

# Generate iOS files if needed
echo "🔧 Generating iOS files..."
flutter build ios --config-only

# Make the run script executable
chmod +x ../run_flutter.sh
chmod +x ../open_xcode_preview.sh

echo "✅ Xcode preview setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Run './open_xcode_preview.sh' to open the project in Xcode"
echo "2. Use './run_flutter.sh' to start the Flutter app"
echo "3. In Xcode, you can now use previews with the Flutter app running"
echo ""
echo "💡 The Flutter app will run with: cd ~/Documents/GitHub/northside-app/northside_app && flutter run"
