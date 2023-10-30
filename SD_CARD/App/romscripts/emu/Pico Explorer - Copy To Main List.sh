#!/bin/sh
echo $0 $*

scriptlabel="DynamicLabel"
sysdir=/mnt/SDCARD/.tmp_update
require_networking=1
rompath="$1"

# DynamicLabel management:
if [ "$3" = "DynamicLabel" ]; then
	emulabel="$4"
	romext="$7"

	echo -e "\n rompath= $1 \n emupath= $2 \n emulabel= $emulabel  \n romext= $romext \n"

	if [ "$romext" == "miyoocmd" ]; then
		DynamicLabel="none"

	else
		if echo "$rompath" | grep -q "Pico Explorer_"; then
			DynamicLabel="Copy this game to root list"
		else
			DynamicLabel="none"
		fi
	fi
	echo -n "$DynamicLabel" >/tmp/DynamicLabel.tmp
	exit
fi

echo -e "\n rompath= $1 \n emupath= $2 \n"

database_file="/mnt/SDCARD/Roms/PICO/PICO_cache6.db"
DBnames_file="/mnt/SDCARD/Roms/PICO/Pico Explorer/PICO_DBnames.db"
romFileName=$(basename "$1")

if cp "$rompath" /mnt/SDCARD/Roms/PICO/; then
	sync
	gamename=$(sqlite3 "$DBnames_file" "SELECT gamename FROM PICO_names WHERE filename = '$romFileName';")

	if [ -n "$gamename" ]; then
		newGameName="$(echo $gamename | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')" # first character forced in uppercase
	else
		newGameName="$(echo $romFileName | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')"
	fi

	query="INSERT INTO PICO_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin) VALUES ('$newGameName', '/mnt/SDCARD/Roms/PICO/$romFileName', '/mnt/SDCARD/Roms/PICO/$romFileName', 0, '.', '$newGameName', '$newGameName');"
	sqlite3 "$database_file" "$query"
	sync
	# sqlite3 "$database_file" "SELECT * FROM PICO_roms ORDER BY LOWER(disp);"
	# sync
else
	echo "Copy of \"$romFileName\" has failed."
fi
