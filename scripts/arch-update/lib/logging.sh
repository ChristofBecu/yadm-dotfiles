# ========================================
# Logging Functions
# ========================================

log() {
    local message="$*"
    echo -e "$message" | tee -a "$LOG_FILE" || true
}

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

rotate_logs() {
    if [[ -f "$LOG_FILE" && $(du -k "$LOG_FILE" | cut -f1) -gt $MAX_LOG_SIZE_KB ]]; then
        log "📁 Log file exceeds ${MAX_LOG_SIZE_KB}KB, rotating..."

        for i in $(seq $((MAX_LOG_FILES-1)) -1 1); do
            [[ -f "${LOG_FILE}.$i" ]] && mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
        done

        mv "$LOG_FILE" "${LOG_FILE}.1"

        [[ -f "${LOG_FILE}.$((MAX_LOG_FILES+1))" ]] && rm -f "${LOG_FILE}.$((MAX_LOG_FILES+1))"
    fi

    find "$LOG_DIR" -name "system_update.log.*" -type f -mtime +$MAX_LOG_AGE_DAYS -delete 2>/dev/null || true
}