COMPOSE_PROJECT_NAME	?= registry-proxy

# Ensure BuildKit is enabled for Docker Engine version earlier than 23.0
# https://docs.docker.com/build/buildkit/#getting-started
DOCKER_BUILDKIT 		:= 1

# https://docs.docker.com/build/building/variables/#buildkit_progress
BUILDKIT_PROGRESS		?= auto

# https://hub.docker.com/_/debian
DEBIAN_VERSION			?= 13.6-slim
DEBIAN_DIGEST			?= sha256:9bb8a3626890e084ab54e888fdd7c4b6d2f119071cd4c5dc5fecb4d73062aa5f

# https://github.com/squid-cache/squid/releases
SQUID_REPOSITORY		:= squid-cache/squid
SQUID_VERSION			?= 7_6
SQUID_ARCHIVE			:= squid-$(subst _,.,$(SQUID_VERSION)).tar.xz
SQUID_ARCHIVE_DIGEST	?= sha256:852178fdc37c5b0786a934fc990c7d2fffc82acf19b2284be209b96431d25992
SQUID_SIGNATURE			:= $(SQUID_ARCHIVE).asc
SQUID_SIGNATURE_DIGEST	?= sha256:3e3e929270eee0e45cbebe9d253353b991a25468de9b26126a2f6d70efd2193c

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
