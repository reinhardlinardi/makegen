# Makegen
A simple, configurable Makefile generator for C/C++.

## How to Use
1. Copy script and config to project root:  
   `/bin/bash -c 'cp makegen{,.conf} <project_root>'`
2. Edit config
3. Generate Makefile: `./makegen`
4. Compile: `make`

**Tips**:  
Run `make clean` to clean build files.

## Config
| Name                | Value                                   |
|---------------------|-----------------------------------------|
| LANGUAGE            | c or c++                                | 
| STANDARD            | e.g. c99 or c++11                       |
| COMPILER            | default: gcc or g++                     |
| DEBUG               | true or false (-g)                      |
| OPTIMIZE            | true or false (-O2)                     |
| COMPILER_FLAGS      | additional compiler flags, e.g. -Wall   |
| LINKER_FLAGS        | additional linker flags, e.g. -lm       |
| SRC_ROOT            | source code root, default: src          |
| HEADER_ROOT         | header files root (-I)                  |
| OBJECT_PATH         | object files directory path, default: . |
| EXE_PATH            | executable directory path, default: .   |
| EXE_NAME            | executable name, default: main          |
