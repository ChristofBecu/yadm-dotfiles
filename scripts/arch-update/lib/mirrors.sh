# ========================================
# Mirror Management Functions
# ========================================

# Track when mirrors were last updated
readonly MIRROR_TIMESTAMP_FILE="$HOME/.cache/arch-update-mirrors-timestamp"
readonly MIRROR_UPDATE_INTERVAL_DAYS=7

should_update_mirrors() {
    # Check if timestamp file exists
    if [[ ! -f "$MIRROR_TIMESTAMP_FILE" ]]; then
        log "No mirror timestamp found - will refresh mirrors"
        return 0
    fi

    # Get timestamp of last update
    local last_update=$(cat "$MIRROR_TIMESTAMP_FILE" 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local days_since_update=$(( (current_time - last_update) / 86400 ))

    if (( days_since_update >= MIRROR_UPDATE_INTERVAL_DAYS )); then
        log "Mirrors last updated $days_since_update days ago - refresh needed"
        return 0
    else
        log "Mirrors updated $days_since_update days ago - skipping refresh"
        return 1
    fi
}

refresh_mirrors() {
    if ! should_update_mirrors; then
        return 0
    fi

    echo
    echo "🔄 Refreshing package mirrors with reflector..."
    log "Starting mirror refresh with reflector"

    # Check if reflector is installed
    if ! command -v reflector &>/dev/null; then
        echo "⚠️  Reflector not installed - skipping mirror refresh"
        log "WARNING: reflector command not found - cannot update mirrors"
        return 0
    fi

    # Backup current mirrorlist
    if [[ -f /etc/pacman.d/mirrorlist ]]; then
        sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup 2>/dev/null || {
            log "WARNING: Could not backup mirrorlist"
        }
    fi

    # Run reflector with specified parameters
    log "Running reflector with: Belgium, Netherlands, Germany, France, UK - age 6 - latest 20 - https - sort age"
    
    if sudo reflector \
        --country Belgium,Netherlands,Germany,France,"United Kingdom" \
        --age 6 \
        --latest 20 \
        --protocol https \
        --sort age \
        --save /etc/pacman.d/mirrorlist; then
        
        echo "✅ Mirrors refreshed successfully"
        log "Mirror refresh completed successfully"
        
        # Update timestamp
        mkdir -p "$(dirname "$MIRROR_TIMESTAMP_FILE")"
        date +%s > "$MIRROR_TIMESTAMP_FILE"
        
        # Show a sample of the new mirrors
        echo "📋 Top 5 mirrors:"
        head -n 15 /etc/pacman.d/mirrorlist | grep -E "^Server" | head -n 5 | sed 's/^/   /'
        
    else
        echo "⚠️  Mirror refresh failed - continuing with existing mirrors"
        log "ERROR: reflector command failed"
        
        # Restore backup if available
        if [[ -f /etc/pacman.d/mirrorlist.backup ]]; then
            sudo cp /etc/pacman.d/mirrorlist.backup /etc/pacman.d/mirrorlist 2>/dev/null || true
            log "Restored mirrorlist from backup"
        fi
        
        # Don't fail the entire update process
        return 0
    fi
}
