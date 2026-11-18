COMPOSE_PROJECT_NAME	?= registry-proxy

# Ensure BuildKit is enabled for Docker Engine version earlier than 23.0
# https://docs.docker.com/build/buildkit/#getting-started
DOCKER_BUILDKIT 		:= 1

# https://docs.docker.com/build/building/variables/#buildkit_progress
BUILDKIT_PROGRESS		?= auto

# https://hub.docker.com/_/debian
DEBIAN_VERSION			?= 13.7-slim
DEBIAN_DIGEST			?= sha256:7378260c0a098d27ac206225db5e7d92b8c7c84ea7afccc86eeb513756bbd392

# https://github.com/squid-cache/squid/releases
SQUID_REPOSITORY		:= squid-cache/squid
SQUID_VERSION			?= 7_8
SQUID_ARCHIVE			:= squid-$(subst _,.,$(SQUID_VERSION)).tar.xz
SQUID_ARCHIVE_DIGEST	?= sha256:52cd716f568faccbd3e237d77fd3518cbfe1548dfa2ebd8871b5a112e8ab0063
SQUID_SIGNATURE			:= $(SQUID_ARCHIVE).asc
SQUID_SIGNATURE_DIGEST	?= sha256:0ecde5edfdff964fb3467ba168b7152b3bf898a7ffe00a624dc508732529832e

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
