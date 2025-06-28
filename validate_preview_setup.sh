#!/bin/bash

# Validate Xcode Preview Setup for Flutter iOS Project
# This script checks and fixes common issues with Xcode previews

set -e

echo "🔍 Validating Xcode Preview Setup..."

# Change to the iOS project directory
cd "$(dirname "$0")/northside_app/ios"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed or not in PATH"
    exit 1
fi

print_status "Xcode is installed"

# Check for available simulators
echo "📱 Available iOS Simulators:"
xcrun simctl list devices iOS | grep -E "(iPhone|iPad)" | grep "Booted\|Shutdown" | head -5

# Check code signing identities
echo ""
echo "🔑 Checking Code Signing Identities:"
IDENTITIES=$(security find-identity -p codesigning -v 2>/dev/null | grep "valid identities found" | awk '{print $1}')

if [ "$IDENTITIES" = "0" ]; then
    print_warning "No code signing identities found"
    echo "   This is normal for simulator-only development"
    echo "   Xcode previews will work with automatic signing"
else
    print_status "Found $IDENTITIES code signing identit(ies)"
fi

# Check if Flutter project structure is correct
if [ ! -f "Runner.xcworkspace/contents.xcworkspacedata" ]; then
    print_error "Flutter iOS project structure is incomplete"
    echo "Run 'flutter pub get' from the Flutter project root"
    exit 1
fi

print_status "Flutter iOS project structure is valid"

# Check for Pod installation
if [ ! -d "Pods" ] || [ ! -f "Podfile.lock" ]; then
    print_warning "CocoaPods not installed or outdated"
    echo "Installing/updating CocoaPods..."
    pod install
    print_status "CocoaPods installation complete"
else
    print_status "CocoaPods are properly installed"
fi

# Validate bundle identifier
BUNDLE_ID=$(grep -A1 "PRODUCT_BUNDLE_IDENTIFIER" Runner.xcodeproj/project.pbxproj | grep "com\." | head -1 | sed 's/.*= \(.*\);/\1/' | tr -d ' ')
if [ -n "$BUNDLE_ID" ]; then
    print_status "Bundle identifier: $BUNDLE_ID"
else
    print_error "Bundle identifier not found or invalid"
fi

# Check development team setting
DEV_TEAM=$(grep -A1 "DEVELOPMENT_TEAM" Runner.xcodeproj/project.pbxproj | grep "= " | head -1 | sed 's/.*= \(.*\);/\1/' | tr -d ' "')
if [ "$DEV_TEAM" = "" ] || [ "$DEV_TEAM" = '""' ]; then
    print_warning "Development team not set"
    echo "   For device deployment, you'll need to set DEVELOPMENT_TEAM"
    echo "   For simulator/preview only, this is fine"
else
    print_status "Development team is set: $DEV_TEAM"
fi

echo ""
echo "🚀 Setup validation complete!"
echo ""
echo "📋 Next steps for Xcode previews:"
echo "1. Open Runner.xcworkspace (not .xcodeproj) in Xcode"
echo "2. Select 'Runner' scheme and any iOS simulator"
echo "3. Build the project (⌘+B) to ensure it compiles"
echo "4. Your Flutter views should now work in Xcode previews"
echo ""
echo "💡 Tips:"
echo "- Use iPhone simulators for best preview performance"
echo "- If you get signing errors, ensure 'Automatically manage signing' is enabled in Xcode"
echo "- For device deployment, add your Apple Developer Team ID to DEVELOPMENT_TEAM"
