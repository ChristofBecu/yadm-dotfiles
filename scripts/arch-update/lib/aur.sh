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

    local attempt=1
    local max_attempts=3
    local yay_success=false
    while (( attempt <= max_attempts )); do
        log "🔁 yay attempt ${attempt}/${max_attempts}"
        if timeout "$UPDATE_TIMEOUT" yay -Suav --noconfirm 2>&1 | tee "$yay_output"; then
            yay_success=true
            break
        else
            log "⚠️  yay attempt ${attempt} failed"
            if (( attempt < max_attempts )); then
                sleep $(( attempt * 2 ))
                log "🔁 Retrying yay (next attempt: $((attempt+1)))..."
            fi
        fi
        ((attempt++))
    done

    if $yay_success; then
        log_updates "yay" "$yay_output"
        log "✅ AUR updates completed successfully"
    else
        log "⚠️  AUR updates encountered issues after ${max_attempts} attempts"
        log "📄 Last 40 lines of yay output:"
        tail -n 40 "$yay_output" | while IFS= read -r l; do log "  $l"; done
        log "📄 Check yay output above for details"
    fi
}