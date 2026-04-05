#!/bin/bash
# Generates 800px-wide thumbnails for all images in the given phtg directories.
# Thumbnails are saved to a thumbs/ subfolder, preserving original filenames.
# Skips images that already have a thumbnail.
#
# Usage: ./generate_thumbs.sh html/film_phtg html/digi_phtg html/ir_phtg

MAX_DIM=800

for dir in "$@"; do
    [ -d "$dir" ] || { echo "Skipping $dir (not a directory)"; continue; }

    thumbs_dir="$dir/thumbs"
    mkdir -p "$thumbs_dir"
    count=0

    for img in "$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.png "$dir"/*.webp; do
        [ -f "$img" ] || continue
        filename=$(basename "$img")
        thumb="$thumbs_dir/$filename"

        [ -f "$thumb" ] && continue

        sips -Z $MAX_DIM "$img" --out "$thumb" 2>/dev/null
        count=$((count + 1))
    done

    echo "$dir: generated $count new thumbnails ($(ls "$thumbs_dir" | wc -l | tr -d ' ') total)"
done
