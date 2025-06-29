#!/bin/bash

# Open Xcode with Full Northside App Preview
# This script opens the complete app with all navigation for live preview development

set -e

echo "🚀 Opening Full Northside App Xcode Preview..."

# Change to the project root
cd "$(dirname "$0")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
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

print_feature() {
    echo -e "${PURPLE}🎯 $1${NC}"
}

# Ensure we're in the Flutter project
if [ ! -f "northside_app/pubspec.yaml" ]; then
    print_warning "Not in Flutter project root. Please run from the project root directory."
    exit 1
fi

print_info "Preparing Full App Preview..."

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

print_status "Opening Xcode workspace with Complete Northside App..."

# Open the workspace in Xcode
open Runner.xcworkspace

print_status "Xcode opened successfully!"
echo ""
echo "🎉 Welcome to Full App Preview Mode!"
echo ""
echo "📋 To start the complete app preview:"
echo "1. Wait for Xcode to finish indexing (progress bar at top)"
echo "2. Navigate to: ios/Runner/BulletinPagePreview.swift"
echo "3. Click 'Resume' in the preview canvas (or press ⌥⌘P)"
echo "4. You'll see the FULL Northside app running!"
echo ""
print_feature "Navigation Testing:"
echo "   • Tap bottom navigation to switch between pages"
echo "   • Home → Athletics → Events → Bulletin → Profile"
echo ""
print_feature "Bulletin Page Features:"
echo "   • Draggable sheet with snap-back behavior"
echo "   • Pinned carousel at top (never gets covered)"
echo "   • Auto-scroll to 'Today' when sheet snaps back"
echo "   • Smart fallback when no 'Today' posts exist"
echo ""
print_feature "Device Testing:"
echo "   • iPhone 15 Pro (default)"
echo "   • iPhone 15 Pro Max (large screen)"
echo "   • iPhone SE (compact screen)"
echo "   • iPad Pro 12.9\" (tablet layout)"
echo ""
echo "🔧 Troubleshooting:"
echo "• No preview? Build first (⌘+B)"
echo "• Wrong scheme? Select 'Runner' from scheme dropdown"
echo "• Preview broken? Refresh with ⌘⇧R in preview canvas"
echo "• Still issues? Check console for Flutter errors"
echo ""
echo "💡 Pro Tips:"
echo "• Use device selector in preview to test different sizes"
echo "• Try portrait/landscape orientations"
echo "• Hot reload works in preview mode!"
echo "• Test the bulletin page snap behavior extensively"
