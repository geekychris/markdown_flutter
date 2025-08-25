# Markdown Editor

A Flutter-based markdown editor application for macOS that provides a split-pane interface for editing and previewing markdown documents.

## Features

- **Split-pane interface**: Edit markdown on the left, see live preview on the right
- **Markdown toolbar**: Quick formatting tools for common markdown syntax
- **File operations**: New, Open, Save, and Save As functionality
- **File associations**: Handles .md, .markdown, .txt, and other text files
- **Keyboard shortcuts**: 
  - `Cmd+N`: New file
  - `Cmd+O`: Open file
  - `Cmd+S`: Save file
  - `Cmd+Shift+S`: Save as
- **Dark/Light theme support**: Follows system appearance
- **Modern macOS design**: Uses Material 3 design system

## Building and Running

1. Make sure you have Flutter installed with macOS support
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run -d macos` to launch the app

## Usage

1. **Creating a new document**: Click the "+" button or press `Cmd+N`
2. **Opening a file**: Click the folder icon or press `Cmd+O`
3. **Saving**: Click the save icon or press `Cmd+S`
4. **Editing**: Use the toolbar buttons for quick markdown formatting or type markdown directly
5. **Preview**: The right pane shows a live preview of your markdown
6. **Hide/Show preview**: Click the eye icon to toggle the preview pane

## Supported File Types

- Markdown files (.md, .markdown, .mdown, .mkd)
- Text files (.txt)

## Dependencies

- `flutter_markdown`: For rendering markdown content
- `file_picker`: For native file dialogs
- `provider`: For state management
- `flutter_highlight`: For syntax highlighting

## Requirements

- macOS 10.14 or later
- Flutter 3.0 or later

## Development

### Running Tests

The app includes comprehensive unit and widget tests.

```bash
# Run all tests
flutter test

# Run tests with detailed output
flutter test --reporter=expanded

# Run tests with coverage report
flutter test --coverage

# Run specific test file
flutter test test/document_state_test.dart
```

#### Test Coverage

The test suite covers:
- **Widget tests**: UI components and user interactions
- **Unit tests**: DocumentState model functionality
- **File operations**: Opening, saving, and managing files
- **State management**: Content updates and change notifications

Coverage report is generated in `coverage/lcov.info` and can be viewed with:
```bash
# Install lcov (macOS)
brew install lcov

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

### Cleaning the Build

To clean all build artifacts and start fresh:

```bash
flutter clean
flutter pub get
```

### Debug Build

For development and testing:

```bash
flutter run -d macos
# or
flutter build macos --debug
```

### Release Build

To create an optimized release build:

```bash
flutter build macos --release
```

The release app will be located at:
`build/macos/Build/Products/Release/markdown_editor.app`

### Automated Build Script

Use the provided build script for easy distribution:

```bash
# Make executable (first time only)
chmod +x build_release.sh

# Unsigned build (simple distribution)
./build_release.sh unsigned

# Signed build (requires Apple Developer Account)
export APPLE_ID="your@email.com"
export TEAM_ID="YOUR_10_CHAR_TEAM_ID"
export APP_PASSWORD="app-specific-password"
./build_release.sh signed

# App Store build preparation
./build_release.sh appstore
```

## Distribution

### Simple Distribution (No Code Signing)

#### Create ZIP Archive
```bash
cd build/macos/Build/Products/Release
zip -r ../../../../../markdown_editor_macos.zip markdown_editor.app
```

#### Create DMG (Recommended)
```bash
hdiutil create -volname "Markdown Editor" -srcfolder "build/macos/Build/Products/Release/markdown_editor.app" -ov -format UDZO "markdown_editor_macos.dmg"
```

**Note**: Users will see a security warning on first launch and need to right-click → Open to bypass Gatekeeper.

### Professional Distribution (Code Signed)

For distribution without security warnings, you need:

1. **Apple Developer Account** ($99/year)
2. **Developer ID Certificate**
3. **App Notarization**

#### Prerequisites

1. Sign up for [Apple Developer Program](https://developer.apple.com/programs/)
2. Install Xcode and Xcode Command Line Tools
3. Create certificates in Apple Developer Console:
   - Developer ID Application Certificate
   - Developer ID Installer Certificate (for pkg)

#### Code Signing Setup

1. **Export your credentials**:
```bash
export APPLE_ID="your@email.com"
export TEAM_ID="YOUR_10_CHAR_TEAM_ID"
export APP_PASSWORD="app-specific-password"  # Generate in Apple ID settings
```

2. **Build and sign**:
```bash
# Clean build
flutter clean
flutter pub get

# Release build
flutter build macos --release

# Sign the app bundle
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name (TEAM_ID)" --options runtime build/macos/Build/Products/Release/markdown_editor.app

# Verify signing
codesign -vvv --deep --strict build/macos/Build/Products/Release/markdown_editor.app
spctl -a -vvv build/macos/Build/Products/Release/markdown_editor.app
```

3. **Create signed DMG**:
```bash
# Create DMG
hdiutil create -volname "Markdown Editor" -srcfolder build/macos/Build/Products/Release/markdown_editor.app -ov -format UDZO signed_markdown_editor.dmg

# Sign DMG
codesign --force --verify --verbose --sign "Developer ID Application: Your Name (TEAM_ID)" signed_markdown_editor.dmg
```

4. **Notarize with Apple**:
```bash
# Submit for notarization
xcrun notarytool submit signed_markdown_editor.dmg --apple-id $APPLE_ID --team-id $TEAM_ID --password $APP_PASSWORD --wait

# Staple the notarization ticket
xcrun stapler staple signed_markdown_editor.dmg

# Verify notarization
xcrun stapler validate signed_markdown_editor.dmg
spctl -a -vvv signed_markdown_editor.dmg
```

## Mac App Store Distribution

### Prerequisites

1. **Apple Developer Program membership** ($99/year)
2. **Mac App Store certificates**:
   - Mac App Store Application Certificate
   - Mac App Store Installer Certificate
3. **App Store Connect** account setup

### App Store Configuration

1. **Update entitlements for App Store**:

Create/update `macos/Runner/AppStore.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
</dict>
</plist>
```

2. **Update Bundle Identifier**:

Edit `macos/Runner/Configs/AppInfo.xcconfig`:
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourname.markdowneditor
```

3. **Configure Xcode project**:
   - Open `macos/Runner.xcworkspace` in Xcode
   - Select Runner target → Signing & Capabilities
   - Set Team to your Apple Developer Team
   - Enable "Automatically manage signing"
   - Set Bundle Identifier to match App Store Connect

### App Store Build Process

1. **Create App Store Connect entry**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Create new macOS app
   - Set Bundle ID, app name, etc.

2. **Build for App Store**:
```bash
# Clean build
flutter clean
flutter pub get

# App Store release build
flutter build macos --release --build-name=1.0.0 --build-number=1

# Archive in Xcode (required for App Store)
open macos/Runner.xcworkspace
```

3. **Archive and Upload via Xcode**:
   - In Xcode: Product → Archive
   - When archive completes: Distribute App
   - Choose "App Store Connect"
   - Upload to App Store Connect

4. **Alternative: Command Line Upload**:
```bash
# Build archive
xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath build/Runner.xcarchive

# Export for App Store
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportPath build/AppStore -exportOptionsPlist macos/ExportOptions.plist

# Upload to App Store
xcrun altool --upload-app --type osx --file "build/AppStore/markdown_editor.pkg" --username $APPLE_ID --password $APP_PASSWORD
```

5. **Create ExportOptions.plist**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

### App Store Review Preparation

1. **App metadata** (in App Store Connect):
   - App description
   - Keywords
   - Screenshots (required: 1280x800, 1440x900, 2560x1600, 2880x1800)
   - App icon (512x512, 1024x1024)
   - Privacy policy URL (if collecting data)

2. **Review notes**:
   - Test account credentials (if needed)
   - Special instructions for reviewers
   - Demo content or files

3. **Submit for review**:
   - Complete all metadata
   - Upload build
   - Submit for App Store review
   - Review typically takes 1-7 days

### Common App Store Issues

- **Sandboxing**: Ensure all required entitlements are declared
- **File access**: Document why file system access is needed
- **Privacy**: Declare any data collection in Privacy Policy
- **Icons**: Provide all required icon sizes
- **Screenshots**: Must show actual app functionality

### Testing App Store Build

```bash
# Test sandbox entitlements
codesign -d --entitlements - build/macos/Build/Products/Release/markdown_editor.app

# Test app functionality
open build/macos/Build/Products/Release/markdown_editor.app
```
