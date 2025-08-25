#!/bin/bash

# Markdown Editor Release Build Script
# Usage: ./build_release.sh [signed|unsigned|appstore]

set -e

BUILD_TYPE=${1:-unsigned}
APP_NAME="markdown_editor"
VERSION="1.0.0"
BUILD_NUMBER="1"

echo "🚀 Building Markdown Editor - Type: $BUILD_TYPE"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Clean build
print_status "Cleaning previous build..."
flutter clean
flutter pub get

# Build release
print_status "Building release version..."
case $BUILD_TYPE in
    "appstore")
        flutter build macos --release --build-name=$VERSION --build-number=$BUILD_NUMBER
        ;;
    *)
        flutter build macos --release
        ;;
esac

APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"

if [ ! -d "$APP_PATH" ]; then
    print_error "Build failed - app not found at $APP_PATH"
    exit 1
fi

print_status "Build completed successfully!"

# Distribution
case $BUILD_TYPE in
    "unsigned")
        print_status "Creating unsigned distribution files..."
        
        # Create ZIP
        cd build/macos/Build/Products/Release
        zip -r "../../../../../${APP_NAME}_macos.zip" "${APP_NAME}.app"
        cd - > /dev/null
        
        # Create DMG
        hdiutil create -volname "Markdown Editor" -srcfolder "$APP_PATH" -ov -format UDZO "${APP_NAME}_macos.dmg"
        
        print_status "Created distribution files:"
        echo "  📁 ${APP_NAME}_macos.zip"
        echo "  💽 ${APP_NAME}_macos.dmg"
        print_warning "Note: Users will see security warnings. Use 'signed' build for distribution."
        ;;
        
    "signed")
        print_status "Creating signed distribution files..."
        
        # Check for required environment variables
        if [ -z "$APPLE_ID" ] || [ -z "$TEAM_ID" ] || [ -z "$APP_PASSWORD" ]; then
            print_error "Missing required environment variables:"
            echo "  export APPLE_ID=\"your@email.com\""
            echo "  export TEAM_ID=\"YOUR_10_CHAR_TEAM_ID\""
            echo "  export APP_PASSWORD=\"app-specific-password\""
            exit 1
        fi
        
        # Find signing identity
        SIGNING_IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed 's/.*) \(.*\)/\1/')
        
        if [ -z "$SIGNING_IDENTITY" ]; then
            print_error "No Developer ID Application certificate found"
            echo "Please install your Developer ID certificate from Apple Developer Portal"
            exit 1
        fi
        
        print_status "Using signing identity: $SIGNING_IDENTITY"
        
        # Sign the app
        codesign --deep --force --verify --verbose --sign "$SIGNING_IDENTITY" --options runtime "$APP_PATH"
        
        # Verify signing
        print_status "Verifying code signature..."
        codesign -vvv --deep --strict "$APP_PATH"
        
        # Create signed DMG
        hdiutil create -volname "Markdown Editor" -srcfolder "$APP_PATH" -ov -format UDZO "signed_${APP_NAME}.dmg"
        
        # Sign DMG
        codesign --force --verify --verbose --sign "$SIGNING_IDENTITY" "signed_${APP_NAME}.dmg"
        
        # Notarize
        print_status "Submitting for notarization (this may take several minutes)..."
        xcrun notarytool submit "signed_${APP_NAME}.dmg" --apple-id "$APPLE_ID" --team-id "$TEAM_ID" --password "$APP_PASSWORD" --wait
        
        # Staple notarization
        print_status "Stapling notarization ticket..."
        xcrun stapler staple "signed_${APP_NAME}.dmg"
        
        # Verify notarization
        xcrun stapler validate "signed_${APP_NAME}.dmg"
        spctl -a -vvv "signed_${APP_NAME}.dmg"
        
        print_status "Created signed distribution file:"
        echo "  💽 signed_${APP_NAME}.dmg"
        ;;
        
    "appstore")
        print_status "Preparing for App Store submission..."
        print_warning "Open Xcode to complete the archive and upload process:"
        echo "  open macos/Runner.xcworkspace"
        echo ""
        echo "In Xcode:"
        echo "  1. Product → Archive"
        echo "  2. Distribute App → App Store Connect"
        echo "  3. Upload to App Store Connect"
        ;;
esac

print_status "Build process completed!"
