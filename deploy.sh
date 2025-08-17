#!/bin/bash

# GuildItemScanner-UI Deployment Script
# Deploys addon to WoW Classic Era AddOns directory

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying GuildItemScanner-UI addon...${NC}"

# Source directory (current directory)
SOURCE_DIR="$(pwd)"

# Target directory - WoW Classic Era AddOns folder
TARGET_DIR="$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles/Games/drive_c/Program Files (x86)/World of Warcraft/_classic_era_/Interface/AddOns/GuildItemScanner-UI"

echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"

# Verify source directory contains the addon
if [ ! -f "$SOURCE_DIR/GuildItemScanner-UI.toc" ]; then
    echo -e "${RED}Error: GuildItemScanner-UI.toc not found in current directory!${NC}"
    echo "Please run this script from the GuildItemScanner-UI directory."
    exit 1
fi

# Create target directory if it doesn't exist
echo -e "${YELLOW}Creating target directory...${NC}"
mkdir -p "$TARGET_DIR"

# Remove old files from target
echo -e "${YELLOW}Removing existing files from target directory...${NC}"
rm -rf "$TARGET_DIR"/*

# Copy addon files (exclude development files)
echo -e "${YELLOW}Copying addon files...${NC}"
rsync -av \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='README.md' \
    --exclude='CLAUDE.md' \
    --exclude='deploy.sh' \
    --exclude='.DS_Store' \
    --exclude='Thumbs.db' \
    --exclude='*.bak' \
    --exclude='*.tmp' \
    "$SOURCE_DIR/" "$TARGET_DIR/"

# Verify deployment
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deployment successful!${NC}"
    echo "Files copied to: $TARGET_DIR"
    
    # List deployed files
    echo -e "${YELLOW}Deployed files:${NC}"
    ls -la "$TARGET_DIR"
    
    # Check if main files exist
    if [ -f "$TARGET_DIR/GuildItemScanner-UI.toc" ] && [ -f "$TARGET_DIR/GuildItemScanner-UI.lua" ]; then
        echo -e "${GREEN}✓ Core addon files present${NC}"
    else
        echo -e "${RED}✗ Missing core addon files!${NC}"
        exit 1
    fi
    
    # Check modules directory
    if [ -d "$TARGET_DIR/modules" ]; then
        module_count=$(ls -1 "$TARGET_DIR/modules"/*.lua 2>/dev/null | wc -l)
        echo -e "${GREEN}✓ Modules directory present ($module_count modules)${NC}"
    else
        echo -e "${RED}✗ Missing modules directory!${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}Ready to test in World of Warcraft!${NC}"
    echo "1. Start/restart WoW Classic Era"
    echo "2. Enable 'GuildItemScanner-UI' in the addon list"
    echo "3. Ensure 'GuildItemScanner' is also enabled"
    echo "4. Look for the minimap button or type '/gisui'"
    
else
    echo -e "${RED}Deployment failed!${NC}"
    exit 1
fi