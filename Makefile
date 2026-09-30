DASM ?= dasm
STELLA ?= stella
SCENARIO_STELLA ?= ../stella/stella

SOURCE := src/adventure.asm
BUILD_DIR := build
ROM := $(BUILD_DIR)/adventure.bin
VALIDATION_DIR := $(BUILD_DIR)/validation
EXPERIMENT_DIR := $(BUILD_DIR)/experiments/dragon-loss
INPUT_SCRIPT := validation/dragon-loss.json
KEYFRAME_INTERVAL ?= 10
GIF_DELAY ?= 6

.PHONY: all run validate validate-dragon-loss record-dragon-loss clean

all: $(ROM)

$(ROM): $(SOURCE) | $(BUILD_DIR)
	$(DASM) $(SOURCE) -o$@ -f3

$(BUILD_DIR):
	mkdir -p $@

run: $(ROM)
	$(STELLA) $(ROM)

validate: $(ROM)
	rm -rf $(VALIDATION_DIR)
	mkdir -p $(VALIDATION_DIR)
	SDL_AUDIODRIVER=dummy $(STELLA) -audio.enabled 0 -snapsavedir "$(abspath $(VALIDATION_DIR))" -snapname rom -sssingle 1 -ss1x 1 -takesnapshot "$(abspath $(ROM))"
	test -n "$$(find "$(VALIDATION_DIR)" -maxdepth 1 -type f -name '*.png' -size +0c -print -quit)"

validate-dragon-loss: $(ROM) $(INPUT_SCRIPT)
	rm -rf $(VALIDATION_DIR)
	mkdir -p $(VALIDATION_DIR)
	SDL_AUDIODRIVER=dummy $(SCENARIO_STELLA) -audio.enabled 0 -inputscript "$(abspath $(INPUT_SCRIPT))" -snapsavedir "$(abspath $(VALIDATION_DIR))" -snapname rom -sssingle 1 -ss1x 1 -snapshotframes 1350 -assertmemory 9d=bf "$(abspath $(ROM))"
	test -n "$$(find "$(VALIDATION_DIR)" -maxdepth 1 -type f -name '*.png' -size +0c -print -quit)"

record-dragon-loss: $(ROM) $(INPUT_SCRIPT)
	rm -rf $(EXPERIMENT_DIR)
	mkdir -p $(EXPERIMENT_DIR)/keyframes
	cp $(INPUT_SCRIPT) $(EXPERIMENT_DIR)/actions.json
	set +e; \
	SDL_AUDIODRIVER=dummy $(SCENARIO_STELLA) -audio.enabled 0 -inputscript "$(abspath $(INPUT_SCRIPT))" \
		-telemetry "$(abspath $(EXPERIMENT_DIR))/telemetry.jsonl" -keyframeinterval $(KEYFRAME_INTERVAL) \
		-snapsavedir "$(abspath $(EXPERIMENT_DIR))/keyframes" -snapname rom -ss1x 1 \
		-snapshotframes 1350 -assertmemory 9d=bf "$(abspath $(ROM))"; \
	run_status=$$?; rom_sha=$$(sha256sum "$(ROM)" | cut -d' ' -f1); \
	convert -delay $(GIF_DELAY) -loop 0 "$(EXPERIMENT_DIR)"/keyframes/*.png "$(EXPERIMENT_DIR)/trajectory.gif"; \
	printf '{\n  "scenario": "dragon-loss",\n  "rom": "adventure.bin",\n  "rom_sha256": "%s",\n  "frame_budget": 1350,\n  "keyframe_interval": %s,\n  "gif_delay_centiseconds": %s,\n  "assertion": "9d=bf",\n  "exit_status": %s\n}\n' "$$rom_sha" "$(KEYFRAME_INTERVAL)" "$(GIF_DELAY)" "$$run_status" > "$(EXPERIMENT_DIR)/manifest.json"; \
	exit $$run_status

clean:
	rm -rf $(BUILD_DIR)
