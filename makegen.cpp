#include <iostream>
#include <fstream>
#include <string>
#include <ctime>
#include <regex>

using namespace std;

/** Constants. */

/** File name. */
const char* CONF_FILE = "makegen.conf";
const char* MAKEFILE = "Makefile";

/** Configurations delimiter. */
const string CONF_DELIMITER = "=";

/** Terminal colors using ANSI escape sequences. */
const string _LIGHT_RED_ = "\e[91m";
const string _LIGHT_GREEN_ = "\e[92m";
const string _LIGHT_YELLOW_ = "\e[93m";
const string _LIGHT_BLUE_ = "\e[94m";
const string _RESET_ = "\e[0m";

/* Global variables. */

/** Configurations and their default values. */

string LANGUAGE; // Language : c/c++/cpp
string STANDARD; // Standard : e.g. c99 or c++11

string COMPILER; // Compiler : e.g. gcc or clang, g++ or clang++
bool ENABLE_DEBUG = true; // Debug : -g flag if true
bool ENABLE_OPTIMIZATION = false; // Optimization : -O2 flag if true
string COMPILE_FLAGS = ""; // Compile flags : e.g. -Wall
string LINKING_FLAGS = ""; // Linking flags : e.g. -lm

string SRC_ROOT = "src"; // Source file root directory : any folder path
string HEADER_ROOT = ""; // Header file root directory : any folder path, for gcc/g++ -I

string OBJ_DIR = "."; // Object files directory path : any folder path
string EXEC_BINARY_DIR = "./"; // Executable binary path : any folder path
string EXEC_BINARY_NAME = "main"; // Executable binary name : any file name


/** Helper functions. */

/** Convert string to lowercase. */
string to_lowercase(string s)
{
    size_t len = s.length();
    string lower_s = "";

    for(size_t idx=0; idx<len; idx++)
    {
        if(s[idx] >= 'A' && s[idx] <= 'Z') lower_s += (s[idx] - 'A') + 'a';
        else lower_s += s[idx];
    }

    return lower_s;
}

/** Convert string to uppercase. */
string to_uppercase(string s)
{
    size_t len = s.length();
    string upper_s = "";

    for(size_t idx=0; idx<len; idx++)
    {
        if(s[idx] >= 'a' && s[idx] <= 'z') upper_s += (s[idx] - 'a') + 'A';
        else upper_s += s[idx];
    }

    return upper_s;
}


/** Main program. */

int main()
{
    /** Open configuration file using read-only mode. */
    fstream file;
    file.open(CONF_FILE, fstream::in);

    /** Check if any error encountered. */
    if(file.fail())
    {
        /** If yes, give warning and use all default values instead. */
        string CONF_FILE_ERR = _LIGHT_RED_ + "Error: Configuration file \"" + CONF_FILE + "\" is missing or cannot be read." + _RESET_;
        string CONF_FILE_WARN = _LIGHT_YELLOW_ + "Warning: Using all default values instead." + _RESET_;
        
        cout << CONF_FILE_ERR << endl;
        cout << CONF_FILE_WARN << endl;
    }
    else
    {
        /** If yes, read all configurations from file. */
        string CONF_READ_START = _LIGHT_GREEN_ + "Reading configuration file..." + _RESET_;
        cout << CONF_READ_START;

        string line;

        while(getline(file, line))
        {
            size_t delimiter_idx = line.find(CONF_DELIMITER);
            
            /** If delimiter found in current line. */
            if(delimiter_idx != line.npos)
            {
                /** Get configuration name and value. */
                string conf_name = line.substr(0, delimiter_idx);
                string conf_value = line.substr(delimiter_idx + 1, line.length() - 1);

                /** Remove leading and trailing spaces. */
                conf_value = regex_replace(regex_replace(conf_value, regex("\\s*$"), ""), regex("^\\s*"), "");

                /** Process each configuration value. */
                if(conf_name == "LANGUAGE")
                {
                    conf_value = to_lowercase(conf_value);
                    
                    if(conf_value != "c" && conf_value != "c++" && conf_value != "cpp")
                    {
                        string LANG_ERR = _LIGHT_RED_ + "Error: Valid options for LANGUAGE are \"c\" or \"c++\"." + _RESET_;
                        cout << endl << LANG_ERR;
                        return 1;
                    }
                    else if(conf_value == "c") LANGUAGE = "c";
                    else LANGUAGE = "cpp";
                }
                else if(conf_name == "STANDARD") 
                {
                    STANDARD = to_lowercase(conf_value);
                    if(STANDARD != "") COMPILE_FLAGS += " -std=" + STANDARD;
                }
                else if(conf_name == "COMPILER")
                {
                    if(conf_value == "")
                    {
                        if(LANGUAGE == "c") COMPILER = "gcc";
                        else COMPILER = "g++";

                        string COMPILER_NOTICE = _LIGHT_BLUE_ + "Info: Using " + COMPILER + " as " + to_uppercase(LANGUAGE) + " default compiler." + _RESET_;
                        cout << endl << COMPILER_NOTICE;
                    }
                    else COMPILER = to_lowercase(conf_value);
                }
                else if(conf_name == "ENABLE_DEBUG")
                {
                    conf_value = to_lowercase(conf_value);

                    if(conf_value == "false") ENABLE_DEBUG = false;
                    else if(conf_value == "")
                    {
                        string DEBUG_INFO = _LIGHT_BLUE_ + "Info: Using TRUE as ENABLE_DEBUG default value." + _RESET_;
                        cout << endl << DEBUG_INFO;
                    }
                    else if(conf_value != "true")
                    {
                        string DEBUG_ERROR = _LIGHT_RED_ + "Error: ENABLE_DEBUG value is not a boolean." + _RESET_;
                        string DEBUG_WARN = _LIGHT_YELLOW_ + "Warning: Using TRUE as ENABLE_DEBUG default value." + _RESET_;

                        cout << endl << DEBUG_ERROR;
                        cout << endl << DEBUG_WARN;
                    }
                    else COMPILE_FLAGS += " -g";
                }
                else if(conf_name == "ENABLE_OPTIMIZATION")
                {
                    conf_value = to_lowercase(conf_value);

                    if(conf_value == "true")
                    {
                        ENABLE_DEBUG = true;
                        COMPILE_FLAGS += " -O2";
                    }
                    else if(conf_value == "")
                    {
                        string OPTIMIZE_INFO = _LIGHT_BLUE_ + "Info: Using FALSE as ENABLE_OPTIMIZATION default value." + _RESET_;
                        cout << endl << OPTIMIZE_INFO;
                    }
                    else if(conf_value != "false")
                    {
                        string OPTIMIZE_ERROR = _LIGHT_RED_ + "Error: ENABLE_OPTIMIZATION value is not a boolean." + _RESET_;
                        string OPTIMIZE_WARN = _LIGHT_YELLOW_ + "Warning: Using FALSE as ENABLE_OPTIMIZATION default value." + _RESET_;

                        cout << endl << OPTIMIZE_ERROR;
                        cout << endl << OPTIMIZE_WARN;
                    }
                }
                else if(conf_name == "COMPILE_FLAGS") COMPILE_FLAGS += " " + conf_value;
                else if(conf_name == "LINKING_FLAGS") LINKING_FLAGS = conf_value;
                else if(conf_name == "SRC_ROOT")
                {
                    if(conf_value == "")
                    {
                        string SRC_ROOT_INFO = _LIGHT_BLUE_ + "Info: Using \"" + SRC_ROOT + "\" as SRC_ROOT default value." + _RESET_;
                        cout << endl << SRC_ROOT_INFO;
                    }
                    else SRC_ROOT = conf_value;
                }
                else if(conf_name == "HEADER_ROOT")
                {
                    HEADER_ROOT = conf_value;
                    if(HEADER_ROOT != "") COMPILE_FLAGS += " -I" + HEADER_ROOT;
                }
                else if(conf_name == "OBJ_DIR")
                {
                    if(conf_value == "")
                    {
                        string OBJ_DIR_INFO = _LIGHT_BLUE_ + "Info: Using current directory as OBJ_DIR default value." + _RESET_;
                        cout << endl << OBJ_DIR_INFO;
                    }
                    else OBJ_DIR = conf_value;
                }
                else if(conf_name == "EXEC_BINARY_DIR")
                {
                    if(conf_value == "")
                    {
                        string EXEC_DIR_INFO = _LIGHT_BLUE_ + "Info: Using current directory as EXEC_BINARY_DIR default value." + _RESET_;
                        cout << endl << EXEC_DIR_INFO;
                    }
                    else EXEC_BINARY_DIR = conf_value;
                }
                else if(conf_name == "EXEC_BINARY_NAME")
                {
                    if(conf_value == "")
                    {
                        string EXEC_NAME_INFO = _LIGHT_BLUE_ + "Info: Using \"main\" as EXEC_BINARY_NAME default value." + _RESET_;
                        cout << endl << EXEC_NAME_INFO;
                    }
                    else EXEC_BINARY_NAME = conf_value;
                }
            }
        }

        file.close();

        string CONF_READ_END = _LIGHT_GREEN_ + "Configuration read succesfully." + _RESET_;
        cout << endl << CONF_READ_END << endl;
    }

    /** Generate Makefile. */

    /* Create or open Makefile using write-only mode.*/
    file.open(MAKEFILE, fstream::out);

    /** Check if any error encountered. */
    if(file.fail())
    {
        /** If yes, print error and exit immediately. */
        string MAKEFILE_ERR = _LIGHT_RED_ + "Error: Cannot create or write \"" + MAKEFILE + "\"." + _RESET_;
        cout << endl << MAKEFILE_ERR;
        return 2;
    }
    else
    {
        /** If no, write Makefile right away. */
        string MAKEFILE_WRITE_START = _LIGHT_GREEN_ + "Generating Makefile..." + _RESET_;
        cout << endl << MAKEFILE_WRITE_START << endl;

        file << "# Makefile" << endl;
        file << "#" << endl;

        time_t raw_time;
        struct tm* time_info;
        char time_buf[100];

        time(&raw_time);
        time_info = localtime(&raw_time);
        strftime(time_buf, 100, "%a, %d %b %Y, %H:%M", time_info);

        file << "# Last update : " << time_buf << endl;
        file << "#" << endl;
        file << "# This file was auto generated by makegen, an automatic makefile generator." << endl;
        file << "#" << endl;
        file << "# Repository : https://github.com/reinhardlinardi/makegen" << endl;
        file << "# Maintainer : segfault1001" << endl;
        
        file << endl;

        file << "# Compiler" << endl << endl;
        file << "COMPILER := " << COMPILER << endl << endl;

        COMPILE_FLAGS = regex_replace(regex_replace(COMPILE_FLAGS, regex("\\s*$"), ""), regex("^\\s*"), "");

        file << "# Flags" << endl << endl;
        file << "COMPILE_FLAGS := " << COMPILE_FLAGS << endl;
        file << "LINKING_FLAGS := " << LINKING_FLAGS << endl << endl;

        file << "# Source code" << endl << endl;
        file << "SRC_ROOT := " << SRC_ROOT << endl;
        file << "SRC_DIRS := $(shell find $(SRC_ROOT) -type d)" << endl;
        file << "SRC_FILES := $(shell find $(SRC_ROOT) -name '*." << LANGUAGE << "' -type f)" << endl << endl;

        file << "# Build" << endl << endl;

        if(OBJ_DIR == EXEC_BINARY_DIR)
        {
            file << "BUILD_DIR := " << OBJ_DIR << endl;
            file << "OBJ_FILES := $(addprefix $(BUILD_DIR)/, $(notdir $(patsubst %." << LANGUAGE << ", %.o, $(SRC_FILES))))" << endl;
            file << "EXEC_BINARY_NAME := " << EXEC_BINARY_NAME << endl;
            file << "EXEC_BINARY := $(BUILD_DIR)/$(EXEC_BINARY_NAME)" << endl << endl;
        }
        else
        {
            file << "OBJ_DIR := " << OBJ_DIR << endl;
            file << "EXEC_BINARY_DIR := " << EXEC_BINARY_DIR << endl;
            file << "OBJ_FILES := $(addprefix $(OBJ_DIR)/, $(notdir $(patsubst %." << LANGUAGE << ", %.o, $(SRC_FILES))))" << endl;
            file << "EXEC_BINARY_NAME := " << EXEC_BINARY_NAME << endl;
            file << "EXEC_BINARY := $(EXEC_BINARY_DIR)/$(EXEC_BINARY_NAME)" << endl << endl;
        }
        
        file << "# Rules" << endl << endl;
        file << ".PHONY : clean" << endl;
        file << "VPATH = $(SRC_DIRS)" << endl << endl;

        if(OBJ_DIR == EXEC_BINARY_DIR)
        {
            file << "$(EXEC_BINARY): $(OBJ_FILES) | $(BUILD_DIR)" << endl;
            file << "\t@echo \"Linking $@ ...\"" << endl;
            file << "\t@$(COMPILER) -o $@ $^ $(LINKING_FLAGS)" << endl << endl;

            file << "$(BUILD_DIR)/%.o: %." << LANGUAGE << " | $(BUILD_DIR)" << endl;
            file << "\t@echo \"Compiling $< ...\"" << endl;
            file << "\t@$(COMPILER) -o $@ -c $< $(COMPILE_FLAGS)" << endl << endl;

            file << "$(BUILD_DIR):" << endl;
            file << "\t@mkdir -p $@" << endl << endl;

            file << "clean:" << endl;
            file << "\t@echo \"Cleaning up ...\"" << endl;
            file << "\t@rm $(EXEC_BINARY) $(BUILD_DIR)/*.o";
        }
        else
        {
            file << "$(EXEC_BINARY): $(OBJ_FILES) | $(EXEC_BINARY_DIR)" << endl;
            file << "\t@echo \"Linking $@ ...\"" << endl;
            file << "\t@$(COMPILER) -o $@ $^ $(LINKING_FLAGS)" << endl << endl;

            file << "$(EXEC_BINARY_DIR):" << endl;
            file << "\t@mkdir -p $@" << endl << endl;

            file << "$(OBJ_DIR)/%.o: %." << LANGUAGE << " | $(OBJ_DIR)" << endl;
            file << "\t@echo \"Compiling $< ...\"" << endl;
            file << "\t@$(COMPILER) -o $@ -c $< $(COMPILE_FLAGS)" << endl << endl;

            file << "$(OBJ_DIR):" << endl;
            file << "\t@mkdir -p $@" << endl << endl;

            file << "clean:" << endl;
            file << "\t@echo \"Cleaning up ...\"" << endl;
            file << "\t@rm $(EXEC_BINARY) $(OBJ_DIR)/*.o";
        }

        file.close();

        string MAKEFILE_WRITE_END = _LIGHT_GREEN_ + "Makefile generated." + _RESET_;
        cout << MAKEFILE_WRITE_END;
    }

    return 0;
}