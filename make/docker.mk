COMPOSE_PROJECT_NAME	?= registry-proxy

# Ensure BuildKit is enabled for Docker Engine version earlier than 23.0
# https://docs.docker.com/build/buildkit/#getting-started
DOCKER_BUILDKIT 		:= 1

# https://docs.docker.com/build/building/variables/#buildkit_progress
BUILDKIT_PROGRESS		?= auto

# https://hub.docker.com/_/alpine
ALPINE_VERSION			?= 3.23.3

# https://github.com/squid-cache/squid/releases
SQUID_VERSION			?= 7_4

IMAGE_REPOSITORY		?= $(COMPOSE_PROJECT_NAME)
IMAGE_TAG				?= $(subst _,.,$(SQUID_VERSION))

# Path where the TLS CA cert and key pem file is located
TLS_CA_PEM				?= ~/.ssl/local.io/CA-key-and-crt.pem

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
down: # 🐋 Stops The Registry Proxy
	docker compose down
