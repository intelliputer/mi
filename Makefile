DASM ?= dasm
STELLA ?= stella

SOURCE := src/adventure.asm
BUILD_DIR := build
ROM := $(BUILD_DIR)/adventure.bin

.PHONY: all run clean

all: $(ROM)

$(ROM): $(SOURCE) | $(BUILD_DIR)
	$(DASM) $(SOURCE) -o$@ -f3

$(BUILD_DIR):
	mkdir -p $@

run: $(ROM)
	$(STELLA) $(ROM)

clean:
	rm -rf $(BUILD_DIR)
