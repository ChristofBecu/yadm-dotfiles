# ========================================
# Utility Functions
# ========================================

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

get_installed_version() {
    local pkg="$1"
    pacman -Q "$pkg" 2>/dev/null | awk '{print $2}' || echo "unknown"
}

track_critical_package() {
    local pkg="$1"
    local old_ver="$2"
    local new_ver="$3"

    for critical in "${CRITICAL_PACKAGES[@]}"; do
        if [[ $pkg == "$critical" || $pkg == "$critical-"* ]]; then
            CRITICAL_UPDATES+=("$pkg ($old_ver -> $new_ver)")
            [[ $pkg == linux* ]] && KERNEL_UPDATED=true
            return 0
        fi
    done
    return 0
}