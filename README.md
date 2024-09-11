# Makegen
A simple, configurable Makefile generator for C/C++.

## How to Use
1. Copy script and config to project root:  
   `/bin/bash -c 'cp makegen{,.conf} <project-root>'`
2. Edit config
3. Generate Makefile: `./makegen`
4. Compile: `make`

**Tips**:  
Run `make clean` to clean build files.

## Config
| Name                | Value                            |
|---------------------|----------------------------------|
| LANGUAGE            | **c** or **c++**                 | 
| STANDARD            | e.g. **c99** or **c++11**        |
| COMPILER            | any, default: **gcc** or **g++** |
| DEBUG               | boolean, default: **true**       |
| OPTIMIZE            | boolean, default: **false**      |
| COMPILER_FLAGS      | any, e.g. **-Wall**              |
| LINKER_FLAGS        | any, e.g. **-lm**                |
| SRC_PATH            | directory path, default: **src** |
| HEADER_PATH         | directory path                   |
| OBJECT_PATH         | directory path, default: **obj** |
| EXE_PATH            | directory path, default: **bin** |
| EXE_NAME            | any, default: **main**           |
