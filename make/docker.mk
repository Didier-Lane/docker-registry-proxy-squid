COMPOSE_PROJECT_NAME	?= registry-proxy

# Ensure BuildKit is enabled for Docker Engine version earlier than 23.0
# https://docs.docker.com/build/buildkit/#getting-started
DOCKER_BUILDKIT 		:= 1

# https://docs.docker.com/build/building/variables/#buildkit_progress
BUILDKIT_PROGRESS		?= auto

# https://hub.docker.com/_/debian
DEBIAN_VERSION			?= 13.4-slim
DEBIAN_DIGEST			?= sha256:5fb70129351edec3723d13f427400ecae3f13b83750e23ad47c46721effcf2db

# https://github.com/squid-cache/squid/releases
SQUID_REPOSITORY		:= squid-cache/squid
SQUID_VERSION			?= 7_5
SQUID_ARCHIVE			:= squid-$(subst _,.,$(SQUID_VERSION)).tar.xz
SQUID_ARCHIVE_DIGEST	?= sha256:f6058907db0150d2f5d228482b5a9e5678920cf368ae0ccbcecceb2ff4c35106
SQUID_SIGNATURE			:= $(SQUID_ARCHIVE).asc
SQUID_SIGNATURE_DIGEST	?= sha256:2637a60ea4e30e7573641d7b07fe8551f063aed08c274287e8fddc23aeda0b28

IMAGE_REPOSITORY		?= $(COMPOSE_PROJECT_NAME)
IMAGE_TAG				?= $(subst _,.,$(SQUID_VERSION))

# Path where the TLS CA cert and key pem file is located
TLS_CA_PEM				?= ~/.ssl/DidierLane/CA-key-and-crt.pem

# Docker container restart policy
RESTART_POLICY			?= unless-stopped

.PHONY: config
config: # 🐋 Renders the Docker Compose file
	docker compose config

.PHONY: build
build: # 🐋 Builds The Registry Proxy
	docker compose build

.PHONY: up
up: # 🐋 Runs The Registry Proxy
	docker compose up --detach

.PHONY: down
down: # 🐋 Stops and removes The Registry Proxy
	docker compose down $(ARGS)

.PHONY: destroy
destroy: # 🐋 Stops and removes The Registry Proxy and its volumes
	$(MAKE) down ARGS=--volumes
