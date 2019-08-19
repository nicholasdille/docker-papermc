# `docker-papermc`

Docker image for the Minecraft PaperMC server at https://papermc.io

## Build

Build latest version:

```bash
docker build --tag nicholasdille/papermc .
```

Build with specific version of PaperMC:

```bash
docker build --build-arg PAPERMC_VERSION=1.14.4 --tag nicholasdille/papermc .
```

Build with specific version of Java:

```bash
docker build --build-arg JAVA_VERSION=10 --tag nicholasdille/papermc .
```

## Launch

```bash
docker run -d --name minecraft --mount type=bind,source=/opt/minecraft/server1,target=/var/opt/papermc -p 25565:25565 nicholasdille/papermc
```
