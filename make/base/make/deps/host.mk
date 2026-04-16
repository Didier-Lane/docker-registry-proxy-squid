OS					?= $(shell uname -s | tr "[:upper:]" "[:lower:]")
ARCH				?= $(shell uname -m)

ifeq (x86_64,$(ARCH))
override	ARCH	= amd64
endif

BIN_DIR				?= ~/.local/bin

$(BIN_DIR):
	mkdir -p $(BIN_DIR)
