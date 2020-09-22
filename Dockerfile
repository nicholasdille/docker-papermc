ARG JAVA_VERSION=11

FROM alpine AS tools
RUN apk add --update-cache --no-cache \
        curl \
        jq

FROM tools AS papermc
ARG PAPERMC_VERSION=latest
RUN if test -z "${PAPERMC_VERSION}" || test "${PAPERMC_VERSION}" == "latest" || test "${PAPERMC_VERSION}" == "master"; then \
        echo "### Fetching latest version"; \
        PAPERMC_VERSION=$(\
            curl --silent --location https://papermc.io/api/v1/paper/ | \
            jq --raw-output '.versions[0]' \
        ); \
    fi && \
    echo "### Using version <${PAPERMC_VERSION}>" && \
    PAPERMC_VERSION_PATCH=$(\
        curl --silent --location https://papermc.io/api/v1/paper/1.16.3/latest | \
        jq --raw-output '.build'\
    ) && \
    echo "### Using patch <${PAPERMC_VERSION_PATCH}>" && \
    curl --silent --location --fail --output /paper.jar https://papermc.io/api/v1/paper/${PAPERMC_VERSION}/${PAPERMC_VERSION_PATCH}/download

FROM tools AS mc-monitor
RUN curl --silent https://api.github.com/repos/itzg/mc-monitor/releases/latest | \
        jq --raw-output '.assets[] | select(.name | endswith("_linux_amd64.tar.gz")) | .browser_download_url' | \
        xargs curl --location --fail | \
        tar -xzC /usr/local/bin/ mc-monitor

FROM openjdk:${JAVA_VERSION}-jre
RUN useradd --create-home --shell /bin/bash minecraft \
 && mkdir -p /opt/papermc /var/opt/papermc \
 && chown -R minecraft /var/opt/papermc/
COPY --from=papermc /paper.jar /opt/papermc/
COPY --from=mc-monitor /usr/local/bin/mc-monitor /usr/local/bin/mc-monitor
USER minecraft
WORKDIR /var/opt/papermc
VOLUME /var/opt/papermc
EXPOSE 25565
ENV JAVA_MEM_START=256M \
    JAVA_MEM_MAX=768M
CMD java -Xms${JAVA_MEM_START} -Xmx${JAVA_MEM_MAX} -jar /opt/papermc/paper.jar
HEALTHCHECK --start-period=60s --interval=30s --timeout=10s --retries=3 \
        CMD mc-monitor status
