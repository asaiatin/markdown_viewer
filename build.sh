#!/usr/bin/env bash
set -e

APP_NAME="MarkdownViewer"
BUNDLE="$APP_NAME.app"
BUILD_DIR=".build/release"

echo "🔨 Building $APP_NAME..."
swift build -c release

echo "📦 Creating app bundle..."
rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS"
mkdir -p "$BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$BUNDLE/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>com.local.MarkdownViewer</string>
  <key>CFBundleName</key>
  <string>Markdown Viewer</string>
  <key>CFBundleDisplayName</key>
  <string>Markdown Viewer</string>
  <key>CFBundleExecutable</key>
  <string>MarkdownViewer</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
  </dict>
</dict>
</plist>
PLIST

echo "✅ Done! App bundle created at: $BUNDLE"
echo ""
echo "To open: open $BUNDLE"
echo "To move to Applications: mv $BUNDLE /Applications/"
