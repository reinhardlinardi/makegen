#!/bin/bash

printf "Collecting information from source files ...\n" 

src_folders=$(find src -type d | grep -o -P '(?<=src/).+') # find all subdirectories of src
obj_folder="bin/obj" # object code directory

test_obj_folder=$(ls bin/obj 2> /dev/null) # redirect any error to /dev/null

if [[ $? -ne 0 ]] # if bin/obj directory does not exists
then
	mkdir $obj_folder # create bin/obj
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

for files in $all_src # search for all cpp except main
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
		rules[cnt]="" # initialize as empty rule
		first=true
	
		for dependency in $dependencies
		do
			# Check all dependencies
			dependency_name=$(basename $dependency ".h") # get dependency name only
			dependency_path=$(printf "$all_header" | grep -o -P ".+(?=(?<=/)$dependency_name\.h)") # get dependency path
			
			if [[ $first == true ]] # if first
			then
				first=false # set first as false
				rules[cnt]+="$obj_folder/$filepath_in_src$filename.o: $files" # add object code name
				files[cnt]=$files
			fi
			
			rules[cnt]+=" $dependency_path$dependency_name.h" # add dependency name
		done
		
		if [[ ${rules[cnt]} == "" ]]
		then
			((cnt--))
		fi
	fi
done

printf "Generating Makefile ...\n" 

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
printf "	@rm -rf bin/obj/*.o\n" >> Makefile
printf "	@echo \"Removing executable ...\"\n" >> Makefile
printf "	@rm -rf bin/main" >> Makefile
