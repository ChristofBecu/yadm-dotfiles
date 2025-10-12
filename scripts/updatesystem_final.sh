#!/bin/bash
# Arch Linux System Update Script - Final Version
# Created: March 20, 2025
# Updated: October 11, 2025 - Combined best practices from multiple versions
# Features: Robust error handling, comprehensive logging, smart cache management

set -euo pipefail

# ========================================
# Configuration
# ========================================
readonly LOG_DIR="$HOME/logs"
readonly LOG_FILE="$LOG_DIR/system_update.log"
readonly MAX_LOG_SIZE_KB=1024   # 1MB
readonly MAX_LOG_AGE_DAYS=30
readonly MAX_LOG_FILES=5
readonly UPDATE_TIMEOUT=300     # 5 minutes

# Comprehensive list of critical system packages
readonly CRITICAL_PACKAGES=(
    # Kernel and firmware
    linux linux-lts linux-zen linux-hardened linux-firmware mkinitcpio
    # Core system
    coreutils util-linux filesystem systemd glibc bash pacman sudo
    # Graphics and display
    libglvnd mesa xorg-server xorg-init xorg-xrandr wayland
    # Network
    wpa_supplicant networkmanager openssh
    # Desktop environment
    i3-wm dmenu rofi wezterm fish
    # Boot and drivers
    grub nvidia nvidia-lts amd-ucode intel-ucode
    # Development
    git
)

# Global state tracking
declare -a CRITICAL_UPDATES=()
declare -a ALL_UPDATES=()
declare -a TMPFILES=()
KERNEL_UPDATED=false
TOTAL_UPDATES=0

# ========================================
# Utility Functions
# ========================================

# Logging function that both prints to stdout and logs to file
log() {
    local message="$*"
    echo -e "$message" | tee -a "$LOG_FILE"
}

# Print step headers for better user experience
print_step() {
    local step_num="$1"
    local total_steps="$2"
    local description="$3"
    
    echo
    echo "========================================"
    echo "[$step_num/$total_steps] $description"
    echo "========================================"
    log "\n[$step_num/$total_steps] $description"
}

# Cleanup function for temporary files
cleanup() {
    local exit_code=$?
    if (( ${#TMPFILES[@]} > 0 )); then
        rm -f "${TMPFILES[@]}" 2>/dev/null || true
    fi
    
    if (( exit_code != 0 )); then
        log "\n❌ Script terminated with error (exit code: $exit_code)"
        log "Check the log file for details: $LOG_FILE"
    fi
    
    exit $exit_code
}

# Set up signal handling
trap cleanup EXIT INT TERM

# ========================================
# Log Management Functions
# ========================================

rotate_logs() {
    # Check if log file exists and is larger than MAX_LOG_SIZE_KB
    if [[ -f "$LOG_FILE" && $(du -k "$LOG_FILE" | cut -f1) -gt $MAX_LOG_SIZE_KB ]]; then
        log "📁 Log file exceeds ${MAX_LOG_SIZE_KB}KB, rotating..."
        
        # Rotate existing backup logs
        for i in $(seq $((MAX_LOG_FILES-1)) -1 1); do
            [[ -f "${LOG_FILE}.$i" ]] && mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
        done
        
        # Move current log to .1 and create new log
        mv "$LOG_FILE" "${LOG_FILE}.1"
        
        # Remove logs beyond MAX_LOG_FILES
        [[ -f "${LOG_FILE}.$((MAX_LOG_FILES+1))" ]] && rm -f "${LOG_FILE}.$((MAX_LOG_FILES+1))"
    fi
    
    # Clean up old log files
    find "$LOG_DIR" -name "system_update.log.*" -type f -mtime +$MAX_LOG_AGE_DAYS -delete 2>/dev/null || true
}

# ========================================
# Package Update Functions
# ========================================

# Parse and log package updates from command output
log_updates() {
    local manager="$1"
    local output_file="$2"
    local update_count=0
    
    while IFS= read -r line; do
        if [[ $line =~ ([a-zA-Z0-9_.-]+)\ \(([0-9a-z:.-]+)\ \-\>\ ([0-9a-z:.-]+)\) ]]; then
            local pkg="${BASH_REMATCH[1]}"
            local old_ver="${BASH_REMATCH[2]}"
            local new_ver="${BASH_REMATCH[3]}"
            
            log "$(date '+%F %T'), $manager, $pkg, $old_ver -> $new_ver"
            ((update_count++))
            
            # Store all updates for summary table
            ALL_UPDATES+=("$pkg|$old_ver|$new_ver|$manager")
            
            # Check if this is a critical package
            for critical in "${CRITICAL_PACKAGES[@]}"; do
                if [[ $pkg == "$critical" || $pkg == "$critical-"* ]]; then
                    CRITICAL_UPDATES+=("$pkg ($old_ver -> $new_ver)")
                    [[ $pkg == linux* ]] && KERNEL_UPDATED=true
                    break
                fi
            done
        fi
    done < "$output_file"
    
    log "📦 $manager: $update_count packages updated"
    TOTAL_UPDATES=$((TOTAL_UPDATES + update_count))
}

# Handle stale pacman lock files
handle_pacman_lock() {
    if [[ -f "/var/lib/pacman/db.lck" ]]; then
        log "🔓 Removing stale pacman lock file..."
        if ! sudo rm -f /var/lib/pacman/db.lck; then
            log "❌ Failed to remove pacman lock file. Manual intervention required."
            return 1
        fi
    fi
}

# Update system packages with pacman
update_pacman() {
    print_step 1 6 "Updating system packages with pacman"
    
    handle_pacman_lock
    
    local pacman_output
    pacman_output=$(mktemp)
    TMPFILES+=("$pacman_output")
    
    log "🔄 Running pacman system update (timeout: ${UPDATE_TIMEOUT}s)..."
    
    if timeout "$UPDATE_TIMEOUT" sudo pacman -Syuv --noconfirm 2>&1 | tee "$pacman_output"; then
        log_updates "pacman" "$pacman_output"
        log "✅ Pacman update completed successfully"
    else
        local exit_code=$?
        if (( exit_code == 124 )); then
            log "⏰ Pacman update timed out after ${UPDATE_TIMEOUT} seconds"
        else
            log "⚠️  Pacman update encountered issues (exit code: $exit_code)"
        fi
        log "📄 Check pacman output above for details"
    fi
}

# Clean package cache intelligently
clean_cache() {
    print_step 2 6 "Cleaning package cache"
    
    log "🧹 Cleaning package cache to free disk space..."
    
    # Use paccache if available (more intelligent cleaning)
    if command -v paccache &>/dev/null; then
        log "📚 Using paccache to keep 2 most recent versions"
        if sudo paccache -rk2; then
            log "✅ paccache cleaning completed"
        else
            log "⚠️  paccache encountered issues, falling back to pacman"
        fi
    fi
    
    # Remove temporary download files
    log "🗑️  Removing temporary download files"
    sudo rm -f /var/cache/pacman/pkg/download-* 2>/dev/null || true
    
    # Clean uninstalled packages cache
    log "📦 Cleaning cache of uninstalled packages"
    if sudo pacman -Sc --noconfirm < /dev/null; then
        log "✅ Package cache cleaning completed"
    else
        log "⚠️  Package cache cleaning encountered issues"
    fi
}

# Update AUR packages with yay
update_aur() {
    if ! command -v yay &>/dev/null; then
        log "ℹ️  yay not found, skipping AUR updates"
        return
    fi
    
    print_step 3 6 "Updating AUR packages with yay"
    
    local yay_output
    yay_output=$(mktemp)
    TMPFILES+=("$yay_output")
    
    log "🔄 Running AUR package updates..."
    
    if yay -Suav --noconfirm 2>&1 | tee "$yay_output"; then
        log_updates "yay" "$yay_output"
        log "✅ AUR updates completed successfully"
    else
        log "⚠️  AUR updates encountered issues"
        log "📄 Check yay output above for details"
    fi
}

# ========================================
# System Health Functions
# ========================================

# Check for failed systemd services
check_failed_services() {
    print_step 4 6 "Checking systemd service health"
    
    log "🔍 Checking for failed systemd services..."
    
    local failed_services
    failed_services=$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)
    
    if [[ -n "$failed_services" ]]; then
        log "⚠️  Failed systemd services detected:"
        echo "$failed_services" | while IFS= read -r line; do
            log "  ❌ $line"
        done
        echo "$failed_services" >> "$LOG_FILE"
    else
        log "✅ No failed systemd services detected"
    fi
}

# Check system journal for recent errors
check_journal_errors() {
    print_step 5 6 "Checking system journal for errors"
    
    log "🔍 Scanning system journal for recent errors..."
    
    local journal_errors
    journal_errors=$(journalctl -p 3 -xb --no-pager --since "1 hour ago" 2>/dev/null | tail -n 20 || true)
    
    if [[ -n "$journal_errors" ]]; then
        log "⚠️  Recent system errors found in journal:"
        echo -e "\nRecent system journal errors (last 20):" >> "$LOG_FILE"
        echo "$journal_errors" >> "$LOG_FILE"
        log "📄 Error details logged to $LOG_FILE"
    else
        log "✅ No recent critical errors in system journal"
    fi
}

# ========================================
# Summary and Recommendations
# ========================================

generate_summary() {
    print_step 6 6 "Generating update summary"
    
    log "\n🎯 UPDATE SUMMARY"
    log "=================="
    log "📊 Total packages updated: $TOTAL_UPDATES"
    log "📅 Update completed: $(date '+%F %T')"
    
    # Display detailed package update table
    if (( ${#ALL_UPDATES[@]} > 0 )); then
        log "\n📋 DETAILED PACKAGE UPDATES:"
        log "$(printf '%-30s | %-20s | %-20s | %s' 'Package' 'Old Version' 'New Version' 'Manager')"
        log "$(printf '%s' '------------------------------------------------------------------------------------------------')"
        
        for update in "${ALL_UPDATES[@]}"; do
            IFS='|' read -r pkg old_ver new_ver manager <<< "$update"
            log "$(printf '%-30s | %-20s | %-20s | %s' "$pkg" "$old_ver" "$new_ver" "$manager")"
        done
    else
        log "\n📋 No packages were updated during this session."
    fi
    
    if (( ${#CRITICAL_UPDATES[@]} > 0 )); then
        log "\n🚨 CRITICAL PACKAGE UPDATES DETECTED:"
        for update in "${CRITICAL_UPDATES[@]}"; do
            log "  🔴 $update"
        done
        
        if $KERNEL_UPDATED; then
            log "\n⚠️  KERNEL UPDATE DETECTED!"
            log "🔄 A system reboot is STRONGLY RECOMMENDED to apply kernel changes."
            log "💡 To reboot now: sudo reboot"
        else
            log "\n📢 RECOMMENDATION:"
            log "🔄 A system reboot is recommended to apply critical updates."
            log "💡 To reboot when convenient: sudo reboot"
        fi
    else
        log "\n✅ SYSTEM STATUS:"
        log "🟢 No critical packages were updated"
        log "ℹ️  A reboot is not necessary at this time"
    fi
    
    log "\n📁 Logs saved to: $LOG_FILE"
    log "🔧 Log rotation: Files > ${MAX_LOG_SIZE_KB}KB rotated, > ${MAX_LOG_AGE_DAYS} days deleted"
}

# ========================================
# Main Execution
# ========================================

main() {
    # Ensure we're running with appropriate permissions
    if [[ $EUID -eq 0 ]]; then
        echo "❌ This script should not be run as root (use sudo when needed)"
        exit 1
    fi
    
    # Setup logging
    mkdir -p "$LOG_DIR"
    rotate_logs
    
    # Log session start
    log "======================================================="
    log "🚀 Arch Linux System Update Started"
    log "📅 $(date '+%F %T')"
    log "👤 User: $(whoami)"
    log "💻 Hostname: $(hostname)"
    log "======================================================="
    
    echo "🔄 Starting comprehensive Arch Linux system update..."
    echo "📁 Logs will be saved to: $LOG_FILE"
    
    # Execute update steps
    update_pacman
    clean_cache
    update_aur
    check_failed_services
    check_journal_errors
    generate_summary
    
    # Final message
    echo
    echo "✨ System update process completed successfully!"
    echo "📋 See summary above for important information"
    
    log "\n======================================================="
    log "✅ System update session completed"
    log "======================================================="
}

# ========================================
# Script Entry Point
# ========================================

# Validate environment
if ! command -v pacman &>/dev/null; then
    echo "❌ This script requires pacman (Arch Linux package manager)"
    exit 1
fi

# Run main function
main "$@"