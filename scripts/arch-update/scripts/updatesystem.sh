#!/bin/bash
# Arch Linux System Update Script - Modular Version
# Created: March 20, 2025
# Updated: October 11, 2025 - Refactored into modules for better maintainability
# Features: Robust error handling, comprehensive logging, smart cache management

set -uo pipefail

# Source library modules
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

source "$LIB_DIR/config.sh"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/mirrors.sh"
source "$LIB_DIR/pacman.sh"
source "$LIB_DIR/aur.sh"
source "$LIB_DIR/cache.sh"
source "$LIB_DIR/system_health.sh"

# Set up signal handling
trap cleanup EXIT INT TERM

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
    refresh_mirrors
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