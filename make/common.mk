# Os name
OS			?= $(shell uname -s | tr "[:upper:]" "[:lower:]")

# Processor architecture
ARCH		?= $(shell uname -m)
ifeq (x86_64,$(ARCH))
override	ARCH	:= amd64
endif

# Path of the local binaries directory
BIN_PATH	?= ~/.local/bin

# Creates the local binaries directory
$(BIN_PATH):
	mkdir -p $(BIN_PATH)
