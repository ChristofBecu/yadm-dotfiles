#!/bin/sh

# Get the file path from argument or stdin
if [ -n "$1" ]; then
    file="$1"
else
    read -r file
fi

# Resolve to absolute path
file=$(realpath "$file")

# Check if file exists
if [ ! -e "$file" ]; then
    echo "Error: File does not exist: $file" >&2
    exit 1
fi

# Get the MIME type
mime_type=$(file -b --mime-type "$file")

# Copy the actual file content with the correct MIME type
# This is what browsers expect
cat "$file" | xclip -selection clipboard -target "$mime_type"

# Also set text/uri-list for file managers
printf "file://%s" "$file" | xclip -selection clipboard -target text/uri-list

# Copy plain path to primary selection for terminal use
printf "%s" "$file" | xclip -selection primary

echo "Copied: $file (MIME: $mime_type)"