#!/usr/bin/env bash

set -e

# loop through each subdirectory under recipes
for dir in recipes/*/; do
    name=$(basename "$dir")

    # If it doesn't contain build.yaml, skip it
    if [[ ! -f "${dir}build.yaml" ]]; then
        continue
    fi

    echo "Checking ${name}..."

    python3 builder/build.py generate $name --recreate --architecture x86_64 --check-only --auto-build
done
