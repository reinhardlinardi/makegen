#include <iostream>
#include <fstream>
#include <string>

using namespace std;

/** Constants. */

/** File name. */
const char* CONF_FILE = "makegen.conf";

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

string LANGUAGE; // Language : c or c++
string STANDARD; // Standard : e.g. c99 or c++11

string COMPILER; // Compiler : e.g. gcc or clang, g++ or clang++
bool ENABLE_DEBUG = true; // Debug : -g flag if true
bool ENABLE_OPTIMIZATION = false; // Optimization : -O2 flag if true
string COMPILE_FLAGS = ""; // Compile flags : e.g. -Wall
string LINKING_FLAGS = ""; // Linking flags : e.g. -lm

string SRC_ROOT_PATH = "src/"; // Source file root directory : any folder path
string HEADER_ROOT_PATH = ""; // Header file root directory : any folder path, for gcc/g++ -I

string BUILD_DIR_PATH = ""; // Build directory path : any folder path
string OBJ_DIR_PATH = "./"; // Object files directory path : any folder path, inside BUILD_DIR_PATH if BUILD_DIR_PATH is not empty
string EXEC_BINARY_PATH = "./"; // Executable binary path : any folder path, inside BUILD_DIR_PATH if BUILD_DIR_PATH is not empty
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
        string CONF_NOT_FOUND_WARN = _LIGHT_YELLOW_ + "Warning: Using all default values instead." + _RESET_;
        
        cout << CONF_FILE_ERR << endl;
        cout << CONF_NOT_FOUND_WARN << endl;
    }
    else
    {
        /** If yes, read all configurations from file. */
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

                /** Process each configuration value. */
                if(conf_name == "LANGUAGE")
                {
                    conf_value = to_lowercase(conf_value);
                    
                    if(conf_value != "c" && conf_value != "c++")
                    {
                        string LANG_ERR = _LIGHT_RED_ + "Error: Valid options for LANGUAGE are \"c\" or \"c++\"." + _RESET_;
                        cout << LANG_ERR << endl;
                        return 1;
                    }
                    else LANGUAGE = conf_value;
                }
                else if(conf_name == "STANDARD") STANDARD = to_lowercase(conf_value);
                else if(conf_name == "COMPILER")
                {
                    if(conf_value == "")
                    {
                        if(LANGUAGE == "c") COMPILER = "gcc";
                        else COMPILER = "g++";

                        string COMPILER_NOTICE = _LIGHT_BLUE_ + "Info: Using " + COMPILER + " as " + to_uppercase(LANGUAGE) + " default compiler." + _RESET_;
                        cout << COMPILER_NOTICE << endl;
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
                        cout << DEBUG_INFO << endl;
                    }
                    else if(conf_value != "true")
                    {
                        string DEBUG_ERROR = _LIGHT_RED_ + "Error: ENABLE_DEBUG value is not a boolean." + _RESET_;
                        string DEBUG_WARN = _LIGHT_YELLOW_ + "Warning: Using TRUE as ENABLE_DEBUG default value." + _RESET_;

                        cout << DEBUG_ERROR << endl;
                        cout << DEBUG_WARN << endl;
                    }
                }
                else if(conf_name == "ENABLE_OPTIMIZATION")
                {
                    conf_value = to_lowercase(conf_value);

                    if(conf_value == "true") ENABLE_DEBUG = true;
                    else if(conf_value == "")
                    {
                        string OPTIMIZE_INFO = _LIGHT_BLUE_ + "Info: Using FALSE as ENABLE_OPTIMIZATION default value." + _RESET_;
                        cout << OPTIMIZE_INFO << endl;
                    }
                    else if(conf_value != "false")
                    {
                        string OPTIMIZE_ERROR = _LIGHT_RED_ + "Error: ENABLE_OPTIMIZATION value is not a boolean." + _RESET_;
                        string OPTIMIZE_WARN = _LIGHT_YELLOW_ + "Warning: Using FALSE as ENABLE_OPTIMIZATION default value." + _RESET_;

                        cout << OPTIMIZE_ERROR << endl;
                        cout << OPTIMIZE_WARN << endl;
                    }
                }
                else if(conf_name == "COMPILE_FLAGS") COMPILE_FLAGS = conf_value;
                else if(conf_name == "LINKING_FLAGS") LINKING_FLAGS = conf_value;
                else if(conf_name == "SRC_ROOT_PATH")
                {
                    if(conf_value == "")
                    {
                        string SRC_ROOT_INFO = _LIGHT_BLUE_ + "Info: Using \"" + SRC_ROOT_PATH + "\" as SRC_ROOT_PATH default value." + _RESET_;
                        cout << SRC_ROOT_INFO << endl;
                    }
                    else SRC_ROOT_PATH = conf_value;
                }
                else if(conf_name == "HEADER_ROOT_PATH") HEADER_ROOT_PATH = conf_value;
                else if(conf_name == "BUILD_DIR_PATH") BUILD_DIR_PATH = conf_value;
                else if(conf_name == "OBJ_DIR_PATH") OBJ_DIR_PATH = conf_value;
                else if(conf_name == "EXEC_BINARY_PATH")
                {
                    if(conf_value == "")
                    {
                        string EXEC_PATH_INFO = _LIGHT_BLUE_ + "Info: Using current directory as EXEC_BINARY_PATH default value." + _RESET_;
                        cout << EXEC_PATH_INFO << endl;
                    }
                    else EXEC_BINARY_PATH = conf_value;
                }
                else if(conf_name == "EXEC_BINARY_NAME")
                {
                    if(conf_value == "")
                    {
                        string EXEC_NAME_INFO = _LIGHT_BLUE_ + "Info: Using \"main\" as EXEC_BINARY_NAME default value." + _RESET_;
                        cout << EXEC_NAME_INFO << endl;
                    }
                    else EXEC_BINARY_NAME = conf_value;
                }
            }
        }

        file.close();
    }



    return 0;
}