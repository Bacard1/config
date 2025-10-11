#!/bin/bash

# Auto setup script for termux-junk-cleaner with all options
# This script will install and configure everything automatically

echo "=============================================="
echo "   AUTOMATIC TERMUX CLEANUP SETUP"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Check and install git if needed
print_status "Checking if git is installed..."
if ! command -v git &> /dev/null; then
    print_warning "Git not found. Installing git..."
    pkg update -y && pkg install git -y
    if [ $? -eq 0 ]; then
        print_success "Git installed successfully"
    else
        print_error "Failed to install git"
        exit 1
    fi
else
    print_success "Git is already installed"
fi

# Step 2: Clone the termux-junk-cleaner repository
print_status "Cloning termux-junk-cleaner repository..."
if [ -d "termux-junk-cleaner" ]; then
    print_warning "termux-junk-cleaner directory already exists. Updating..."
    cd termux-junk-cleaner
    git pull
    cd ..
else
    git clone https://github.com/ArjunCodesmith/termux-junk-cleaner.git
    if [ $? -eq 0 ]; then
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository"
        exit 1
    fi
fi

# Step 3: Make the main script executable
print_status "Making termux-junk-cleaner executable..."
chmod +x ~/termux-junk-cleaner/termux-junk-cleaner.sh
if [ $? -eq 0 ]; then
    print_success "Script made executable"
else
    print_error "Failed to make script executable"
    exit 1
fi

# Step 4: Create the cleanup-options.sh script
print_status "Creating cleanup-options.sh script..."
cat > ~/cleanup-options.sh << 'EOF'
#!/bin/bash

# Script for calling termux-junk-cleaner with different options
# Location: ~/termux-junk-cleaner/

SCRIPT_DIR="$HOME/termux-junk-cleaner"
SCRIPT="$SCRIPT_DIR/termux-junk-cleaner.sh"

# Check if script exists
if [ ! -f "$SCRIPT" ]; then
    echo "Error: termux-junk-cleaner.sh not found in $SCRIPT_DIR"
    echo "Please make sure the script is installed in the correct location"
    exit 1
fi

# Check if script is executable
if [ ! -x "$SCRIPT" ]; then
    echo "Making script executable..."
    chmod +x "$SCRIPT"
fi

# Function to display usage
usage() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  -c    Clean cache files"
    echo "  -p    Clean cached packages" 
    echo "  -n    Remove unnecessary packages"
    echo "  -t    Clean temporary files"
    echo "  -b    Clean temporary backup files"
    echo "  -l    Clean unnecessary logs"
    echo "  -a    Clean all types of junk"
    echo "  -h    Show this help message"
}

# Parse command line options
case "$1" in
    -c)
        echo "Cleaning cache files..."
        "$SCRIPT" -c
        ;;
    -p)
        echo "Cleaning cached packages..."
        "$SCRIPT" -p
        ;;
    -n)
        echo "Removing unnecessary packages..."
        "$SCRIPT" -n
        ;;
    -t)
        echo "Cleaning temporary files..."
        "$SCRIPT" -t
        ;;
    -b)
        echo "Cleaning temporary backup files..."
        "$SCRIPT" -b
        ;;
    -l)
        echo "Cleaning unnecessary logs..."
        "$SCRIPT" -l
        ;;
    -a)
        echo "Cleaning all types of junk..."
        "$SCRIPT" -a
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo "Error: No option specified or invalid option"
        usage
        exit 1
        ;;
esac
EOF

if [ $? -eq 0 ]; then
    print_success "cleanup-options.sh created successfully"
else
    print_error "Failed to create cleanup-options.sh"
    exit 1
fi

# Step 5: Make cleanup-options.sh executable
chmod +x ~/cleanup-options.sh
print_success "cleanup-options.sh made executable"

# Step 6: Add aliases to .bashrc
print_status "Adding aliases to .bashrc..."
if ! grep -q "Termux junk cleaner aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Termux junk cleaner aliases
alias clean-cache='~/termux-junk-cleaner/termux-junk-cleaner.sh -c'
alias clean-packages='~/termux-junk-cleaner/termux-junk-cleaner.sh -p'
alias remove-unnecessary='~/termux-junk-cleaner/termux-junk-cleaner.sh -n'
alias clean-temp='~/termux-junk-cleaner/termux-junk-cleaner.sh -t'
alias clean-backups='~/termux-junk-cleaner/termux-junk-cleaner.sh -b'
alias clean-logs='~/termux-junk-cleaner/termux-junk-cleaner.sh -l'
alias clean-all='~/termux-junk-cleaner/termux-junk-cleaner.sh -a'
alias cleanup-menu='~/cleanup-options.sh'

EOF
    print_success "Aliases added to .bashrc"
else
    print_warning "Aliases already exist in .bashrc"
fi

# Step 7: Create the menu version script
print_status "Creating cleanup-menu.sh script..."
cat > ~/cleanup-menu.sh << 'EOF'
#!/bin/bash

# Improved cleanup script with menu
SCRIPT_DIR="$HOME/termux-junk-cleaner"
SCRIPT="$SCRIPT_DIR/termux-junk-cleaner.sh"

# Check if script exists
if [ ! -f "$SCRIPT" ]; then
    echo "Error: termux-junk-cleaner.sh not found in $SCRIPT_DIR"
    exit 1
fi

if [ ! -x "$SCRIPT" ]; then
    chmod +x "$SCRIPT"
fi

# If no arguments provided, show menu
if [ $# -eq 0 ]; then
    echo "======================================"
    echo "    TERMUX CLEANUP MENU"
    echo "======================================"
    echo "1) Clean cache files (-c)"
    echo "2) Clean cached packages (-p)"
    echo "3) Remove unnecessary packages (-n)"
    echo "4) Clean temporary files (-t)"
    echo "5) Clean temporary backup files (-b)"
    echo "6) Clean unnecessary logs (-l)"
    echo "7) Clean ALL junk (-a)"
    echo "8) Show help (-h)"
    echo "9) Exit"
    echo "======================================"
    read -p "Choose an option (1-9): " choice
    
    case $choice in
        1) option="-c" ;;
        2) option="-p" ;;
        3) option="-n" ;;
        4) option="-t" ;;
        5) option="-b" ;;
        6) option="-l" ;;
        7) option="-a" ;;
        8) option="-h" ;;
        9) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option!"; exit 1 ;;
    esac
else
    option="$1"
fi

# Execute the chosen option
case "$option" in
    -c)
        echo "Cleaning cache files..."
        "$SCRIPT" -c
        ;;
    -p)
        echo "Cleaning cached packages..."
        "$SCRIPT" -p
        ;;
    -n)
        echo "Removing unnecessary packages..."
        "$SCRIPT" -n
        ;;
    -t)
        echo "Cleaning temporary files..."
        "$SCRIPT" -t
        ;;
    -b)
        echo "Cleaning temporary backup files..."
        "$SCRIPT" -b
        ;;
    -l)
        echo "Cleaning unnecessary logs..."
        "$SCRIPT" -l
        ;;
    -a)
        echo "Cleaning all types of junk..."
        "$SCRIPT" -a
        ;;
    -h|--help)
        echo "Usage: $0 [OPTION]"
        echo "Options:"
        echo "  -c    Clean cache files"
        echo "  -p    Clean cached packages"
        echo "  -n    Remove unnecessary packages"
        echo "  -t    Clean temporary files"
        echo "  -b    Clean temporary backup files"
        echo "  -l    Clean unnecessary logs"
        echo "  -a    Clean all types of junk"
        echo "  -h    Show this help message"
        echo ""
        echo "If no option provided, shows interactive menu."
        ;;
    *)
        echo "Error: Invalid option '$option'"
        echo "Use '$0 -h' for help."
        exit 1
        ;;
esac
EOF

chmod +x ~/cleanup-menu.sh
print_success "cleanup-menu.sh created and made executable"

# Step 8: Reload bashrc
print_status "Reloading .bashrc..."
source ~/.bashrc
print_success ".bashrc reloaded"

# Step 9: Test the installation
print_status "Testing the installation..."
if [ -f ~/termux-junk-cleaner/termux-junk-cleaner.sh ] && [ -x ~/termux-junk-cleaner/termux-junk-cleaner.sh ]; then
    print_success "Main script is installed and executable"
else
    print_error "Main script test failed"
    exit 1
fi

# Final summary
echo ""
echo "=============================================="
print_success "SETUP COMPLETED SUCCESSFULLY!"
echo "=============================================="
echo ""
echo "Available commands:"
echo "  ${GREEN}clean-cache${NC}        - Clean cache files"
echo "  ${GREEN}clean-packages${NC}      - Clean cached packages"
echo "  ${GREEN}remove-unnecessary${NC}  - Remove unnecessary packages"
echo "  ${GREEN}clean-temp${NC}          - Clean temporary files"
echo "  ${GREEN}clean-backups${NC}       - Clean temporary backup files"
echo "  ${GREEN}clean-logs${NC}          - Clean unnecessary logs"
echo "  ${GREEN}clean-all${NC}           - Clean all types of junk"
echo "  ${GREEN}cleanup-menu${NC}        - Show interactive menu"
echo "  ${GREEN}./cleanup-options.sh${NC} - Script with options"
echo "  ${GREEN}./cleanup-menu.sh${NC}    - Interactive menu script"
echo ""
echo "Usage examples:"
echo "  clean-all                    # Clean everything"
echo "  clean-cache                 # Clean cache only"
echo "  ./cleanup-options.sh -a     # Alternative way"
echo "  ./cleanup-menu.sh           # Interactive menu"
echo ""
print_success "You're ready to use the cleanup system!"