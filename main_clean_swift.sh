#!/usr/bin/env bash
set -e

curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages

echo Enter container filename to be deleted on SWIFT storage:
read containerName

source ../setupSwift.sh
swift delete singularityImages ${containerName}
