#!/bin/bash

# Function to correct code
correct_code() {
    local file_path="$1"
    local search_pattern="$2"
    local message="$3"

    # Perform the substitution
    sed -i "$search_pattern" "$file_path"
    if [ $? -eq 0 ]; then
        echo "Code substitution successful in $file_path."
        if [ -n "$message" ]; then
            echo "$message"
        else
            echo "Edit successful in $file_path with pattern: $search_pattern"
        fi
    else
        echo "Code substitution failed in $file_path."
    fi
}

# Function to replace the entire file with an updated one
replace_code_file() {
    local outdated_file="$1"
    local new_file="$2"
    
    # Check if both files exist
    if [ -f "$new_file" ]; then
        if [ -f "$outdated_file" ]; then
            # Backup the old file
            cp "$outdated_file" "${outdated_file}.bak"
            echo "Backup created for $outdated_file as ${outdated_file}.bak"

            # Replace the outdated file with the new one
            cp "$new_file" "$outdated_file"
            if [ $? -eq 0 ]; then
                echo "Successfully replaced $outdated_file with $new_file."
            else
                echo "Failed to replace $outdated_file."
            fi
        else
            echo "Outdated file $outdated_file not found!"
        fi
    else
        echo "New file $new_file not found!"
    fi
}

# RUNAPP_PATH="/tmp/ramdisk/VAP-Concierge/src/runApp.py"
# correct_code "$RUNAPP_PATH" '/subprocess.Popen(\[\"sudo\", \"\/home\/cc\/miniconda3\/envs\/dds\/bin\/python\", \"cache_video.py\"/s|\"cache_video.py\"|\"app/cache_video.py\"|' "Update the path to cache_video.py in runApp.py"

