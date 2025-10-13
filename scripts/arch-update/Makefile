# Makefile for Arch Update Project

# Define variables
SHELL := /bin/bash
BIN_DIR := bin
LIB_DIR := lib
TEST_DIR := tests

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "Makefile for Arch Update Project"
	@echo "Available targets:"
	@echo "  build       - Build the project"
	@echo "  test        - Run tests"
	@echo "  clean       - Clean up generated files"
	@echo "  run         - Execute the update script"

# Build target
.PHONY: build
build:
	@echo "Building the project..."
	# Add build steps if necessary

# Test target
.PHONY: test
test:
	@echo "Running tests..."
	bats $(TEST_DIR)/update_tests.bats

# Clean target
.PHONY: clean
clean:
	@echo "Cleaning up..."
	# Add cleanup steps if necessary

# Run target
.PHONY: run
run:
	@echo "Executing the update script..."
	$(BIN_DIR)/updatesystem.sh