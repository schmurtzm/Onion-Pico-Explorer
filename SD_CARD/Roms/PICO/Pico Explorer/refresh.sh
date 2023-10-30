#!/bin/sh

# Function to retrieve the URL games from Splore
Refresh_PicoSection() {
	local SectionURL="$1"
	local TargetDir="$2"
	count=1

	echo -e "\n\n********************* Downloading Splore \"$(echo "$TargetDir" | sed 's/Pico Explorer_//')\" content... *********************\n\n"

	mkdir -p "../$TargetDir"

	curl -o /tmp/output.html -k "$SectionURL"

	if [ $? -ne 0 ]; then
		echo -e "\n\n********************* Splore download content failed. *********************\n\n"
		return 1
	fi

	data=$(cat /tmp/output.html)
	pdat_content=$(echo "$data" | awk '/pdat=\[/,/\];/')
	# For debugging:
	# echo $pdat_content

	# Define pdat_content for tests
	# pdat_content="['129136', 52547, 'Pico Froggo: Hop Across the Seasons', '/bbs/thumbs/pico8_froggohats-1.png', 96, 64, '2023-04-29 17:03:36', 76450, 'TheSmellyFrog', '2023-07-03 22:51:29', 79089, 'Pinapple', 53, 8, 0, 7, 2, '0', ['platformer', 'frog'], 0, 273, '', '', ],
	# ['45781', 30172, 'Happy Larry and the Vampire Bat', '/bbs/thumbs/pico45820.png', 96, 64, '2017-11-01 19:26:54', 11290, 'dollarone', '2023-10-24 16:17:50', 67356, 'thePixelXb_', 35, 15, 0, 7, 2, '0', ['3cjam', 'adventure', 'halloween', '3cjam'], 0, 273, '', '', ],
	# ['132559', 53583, 'Whiplash Taxi Co', '/bbs/thumbs/pico8_mot_taxi-6.png', 96, 64, '2023-07-30 10:31:59', 39676, 'Mot', '2023-10-12 08:31:59', 39676, 'Mot', 72, 13, 0, 7, 2, '0', ['3d', 'taxi', 'racing', 'driving'], 0, 277, '', '', ],"

	# Split pdat_content into individual lines
	IFS="
	"
	set -- $pdat_content

	while [ $# -gt 0 ]; do
		line="$1"
		shift

		# Extract long Game Name
		GameName=$(echo "$line" | awk -F "," '{print $3}' | sed "s/\`//g" | sed 's/^ *//g')

		if [ -z "$GameName" ]; then  # if game name is not found we take another field
			GameName=$(echo "$line" | awk -F "," '{print $23}' | sed "s/\`//g" | sed 's/^ *//g')
		fi
		GameName="${GameName//\'/ }"   #replaces all single quotes (') with spaces

		# Extract GameName
		GameFileURL=$(echo "$line" | awk -F "," '{print $4}' | sed "s/\"//g")

		if [ -n "$GameFileURL" ]; then
			RomID=$(basename "$GameFileURL" .png | sed -e "s/^\(pico8_\|pico\)//" -e "s/\"//") # removing  : the .png extension |  the prefixes "pico8_" or "pico" | the  double quotes
			RomFileName="${RomID}.png"
			formatted_number=$(printf "%03d" $count)

			# Manage thumbnail : disabled because it's almost the same as the rom itself...
			# ImageURL="https://www.lexaloffle.com$GameFileURL"
			# curl -o "../$TargetDir/Imgs/$RomFileName" -k "$ImageURL"

			if ! [ -f ../$TargetDir/$RomFileName ]; then
				DownloadURL="https://www.lexaloffle.com/bbs/get_cart.php?cat=7&play_src=2&lid=$RomID"

				# --- Multiple asynchronous downloads ---
				running=$(pgrep "curl" | wc -l)

				while [ $running -ge 2 ]; do
					sleep 0.3 # Wait for 1 second
					running=$(pgrep -f "curl -o ../$TargetDir/$RomFileName" | wc -l)
				done

				# Start a new 'curl' process in the background
				curl -s -o "../$TargetDir/$RomFileName" -k "$DownloadURL" &
				# ---------------------------------------

				echo -e " GameName: $formatted_number $GameName \n filename: $RomFileName \n $DownloadURL \n"
				# We add the long GameName to a dedicated database that we will use in scanner script to display better names than file names
				subfolder_query="INSERT OR IGNORE INTO PICO_names (filename, gamename ) VALUES ('$RomFileName', '$GameName');"
				sqlite3 "$DBnames_file" "$subfolder_query"

			else
				echo -e " GameName: $formatted_number $GameName \n RomID: $RomID \n RomFileName: $RomFileName \n $RomFileName already exist \n"
			fi

			# we add a suffix number to order the Splore results
			update_query="UPDATE PICO_names SET numberorder = '$formatted_number' WHERE filename = '$RomFileName';"
			sqlite3 "$DBnames_file" "$update_query"
			count=$((count + 1))

		fi
	done

	# if some download are still in background, we wait 20 seconds
	counter=0

	while pgrep -x curl >/dev/null; do
		if [ $counter -ge 40 ]; then
			pkill -9 curl
			echo "Pending curl have been killed."
			break
		fi
		counter=$((counter + 1))
		sleep 0.5
	done
}

enable_wifi() {
	# Enable wifi if necessary
	IP=$(ip route get 1 | awk '{print $NF;exit}')
	if [ "$IP" = "" ]; then
		echo "Wifi is disabled - trying to enable it..."
		insmod /mnt/SDCARD/8188fu.ko
		ifconfig lo up
		/customer/app/axp_test wifion
		sleep 2
		ifconfig wlan0 up
		wpa_supplicant -B -D nl80211 -iwlan0 -c /appconfigs/wpa_supplicant.conf
		udhcpc -i wlan0 -s /etc/init.d/udhcpc.script
		sleep 3
		clear
	fi
}

DBnames_file="/mnt/SDCARD/Roms/PICO/Pico Explorer/PICO_DBnames.db"

if ! [ -f $DBnames_file ]; then
	sqlite3 "$DBnames_file" "CREATE TABLE PICO_names (id INTEGER PRIMARY KEY, numberorder TEXT, filename TEXT UNIQUE, gamename TEXT);"
fi

rm /tmp/dismiss_info_panel
sync
infoPanel -t "Pico Explorer" -m "Downloading game list..." --persistent 2>/dev/null &
echo "=================================== Downloading Splore content... =$1=================================="

enable_wifi

if [ "$1" = "/mnt/SDCARD/Roms/PICO/Pico Explorer/~Refresh Pico Explorer.miyoocmd" ]; then
	sqlite3 "$DBnames_file" "UPDATE PICO_names SET numberorder = NULL;"
	Refresh_PicoSection "https://www.lexaloffle.com/bbs/?&orderby=featured&cat=7&sub=2&mode=carts" "Pico Explorer_Featured"
	Refresh_PicoSection "https://www.lexaloffle.com/bbs/?&cat=7&sub=2&mode=carts" "Pico Explorer_New"
	Refresh_PicoSection "https://www.lexaloffle.com/bbs/?&cat=7&sub=8&mode=carts" "Pico Explorer_Jam"
	Refresh_PicoSection "https://www.lexaloffle.com/bbs/?&cat=7&sub=3&mode=carts" "Pico Explorer_Work in Progress"
else
	# this is a search
	rm "../Pico Explorer_Search/*.png"
	Refresh_PicoSection "https://www.lexaloffle.com/bbs/lister.php?search=$1" "Pico Explorer_Search"

fi

echo "===================================    Splore Downloads Finished    ... ==================================="
