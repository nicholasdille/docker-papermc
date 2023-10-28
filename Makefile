all:
	@docker buildx build --tag ghcr.io/nicholasdille/papermc:latest --load .