#!/bin/bash

# pdx_mods_extractor.sh - anime girl bash edition v1.3 (｡♥‿♥｡)
# mascot: a hardworking fanloid girl who learned bash just for you!

# check if unzip is installed, cuz i'm not a magician (╥﹏╥)
if ! command -v unzip &> /dev/null; then
    echo -e "\e[31muwaaa! unzip command not found! pwease install it! (╯°□°）╯︵ ┻━┻\e[0m"
    exit 1
fi

modPath=$(pwd)
parentFolder=$(basename "$(dirname "$modPath")")
storagePath="$HOME/Documents/Mods/$parentFolder"

# making sure there's a cozy place for backups ヽ(♡‿♡)ノ
mkdir -p "$storagePath"

zipFiles=(*.zip)
totalZips=${#zipFiles[@]}
currentZipCount=0
totalUnpackTime=0

if [ "$totalZips" -eq 0 ] || [ ! -e "${zipFiles[0]}" ]; then
    echo -e "\e[31muwaaa! no zips found here! where did they go?! (｡T ω T｡)\e[0m"
    read -p "press enter to bail... ＞︿＜"
    exit 1
fi

echo -e "\e[36mstarting super fast batch extraction of $totalZips mods... (´• ω •\`)\e[0m"
echo -e "\e[90mi will be quiet until the end so you can eat your yummy food! ( ˘▽˘)っ♨\n\e[0m"

# --- BATCH PROCESSING START (Ninja Mode) ---
for zip in "${zipFiles[@]}"; do
    ((currentZipCount++))
    startTime=$(date +%s)
    
    # drawing the kawaii progress bar (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧
    percent=$(( currentZipCount * 100 / totalZips ))
    barLength=25
    doneCount=$(( percent * barLength / 100 ))
    todoCount=$(( barLength - doneCount ))
    
    bar=$(printf "%${doneCount}s" | tr ' ' '█')
    dots=$(printf "%${todoCount}s" | tr ' ' '░')
    
    # updating the same line! keep it clean! 🧹
    printf "\r\e[36m[%s%s] %d%% | unpacking: %-30s\e[0m" "$bar" "$dots" "$percent" "${zip%.zip}"

    # peek inside for descriptor.mod (¬‿¬ )
    # unzip -p prints file content to stdout
    content=$(unzip -p "$zip" "descriptor.mod" 2>/dev/null)

    if [ $? -eq 0 ]; then
        # regex magic for Engrish power!
        modName=$(echo "$content" | grep -oP 'name\s*=\s*"\K[^"]+' || echo "${zip%.zip}")
        version=$(echo "$content" | grep -oP 'version\s*=\s*"\K[^"]+' || echo "1.0")
        tags=$(echo "$content" | grep -oP 'tags\s*=\s*\{\K[^\}]+' || echo "")
        
        folderName=$(echo "$modName" | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_')
        
        # zoom zoom direct unpacking! 🚀
        rm -rf "$folderName"
        unzip -q "$zip" -d "$folderName"
        
        # writing .mod file for paradox launcher (^_<)b
        cat <<EOF > "${folderName}.mod"
version="$version"
tags={
    $tags
}
name="$modName"
path="mod/$folderName"
EOF
        # move zip to storage
        mv "$zip" "$storagePath/"
        
        endTime=$(date +%s)
        duration=$(( endTime - startTime ))
        totalUnpackTime=$(( totalUnpackTime + duration ))
    else
        echo -e "\n\e[33muwaa! skipping $zip cuz no descriptor.mod found... (´-ω-`)\e[0m"
    fi
done

echo -e "\n"

# --- EMOTIONAL ENGINE 1.6 (The Bash Patch) ---
echo -e "\e[35m========================================\e[0m"
echo -e "\e[35m--- MISSION COMPLETE! (★ω★) ---\e[0m"
echo -e "\e[37mtotal time for $totalZips mods: ${totalUnpackTime}s\e[0m"
echo -e "\e[35m========================================\n\e[0m"

# check if i was a fast girl today!
if [ "$totalUnpackTime" -le $(( totalZips * 10 )) ]; then
    echo -e "\e[36mK-KAWAII!! i was super fast today right?! (๑˃ᴗ˂)ﻭ\e[0m"
    read -p "will you star me on GitHub? (y/n/s - already starred) (^///^): " choice
    
    case "$choice" in
        s|S) echo -e "\e[33myippy! you are my hero! thank u for the star already! (❤ω❤)\e[0m" ;;
        y|Y) echo -e "\e[36mYippy!!!!!!!!!! thank uuuuuuu!!!! (人◕ω◕)\e[0m" ;;
        *)   echo -e "\e[90moh... okay... i'll still work my best for you... (´｡• ᵕ •｡`)\e[0m" ;;
    esac
else
    echo -e "\e[33muwaaaa! ${totalUnpackTime} seconds?! i'm so sorry... (╥﹏╥)\e[0m"
    read -p "do you hate me now because i'm so slow? (y/n) {{{(>_<)}}}: " hate
    
    if [ "$hate" == "y" ]; then
        echo -e "\e[31mwhy are you so a big meanie?! i'm working so hard... (╥﹏╥)\e[0m"
    else
        echo -e "\e[36mphew! you are so kind to me! (´｡• ᵕ •｡`) ♡\e[0m"
    fi
fi

echo -e "\n\e[35mbye-bye! take care of your mods! (＾▽＾)ノ\e[0m"
read -p "press enter to let me rest pweease... ＞︿＜"