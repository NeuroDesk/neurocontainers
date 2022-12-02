#!/bin/bash

APPLICATION="template"

FREEUPSPACE=$(cat .github/workflows/build-config.json | jq ".${APPLICATION} .freeUpSpace")
echo $FREEUPSPACE