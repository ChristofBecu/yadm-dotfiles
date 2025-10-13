# ========================================
# Configuration
# ========================================
readonly LOG_DIR="$HOME/logs"
readonly LOG_FILE="$LOG_DIR/system_update.log"
readonly MAX_LOG_SIZE_KB=1024   # 1MB
readonly MAX_LOG_AGE_DAYS=30
readonly MAX_LOG_FILES=5
readonly UPDATE_TIMEOUT=300     # 5 minutes
readonly CACHE_KEEP_VERSIONS=4  # Number of package versions to keep in cache (for easy rollback)

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