#!/bin/bash
# Complete System Update Script for Arch Linux
# Created: March 20, 2025
# Updated: March 23, 2025 - Added package update logging

# Create logs directory if it doesn't exist
mkdir -p ~/logs

# Log file location
LOG_FILE=~/logs/system_update.log
LOG_DIR=~/logs
MAX_LOG_SIZE_KB=1024  # 1MB
MAX_LOG_AGE_DAYS=30   # Keep logs for 30 days
MAX_LOG_FILES=5       # Keep at most 5 rotated log files

# Critical packages to monitor
CRITICAL_PACKAGES=(
    "linux"           # Kernel
    "linux-lts"       # LTS Kernel
    "linux-zen"       # Zen Kernel
    "linux-hardened"  # Hardened Kernel
    "linux-firmware"  # Kernel firmware
    "mkinitcpio"      # Initial ramdisk
    "coreutils"       # Core utilities
    "libglvnd"        # OpenGL Vendor-Neutral Dispatch library
    "util-linux"      # System utilities
    "wpa_supplicant"  # Wi-Fi supplicant
    "git"             # Version control
    "openssh"         # SSH
    "xorg-xrandr"     # X Resize, Rotate and Reflect extension
    "filesystem"      # Filesystem
    "i3-wm"           # i3 window manager
    "dmenu"           # dmenu
    "rofi"            # Rofi
    "xorg-server"     # X server
    "xorg-init"       # X server initialization
    "wezterm"         # WezTerm terminal
    "fish"            # Fish shell
    "networkmanager"  # Network manager
    "grub"            # Boot loader
    "systemd"         # System and service manager
    "glibc"           # GNU C Library
    "bash"            # Bourne Again SHell
    "pacman"          # Package manager
    "sudo"            # Privilege escalation
    "xorg-server"     # X server
    "wayland"         # Wayland compositor
    "mesa"            # OpenGL implementation
    "nvidia"          # NVIDIA drivers
    "nvidia-lts"      # NVIDIA LTS drivers
    "amd-ucode"       # AMD microcode
    "intel-ucode"     # Intel microcode
)

# Initialize arrays for tracking critical updates
CRITICAL_UPDATES=()
KERNEL_UPDATED=false

# Function to rotate logs
rotate_logs() {
    # Check if log file exists and is larger than MAX_LOG_SIZE_KB
    if [[ -f "$LOG_FILE" ]] && [[ $(du -k "$LOG_FILE" | cut -f1) -gt $MAX_LOG_SIZE_KB ]]; then
        echo "Log file exceeds ${MAX_LOG_SIZE_KB}KB, rotating..."
        
        # Rotate existing backup logs
        for i in $(seq $((MAX_LOG_FILES-1)) -1 1); do
            if [[ -f "${LOG_FILE}.$i" ]]; then
                mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
            fi
        done
        
        # Move current log to .1
        mv "$LOG_FILE" "${LOG_FILE}.1"
        
        # Create new empty log file
        touch "$LOG_FILE"
        
        # Remove logs beyond MAX_LOG_FILES
        if [[ -f "${LOG_FILE}.$((MAX_LOG_FILES+1))" ]]; then
            rm "${LOG_FILE}.$((MAX_LOG_FILES+1))"
        fi
    fi
    
    # Clean up old log files (older than MAX_LOG_AGE_DAYS)
    find "$LOG_DIR" -name "system_update.log.*" -type f -mtime +$MAX_LOG_AGE_DAYS -delete
}

# Rotate logs before starting new update
rotate_logs

# Log header with date and time
echo "=======================================================" >> "$LOG_FILE"
echo "System update started at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "=======================================================" >> "$LOG_FILE"

echo "Starting complete system update..."
echo "=================================="

# Function to log package updates
log_updates() {
    local package_manager=$1
    local updates_file=$2
    
    # Parse the pacman/yay output and log updates
    while IFS= read -r line; do
        if [[ $line =~ ([a-zA-Z0-9_\-\.]+)\ \(([0-9\.a-z\-]+)\ \-\>\ ([0-9\.a-z\-]+)\) ]]; then
            package_name="${BASH_REMATCH[1]}"
            old_version="${BASH_REMATCH[2]}"
            new_version="${BASH_REMATCH[3]}"
            
            # log the update
            echo "$(date '+%Y-%m-%d %H:%M:%S'), $package_manager, $package_name, $old_version -> $new_version" >> "$LOG_FILE"

             # Check if this is a critical package
            for critical in "${CRITICAL_PACKAGES[@]}"; do
                if [[ "$package_name" == "$critical" || "$package_name" == "$critical-"* ]]; then
                    CRITICAL_UPDATES+=("$package_name ($old_version -> $new_version)")
                    
                    # Check if it's a kernel update
                    if [[ "$package_name" == "linux" || "$package_name" == "linux-"* ]]; then
                        KERNEL_UPDATED=true
                    fi
                    break
                fi
            done
        fi
    done < "$updates_file"
}

# Update the package databases and upgrade all packages
echo "Step 1: Updating package databases and upgrading packages..."
# Create a temporary file to store pacman output
PACMAN_OUTPUT=$(mktemp)
sudo pacman -Syuv --noconfirm 2>&1 | tee "$PACMAN_OUTPUT"

# Log pacman updates
echo "Logging pacman updates..." >> "$LOG_FILE"
log_updates "pacman" "$PACMAN_OUTPUT"
rm -f "$PACMAN_OUTPUT"

# Clean the package cache to free up disk space
echo "Step 2: Cleaning package cache..."
sudo pacman -Scv --noconfirm

# Update AUR packages if yay is installed
if command -v yay &> /dev/null; then
    echo "Step 3: Updating AUR packages using yay..."
    # Create a temporary file to store yay output
    YAY_OUTPUT=$(mktemp)
    yay -Suav --noconfirm 2>&1 | tee "$YAY_OUTPUT"
    
    # Log yay updates
    echo "Logging yay updates..." >> "$LOG_FILE"
    log_updates "yay" "$YAY_OUTPUT"
    rm -f "$YAY_OUTPUT"
fi

# Check for failed systemd services
echo "Step 4: Checking for failed systemd services..."
FAILED_SERVICES=$(systemctl --failed)
echo -e "\nFailed systemd services:" >> "$LOG_FILE"
echo "$FAILED_SERVICES" >> "$LOG_FILE"

# Check system journal for errors
echo "Step 5: Checking system journal for errors..."
JOURNAL_ERRORS=$(journalctl -p 3 -xb --no-pager | tail -n 20)
echo -e "\nRecent system journal errors:" >> "$LOG_FILE"
echo "$JOURNAL_ERRORS" >> "$LOG_FILE"

# Log critical updates
if [ ${#CRITICAL_UPDATES[@]} -gt 0 ]; then
    echo -e "\nCritical package updates detected:" >> "$LOG_FILE"
    for update in "${CRITICAL_UPDATES[@]}"; do
        echo "  - $update" >> "$LOG_FILE"
    done
fi

# Log footer
echo -e "\nSystem update completed at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "=======================================================" >> "$LOG_FILE"

echo "=================================="
echo "System update completed!"
echo "Updated packages have been logged to $LOG_FILE"
echo "Log rotation is enabled: logs over ${MAX_LOG_SIZE_KB}KB will be rotated, and logs older than ${MAX_LOG_AGE_DAYS} days will be deleted"

# Display critical update notification
if [ ${#CRITICAL_UPDATES[@]} -gt 0 ]; then
    echo ""
    echo "!!! IMPORTANT: Critical system packages were updated !!!"
    echo "The following critical packages were updated:"
    for update in "${CRITICAL_UPDATES[@]}"; do
        echo "  - $update"
    done
    
    if [ "$KERNEL_UPDATED" = true ]; then
        echo ""
        echo "!!! KERNEL UPDATE DETECTED !!!"
        echo "A system reboot is STRONGLY RECOMMENDED to apply the kernel update."
        echo "To reboot, type: reboot"
    else
        echo ""
        echo "A system reboot is recommended to apply these critical updates."
        echo "To reboot, type: reboot"
    fi
else
    echo "No critical system packages were updated."
    echo "A reboot is not necessary at this time."
fi
