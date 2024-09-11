# --- Autogenerated by makegen ---

# Source
SRC_PATH := src

# Build
COMPILER := g++
COMPILER_FLAGS := -g
LINKER_FLAGS := 

# Output
OBJECT_PATH := obj
EXE_PATH := bin
EXE_NAME := main

# Vars
SRC_FILES := $(shell find $(SRC_PATH) -name '*.cpp' -type f)
OBJECT_FILES := $(addprefix $(OBJECT_PATH)/, $(notdir $(patsubst %.cpp, %.o, $(SRC_FILES))))
EXE_BINARY := $(EXE_PATH)/$(EXE_NAME)

# Rules
.PHONY : clean

$(EXE_BINARY): $(OBJECT_FILES) | $(EXE_PATH)
	@echo "Linking   $@ ..."
	@$(COMPILER) -o $@ $^ $(LINKER_FLAGS)

$(EXE_PATH):
	@mkdir -p $@

$(OBJECT_PATH)/%.o: %.cpp | $(OBJECT_PATH)
	@echo "Compiling $< ..."
	@$(COMPILER) -o $@ -c $< $(COMPILER_FLAGS)

$(OBJECT_PATH):
	@mkdir -p $@

clean:
	@echo "Cleaning up ..."
	@rm $(EXE_BINARY) $(OBJECT_PATH)/*.o