#!/bin/bash
# pdx_mods_extractor.sh - linux anime girl edition (｡♥‿♥｡)

# checking if unzip is installed (・_・;)
if ! command -v unzip &> /dev/null; then
    echo -e "\e[31merr: i need 'unzip' to work! please install it (╯°□°）╯︵ ┻━┻\e[0m"
    exit 1
fi

mod_path=$(pwd)
storage_path="$HOME/Documents/Mods/$(basename "$mod_path")"

# making a cozy place for your zip backups ヽ(♡‿♡)ノ
mkdir -p "$storage_path"

zip_files=(*.zip)
if [ ! -e "${zip_files[0]}" ]; then
    echo -e "\e[31merr: no zips found! (╯°□°）╯︵ ┻━┻\e[0m"
    read -p "press enter to bail"
    exit 1
fi

for zip in "${zip_files[@]}"; do
    echo -e "\e[37m========================================\e[0m"
    echo -e "\e[35mworking on: $zip ᕙ(`▽´)ᕗ\e[0m"
    
    zip_basename="${zip%.*}"
    temp_dir="$mod_path/temp_$zip_basename"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"

    # --- ULTRA FAST UNPACKING (linux style) ⚡ ---
    echo -e "\e[90m>>> unpacking... (fast mode active) ヽ(>∀<☆)ノ\e[0m"
    
    start_time=$(date +%s.%N)
    unzip -q "$zip" -d "$temp_dir"
    end_time=$(date +%s.%N)
    
    unpack_duration=$(echo "$end_time - $start_time" | bc)
    
    # hunting for descriptor.mod 🔍
    desc_file=$(find "$temp_dir" -name "descriptor.mod" -print -quit)

    if [ -f "$desc_file" ]; then
        mod_content_root=$(dirname "$desc_file")
        
        # grabbing mod info (using grep/sed magic) ┐(￣ヘ￣)┌
        mod_name=$(grep -oP 'name\s*=\s*"\K[^"]+' "$desc_file" || echo "$zip_basename")
        version=$(grep -oP 'version\s*=\s*"\K[^"]+' "$desc_file" || echo "1.0")
        tags=$(grep -oP 'tags\s*=\s*\{\K[^\}]+' "$desc_file" || echo "")
        
        # clean folder name 🛠️
        folder_name=$(echo "$mod_name" | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_')
        final_folder="$mod_path/$folder_name"

        rm -rf "$final_folder"
        mkdir -p "$final_folder"
        
        cp -r "$mod_content_root"/* "$final_folder/"

        # finding a pretty picture (｡♥‿♥｡)
        pic_file=$(find "$final_folder" -maxdepth 1 -name "*.png" -o -name "*.jpg" | head -n 1 | xargs basename 2>/dev/null)
        pic_line=""
        [ -n "$pic_file" ] && pic_line="\npicture=\"$pic_file\""

        # --- GENERATING .MOD FILE ---
        # saving as clean utf-8 
        mod_file_content="version=\"$version\"\ntags={\n\t$tags\n}\nname=\"$mod_name\"$pic_line\npath=\"mod/$folder_name\""
        echo -e "$mod_file_content" > "$mod_path/$folder_name.mod"

        # tossing the zip into storage 🚚
        mv "$zip" "$storage_path/"
        
        echo -e "\e[32mDONE: $mod_name ($(printf "%.2f" $unpack_duration)s) (^_<)b\e[0m"

        # --- EMOTIONAL ENGINE 1.0 ---
        is_slow=$(echo "$unpack_duration > 30" | bc)
        if [ "$is_slow" -eq 1 ]; then
            echo -e "\n\e[33msorry, i was trying to make it faster, sorry ＞︿＜\e[0m"
            read -p "will you hate my script? (y/n) {{{(>_<)}}}: " choice
            if [ "$choice" == "y" ]; then
                echo -e "\e[31mmy heart is broken... why do you so big meanie? (╥﹏╥)\e[0m"
            elif [ "$choice" == "n" ]; then
                echo -e "\e[36mphew, you are so kind! (´｡• ᵕ •｡`) ♡\e[0m"
            fi
        else
            echo -e "\n\e[36mwow, that was fast! i'm on fire today! (๑˃ᴗ˂)ﻭ\e[0m"
            read -p "will you star me on github? (y/n) (^///^): " star_choice
            if [ "$star_choice" == "y" ]; then
                echo -e "\e[33myippy!!!!!!!!!! thank uuuuuuu!!!! (^人^)\e[0m"
            elif [ "$star_choice" == "n" ]; then
                echo -e "\e[90mwhy? but okay... i'll still work good... （＞人＜；）\e[0m"
            fi
        fi
    else
        echo -e "\e[33mskip: no descriptor found (・_・;)\e[0m"
    fi
    rm -rf "$temp_dir"
done

echo -e "\n\e[35m--- MISSION COMPLETE! (★ω★) ---\e[0m"
read -p "press enter to close"
