.PHONY: check
check: jq jq/check # 🔄 Checks for newer versions of dependencies
	$(call dockerhub_check_version,debian,$(DEBIAN_VERSION),13-slim,trixie)
	$(call github_check_release_version,$(SQUID_REPOSITORY),SQUID_$(SQUID_VERSION),$(SQUID_ARCHIVE) $(SQUID_SIGNATURE))
