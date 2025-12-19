#!/bin/bash

# Create elegant DMG installer for droplet
# Features: Positioned icons, clean design

set -e

APP_NAME="droplet"
DMG_NAME="droplet-installer"
VOL_NAME="droplet"
APP_BUNDLE="${APP_NAME}.app"
DMG_TEMP="dmg_temp"
DMG_RW="droplet_rw.dmg"
DMG_FINAL="${DMG_NAME}.dmg"
WINDOW_WIDTH=540
WINDOW_HEIGHT=380

echo "📦 Creating elegant DMG installer..."

# Make sure the app is built
if [ ! -d "${APP_BUNDLE}" ]; then
    echo "🔨 Building app first..."
    ./build.sh
fi

# Verify sounds are included
SOUND_COUNT=0
if [ -d "${APP_BUNDLE}/Contents/Resources/Sounds" ]; then
    SOUND_COUNT=$(ls -1 "${APP_BUNDLE}/Contents/Resources/Sounds" 2>/dev/null | wc -l | tr -d ' ')
    echo "🎵 Sounds bundled: ${SOUND_COUNT} files"
fi

# Clean up previous
rm -rf "${DMG_TEMP}"
rm -f "${DMG_RW}" "${DMG_FINAL}"

# Force unmount if already mounted
hdiutil detach "/Volumes/${VOL_NAME}" 2>/dev/null || true
sleep 1

# Create temp directory
mkdir -p "${DMG_TEMP}"

# Copy app
echo "📁 Copying app..."
cp -r "${APP_BUNDLE}" "${DMG_TEMP}/"

# Create Applications symlink
ln -s /Applications "${DMG_TEMP}/Applications"

# Calculate size (add buffer for DMG overhead)
APP_SIZE=$(du -sm "${DMG_TEMP}" | cut -f1)
DMG_SIZE=$((APP_SIZE + 20))

echo "📀 Creating read-write DMG (${DMG_SIZE}MB)..."

# Create read-write DMG first
hdiutil create -volname "${VOL_NAME}" \
    -srcfolder "${DMG_TEMP}" \
    -ov -format UDRW \
    -size ${DMG_SIZE}m \
    "${DMG_RW}"

# Mount the DMG
echo "🎨 Styling DMG window..."
MOUNT_OUTPUT=$(hdiutil attach -readwrite -noverify "${DMG_RW}")
MOUNT_DIR="/Volumes/${VOL_NAME}"

sleep 2

# Use AppleScript to style the Finder window
osascript << APPLESCRIPT
tell application "Finder"
    tell disk "${VOL_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, $((100 + WINDOW_WIDTH)), $((100 + WINDOW_HEIGHT))}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 96
        set text size of viewOptions to 13
        -- Position icons nicely
        set position of item "${APP_NAME}.app" of container window to {140, 180}
        set position of item "Applications" of container window to {400, 180}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
APPLESCRIPT

# Wait for Finder to finish
sleep 3

# Sync and unmount
sync
hdiutil detach "$MOUNT_DIR" -force

# Wait for unmount
sleep 2

echo "🗜️  Compressing DMG..."

# Convert to compressed read-only DMG
hdiutil convert "${DMG_RW}" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "${DMG_FINAL}"

# Clean up
rm -rf "${DMG_TEMP}"
rm -f "${DMG_RW}"

FINAL_SIZE=$(du -h "${DMG_FINAL}" | cut -f1)

echo ""
echo "✅ ${DMG_FINAL} created (${FINAL_SIZE})"
echo ""
echo "📦 Contents:"
echo "   • droplet.app (with ${SOUND_COUNT} bundled sounds)"
echo "   • Applications shortcut"
echo ""
echo "🚀 Open and drag droplet → Applications to install"
