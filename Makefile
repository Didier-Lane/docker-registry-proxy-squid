# https://www.gnu.org/software/make/manual/make.html

# Do not print directory changes when using recursive make commands with the variable MAKE
MAKE += --no-print-directory

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

# includes sub makefiles from the "make" directory
-include $(addsuffix /*.mk, $(shell find ./make -type d))
