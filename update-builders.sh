#!/bin/bash

for RECIPES in recipes/*/; do
    APPLICATION="$(basename $RECIPES /)"
    if [ "$APPLICATION" != "template" ]; then
        sed "s/template/$APPLICATION/g" <.github/workflows/template.yml >.github/workflows/$APPLICATION.yml
        if ! grep -m 1 -q "$APPLICATION" .github/workflows/free-up-space-list.txt; then
            sed -i '/      - .github\/workflows\/free-up-space-list.txt/d' .github/workflows/$APPLICATION.yml
        fi
    fi
done
