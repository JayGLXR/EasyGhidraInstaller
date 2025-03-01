#!/bin/bash

# EasyGhidraInstaller - Setup Ghidra as a macOS application
# This script will:
# 1. Download the latest version of Ghidra (if not already downloaded)
# 2. Extract the Ghidra zip file
# 3. Create an application wrapper
# 4. Add a proper icon and make it launchable from Dock

# Exit on any error
set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}==>${NC} $1"
}

# Function to download the latest Ghidra
download_latest_ghidra() {
    print_step "Downloading the latest version of Ghidra..."
    
    # Get the download page
    GHIDRA_PAGE=$(curl -s -L "https://ghidra-sre.org/")
    
    # Extract the latest version link
    LATEST_LINK=$(echo "$GHIDRA_PAGE" | grep -o 'https://[^"]*_PUBLIC_[^"]*\.zip' | head -1)
    
    if [ -z "$LATEST_LINK" ]; then
        print_warning "Failed to find download link. Using fallback URL..."
        LATEST_LINK="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.3.1_build/ghidra_11.3.1_PUBLIC_20250219.zip"
    fi
    
    # Extract filename from URL
    FILENAME=$(basename "$LATEST_LINK")
    
    print_step "Downloading $FILENAME..."
    curl -L "$LATEST_LINK" -o "/tmp/$FILENAME"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download Ghidra."
        exit 1
    fi
    
    print_success "Download complete."
    echo "$FILENAME"
}

# Check if Ghidra zip exists at the specified location or download it
if [ -f "/Applications/ghidra_11.3.1_PUBLIC_20250219.zip" ]; then
    GHIDRA_ZIP="/Applications/ghidra_11.3.1_PUBLIC_20250219.zip"
    print_warning "Using existing Ghidra zip file: $GHIDRA_ZIP"
else
    # Ask if user wants to download the latest version
    read -p "No Ghidra zip file found. Do you want to download the latest version? (y/n): " DOWNLOAD_CHOICE
    if [[ "$DOWNLOAD_CHOICE" =~ ^[Yy]$ ]]; then
        FILENAME=$(download_latest_ghidra)
        GHIDRA_ZIP="/tmp/$FILENAME"
        
        # Extract version for later use
        GHIDRA_VERSION=$(echo "$FILENAME" | grep -o "ghidra_[0-9.]*_PUBLIC" | sed 's/ghidra_//;s/_PUBLIC//')
        GHIDRA_DIR_NAME=$(echo "$FILENAME" | sed 's/\.zip$//')
    else
        echo "Please download Ghidra manually and run this script again."
        exit 1
    fi
fi

# Extract version and directory name from the zip filename if not already set
if [ -z "$GHIDRA_VERSION" ]; then
    GHIDRA_VERSION=$(basename "$GHIDRA_ZIP" | grep -o "ghidra_[0-9.]*_PUBLIC" | sed 's/ghidra_//;s/_PUBLIC//')
    GHIDRA_DIR_NAME=$(basename "$GHIDRA_ZIP" | sed 's/\.zip$//')
fi

# Set up paths
EXTRACT_DIR="/Applications"
GHIDRA_DIR="$EXTRACT_DIR/$GHIDRA_DIR_NAME"
APP_NAME="Ghidra.app"
APP_PATH="/Applications/$APP_NAME"

# Step 1: Extract the zip file if not already extracted
if [ ! -d "$GHIDRA_DIR" ]; then
    print_step "Extracting Ghidra..."
    unzip -q "$GHIDRA_ZIP" -d "$EXTRACT_DIR"
    print_success "Extraction complete."
else
    print_warning "Ghidra directory already exists. Skipping extraction."
fi

# Step 2: Check if Java is installed
print_step "Checking Java installation..."
if ! command -v java &> /dev/null; then
    print_warning "Java not found. Checking for Homebrew to install OpenJDK..."
    if command -v brew &> /dev/null; then
        print_step "Installing OpenJDK 17 via Homebrew..."
        brew install openjdk@17
        print_success "OpenJDK 17 installed."
    else
        print_warning "Homebrew not found. Please install Java manually before running Ghidra."
        print_warning "You can install Homebrew with: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        print_warning "Then install Java with: brew install openjdk@17"
    fi
else
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    print_success "Java found (version: $JAVA_VERSION)."
fi

# Step 3: Create a proper macOS application wrapper
print_step "Creating macOS application wrapper..."

# Remove existing app if it exists
if [ -d "$APP_PATH" ]; then
    print_warning "Removing existing Ghidra application..."
    rm -rf "$APP_PATH"
fi

# Create the application bundle structure
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>GhidraLauncher</string>
    <key>CFBundleIconFile</key>
    <string>ghidra.icns</string>
    <key>CFBundleIdentifier</key>
    <string>org.ghidra.Ghidra</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Ghidra</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${GHIDRA_VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${GHIDRA_VERSION}</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create launcher script
cat > "$APP_PATH/Contents/MacOS/GhidraLauncher" << EOF
#!/bin/bash
cd "$GHIDRA_DIR"
./ghidraRun "\$@"
EOF

# Make the launcher executable
chmod +x "$APP_PATH/Contents/MacOS/GhidraLauncher"

# Create an icon (a simple placeholder since we don't have the official icon)
# Using AppleScript to create a temporary icon from the app
print_step "Creating app icon..."

# First try to extract the icon from Ghidra's resources if it exists
ICON_SOURCE="$GHIDRA_DIR/support/ghidra.ico"
ICON_DEST="$APP_PATH/Contents/Resources/ghidra.icns"

if [ -f "$ICON_SOURCE" ]; then
    # If we have sips and iconutil, try to convert the ico to icns
    if command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
        TMP_ICONSET="$(mktemp -d)/ghidra.iconset"
        mkdir -p "$TMP_ICONSET"
        
        # Convert ico to png and resize for various icon sizes
        for size in 16 32 64 128 256 512; do
            sips -s format png --resampleHeightWidth $size $size "$ICON_SOURCE" --out "$TMP_ICONSET/icon_${size}x${size}.png" &>/dev/null || true
            sips -s format png --resampleHeightWidth $((size*2)) $((size*2)) "$ICON_SOURCE" --out "$TMP_ICONSET/icon_${size}x${size}@2x.png" &>/dev/null || true
        done
        
        # Create icns file
        iconutil -c icns "$TMP_ICONSET" -o "$ICON_DEST" &>/dev/null || true
        rm -rf "$(dirname "$TMP_ICONSET")"
    fi
fi

# If icon creation failed, use a generic icon
if [ ! -f "$ICON_DEST" ]; then
    print_warning "Could not create custom icon, using a generic app icon."
    # Create a simple AppleScript to set a generic icon
    osascript -e "tell application \"Finder\" to set icon of POSIX file \"$APP_PATH\" to icon of application \"Utilities\"" &>/dev/null || true
fi

print_success "Application wrapper created at $APP_PATH"

# Step 4: Add to dock if not already there
print_step "Adding Ghidra to your Dock..."
if ! defaults read com.apple.dock persistent-apps | grep -q "$APP_NAME"; then
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$APP_PATH</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    killall Dock
    print_success "Ghidra added to your Dock."
else
    print_warning "Ghidra appears to be already in your Dock."
fi

# Final instructions
print_success "Setup complete! You can now launch Ghidra from your Applications folder or Dock."
print_success "If you encounter any issues:"
print_warning "1. Make sure Java is properly installed (JDK 17+ recommended)"
print_warning "2. For Apple Silicon Macs, Ghidra runs via Rosetta 2"
print_warning "3. If needed, you can run directly from Terminal with: $GHIDRA_DIR/ghidraRun"

exit 0