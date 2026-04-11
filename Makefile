# https://www.gnu.org/software/make/manual/make.html

# Do not print directory changes when using recursive make commands with the variable MAKE
GNUMAKEFLAGS = --no-print-directory

# all lines of the recipe will be given to a single invocation of the shell
# rather than each line being invoked separately
.ONESHELL:

# setting ZSH or BASH as the make recipes shell
SHELL := $(or $(shell which zsh 2> /dev/null), $(shell which bash 2> /dev/null))

ifeq ($(SHELL),)
$(error ZSH or BASH is required, but none were found)
endif

# includes working copy environment variables
-include .env

# flags of invoked shell in make recipes
.SHELLFLAGS = -Eeu -o pipefail

# enables make recipes verbosity
ifdef VERBOSE
.SHELLFLAGS += -x
else
.SILENT:
endif

.SHELLFLAGS += -c

# shares all environment variables accross makefiles
.EXPORT_ALL_VARIABLES:

# list of dependencies required by the project
DEPENDENCIES	?=

# list of all makefiles
ALL_MAKEFILES			:= $(shell find ./make -type f -name '*.mk')

# list of dependencies folders
DEPS_FOLDERS			:= $(shell find ./make -type d -name deps)

# list of dependencies makefiles
DEPS_MAKEFILES 			:= $(filter $(foreach path,$(DEPS_FOLDERS),$(path)%mk),$(ALL_MAKEFILES))

# list of makefiles filtered out with dependencies makefiles
MAKEFILES_WITHOUT_DEPS	:= $(filter-out $(foreach path,$(DEPS_FOLDERS),$(path)%mk),$(ALL_MAKEFILES))

# list of selected dependencies makefiles
SELECTED_DEPS_MAKEFILES	:= $(filter $(foreach dep,$(DEPENDENCIES),%/deps/$(dep).mk),$(DEPS_MAKEFILES))

# list of included makefiles
INCLUDED_MAKEFILES		:= $(strip $(MAKEFILES_WITHOUT_DEPS) $(SELECTED_DEPS_MAKEFILES))

# includes sub makefiles from the "make" directory
-include $(INCLUDED_MAKEFILES)
