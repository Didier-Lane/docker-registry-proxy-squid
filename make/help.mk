.DEFAULT_GOAL := help

define HEADER
Usage

	# To run and execute a target
	${bold}make ${cyan}<target>${reset}

Available Targets

endef

.PHONY: help
help: ## 💡 Shows This Help Menu
	echo -e "$(HEADER)"
	grep -E '(^[^\:]+:.*?## .*$$)|(^## )' $(MAKEFILE_LIST) | sed 's/^[^:]*://g' | awk 'BEGIN {FS = ":.*?## | #"} ; {printf "${bold}${blue}%-10s${reset} ${white}%s${reset} ${green}%s${reset}\n", $$1, $$2, $$3}' | sed -e 's/\[36m##/\n[32m##/'
