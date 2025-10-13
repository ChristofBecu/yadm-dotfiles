clean_cache() {
    print_step 2 6 "Cleaning package cache"

    log "🧹 Cleaning package cache to free disk space..."

    if command -v paccache &>/dev/null; then
        log "📚 Using paccache to keep ${CACHE_KEEP_VERSIONS} most recent versions (for easy rollback)"
        if sudo paccache -rk${CACHE_KEEP_VERSIONS}; then
            log "✅ paccache cleaning completed"
        else
            log "⚠️  paccache encountered issues, falling back to pacman"
        fi
    fi

    log "🗑️  Removing temporary download files"
    sudo rm -f /var/cache/pacman/pkg/download-* 2>/dev/null || true

    log "📦 Cleaning cache of uninstalled packages"
    if sudo pacman -Sc --noconfirm < /dev/null; then
        log "✅ Package cache cleaning completed"
    else
        log "⚠️  Package cache cleaning encountered issues"
    fi
}