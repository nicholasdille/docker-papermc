#!/bin/bash
set -o errexit -o pipefail

ENTRPOINTS="$( find /opt/minecraft-entrypoint.d/ -type f -executable )"
for file in ${ENTRPOINTS}; do
    if test -x "${file}"; then
        echo "+++ Running ${file}"
        "${file}"
        echo "--- Done running ${file}"

    else
        echo "Found file ${file} but it is not executable"
    fi
done

if test "$#" -eq 0; then
    set -- java -Xms${JAVA_MEM_START} -Xmx${JAVA_MEM_MAX} -jar /opt/papermc/papermc.jar --plugins /opt/minecraft-plugins --universe /opt/minecraft-worlds
fi

echo "Starting: $@"
exec "$@"
