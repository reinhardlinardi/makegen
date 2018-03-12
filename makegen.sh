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


# Global variables

config_valid=true # all configurations are valid

src_extension= # determined from language, extension for implementation source files
header_extension="h" # extension for header source files
obj_extension="o" # extension for object files

src_folders= # all subdirectories of SRC_ROOT_FOLDER_NAME
src_files= # all implementation source files
header_files= # all header source files
obj_folder_path= # object files root folder, BINARY_FOLDER_NAME/obj

all_obj_files="" # list of all object files needed to build main executable
cnt=0 # implementation source file counter


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
	fi
fi


# Final result of read configuration

if [[ $config_valid == false ]] # if there are invalid config(s), abort makefile generation
then
	printf "\n\e[91mConfiguration error. Makefile generation aborted.\e[0m"
	exit 1
else
	printf "\e[92mConfiguration loaded.\nStarting dependency processing ...\e[0m\n"
fi


# Source code directory and file mapping

src_folders=$(find $SRC_ROOT_FOLDER_NAME -type d | grep -o -P "(?<=$SRC_ROOT_FOLDER_NAME/).+") # find all subdirectories of SRC_ROOT_FOLDER_NAME
src_files=$(find $SRC_ROOT_FOLDER_NAME -type f -name "*.$src_extension") # find all implementation source files
header_files=$(find $SRC_ROOT_FOLDER_NAME -type f -name "*.$header_extension") # find all header source files


# Object file directory mapping and preparation

if [[ $CREATE_OBJ_FILE == true ]]
then
	# Set object code directory path

	if [[ $CREATE_BINARY_DIR == true ]]
	then
		obj_folder_path="$BINARY_FOLDER_NAME/"

		if ! [[ -d "$obj_folder_path" ]] # create directory if not exists
		then
			mkdir $obj_folder_path
		fi

		if [[ $CREATE_CORRESPONDING_DIR == true ]]
		then
			obj_folder_path+="obj/"

			for src_folder in $src_folders # create corresponding folder in obj_folder_path
			do
				obj_file_path="$obj_folder_path$src_folder/" # concat path 
				mkdir -p "$obj_file_path" # create folder
			done
		fi
	else
		obj_folder_path="./"
	fi
fi


# Source files dependency processing

for src_file in $src_files # for every implementation source files
do
	# Get file name and file relative path to SRC_ROOT_FOLDER_NAME of current implementation source file

	src_file_name=$(basename $src_file ".$src_extension") # file name
	src_file_path=$(printf "$src_file" | grep -o -P ".+(?=$src_file_name\.$src_extension)") # file path

	if [[ $CREATE_CORRESPONDING_DIR == true ]]
	then
		src_file_path_relative=$(printf "$src_file_path" | grep -o -P "(?<=$SRC_ROOT_FOLDER_NAME/).+") #  file path relative to SRC_ROOT_FOLDER_NAME
	fi
	
	# Add to all object files list

	if [[ $CREATE_CORRESPONDING_DIR == true ]]
	then
		all_obj_files+="$obj_folder_path$src_file_path_relative$src_file_name.$obj_extension "
	else
		all_obj_files+="$obj_folder_path$src_file_name.$obj_extension "
	fi

	# Get all dependencies

	includes=$(cat "$src_file" | grep -o -P '#include *".+"') # all #include directives
	dependencies=$(printf "$includes" | grep -o -P '(?<=")[^"]+') # all dependencies
	

	# Set basic rule and source file name mapping

	((cnt++)) # increment counter

	# Add basic rule

	if [[ $CREATE_CORRESPONDING_DIR == true ]]
	then
		rules[cnt]="$obj_folder_path$src_file_path_relative$src_file_name.$obj_extension: $src_file"
	else
		rules[cnt]="$obj_folder_path$src_file_name.$obj_extension: $src_file"
	fi
	
	src[cnt]=$src_file # add file name mapping
	

	# Add all dependency to build rule
	
	for dependency in $dependencies # for every dependency
	do
		dependency_name=$(basename $dependency ".$header_extension") # dependency name
		dependency_path=$(printf "$header_files" | grep -o -P ".+(?=(?<=/)$dependency_name\.$header_extension)") # dependency path
		
		rules[cnt]+=" $dependency_path$dependency_name.$header_extension" # add dependency to rules
	done	
done

# Remove leading and trailing spaces from all_obj_files
all_obj_files=$(printf "$all_obj_files" | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")

# Add additional flags

if [[ $LANGUAGE_STANDARD != "" ]]
then
	if [[ $LANGUAGE == "c" ]]
	then
		lang="c"
	else
		lang="c++"
	fi

	COMPILE_DEFAULT_FLAGS+=" -std=$lang$LANGUAGE_STANDARD"
fi

if [[ $ENABLE_DEBUG_INFO == true ]]
then
	COMPILE_DEFAULT_FLAGS+=" -g"
fi

if [[ $ENABLE_OPTIMIZATION == true ]]
then
	COMPILE_DEFAULT_FLAGS+=" -O2"
fi

# Remove leading and trailing spaces from COMPILE_DEFAULT_FLAGS
COMPILE_DEFAULT_FLAGS=$(printf -- "$COMPILE_DEFAULT_FLAGS" | sed -e "s/^\s*//g" | sed -e "s/\s*$//g")


# Writing Makefile

printf "\e[92mGenerating Makefile ...\e[0m\n"

# Clear old Makefile, create Makefile if not exists

printf "" > Makefile

# Write rules

if [[ $CREATE_OBJ_FILE == true ]]
then
	# Write linking rule

	printf "$MAIN_EXECUTABLE_FILE_PATH$MAIN_EXECUTABLE_FILE_NAME: $all_obj_files\n" >> Makefile
	printf "	@echo \"Linking ...\"\n" >> Makefile
	printf "	@$COMPILER_COMMAND $all_obj_files -o $MAIN_EXECUTABLE_FILE_PATH$MAIN_EXECUTABLE_FILE_NAME $LINKING_DEFAULT_FLAGS\n\n" >> Makefile


	# Write compile rules

	for index in $(seq 1 $cnt)
	do
		current_obj_file_path=$(printf "${rules[index]}" | grep -o -P '^[^:]+')
		src_name=$(basename ${src[index]} ".$src_extension")

		printf "${rules[index]}\n" >> Makefile
		printf "	@echo \"Compiling $src_name.$src_extension ...\"\n" >> Makefile
		printf "	@$COMPILER_COMMAND -c ${src[index]} -o $current_obj_file_path $COMPILE_DEFAULT_FLAGS\n\n" >> Makefile
	done
else
	# Write compile and linking rule

	printf "$MAIN_EXECUTABLE_FILE_PATH$MAIN_EXECUTABLE_FILE_NAME: $SRC_ROOT_FOLDER_NAME/$MAIN_SRC_FILE_NAME.$src_extension $header_files\n" >> Makefile
	printf "	@echo \"Building ...\"\n" >> Makefile
	printf "	@$COMPILER_COMMAND $src_files -o $MAIN_EXECUTABLE_FILE_PATH$MAIN_EXECUTABLE_FILE_NAME $COMPILE_DEFAULT_FLAGS $LINKING_DEFAULT_FLAGS\n\n" >> Makefile
fi


# Write clean rule

if [[ $CREATE_CLEAN_RULE == true ]]
then
	printf ".PHONY: clean\n\n" >> Makefile
	printf "clean:\n" >> Makefile

	# Write remove all object files rule

	if [[ $CREATE_OBJ_FILE == true ]]
	then
		printf "	@echo \"Removing object files ...\"\n" >> Makefile
		
		if [[ $CREATE_BINARY_DIR == true ]]
		then
			printf "	@rm -rf $obj_folder_path\n" >> Makefile
			printf "	@mkdir $obj_folder_path\n" >> Makefile

			if [[ $CREATE_CORRESPONDING_DIR == true ]]
			then
				for src_folder in $src_folders # create corresponding folder in obj_folder_path
				do
					obj_file_path="$obj_folder_path$src_folder/" # concat path 
					mkdir -p "$obj_file_path" # create folder
				done
			fi
		else
			printf "	@rm *.o\n" >> Makefile
		fi
	fi

	# Write remove executable rule

	printf "\n	@echo \"Removing executable ...\"\n" >> Makefile
	printf "	@rm -rf $MAIN_EXECUTABLE_FILE_PATH$MAIN_EXECUTABLE_FILE_NAME" >> Makefile
fi


# Write run script

if [[ $CREATE_RUN_SCRIPT == true ]]
then
	printf "\e[92mGenerating run script ...\e[0m\n"

	# Clean old run script

	printf "" > run.sh

	# Write script

	printf "#!/bin/bash\n\n" >> run.sh

	if [[ $ENABLE_DEBUG_INFO == true ]]
	then
		printf "if [[ \$1 == \"-g\" ]] || [[ \$1 == \"--debug\" ]]\n" >> run.sh
		printf "then\n" >> run.sh
		printf "	gdb $MAIN_EXECUTABLE_FILE_PATH$MAIN_EXECUTABLE_FILE_NAME\n" >> run.sh
		printf "else\n" >> run.sh
		printf "	$MAIN_EXECUTABLE_FILE_PATH$MAIN_EXECUTABLE_FILE_NAME\n" >> run.sh
		printf "fi" >> run.sh
	else
		printf "$MAIN_EXECUTABLE_FILE_PATH$MAIN_EXECUTABLE_FILE_NAME" >> run.sh
	fi
fi

printf "\n\e[92mDone.\e[0m"