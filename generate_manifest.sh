#!/bin/bash

# Define the folders to scan
FOLDERS=("body" "pattern" "feet" "face" "arm" "horn")
# Folders that should include a 'none' option
OPTIONAL_FOLDERS=("pattern" "arm" "horn")

echo "{" > manifest.json

for i in "${!FOLDERS[@]}"; do
    FOLDER="${FOLDERS[$i]}"
    echo "  \"$FOLDER\": [" >> manifest.json
    
    # Add 'none' if it's an optional folder
    IS_OPTIONAL=false
    for OPT in "${OPTIONAL_FOLDERS[@]}"; do
        [[ "$OPT" == "$FOLDER" ]] && IS_OPTIONAL=true && break
    done
    
    FIRST_ITEM=true
    if [ "$IS_OPTIONAL" = true ]; then
        echo -n "    \"none\"" >> manifest.json
        FIRST_ITEM=false
    fi
    
    # Find all png files in the folder
    if [ -d "$FOLDER" ]; then
        FILES=($(ls "$FOLDER"/*.png 2>/dev/null | xargs -n 1 basename))
        for FILE in "${FILES[@]}"; do
            if [ "$FIRST_ITEM" = true ]; then
                echo -n "    \"$FILE\"" >> manifest.json
                FIRST_ITEM=false
            else
                echo "," >> manifest.json
                echo -n "    \"$FILE\"" >> manifest.json
            fi
        done
    fi
    
    echo "" >> manifest.json
    
    # Add trailing comma if not the last folder
    if [ $i -lt $((${#FOLDERS[@]} - 1)) ]; then
        echo "  ]," >> manifest.json
    else
        echo "  ]" >> manifest.json
    fi
done

echo "}" >> manifest.json
echo "Manifest generated in manifest.json"
