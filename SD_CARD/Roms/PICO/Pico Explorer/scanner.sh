#!/bin/sh
echo $0 $*
progdir=$(dirname "$0")

Version="Pico Explorer v1.0"

cd "$progdir"

database_file="/mnt/SDCARD/Roms/PICO/PICO_cache6.db"
DBnames_file="/mnt/SDCARD/Roms/PICO/Pico Explorer/PICO_DBnames.db"
SubFoldersList="."

touch /tmp/dismiss_info_panel
sync
sleep 0.3
infoPanel -t "Pico Explorer" -m "Refreshing game list..." --persistent 2>/dev/null &
echo -e "\nImport game list...\n"

# Get the previous number of PICO games
OldGameNumber=$(sqlite3 "$database_file" "SELECT COUNT(*) FROM PICO_roms WHERE type = 0")
rm -f "$database_file"
sync
sleep 0.3
sync

## Test to create the database with MainUI (faster)
# echo "========================================================================================================================================="
# miyoodir=/mnt/SDCARD/miyoo
# cd $miyoodir/app
# PATH="$miyoodir/app:$PATH" LD_LIBRARY_PATH="$miyoodir/lib:/config/lib:/lib" LD_PRELOAD="$miyoodir/lib/libpadsp.so" ./MainUI &
# infoPanel -t "Pico Explorer" -m "Refreshing game list..." --persistent 2>/dev/null &
# sleep 5
# touch /tmp/dismiss_info_panel
# rm /tmp/state.json
# pkill -9 MainUI
# echo "========================================================================================================================================="

# Create a new database file
sqlite3 "$database_file" "CREATE TABLE PICO_roms (id INTEGER PRIMARY KEY, disp TEXT, path TEXT, imgpath TEXT, type INTEGER, ppath TEXT, pinyin TEXT, cpinyin TEXT);"

# Read the PICO config.json file
config_file="/mnt/SDCARD/Emu/PICO/config.json"
extlist=$(jq -r '.extlist' "$config_file")

# Scan files in the rompath directory
search_path="/mnt/SDCARD/Roms/PICO/"
img_path="/mnt/SDCARD/Roms/PICO/Imgs"
count=0

find "$search_path" -mindepth 1 -maxdepth 2 -type f | while read -r file; do

  # Skip files starting with a dot (.) or if it is the folder thumbnail
  filename=$(basename "$file")
  if [ "${filename#.*}" != "$filename" ]; then
    continue
  fi

  # Extract the extension of the file
  extension="${file##*.}"

  # Check if the extension is in the extlist
  if echo "$extlist" | grep -q "\b$extension\b"; then
    # ============================================================ Game Name Management ============================================================
    # we try to find the name in the database with 2 different queries (if we are in PICO Explorer then we prefix with numbers)
    if echo "$file" | grep -q "Pico Explorer_"; then
      gamename=$(sqlite3 "$DBnames_file" "SELECT numberorder, gamename FROM PICO_names WHERE filename = '$filename';" | sed 's/|/ /g' | sed 's/^ *//g')
    else
      gamename=$(sqlite3 "$DBnames_file" "SELECT gamename FROM PICO_names WHERE filename = '$filename';" | sed 's/^ *//g')
    fi

    if [ -n "$gamename" ]; then
      clean_filename="$(echo $gamename | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')" # first character forced in uppercase for right MainUI ordering
    else
      filename_without_ext="${filename%.*}"                                                      # Extract filename without extension
      clean_filename=$(echo "$filename_without_ext" | sed "s/'/''/g")                            # Escape single quotes in the filename
      clean_filename="$(echo $clean_filename | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')" # first character forced in uppercase for right MainUI ordering
    fi

    # ============================================================ Parent Folder Name Management ============================================================
    folder_fullpath=$(dirname "$file")
    # Determine if it is a subfolder
    if [ "${folder_fullpath%/}" = "${search_path%/}" ]; then
      subfolder_name="." # rom is in root
    else
      subfolder_name="${folder_fullpath##*/}"                   # we get just the subfolder name
      subfolder_name=$(echo "$subfolder_name" | sed "s/'/''/g") # we escape simple quotes by adding another simple quote
      if echo "$subfolder_name" | grep -q "Pico Explorer_"; then
        parent_folder="Pico Explorer" # rom is in a subfolder of "Pico Explorer"
        subfolder_name=$(echo "$subfolder_name" | sed 's/Pico Explorer_//')
      else
        parent_folder="." # rom is in a user folder (or "Pico Explorer" main folder itself)
      fi

      if ! echo "$SubFoldersList" | grep -q "$subfolder_name"; then
        imgpath="/mnt/SDCARD/Roms/PICO/Pico Explorer/Imgs/${subfolder_name}.png"
        # Create an entry for subfolder as if it were a game
        subfolder_query="INSERT INTO PICO_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin) VALUES (\"$subfolder_name\", \"$folder_fullpath\", \"$imgpath\", 1, \"$parent_folder\", \"$subfolder_name\", \"$subfolder_name\")"
        sqlite3 "$database_file" "$subfolder_query"
        SubFoldersList="$SubFoldersList,$subfolder_name"
      fi

      # Check if the subfolder entry already exists in the database
      # subfolder_check_query="SELECT COUNT(*) FROM PICO_roms WHERE disp = \"$subfolder_name\" AND type = 1"
      # subfolder_count=$(sqlite3 "$database_file" "$subfolder_check_query")
      # if [ "$subfolder_count" -eq 0 ]; then
      # fi
    fi

# ============================================================ Game Management ============================================================
    # Set the imgpath with the subfolder "Imgs"
    imgpath="$file"
    if [ "$filename" = "~Refresh Pico Explorer.miyoocmd" ]; then
      imgpath="/mnt/SDCARD/Roms/PICO/Pico Explorer/Imgs/refresh.png"
    fi

    let count++
    echo $count >/tmp/count.log

    # Utilisez clean_filename dans votre requête d'insertion
    query="INSERT INTO PICO_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin) VALUES ('$clean_filename', '$file', '$imgpath', 0, '$subfolder_name', '$clean_filename', '$clean_filename');"
    sqlite3 "$database_file" "$query"

    echo "Entry created for file: $file"
  fi

done


sync
touch /tmp/dismiss_info_panel
sync

count=$(cat /tmp/count.log)
rm /tmp/count.log

# Reset list and cache
/mnt/SDCARD/.tmp_update/script/reset_list.sh "/mnt/SDCARD/Roms/PICO/Pico Explorer"

if [ $count -eq 0 ]; then
  result_message="No games found"
elif [ $count -eq 1 ]; then
  result_message="Found 1 game"
else
  result_message="Found $count games\n$((count - OldGameNumber)) Games added."
fi

result_message="$result_message\n \n \n $Version By Schmurtz."

echo "\n================================= DONE! $result_message =================================\n\n"
infoPanel -t "Pico Explorer" -m "$result_message" 

sync
