# ----- Makefile -------

# Colors

DIM := $(shell printf '\e[2m')
RESET := $(shell printf '\e[22m')

# Compiler

COMPILER := g++

# Flags

COMPILE_FLAGS := -Wall -g
LINKING_FLAGS := 

# Source code

SRC_ROOT := src
SRC_DIRS := $(shell find $(SRC_ROOT) -type d)
SRC_FILES := $(shell find $(SRC_ROOT) -name '*.cpp' -type f)

# Build

OBJ_DIR := bin
EXEC_BINARY_DIR := .
OBJ_FILES := $(addprefix $(OBJ_DIR)/, $(notdir $(patsubst %.cpp, %.o, $(SRC_FILES))))
EXEC_BINARY_NAME := main
EXEC_BINARY := $(EXEC_BINARY_DIR)/$(EXEC_BINARY_NAME)

# Rules

.PHONY : clean
VPATH = $(SRC_DIRS)

$(EXEC_BINARY): $(OBJ_FILES) | $(EXEC_BINARY_DIR)
	@echo "$(DIM)Linking $@ ...$(RESET)"
	@$(COMPILER) -o $@ $^ $(LINKING_FLAGS)

$(EXEC_BINARY_DIR):
	@mkdir -p $@

$(OBJ_DIR)/%.o: %.cpp | $(OBJ_DIR)
	@echo "$(DIM)Compiling $< ...$(RESET)"
	@$(COMPILER) -o $@ -c $< $(COMPILE_FLAGS)

$(OBJ_DIR):
	@mkdir -p $@

clean:
	@echo "$(DIM)Cleaning up ...$(RESET)"
	@rm -f $(EXEC_BINARY) $(OBJ_DIR)/*.o
