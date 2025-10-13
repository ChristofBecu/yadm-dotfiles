# ========================================
# Package Update Functions
# ========================================

parse_package_list() {
    local output_file="$1"
    local -n versions_map="$2"
    local in_package_list=false

    while IFS= read -r line; do
        if [[ $line =~ ^(Packages|Pakketten)\ \([0-9]+\) ]]; then
            in_package_list=true
            local packages_part="${line#*) }"
            [[ -n "$packages_part" ]] && parse_package_entries "$packages_part" versions_map
            continue
        fi

        if [[ $in_package_list == true ]]; then
            if [[ $line =~ ^$ ]] || [[ $line =~ ^(Total|Totale|::) ]]; then
                in_package_list=false
            else
                parse_package_entries "$line" versions_map
            fi
        fi
    done < "$output_file"
}

parse_package_entries() {
    local entries="$1"
    local -n vers_map="$2"

    for pkg_entry in $entries; do
        if [[ $pkg_entry =~ ^([a-zA-Z0-9_@.+-]+)-([0-9]+:)?([0-9a-z.+-]+)$ ]]; then
            vers_map["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
        fi
    done
}

process_upgrade_actions() {
    local output_file="$1"
    local manager="$2"
    local -n pkg_versions="$3"
    UPDATE_COUNT=0

    while IFS= read -r line; do
        if [[ $line =~ ^([a-zA-Z0-9_@.+-]+)\ (upgraden|upgrading|opwaarderen)\.\.\. ]]; then
            local pkg="${BASH_REMATCH[1]}"
            local new_ver="${pkg_versions[$pkg]:-unknown}"
            local old_ver
            old_ver=$(get_installed_version "$pkg")
            printf "%s, %s, %s, %s -> %s\n" "$(date '+%F %T')" "$manager" "$pkg" "$old_ver" "$new_ver" >> "$LOG_FILE" 2>/dev/null || true
            echo "$(date '+%F %T'), $manager, $pkg, $old_ver -> $new_ver"
            ((UPDATE_COUNT++))
            ALL_UPDATES+=("$pkg|$old_ver|$new_ver|$manager")
            track_critical_package "$pkg" "$old_ver" "$new_ver"
        elif [[ $line =~ ^(upgrading|opwaarderen|upgraden)\ ([a-zA-Z0-9_@.+-]+)\.\.\. ]]; then
            local pkg="${BASH_REMATCH[2]}"
            local new_ver="${pkg_versions[$pkg]:-unknown}"
            local old_ver
            old_ver=$(get_installed_version "$pkg")
            printf "%s, %s, %s, %s -> %s\n" "$(date '+%F %T')" "$manager" "$pkg" "$old_ver" "$new_ver" >> "$LOG_FILE" 2>/dev/null || true
            echo "$(date '+%F %T'), $manager, $pkg, $old_ver -> $new_ver"
            ((UPDATE_COUNT++))
            ALL_UPDATES+=("$pkg|$old_ver|$new_ver|$manager")
            track_critical_package "$pkg" "$old_ver" "$new_ver"
        fi
    done < "$output_file"
}

log_updates() {
    local manager="$1"
    local output_file="$2"
    local -A package_versions

    parse_package_list "$output_file" package_versions

    UPDATE_COUNT=0
    process_upgrade_actions "$output_file" "$manager" package_versions
    local update_count=$UPDATE_COUNT

    log "📦 $manager: $update_count packages updated"
    TOTAL_UPDATES=$((TOTAL_UPDATES + update_count))
}

handle_pacman_lock() {
    if [[ -f "/var/lib/pacman/db.lck" ]]; then
        log "🔓 Removing stale pacman lock file..."
        if ! sudo rm -f /var/lib/pacman/db.lck; then
            log "❌ Failed to remove pacman lock file. Manual intervention required."
            return 1
        fi
    fi
}

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
            :
        else
            log "⚠️  Pacman update encountered issues (exit code: $exit_code)"
        fi
        log "📄 Check pacman output above for details"
    fi
}