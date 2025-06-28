# Xcode Preview Setup for Flutter iOS

This guide helps you set up Xcode previews for your Flutter iOS app and resolve common signing issues.

## Quick Start

1. **Run the validation script:**
   ```bash
   ./validate_preview_setup.sh
   ```

2. **Open Xcode with the correct workspace:**
   ```bash
   ./open_xcode_preview.sh
   ```

## Common Signing Issues and Solutions

### Issue 1: "No signing certificate found"

**Solution A: Enable Automatic Signing (Recommended for development)**
1. Open `Runner.xcworkspace` in Xcode (not .xcodeproj)
2. Select the Runner project in the navigator
3. Go to the "Signing & Capabilities" tab
4. Check "Automatically manage signing"
5. If you have an Apple Developer account, select your team

**Solution B: Manual Configuration**
- The project is already configured with `CODE_SIGN_STYLE = Automatic`
- Development team is set to empty (works for simulator)

### Issue 2: "Bundle identifier conflicts"

The app uses bundle ID: `com.northsideapp.dev`

If you need to change it:
1. In Xcode, go to Runner target → General → Identity
2. Change the Bundle Identifier
3. Or modify it in the project.pbxproj file

### Issue 3: "No provisioning profile found"

For **simulator/preview only** (no device deployment needed):
- No provisioning profile required
- Automatic signing should work

For **device deployment**:
1. Add your Apple Developer Team ID to `DEVELOPMENT_TEAM` in project.pbxproj
2. Or set it in Xcode under Signing & Capabilities

## Project Configuration

### Current Signing Settings:
- **Code Sign Style**: Automatic
- **Development Team**: Empty (simulator-only)
- **Bundle Identifier**: com.northsideapp.dev
- **Supports Platforms**: iPhone, iPad (iOS 12.0+)

### Build Configurations:
- **Debug**: Optimized for development and previews
- **Release**: Optimized for App Store
- **Profile**: Optimized for performance testing

## Troubleshooting Steps

### 1. Clean Build
```bash
cd northside_app/ios
rm -rf build/
rm -rf Pods/
pod install
```

### 2. Reset Simulator
```bash
xcrun simctl erase all
```

### 3. Xcode Clean
In Xcode: Product → Clean Build Folder (⇧⌘K)

### 4. Flutter Clean
```bash
cd northside_app
flutter clean
flutter pub get
```

## Development Workflow

### For Xcode Previews:
1. Open `Runner.xcworkspace` in Xcode
2. Select Runner scheme + any iOS simulator
3. Build project (⌘+B)
4. Navigate to Flutter widgets for previews

### For Flutter Development:
```bash
# Run on simulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### For iOS Release:
1. Set proper development team
2. Create App Store provisioning profile
3. Archive in Xcode or use `flutter build ios`

## Tips for Success

1. **Always use .xcworkspace**, not .xcodeproj
2. **Keep CocoaPods updated**: Run `pod install` after changes
3. **Use iPhone simulators** for best preview performance
4. **Enable automatic signing** for easier development
5. **Add development team** only when deploying to physical devices

## Getting Help

If you still encounter issues:

1. Check the validation script output
2. Verify Xcode version compatibility
3. Ensure Flutter is up to date: `flutter upgrade`
4. Check iOS deployment target compatibility

## File Structure

```
ios/
├── Runner.xcworkspace/     # ← Open this in Xcode
├── Runner.xcodeproj/       # Project configuration
├── Runner/                 # iOS app source
├── Pods/                   # CocoaPods dependencies
└── Podfile                 # Dependency specification
```
