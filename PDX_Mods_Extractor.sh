#!/bin/bash

# pdx_mods_extractor.sh - v1.3 "Data-Aware Ninja" (｡♥‿♥｡)
# emotional engine version: 1.6 (DRAMA PATCH)

# basic check for tools
if ! command -v unzip &> /dev/null; then
    echo -e "\e[31muwaaa! unzip is missing! i can't work like this! (╯°□°）╯\e[0m"
    exit 1
fi

modPath=$(pwd)
parentFolder=$(basename "$(dirname "$modPath")")
storagePath="$HOME/Documents/Mods/$parentFolder"
mkdir -p "$storagePath"

zipFiles=(*.zip)
totalZips=${#zipFiles[@]}

if [ "$totalZips" -eq 0 ] || [ ! -e "${zipFiles[0]}" ]; then
    echo -e "\e[31mempty... there are no zips here... (｡T ω T｡)\e[0m"
    exit 1
fi

# --- DATA-BASED PROGRESS CALCULATION ---
totalSizeBytes=0
for f in "${zipFiles[@]}"; do
    size=$(stat -c%s "$f")
    totalSizeBytes=$((totalSizeBytes + size))
done

processedSizeBytes=0
totalUnpackTime=0

echo -e "\e[36mstarting v1.3 turbo extraction... [Total: $((totalSizeBytes / 1024 / 1024)) MB]\e[0m"
echo -e "\e[90mi'll be a quiet shadow while you eat... ( ˘▽˘)っ♨\n\e[0m"

# --- MAIN LOOP (Silent & Efficient) ---
for zip in "${zipFiles[@]}"; do
    startTime=$(date +%s)
    zipSize=$(stat -c%s "$zip")
    
    # Progress bar logic
    percent=$(( processedSizeBytes * 100 / totalSizeBytes ))
    barLength=25
    doneCount=$(( percent * barLength / 100 ))
    todoCount=$(( barLength - doneCount ))
    bar=$(printf "%${doneCount}s" | tr ' ' '█')
    dots=$(printf "%${todoCount}s" | tr ' ' '░')
    
    printf "\r\e[36m[%s%s] %d%% | unpacking: %-30s\e[0m" "$bar" "$dots" "$percent" "${zip%.zip}"

    # Extracting descriptor
    content=$(unzip -p "$zip" "descriptor.mod" 2>/dev/null)

    if [ $? -eq 0 ]; then
        modName=$(echo "$content" | grep -oP 'name\s*=\s*"\K[^"]+' || echo "${zip%.zip}")
        version=$(echo "$content" | grep -oP 'version\s*=\s*"\K[^"]+' || echo "1.0")
        tags=$(echo "$content" | grep -oP 'tags\s*=\s*\{\K[^\}]+' || echo "")
        folderName=$(echo "$modName" | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_')
        
        rm -rf "$folderName"
        unzip -q "$zip" -d "$folderName"
        
        # Generator
        cat <<EOF > "${folderName}.mod"
version="$version"
tags={ $tags }
name="$modName"
path="mod/$folderName"
EOF
        mv "$zip" "$storagePath/"
        
        duration=$(( $(date +%s) - startTime ))
        totalUnpackTime=$(( totalUnpackTime + duration ))
        processedSizeBytes=$(( processedSizeBytes + zipSize ))
    else
        processedSizeBytes=$(( processedSizeBytes + zipSize ))
        echo -e "\n\e[33mskipped: $zip (missing descriptor)\e[0m"
    fi
done

# Final 100% update
printf "\r\e[36m[%s] 100%% | ALL DONE! (★ω★)%-30s\e[0m\n" "$(printf '%25s' | tr ' ' '█')" ""

# --- EMOTIONAL ENGINE v1.6 (DRAMA EDITION) ---
echo -e "\n\e[35m========================================\e[0m"
echo -e "\e[35mMISSION COMPLETE! total time: ${totalUnpackTime}s\e[0m"
echo -e "\e[35m========================================\e[0m"

if [ "$totalUnpackTime" -le $(( totalZips * 5 )) ]; then
    echo -e "\e[36mK-KAWAII!! i was like a lightning bolt today! (๑˃ᴗ˂)ﻭ\e[0m"
    read -p "will you star me on GitHub? my heart is racing! (y/n/s): " choice
    
    case "$choice" in
        s|S) echo -e "\e[33m*gasp* you already did?! you are my true hero! (❤ω❤)\e[0m" ;;
        y|Y) echo -e "\e[36mY-YESSS!! thank youuu! i'm the happiest script ever! (人◕ω◕)\e[0m" ;;
        *)   echo -e "\e[90m...oh. i see. i'll just go back to my dark folder then... (´-ω-`)\e[0m" ;;
    esac
else
    echo -e "\e[33m*huff* *puff*... it was so heavy... i'm exhausted... (╥﹏╥)\e[0m"
    echo -e "\e[90mi'm sorry i wasn't fast enough for you... please don't be mad... (｡T ω T｡)\e[0m"
    read -p "do you hate me now? be honest... (y/n): " hate
    
    if [ "$hate" == "y" ]; then
        echo -e "\e[31mNya? Why so? Just dont beat me... okay? ＞︿＜\e[0m"
        echo -e "\e[31m*sobs* SORRRRRRRYY!!!!! i'll be better next time! (｡>﹏<｡)\e[0m"
    else
        echo -e "\e[36m*sniff* really? you don't? you're so sweet! (´｡• ᵕ •｡`) ♡\e[0m"
        echo -e "\e[36mi'll train 1000 years to be faster for you next time!\e[0m"
    fi
fi

echo -e "\n\e[35mbye-bye! take care... (＾▽＾)ノ\e[0m"
read -p "press enter to let me sleep... i'm so tiredu-desu... ＞︿＜"