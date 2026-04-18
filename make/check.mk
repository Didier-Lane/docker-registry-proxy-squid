.PHONY: check
check: jq # 🔄 Checks for newer versions of dependencies
	$(call github_check_release_version,$(JQ_REPOSITORY),$(JQ_VERSION),$(JQ_ASSET))
	$(call docker_check_version,debian,$(DEBIAN_VERSION),13-slim,trixie)
	$(call github_check_release_version,$(SQUID_REPOSITORY),SQUID_$(SQUID_VERSION),$(SQUID_ARCHIVE) $(SQUID_SIGNATURE))
