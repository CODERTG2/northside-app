#!/bin/bash

# Open Xcode with Full Northside App Preview
# This script opens the complete app for live preview development

set -e

echo "📱 Opening Full Northside App Xcode Preview..."

# Change to the project root
cd "$(dirname "$0")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Ensure we're in the Flutter project
if [ ! -f "northside_app/pubspec.yaml" ]; then
    print_warning "Not in Flutter project root. Please run from the project root directory."
    exit 1
fi

# Change to iOS directory
cd northside_app/ios

# Check if workspace exists and install pods if needed
if [ ! -f "Runner.xcworkspace/contents.xcworkspacedata" ] || [ ! -d "Pods" ]; then
    print_status "Setting up iOS dependencies..."
    cd ..
    flutter pub get
    cd ios
    pod install
fi

print_status "Opening Xcode workspace with Full App preview..."

# Open the workspace in Xcode
open Runner.xcworkspace

print_status "Xcode opened successfully!"
echo ""
echo "📋 To view the complete Northside App in Xcode:"
echo "1. Wait for Xcode to finish indexing"
echo "2. Navigate to ios/Runner/BulletinPagePreview.swift (now renamed to Full App Preview)"
echo "3. Click the 'Resume' button in the preview canvas (or press ⌥⌘P)"
echo "4. You'll see the complete app with navigation!"
echo ""
echo "🎯 What you can test in the full app preview:"
echo "• Navigate between all pages using the bottom navigation"
echo "• Test the bulletin page with draggable sheet"
echo "• See pinned carousel protection"
echo "• Test auto-scroll to 'Today' section"
echo "• Navigate to home, athletics, events, bulletin, and profile"
echo "• Test on different device sizes"
echo ""
echo "📱 Available device previews:"
echo "• iPhone 15 Pro"
echo "• iPhone 15 Pro Max"
echo "• iPhone SE"
echo "• iPad Pro 12.9-inch"
echo ""
echo "🔧 If the preview doesn't load:"
echo "1. Build the project first (⌘+B)"
echo "2. Make sure 'Runner' scheme is selected"
echo "3. Try refreshing the preview (⌘⇧R in preview canvas)"
echo "4. Check that main_preview.dart exists in lib/"
