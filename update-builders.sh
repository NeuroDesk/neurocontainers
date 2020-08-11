#!/bin/bash

for RECIPES in recipes/*/; do
    APPLICATION="$(basename $RECIPES /)"
    if [ "$APPLICATION" != "template" ]; then
        sed "s/template/$APPLICATION/g" <.github/workflows/template.yml >.github/workflows/$APPLICATION.yml
    fi
done
