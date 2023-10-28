#!/bin/bash
set -o errexit -o pipefail

if test -f /var/opt/papermc/eula.txt; then
    echo "EULA already accepted	"

elif test "${EULA}" == "true"; then
    echo "Accepting EULA"
    echo "eula=true" >/var/opt/papermc/eula.txt

else
    echo "ERROR: Missing eula.txt and environment variable EULA is not set to true"
    exit 1
fi
