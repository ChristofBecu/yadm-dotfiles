# Arch Update Script

## Overview
The Arch Update project is a comprehensive, modular system update script designed for Arch Linux. It automates the process of updating system packages, cleaning the package cache, and checking system health. The script is built with robust error handling, comprehensive logging, and smart retry logic for reliability.

## Features
- **Automated System Updates**: Update system packages using pacman with intelligent parsing and tracking.
- **AUR Package Management**: Update AUR packages using yay with retry logic for transient network/TLS errors.
- **Cache Management**: Intelligent cleaning of the package cache using paccache for easy rollback.
- **System Health Checks**: Verify system health by checking failed systemd services and scanning the journal for errors.
- **Critical Package Tracking**: Identifies kernel and critical system updates, recommending reboots when necessary.
- **Comprehensive Logging**: Detailed logging to both console and rotating log files for troubleshooting.
- **Modular Design**: Separated into libraries for configuration, logging, utilities, and specific functions for maintainability.
- **Testing**: Includes BATS test suite for validation.
- **Installation**: Supports both local usage and system-wide installation via Makefile.

## Project Structure
```
arch-update/
├── bin/
│   └── updatesystem.sh        # Main executable script
├── lib/
│   ├── config.sh              # Configuration constants and global variables
│   ├── logging.sh             # Logging and log rotation functions
│   ├── utils.sh               # Utility functions (cleanup, version checking)
│   ├── pacman.sh              # Pacman update functions and parsing
│   ├── aur.sh                 # AUR update functions with retries
│   ├── cache.sh               # Package cache cleaning
│   └── system_health.sh       # System health checks and summary
├── tests/
│   └── update_tests.bats      # BATS test cases
├── docs/
│   └── architecture.md        # Project architecture documentation
├── Makefile                   # Build, test, and installation tasks
├── README.md                  # This file
└── .gitignore                 # Git ignore rules
```

## Installation

### Local Usage (Recommended for Development)
1. Navigate to the project directory:
   ```bash
   cd /path/to/arch-update
   ```
2. Create a local symlink for easy access:
   ```bash
   make symlink
   # Or manually: ln -sf bin/updatesystem.sh us
   ```
3. Run the script:
   ```bash
   ./us
   ```

### System-Wide Installation
1. Install dependencies:
   ```bash
   sudo pacman -S pacman yay paccache  # Core dependencies
   sudo pacman -S bats-core shellcheck  # For testing and linting (optional)
   ```
2. Install the script:
   ```bash
   sudo make install
   ```
3. Run from anywhere:
   ```bash
   updatesystem
   ```

### Dependencies
- **Required**: `pacman`, `sudo`
- **Recommended**: `yay` (for AUR support), `paccache` (for intelligent cache cleaning)
- **Development**: `bats-core` (for tests), `shellcheck` (for linting)

## Usage
Run the update script:
```bash
./bin/updatesystem.sh
# Or if symlinked: ./us
# Or if installed: updatesystem
```

The script will:
1. Update system packages with pacman
2. Clean the package cache
3. Update AUR packages (if yay is available)
4. Check systemd services and journal errors
5. Generate a detailed update summary

Logs are saved to `~/logs/system_update.log` with automatic rotation.

## Development

### Testing
Run the test suite:
```bash
make test
# Or: bats tests/update_tests.bats
```

### Linting
Check for script issues:
```bash
make lint
```

### Other Tasks
- `make clean`: Remove temporary files
- `make check-deps`: Verify dependencies
- `make help`: Show all available targets

## Contributing
Contributions are welcome! Please:
- Run tests and linting before submitting
- Follow the modular structure
- Update documentation as needed

Submit pull requests or open issues for enhancements and bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.