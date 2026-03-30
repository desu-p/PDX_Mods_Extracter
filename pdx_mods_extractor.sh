#!/bin/bash

# --- CONFIGURATION ---
# Get the current working directory where the script is located
MOD_PATH=$(pwd)
# Define the backup/storage path (analogous to Windows Documents folder)
# On Linux/macOS, $HOME/Documents is the standard location
STORAGE_PATH="$HOME/Documents/Mods/$(basename "$MOD_PATH")"

# Ensure the storage directory exists
mkdir -p "$STORAGE_PATH"

# --- FILE CHECK ---
# Collect all .zip files in the current directory into an array
zip_files=(*.zip)

# Check if any .zip files actually exist
if [ ! -e "${zip_files[0]}" ]; then
    echo -e "\e[31mERROR: No .zip files found in this directory!\e[0m"
    exit 1
fi

total_zips=${#zip_files[@]}
current_zip_count=0

# --- MAIN LOOP ---
for zip in "${zip_files[@]}"; do
    ((current_zip_count++))
    # Calculate progress percentage for the console output
    total_percent=$(( current_zip_count * 100 / total_zips ))
    
    echo -e "\n\e[37m========================================\e[0m"
    echo -e "\e[35mTOTAL PROGRESS: $total_percent% [$current_zip_count / $total_zips]\e[0m"
    echo -e "\e[37mProcessing: $zip\e[0m"
    
    start_time=$(date +%s)
    base_name="${zip%.*}"
    temp_dir="temp_$base_name"
    
    # Clean up any existing temp directory and create a fresh one
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"

    # Extract the archive quietly using the standard 'unzip' utility
    unzip -q "$zip" -d "$temp_dir"
    echo -e "\e[90m>>> Unpacking finished (100%)\e[0m"

    # --- DESCRIPTOR PROCESSING ---
    # Locate the descriptor.mod file (Paradox mods require this file)
    desc_file=$(find "$temp_dir" -name "descriptor.mod" -print -quit)

    if [ -n "$desc_file" ]; then
        mod_content_root=$(dirname "$desc_file")
        
        # Extract metadata using grep and PCRE (Perl Compatible Regular Expressions)
        # If not found, fall back to default values
        mod_name=$(grep -oP 'name\s*=\s*"\K[^"]+' "$desc_file" || echo "$base_name")
        version=$(grep -oP 'version\s*=\s*"\K[^"]+' "$desc_file" || echo "1.0")
        tags=$(sed -n '/tags={/,/}/p' "$desc_file" | tr -d '\n' | grep -oP '\{?\K[^\}]+')

        # Sanitize the folder name: replace non-alphanumeric characters with underscores
        folder_name=$(echo "$mod_name" | sed 's/[^a-zA-Z0-9]/_/g')
        final_folder="$MOD_PATH/$folder_name"

        # Remove old version if it exists and move new content to the final destination
        rm -rf "$final_folder"
        mkdir -p "$final_folder"
        cp -r "$mod_content_root"/* "$final_folder/"

        # Handle mod thumbnail/picture if present
        pic_file=$(find "$final_folder" -maxdepth 1 -name "*.png" -o -name "*.jpg" | head -n 1)
        pic_line=""
        if [ -n "$pic_file" ]; then
            pic_line="\npicture=\"$(basename "$pic_file")\""
        fi

        # Generate the .mod file (the "manifest" for the Paradox Launcher)
        cat <<EOF > "${final_folder}.mod"
version="$version"
tags={
    $tags
}
name="$mod_name"$pic_line
path="mod/$folder_name"
EOF

        # Archive the original .zip file to the storage path to keep the workspace clean
        mv "$zip" "$STORAGE_PATH/"
        
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        echo -e "\e[32mSUCCESS: $mod_name (${duration}s)\e[0m"
    else
        echo -e "\e[33mSKIP: No descriptor.mod found inside $zip\e[0m"
    fi

    # Cleanup: remove temporary extraction folder
    rm -rf "$temp_dir"
done

echo -e "\n\e[35m--- ALL MISSIONS COMPLETE (100%) ---\e[0m"
