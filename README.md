# makegen.sh

`makegen` stands for makefile generator, a script that will generate a `Makefile` based on dependencies of your C++ source files.

This project is purely just for fun and free to use.

## Installation

1. Run `git clone https://github.com/reinhardlinardi/makegen.git` in your desired directory.
2. Type `chmod +x makegen.sh` to make the script executable.

## Usage

Although now you can run the script directly, it is recommended to follow instructions below.

1. Move `makegen.sh` to a *$PATH* directory such as `~/.local/bin/`.
    For example: `mv makegen.sh ~/.local/bin/`.
2. Set alias to run makegen. Here are some examples how to set alias based on your shell :
    * Bash:
        `echo "alias makegen='/usr/bin/makegen.sh'" >> ~/.bash_aliases`.
    * Zsh:
        `echo "alias makegen='~/.local/bin/makegen.sh'" >> ~/.zshrc`.
    * Fish:
        `alias makegen='~/.local/bin/makegen.sh'`.
        `funcsave makegen`.
3. Now you can generate a Makefile for your project just by running `makegen` from your project folder containing `src/`.

## Notes

* In order for the script to work properly, you have to notice the following rules:
  * You **must** place your main source code and all dependencies in **src** folder. Place your unit tests in another folder, for example `driver`.
  * This script **requires** PCRE (Perl Compatible Regular Expression) library. Most UNIX-based operating systems has this library pre-installed.
  * **Do not** use **spaces** in your subdirectories names, source files names, and header files names. This script uses shell script's lists that relies on whitespaces as delimiter.
* `Makefile` generated by this script is a very simple `Makefile`. Nothing can be done beside `make` and `make clean`.
* The default executable name is `main`. If you want to change the name, you can edit the script yourself by changing all `bin/main` to `bin/<your_executable_name>`.
* `g++` is the default C++ compiler in this script. If you want to change the compiler, simply find all `g++` and replace it.
* No default compile flags used in this script. To add compile flags, pass them as command line arguments. For example `makegen -std=c++11`.
* Object files will be stored in `bin/obj/` directory. The script will instruct the `Makefile` to create subdirectories in `bin/obj/` corresponding to subdirectories in `src/`. Every object file will be stored in subdirectory in `bin/obj/` corresponds to its source file location in `src/`.
* Because this project is just for fun, the only supported extensions are `.h` and `.cpp`. If you want to add extensions, you can edit this script by yourself.
