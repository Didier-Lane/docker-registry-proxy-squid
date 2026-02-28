COLORS                  ?= yes

# Enables fancy display
ifneq (,$(and $(findstring yes,$(COLORS)),$(findstring color,$(TERM))))
# Colors
bold                    := $(shell tput bold)
normal                  := $(shell tput sgr0)
errorTitle              := $(shell tput setab 1 && tput bold && echo '\n')
recommendation  		:= $(shell tput setab 4)
underline               := $(shell tput smul)
reset                   := $(shell tput -Txterm sgr0)
black                   := $(shell tput setaf 0)
red                     := $(shell tput setaf 1)
green                   := $(shell tput setaf 2)
yellow                  := $(shell tput setaf 3)
blue                    := $(shell tput setaf 4)
magenta                 := $(shell tput setaf 5)
cyan                    := $(shell tput setaf 6)
white                   := $(shell tput setaf 7)
space                   := $(shell echo -n " ")

#
# Fancy display
#
define message
echo "$(1) $(2) $(bold)$(cyan)$(3)$(reset) $(4) $(bold)$(cyan)$(5)$(reset)"
endef

define help_line
'{printf "$(bold)$(cyan)%-16s$(reset)%s %s\n", $$1, $$2, $$3}'
endef

#
# Default display
#
else

define message
echo "$(2) $(3) $(4) $(5)"
endef

define help_line
'{gsub(/^ /, "", $$3); printf "%-16s %s\n", $$1, $$3}'
endef

endif
