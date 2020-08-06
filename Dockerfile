ARG JAVA_VERSION=11

FROM alpine AS papermc
ARG PAPERMC_VERSION=latest
RUN apk add --update-cache --no-cache \
        curl \
        jq
RUN if test "${PAPERMC_VERSION}" = "latest"; then \
        PAPERMC_VERSION=$(curl --silent --location https://papermc.io/api/v1/paper/ | jq --raw-output '.versions[0]'); \
    fi && \
    curl --silent --location --fail --output paper.jar https://papermc.io/api/v1/paper/${PAPERMC_VERSION}/latest/download

FROM openjdk:${JAVA_VERSION}-jre
RUN useradd --create-home --shell /bin/bash minecraft \
 && mkdir -p /opt/papermc /var/opt/papermc \
 && chown -R minecraft /var/opt/papermc/
COPY --from=papermc /paper.jar /opt/papermc/
USER minecraft
WORKDIR /var/opt/papermc
VOLUME /var/opt/papermc
EXPOSE 25565
ENTRYPOINT [ "java" ]
CMD [ "-Xms256M", "-Xmx768M", "-jar", "/opt/papermc/paper.jar" ]
