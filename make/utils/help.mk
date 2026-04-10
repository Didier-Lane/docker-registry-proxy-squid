.DEFAULT_GOAL := help

define HEADER
$(underline)Usage$(reset)

	# To run and execute a target
	$(bold)make $(cyan)<target>$(reset)

$(underline)Available Targets$(reset)

endef

.PHONY: help
help: # 💡 Shows This Help Menu
	echo -e "$(HEADER)"
	grep -hEo '(^[^\: ]+:.*?# .*$$)' $(MAKEFILE_LIST) \
		| sed -e 's/:.*# /|/g' -e 's/ /|/1' \
		| awk -F'|' $(help_line)
