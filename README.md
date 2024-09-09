# Makegen
A simple, configurable Makefile generator for C/C++.

## How to Use
1. Copy script and config to project root:  
   `/bin/bash -c 'cp makegen{,.conf} <project_root>'`
2. Edit config
3. Generate Makefile: `./makegen`
4. Compile: `make`

**Tips**: Run `make clean` to clean build files.

## Config
| Name                | Description                           |
|---------------------|---------------------------------------|
| LANGUAGE            | c, c++, or cpp                        | 
| STANDARD            | e.g. c++11                            |
| COMPILER            | default: gcc/g++                      |
| ENABLE_DEBUG        | add debug info: -g                    |
| ENABLE_OPTIMIZATION | optimize executable: -O2              |
| COMPILE_FLAGS       | additional compile flags, e.g. -Wall  |
| LINKING_FLAGS       | additional linker flags, e.g. -lm     |
| SRC_ROOT            | source code root, default: src        |
| HEADER_ROOT         | header files root, use with: -I       |
| OBJ_DIR             | object files path, default: .         |
| EXEC_BINARY_DIR     | executable path, default: .           |
| EXEC_BINARY_NAME    | executable name, default: main        |

## Notes
- Path can't contain space and should not end with '/'
- Test files can't be inside source code root
