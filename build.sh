#!/bin/bash

# Build script for droplet macOS app
# Creates a proper .app bundle with Sparkle for auto-updates

set -e

APP_NAME="droplet"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
FRAMEWORKS_DIR="${CONTENTS_DIR}/Frameworks"

echo "🔨 Building droplet in release mode..."
swift build -c release

echo "📦 Creating app bundle..."

# Clean previous bundle
rm -rf "${APP_BUNDLE}"

# Create directory structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"
mkdir -p "${FRAMEWORKS_DIR}"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

# Copy Info.plist
cp "Resources/Info.plist" "${CONTENTS_DIR}/"

# Copy Sounds folder if it exists
if [ -d "Resources/Sounds" ]; then
    echo "🎵 Bundling sounds..."
    cp -r "Resources/Sounds" "${RESOURCES_DIR}/"
fi

# Copy app icon if it exists
if [ -f "Resources/AppIcon.icns" ]; then
    echo "🎨 Adding app icon..."
    cp "Resources/AppIcon.icns" "${RESOURCES_DIR}/"
fi

# Copy Sparkle framework
SPARKLE_PATH=$(find .build -name "Sparkle.framework" -type d 2>/dev/null | head -1)
if [ -n "$SPARKLE_PATH" ]; then
    echo "✨ Adding Sparkle framework..."
    cp -R "$SPARKLE_PATH" "${FRAMEWORKS_DIR}/"
fi

# Create a simple PkgInfo
echo "APPL????" > "${CONTENTS_DIR}/PkgInfo"

echo "✅ App bundle created: ${APP_BUNDLE}"
echo ""
echo "To run: open ${APP_BUNDLE}"
echo "To install: cp -r ${APP_BUNDLE} /Applications/"

