# Makegen
A simple, configurable Makefile generator for C/C++

## Setup
1. Copy script and config
```bash
/bin/bash -c 'cp makegen{,.conf} SRC_ROOT'
```
2. Edit config file makegen.conf

## Usage
- Generate Makefile: `./makegen`  
- Build project: `make`  
- Clean build: `make clean`  

## Config
| Name                | Type    | Value           | Default |
|---------------------|---------|-----------------|---------|
| LANGUAGE            | string  | c/c++           | -       | 
| STANDARD            | string  | any, e.g. c++11 | -       |
| COMPILER            | string  | any             | gcc/g++ |  
| DEBUG               | boolean | any             | true    |
| OPTIMIZE            | boolean | any             | false   |
| COMPILER_FLAGS      | string  | any, e.g. -Wall | -       |
| LINKER_FLAGS        | string  | any, e.g. -lm   | -       |
| SRC_PATH            | path    | any             | src     |
| HEADER_PATH         | path    | any             | -       |
| OBJECT_PATH         | path    | any             | obj     |
| EXE_PATH            | path    | any             | bin     |
| EXE_NAME            | string  | any             | main    |
