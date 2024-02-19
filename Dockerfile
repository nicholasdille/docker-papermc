#syntax=docker/dockerfile:1.6

FROM alpine AS papermc
RUN <<EOF
apk add --update-cache --no-cache \
    curl \
    jq
EOF
RUN <<EOF
set -o errexit -o pipefail
VERSION="$(
    curl -sSLf \
        https://api.papermc.io/v2/projects/paper \
    | jq -r '.versions[]' \
    | sort -V \
    | tail -n 1
)"
echo "### Using version <${VERSION}>"
BUILD_JSON="$(
    curl -sSLf \
        https://api.papermc.io/v2/projects/paper/versions/${VERSION}/builds \
    | jq '.builds[-1]'
)"
BUILD="$(
    echo "${BUILD_JSON}" \
    | jq -r '.build'
)"
SHA256="$(
    echo "${BUILD_JSON}" \
    | jq -r '.downloads.application.sha256'
)"
FILE="$(
    echo "${BUILD_JSON}" \
    | jq -r '.downloads.application.name'
)"
URL="https://papermc.io/api/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/${FILE}"
echo "### Using build <${BUILD}> with SHA256 <${SHA256}> from <${URL}>"

curl -sSLf \
    --output /papermc.jar \
    "${URL}"
echo "${SHA256} /papermc.jar" | sha256sum -c -

echo "VERSION=${VERSION}" >>/papermc.env
echo "BUILD=${BUILD}" >>/papermc.env
echo "SHA256=${SHA256}" >>/papermc.env
EOF

FROM eclipse-temurin:21-jre-jammy
COPY --from=papermc /papermc.jar /opt/papermc/
COPY --from=papermc /papermc.env /opt/papermc/
COPY --chmod=0755 entrypoint.sh /
RUN <<EOF
useradd --create-home --shell /bin/bash minecraft
mkdir -p \
    /opt/papermc \
    /opt/minecraft-plugins \
    /opt/minecraft-worlds \
    /opt/minecraft-entrypoint.d \
    /var/opt/papermc
chown -R minecraft:minecraft \
    /var/opt/papermc/ \
    /opt/minecraft-plugins/ \
    /opt/minecraft-worlds/
EOF
COPY --chmod=0755 entrypoint.d/* /opt/minecraft-entrypoint.d/
USER minecraft
WORKDIR /var/opt/papermc
VOLUME /var/opt/papermc
EXPOSE 25565
ENV JAVA_MEM_START=256M \
    JAVA_MEM_MAX=768M
RUN <<EOF
java -jar /opt/papermc/papermc.jar --plugins /opt/minecraft-plugins --universe /opt/minecraft-worlds --help
EOF
ENTRYPOINT [ "/entrypoint.sh" ]
