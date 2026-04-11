define message
echo "$(2) $(3)"
endef

define help_line
'{gsub(/^ /, "", $$3); printf "%-16s %s\n", $$1, $$3}'
endef

ifndef NOCOLORS
ifneq (,$(findstring color,$(TERM)))
reset			:= \033[0m
bold			:= \033[1m
underline		:= \033[4m
gray 			:= \033[1;30m
red 			:= \033[1;31m
green 			:= \033[1;32m
yellow 			:= \033[1;33m
blue 			:= \033[1;34m
purple 			:= \033[1;35m
cyan 			:= \033[1;36m
white 			:= \033[1;37m
highlight		:= $(bold)$(cyan)
hl				:= $(highlight)
rs				:= $(reset)

define message
echo -e "$(1) $(2) $(3)"
endef

define help_line
'{printf "$(hl)%-16s$(rs)%s %s\n", $$1, $$2, $$3}'
endef

endif
endif
