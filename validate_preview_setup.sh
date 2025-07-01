#!/bin/bash

# Validation Script for Xcode Preview Setup
# This script validates that all components are properly configured

set -e

echo "🔍 Validating Xcode preview setup..."

# Check if we're in the right directory
if [ ! -d "northside_app" ]; then
    echo "❌ Not in the correct directory. Please run from the northside-app root."
    exit 1
fi

echo "✅ In correct directory"

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter is available: $(flutter --version | head -n 1)"

# Check if Flutter project exists
if [ ! -f "northside_app/pubspec.yaml" ]; then
    echo "❌ Flutter project not found"
    exit 1
fi

echo "✅ Flutter project found"

# Check iOS project
if [ ! -d "northside_app/ios" ]; then
    echo "❌ iOS project directory not found"
    exit 1
fi

echo "✅ iOS project directory found"

# Check if Xcode workspace exists
if [ ! -f "northside_app/ios/Runner.xcworkspace" ] && [ ! -f "northside_app/ios/Runner.xcodeproj" ]; then
    echo "⚠️  Xcode workspace/project not found. Running flutter build ios --config-only..."
    cd northside_app
    flutter build ios --config-only
    cd ..
fi

echo "✅ Xcode project is available"

# Check script permissions
scripts=("setup_xcode_previews.sh" "run_flutter.sh" "open_xcode_preview.sh" "validate_preview_setup.sh")
for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ ! -x "$script" ]; then
            echo "🔧 Making $script executable..."
            chmod +x "$script"
        fi
        echo "✅ $script is executable"
    else
        echo "⚠️  $script not found"
    fi
done

# Check PreviewHelper.swift
if [ ! -f "northside_app/ios/Runner/PreviewHelper.swift" ]; then
    echo "❌ PreviewHelper.swift not found"
    exit 1
fi

echo "✅ PreviewHelper.swift found"

# Test Flutter dependencies
echo "📦 Checking Flutter dependencies..."
cd northside_app
if flutter pub deps > /dev/null 2>&1; then
    echo "✅ Flutter dependencies are resolved"
else
    echo "⚠️  Flutter dependencies need to be resolved. Running flutter pub get..."
    flutter pub get
fi
cd ..

echo ""
echo "🎉 Validation complete! Your Xcode preview setup is ready."
echo ""
echo "📋 To use the setup:"
echo "1. Run './run_flutter.sh' in one terminal to start Flutter"
echo "2. Run './open_xcode_preview.sh' to open Xcode"
echo "3. In Xcode, you can use the previews defined in PreviewHelper.swift"
echo ""
echo "💡 The Flutter command that will be used: cd ~/Documents/GitHub/northside-app/northside_app && flutter run"
