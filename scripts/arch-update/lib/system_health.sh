# ========================================
# System Health Functions
# ========================================

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
    log "📦 Total unique packages updated: ${#ALL_UPDATES[@]}"

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