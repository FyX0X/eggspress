#!/usr/bin/env bash
set -euo pipefail

# Run from the directory containing project.godot
cd "$(dirname "$0")"

GODOT="godot"
BUILD_DIR="builds"

# Preset name -> output filename
declare -A EXPORTS=(
    ["windows"]="eggspress.exe"
    ["linux"]="eggspress.x86_64"
    ["web"]="index.html"
    ["macos"]="eggspress.zip"
)

# Delete previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

for preset in "${!EXPORTS[@]}"; do
    filename="${EXPORTS[$preset]}"
    output_dir="$BUILD_DIR/$preset"
    output_path="$output_dir/$filename"

    mkdir -p "$output_dir"

    echo "==> Exporting $preset..."
    "$GODOT" --headless --path . \
        --export-release "$preset" "$output_path"

    echo "==> Zipping $preset..."
    (
        cd "$output_dir"
        zip -qr "../${preset}.zip" .
    )
done

echo "All exports completed in $BUILD_DIR/"
