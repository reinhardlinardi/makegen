#!/bin/bash


############################
# ------ makegen.sh ------ #
############################


# Config parameters

LANGUAGE= # required, no default value
LANGUAGE_STANDARD= # default value = empty
ENABLE_DEBUG_INFO= # default value = true 
ENABLE_OPTIMIZATION= # default value = true
COMPILE_DEFAULT_FLAGS= # default value = empty
LINKING_DEFAULT_FLAGS= # default value = empty

CREATE_OBJ_FILE= # default value = false
CREATE_BINARY_DIR= # default value = false
BINARY_FOLDER_NAME= # default value = "bin"
CREATE_CORRESPONDING_DIR= # default value = false
SRC_ROOT_FOLDER_NAME= # default value = "src"
MAIN_SRC_FILE_NAME= # default value = "main"
MAIN_EXECUTABLE_FILE_NAME= # default value = "main"
MAIN_EXECUTABLE_FILE_PATH= # default value = "./"
COMPILER_COMMAND= # default value = gcc/g++

CREATE_CLEAN_RULE= # default value = true

CREATE_RUN_SCRIPT= # default value = false

EXCLUDE_IN_GITIGNORE= # default value = true


# Global variable

config_valid=true # all configurations are valid

src_extension= # determined from language, extension for implementation source files
header_extension="h" # extension for header source files


# Read config parameters

if [[ -f makegen.conf ]] # if configuration file exists
then
	conf=$(cat makegen.conf) # load configuration data


	# read LANGUAGE value, convert to lowercase, remove leading and trailing whitespaces
	LANGUAGE=$(printf "$conf" | grep -o -P '(?<=LANGUAGE=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

	# if value is not listed in one of below
	if [[ $LANGUAGE != "c" ]] && [[ $LANGUAGE != "cpp" ]] && [[ $LANGUAGE != "c++" ]] && [[ $LANGUAGE != "cplusplus" ]]
	then
		printf "\e[91mError:\e[0m Invalid language in config. Valid options are \"c\", \"cpp\", \"c++\", or \"cplusplus\".\n"
		config_valid=false
	else
		if [[ $LANGUAGE == "c" ]]
		then
			src_extension="c"
		else
			src_extension="cpp"
		fi


		# read LANGUAGE_STANDARD value, convert to lowercase, remove leading and trailing whitespaces
		LANGUAGE_STANDARD=$(printf "$conf" | grep -o -P '(?<=LANGUAGE_STANDARD=)\d+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

		
		# read COMPILER_COMMAND value, remove leading and trailing whitespaces
		COMPILER_COMMAND=$(printf "$conf" | grep -o -P '(?<=COMPILER_COMMAND=).+' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

		if [[ $COMPILER_COMMAND == "" ]] # set to default value when value is empty
		then
			if [[ $LANGUAGE == "c" ]]
			then
				COMPILER_COMMAND="gcc"
			else
				COMPILER_COMMAND="g++"
			fi
		fi


		# read ENABLE_DEBUG_INFO value, convert to lowercase, remove leading and trailing whitespaces
		ENABLE_DEBUG_INFO=$(printf "$conf" | grep -o -P '(?<=ENABLE_DEBUG_INFO=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
		
		if [[ $ENABLE_DEBUG_INFO == "" ]] # set to default value when value is empty
		then
			ENABLE_DEBUG_INFO=true
		fi
		
		if [[ $ENABLE_DEBUG_INFO != true ]] && [[ $ENABLE_DEBUG_INFO != false ]] # set to default value when value is not boolean, and print warning
		then
			ENABLE_DEBUG_INFO=true
			printf "\e[93mWarning:\e[0m ENABLE_DEBUG_INFO value is not a boolean. Set value to true.\n"
		fi


		# read ENABLE_OPTIMIZATION value, convert to lowercase, remove leading and trailing whitespaces
		ENABLE_OPTIMIZATION=$(printf "$conf" | grep -o -P '(?<=ENABLE_OPTIMIZATION=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
		
		if [[ $ENABLE_OPTIMIZATION == "" ]] # set to default value when value is empty
		then
			ENABLE_OPTIMIZATION=true
		fi
		
		if [[ $ENABLE_OPTIMIZATION != true ]] && [[ $ENABLE_OPTIMIZATION != false ]] # set to default value when value is not boolean, and print warning
		then
			ENABLE_OPTIMIZATION=true
			printf "\e[93mWarning:\e[0m ENABLE_OPTIMIZATION value is not a boolean. Set value to true.\n"
		fi


		# read COMPILE_DEFAULT_FLAGS value, remove leading and trailing whitespaces
		COMPILE_DEFAULT_FLAGS=$(printf "$conf" | grep -o -P '(?<=COMPILE_DEFAULT_FLAGS=).+' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
		

		# read LINKING_DEFAULT_FLAGS value, remove leading and trailing whitespaces
		LINKING_DEFAULT_FLAGS=$(printf "$conf" | grep -o -P '(?<=LINKING_DEFAULT_FLAGS=).+' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")


		# read CREATE_OBJ_FILE value, convert to lowercase, remove leading and trailing whitespaces
		CREATE_OBJ_FILE=$(printf "$conf" | grep -o -P '(?<=CREATE_OBJ_FILE=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
		
		if [[ $CREATE_OBJ_FILE == "" ]] # set to default value when value is empty
		then
			CREATE_OBJ_FILE=false
		fi
		
		if [[ $CREATE_OBJ_FILE != true ]] && [[ $CREATE_OBJ_FILE != false ]] # set to default value when value is not boolean, and print warning
		then
			CREATE_OBJ_FILE=false
			printf "\e[93mWarning:\e[0m CREATE_OBJ_FILE value is not a boolean. Set value to false.\n"
		fi


		# if user wants to create object files
		if [[ $CREATE_OBJ_FILE == true ]]
		then
			# read CREATE_BINARY_DIR value, convert to lowercase, remove leading and trailing whitespaces
			CREATE_BINARY_DIR=$(printf "$conf" | grep -o -P '(?<=CREATE_BINARY_DIR=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
			
			if [[ $CREATE_BINARY_DIR == "" ]] # set to default value when value is empty, and print warning
			then
				CREATE_BINARY_DIR=false
			fi

			if [[ $CREATE_BINARY_DIR != true ]] && [[ $CREATE_BINARY_DIR != false ]] # set to default value when value is not boolean
			then
				CREATE_BINARY_DIR=false
				printf "\e[93mWarning:\e[0m CREATE_BINARY_DIR value is not a boolean. Set value to false.\n"
			fi


			# if user wants to create binary files directory
			if [[ $CREATE_BINARY_DIR == true ]]
			then
				# read BINARY_FOLDER_NAME value, remove leading and trailing whitespaces
				BINARY_FOLDER_NAME=$(printf "$conf" | grep -o -P '(?<=BINARY_FOLDER_NAME=).+' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

				if [[ $BINARY_FOLDER_NAME == "" ]] # set to default value when value is empty
				then
					BINARY_FOLDER_NAME="bin"
				fi			
				
				if ! [[ -d $BINARY_FOLDER_NAME ]] # if directory does not exists
				then
					mkdir $BINARY_FOLDER_NAME # create directory
				fi			


				# read CREATE_CORRESPONDING_DIR value, convert to lowercase, remove leading and trailing whitespaces
				CREATE_CORRESPONDING_DIR=$(printf "$conf" | grep -o -P '(?<=CREATE_CORRESPONDING_DIR=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
				
				if [[ $CREATE_CORRESPONDING_DIR == "" ]] # set to default value when value is empty, and print warning
				then
					CREATE_CORRESPONDING_DIR=false
				fi

				if [[ $CREATE_CORRESPONDING_DIR != true ]] && [[ $CREATE_CORRESPONDING_DIR != false ]] # set to default value when value is not boolean
				then
					CREATE_CORRESPONDING_DIR=false
					printf "\e[93mWarning:\e[0m CREATE_CORRESPONDING_DIR value is not a boolean. Set value to false.\n"
				fi
			fi		
		fi


		# read SRC_ROOT_FOLDER_NAME value, remove leading and trailing whitespaces
		SRC_ROOT_FOLDER_NAME=$(printf "$conf" | grep -o -P '(?<=SRC_ROOT_FOLDER_NAME=).+' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

		if [[ $SRC_ROOT_FOLDER_NAME == "" ]] # set to default value when value is empty
		then
			SRC_ROOT_FOLDER_NAME="src"
		fi

		if ! [[ -d $SRC_ROOT_FOLDER_NAME ]] # if directory does not exists
		then
			printf "\e[91mError:\e[0m Folder with name specified in SRC_ROOT_FOLDER_NAME does not exists.\n"
			config_valid=false
		else

			# read MAIN_SRC_FILE_NAME value, remove leading and trailing whitespaces
			MAIN_SRC_FILE_NAME=$(printf "$conf" | grep -o -P '(?<=MAIN_SRC_FILE_NAME=).+' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

			if [[ $MAIN_SRC_FILE_NAME == "" ]] # set to default value when value is empty
			then
				MAIN_SRC_FILE_NAME="main"
			fi

			if ! [[ -f "$SRC_ROOT_FOLDER_NAME/$MAIN_SRC_FILE_NAME.$src_extension" ]] # if file does not exists
			then
				printf "\e[91mError:\e[0m File with name specified in MAIN_SRC_FILE_NAME does not exists in SRC_ROOT_FOLDER_NAME.\n"
				config_valid=false
			else
				
				# read MAIN_EXECUTABLE_FILE_NAME value, remove leading and trailing whitespaces
				MAIN_EXECUTABLE_FILE_NAME=$(printf "$conf" | grep -o -P '(?<=MAIN_EXECUTABLE_FILE_NAME=).+' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

				if [[ $MAIN_EXECUTABLE_FILE_NAME == "" ]] # set to default value when value is empty
				then
					MAIN_EXECUTABLE_FILE_NAME="main"
				fi

				# read MAIN_EXECUTABLE_FILE_PATH value, remove leading and trailing whitespaces
				MAIN_EXECUTABLE_FILE_PATH=$(printf "$conf" | grep -o -P '(?<=MAIN_EXECUTABLE_FILE_PATH=).+' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

				if [[ $MAIN_EXECUTABLE_FILE_PATH == "" ]] # set to default value when value is empty
				then
					MAIN_EXECUTABLE_FILE_PATH="./"
				fi

			fi
		fi


		# read CREATE_CLEAN_RULE value, convert to lowercase, remove leading and trailing whitespaces
		CREATE_CLEAN_RULE=$(printf "$conf" | grep -o -P '(?<=CREATE_CLEAN_RULE=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
		
		if [[ $CREATE_CLEAN_RULE == "" ]] # set to default value when value is empty
		then
			CREATE_CLEAN_RULE=true
		fi
		
		if [[ $CREATE_CLEAN_RULE != true ]] && [[ $CREATE_CLEAN_RULE != false ]] # set to default value when value is not boolean, and print warning
		then
			CREATE_CLEAN_RULE=true
			printf "\e[93mWarning:\e[0m CREATE_CLEAN_RULE value is not a boolean. Set value to true.\n"
		fi


		# read CREATE_RUN_SCRIPT value, convert to lowercase, remove leading and trailing whitespaces
		CREATE_RUN_SCRIPT=$(printf "$conf" | grep -o -P '(?<=CREATE_RUN_SCRIPT=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
		
		if [[ $CREATE_RUN_SCRIPT == "" ]] # set to default value when value is empty
		then
			CREATE_RUN_SCRIPT=true
		fi
		
		if [[ $CREATE_RUN_SCRIPT != true ]] && [[ $CREATE_RUN_SCRIPT != false ]] # set to default value when value is not boolean, and print warning
		then
			CREATE_RUN_SCRIPT=true
			printf "\e[93mWarning:\e[0m CREATE_RUN_SCRIPT value is not a boolean. Set value to true.\n"
		fi


		# read EXCLUDE_IN_GITIGNORE value, convert to lowercase, remove leading and trailing whitespaces
		EXCLUDE_IN_GITIGNORE=$(printf "$conf" | grep -o -P '(?<=EXCLUDE_IN_GITIGNORE=).+' | tr '[:upper:]' '[:lower:]' | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")
		
		if [[ $EXCLUDE_IN_GITIGNORE == "" ]] # set to default value when value is empty
		then
			EXCLUDE_IN_GITIGNORE=true
		fi
		
		if [[ $EXCLUDE_IN_GITIGNORE != true ]] && [[ $EXCLUDE_IN_GITIGNORE != false ]] # set to default value when value is not boolean, and print warning
		then
			EXCLUDE_IN_GITIGNORE=true
			printf "\e[93mWarning:\e[0m EXCLUDE_IN_GITIGNORE value is not a boolean. Set value to true.\n"
		fi
	fi
fi

if [[ $config_valid == false ]] # if there are invalid config(s), abort makefile generation
then
	printf "\n\e[91mConfiguration error. Makefile generation aborted.\e[0m"
	exit 1
else
	printf "\e[92mConfiguration loaded. Starting dependency processing...\e[0m"
fi


# Source file dependency processing


if [[ -d src ]] # if src exists and is a directory
then
	#printf "Collecting information from source files ...\n"

	src_folders=$(find src -type d | grep -o -P '(?<=src/).+') # find all subdirectories of src
	obj_folder="bin/obj" # object code directory

	test_obj_folder=$(ls bin/obj 2> /dev/null) # redirect any error to /dev/null

	if [[ $? -ne 0 ]] # if bin/obj directory does not exists
	then
		mkdir -p $obj_folder # create bin/obj
	fi

	for folders in $src_folders # create corresponding folder in bin/obj
	do
		object_path="$obj_folder/$folders" # concat path
		mkdir -p "$object_path" # create folder
	done

	touch Makefile # assure Makefile exists
	rm Makefile # remove Makefile

	all_header=$(find src -type f -name '*.h') # find all header files
	all_src=$(find src -type f -name '*.cpp') # find all implementation files

	object_files="" # list of all object files
	cnt=0 # counter
	first_obj_file=true

	for files in $all_src # search for all cpp
	do
		extension=$(printf "$files" | grep -o -P '\..+$') # get file extension
		filename=$(basename $files $extension) # get filename
		filepath=$(printf "$files" | grep -o -P ".+(?=$filename$extension)") # get file path
		
		if [[ $extension != ".h" ]] # for every .cpp files
		then
			filepath_in_src=$(printf "$filepath" | grep -o -P '(?<=src/).+') # get file path relative to src
			
			if [[ $first_obj_file == true ]]
			then
				first_obj_file=false
			else
				object_files+=" "
			fi
			
			object_files+="$obj_folder/$filepath_in_src$filename.o" # object files
			
			includes=$(cat "$files" | grep -o -P '#include *".+"') # get all #include
			dependencies=$(printf "$includes" | grep -o -P '(?<=")[^"]+') # get all dependencies
			
			((cnt++))
			rules[cnt]="$obj_folder/$filepath_in_src$filename.o: $files" # add object code name
			files[cnt]=$files
			
			for dependency in $dependencies
			do
				# Check all dependencies
				dependency_name=$(basename $dependency ".h") # get dependency name only
				dependency_path=$(printf "$all_header" | grep -o -P ".+(?=(?<=/)$dependency_name\.h)") # get dependency path
				
				rules[cnt]+=" $dependency_path$dependency_name.h" # add dependency name
			done
			
			if [[ ${rules[cnt]} == "" ]]
			then
				((cnt--))
			fi
		fi
	done

	#printf "Generating Makefile ...\n"

	# Write linking executable rule

	printf "bin/main: $object_files\n" >> Makefile
	printf "	@echo \"Linking ...\"\n" >> Makefile
	printf "	@g++ $object_files -o bin/main\n\n" >> Makefile

	# Write compiling source file rule

	for i in $(seq 1 $cnt)
	do
		current_obj_path=$(printf "${rules[i]}" | grep -o -P '^[^:]+')
		src_name=$(printf "${rules[i]}" | grep -o -P '(?<=bin/obj/)[^\.]+')

		printf "${rules[i]}\n" >> Makefile
		printf "	@echo \"Compiling $src_name.cpp ...\"\n" >> Makefile
		printf "	@g++ -c ${files[i]} -o $current_obj_path $@\n\n" >> Makefile
	done

	# Write clean rule

	printf ".PHONY: clean\n\n" >> Makefile

	printf "clean:\n" >> Makefile
	printf "	@echo \"Removing object files ...\"\n" >> Makefile
	printf "	@rm -rf bin/obj\n" >> Makefile
	printf "	@mkdir bin/obj\n" >> Makefile
	
	for folders in $src_folders # create corresponding folder in bin/obj
	do
		object_path="$obj_folder/$folders" # concat path
		printf "	@mkdir -p \"$object_path\"\n" >> Makefile # create folder
	done
	
	printf "\n	@echo \"Removing executable ...\"\n" >> Makefile
	printf "	@rm -rf bin/main" >> Makefile
else
	printf "Cannot find \"src\" folder. Please put your source files (except drivers) in \"src\" folder.\n"
fi
