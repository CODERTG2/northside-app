#!/bin/bash

# Open Xcode Preview for Flutter iOS Project
# This script opens the correct Xcode workspace for Flutter development

set -e

echo "🔧 Preparing Xcode for Flutter iOS development..."

# Change to the project root
cd "$(dirname "$0")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
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

# Check if workspace exists
if [ ! -f "Runner.xcworkspace/contents.xcworkspacedata" ]; then
    print_warning "Xcode workspace not found. Running flutter pub get..."
    cd ..
    flutter pub get
    cd ios
fi

# Install/update pods if needed
if [ ! -d "Pods" ] || [ "Podfile" -nt "Podfile.lock" ]; then
    print_status "Installing/updating CocoaPods..."
    pod install
fi

print_status "Opening Xcode workspace..."

# Open the workspace in Xcode
open Runner.xcworkspace

print_status "Xcode workspace opened!"
echo ""
echo "📋 In Xcode:"
echo "1. Select 'Runner' scheme from the scheme selector"
echo "2. Choose any iOS simulator (iPhone 15 recommended)"
echo "3. Build the project (⌘+B) to ensure everything compiles"
echo "4. Navigate to your Flutter widgets to see Xcode previews"
echo ""
echo "🔧 If you encounter signing issues:"
echo "1. Select the Runner project in the navigator"
echo "2. Go to 'Signing & Capabilities' tab"
echo "3. Enable 'Automatically manage signing'"
echo "4. Select your development team (if you have one)"
