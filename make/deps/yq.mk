YQ_REPOSITORY	:= mikefarah/yq
YQ_VERSION		?= v4.52.5
YQ_DIGEST		?= sha256:75d893a0d5940d1019cb7cdc60001d9e876623852c31cfc6267047bc31149fa9
YQ_ASSET		:= yq_$(OS)_$(ARCH)
YQ_DOWNLOAD_URL	:= https://github.com/$(YQ_REPOSITORY)/releases/download/$(YQ_VERSION)/$(YQ_ASSET)
YQ_BIN			:= $(call path,$(BIN_DIR)/yq)

$(YQ_BIN): $(BIN_DIR)
	if [[ ! -f "$(YQ_BIN)" ]] || [[ "$$( yq --version | grep -Eo 'v([0-9\.]+)$$' )" != "$(YQ_VERSION)" ]]; then
		$(call release_install,YQ,$(YQ_VERSION),$(YQ_DOWNLOAD_URL),$(YQ_DIGEST),$(YQ_BIN))
	fi

.PHONY: yq
yq: $(YQ_BIN)
