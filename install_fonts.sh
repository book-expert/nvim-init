#!/bin/bash

# Function to display help
display_help() {
    echo -e "${BLUE}Usage: $0 <FontName>${NC}"
    echo ""
    echo "Common Nerd Fonts:"
    echo "  - FiraCode"
    echo "  - Hack"
    echo "  - SourceCodePro"
    echo "  - JetBrainsMono"
    echo "  - Meslo"
    echo "  - DroidSansMono"
    echo "  - Inconsolata"
    echo "  - Iosevka"
    echo "  - Ubuntu"
    echo "  - AnonymousPro"
    echo ""
    echo "See all options at: https://www.nerdfonts.com/font-downloads"
    exit 1
}

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Require an argument
if [ -z "$1" ]; then
    echo -e "${RED}Error: No font name provided.${NC}"
    display_help
fi

FONT_NAME="$1"
NERD_FONT_VERSION="v3.1.1" # Updated to a recent version
FONT_DIR="$HOME/.local/share/fonts"
TEMP_DIR=$(mktemp -d)

echo -e "${BLUE}Starting Nerd Font installation for: ${FONT_NAME}${NC}"

# 1. Create fonts directory if it doesn't exist
if [ ! -d "$FONT_DIR" ]; then
    echo -e "${BLUE}Creating font directory: $FONT_DIR${NC}"
    mkdir -p "$FONT_DIR"
else
    echo -e "${BLUE}Font directory exists: $FONT_DIR${NC}"
fi

# 2. Download the font
ZIP_FILE="${FONT_NAME}.zip"
DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/${ZIP_FILE}"

echo -e "${BLUE}Downloading ${ZIP_FILE} from ${DOWNLOAD_URL}...${NC}"
if ! curl -L --fail --progress-bar -o "${TEMP_DIR}/${ZIP_FILE}" "$DOWNLOAD_URL"; then
    echo -e "${RED}Error: Failed to download ${FONT_NAME}. Please check the font name and version.${NC}"
    echo -e "${RED}Valid font names: https://www.nerdfonts.com/font-downloads${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 3. Unzip the font
echo -e "${BLUE}Extracting fonts...${NC}"
if ! unzip -o -q "${TEMP_DIR}/${ZIP_FILE}" -d "$TEMP_DIR/${FONT_NAME}"; then
    echo -e "${RED}Error: Failed to unzip ${ZIP_FILE}.${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 4. Install font files
echo -e "${BLUE}Installing font files to $FONT_DIR...${NC}"
# Find all ttf and otf files and move them
find "$TEMP_DIR/${FONT_NAME}" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONT_DIR/" \;

# 5. Update font cache
echo -e "${BLUE}Updating font cache...${NC}"
if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -fv >/dev/null
    echo -e "${GREEN}Font cache updated.${NC}"
else
    echo -e "${RED}Warning: 'fc-cache' not found. You may need to run it manually or restart your session.${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Successfully installed ${FONT_NAME} Nerd Font!${NC}"
echo -e "${BLUE}IMPORTANT: Configure your terminal emulator to use '${FONT_NAME} Nerd Font' now.${NC}"
