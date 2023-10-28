#!/bin/bash
set -o errexit -o pipefail

echo "EULA=${EULA}."
if ! test -f /var/opt/papermc/eula.txt && test "${EULA}" == "true"; then
    echo "Accepting EULA"
    echo "eula=true" >/var/opt/papermc/eula.txt
fi

echo "Starting: $@"
exec "$@"
