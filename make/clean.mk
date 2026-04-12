ifndef CLEAN_COMMAND
define CLEAN_COMMAND
rm -f .env
endef
endif

.PHONY: clean
clean: ## ✨ Cleans The Working Copy
	$(CLEAN_COMMAND)
