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

RUNAPP_PATH="/tmp/ramdisk/VAP-Concierge/src/runApp.py"
correct_code "$RUNAPP_PATH" '/subprocess.Popen(\[\"sudo\", \"\/home\/cc\/miniconda3\/envs\/dds\/bin\/python\", \"cache_video.py\"/s|\"cache_video.py\"|\"app/cache_video.py\"|' "Update the path to cache_video.py in runApp.py"