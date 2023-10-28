#!/bin/bash
set -o errexit -o pipefail

mkdir -p /var/opt/papermc/plugins

PLUGINS="$( find /opt/minecraft-plugins/ -type f -name '*.jar' )"
for PLUGIN in ${PLUGINS}; do
    echo "Adding plugin ${PLUGIN}"
    cp "${PLUGIN}" /var/opt/papermc/plugins/
done
