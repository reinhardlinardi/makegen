# Makegen v2

## Overview

Makegen stands for *Makefile generator*.  
Makegen reads your configuration and generate the appropriate Makefile for you.

## What's new in v2?

Makegen v2 uses lightning-fast optimized binary executable instead of slow fork-everywhere shell script.  
Makegen v2 is more intelligent, it uses general rules and leave the work to `make` itself.

## Installation

1. Git clone this repository or download as zip.
2. Give execute permission for binary using `chmod +x makegen` (first time only).

## Usage

1. Copy *makegen.conf* and *makegen* to your project root directory.
2. Adjust config settings as you like.
3. Run `./makegen` to generate Makefile. You will be noticed for any errors, warnings, and infos.
4. Use `make` to build your project.
5. Run the executable and voila!

## Configuration

| Config                       | Description                                                                                 |
|------------------------------|---------------------------------------------------------------------------------------------|
| LANGUAGE                     | Programming language used. Valid options are "c", "c++", "cpp".                             |
| STANDARD                     | Which standard to use. For example, "c++11".                                                |
| COMPILER                     | The compiler. `gcc` and `g++` are default values. You can use other compilers like `clang++` too.|
| ENABLE_DEBUG                 | Add debugging information. If true, "-g" flag will be appended to COMPILE_FLAGS.            |
| ENABLE_OPTIMIZATION          | Optimize executable binary. If true, "-O2" flag will be appended to COMPILE_FLAGS.          |
| COMPILE_FLAGS                | Compile flags that you want for compilation. For example, "-Wall".                          |
| LINKING_FLAGS                | Linker flags to use when linking the executable. For example, "-lm", to use math library in C.            |
| SRC_ROOT                     | The source code root folder path. The default value is "src".                               |
| HEADER_ROOT                  | The header files root folder path. Fill this field if you want to use `gcc -I or g++ -I`.   |
| OBJ_DIR                      | The object files root folder path. This is where the object files will be created. The default value is current directory.|
| EXEC_BINARY_DIR              | The executable binary folder path. This is where the executable binary will be created. The default value is current directory.|
| EXEC_BINARY_NAME             | The name of the executable binary. By default, it is "main".                                |

## Notes
- **Do not use spaces** for file and folder names.
- **Do not place unit tests inside SRC_ROOT**. Only one file can be the main program.
- Suitable for **Unix environment only**.
- The first 5 configurations are case insensitive, **the rest are case sensitive**.
- Leading and trailing whitespaces will be ignored in all configurations.
- **Make sure folder path configurations ends with folder name, not with "/"**.
- Every time you change configuration, consider running `make clean` and regenerate your Makefile.

## Limitations
- **No language autodetection. LANGUAGE is mandatory**.
- No multiple executable binaries support.
