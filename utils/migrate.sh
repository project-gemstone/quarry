#!/bin/bash

msg() {
	echo -e "==> $1"
}

msg2() {
	echo -e " -> $1"
}

msgerr() {
	echo -e "==> ERROR: $1"
}

msgwarn() {
	echo -e "==> WARNING: $1"
}

SOURCE_DIR=/home/john/sources
DOWNLOAD_PROG="curl"

migratesums() {
	
	msg "Checking sums..."
	
	for s in $(seq 0 $((${#source[@]} - 1))); do
		if [ $(echo ${source[$s]} | grep -E "(ftp|http|https)://" ]; then
			if [ $(echo ${source[$s]} | grep -E "::(ftp|http|https)://" ]; then
				sourcename=$SOURCE_DIR/$(echo ${source[$s]} | awk -F '::' '{print $1}')
			else
				sourcename=$SOURCE_DIR/$(echo ${source[$s]} | rev | cut -d / -f 1 | rev)
			fi
		else
			sourcename="${source[$s]}"
		fi
		
        sum=$(sha256sum "$sourcename" | awk '{ print $1 }')
        filename=$(basename "$sourcename"

        echo "$sum  $filename" >> sha256sums
	done
}

download_src() {
	local FILE FILENAME
	
	for FILE in ${source[@]}; do
		if [[ $FILE =~ ::(http|https|ftp|file):// ]]; then
			FILENAME=$(echo $FILE | awk -F '::' '{print $1}')
			SRCURL=$(echo $FILE | awk -F '::' '{print $2}')
		else
			FILENAME=$(basename $FILE)
			SRCURL=$FILE
		fi
		case $DOWNLOAD_PROG in
			curl) DLCMD="curl -C - --fail --ftp-pasv --retry 3 --retry-delay 3 -o $SOURCE_DIR/$FILENAME.partial $CURL_OPTS" ;;
			wget) DLCMD="wget -c --passive-ftp --no-directories --tries=3 --waitretry=3 --output-document=$SOURCE_DIR/$FILENAME.partial $WGET_OPTS" ;;
		esac
		if [ "$FILENAME" != "$FILE" ]; then
			if [ -f "$SOURCE_DIR/$FILENAME" ] && [ -z "$REDOWNLOAD_SOURCE" ]; then
				msg "Source '$FILENAME' found."
			else
				[ "$REDOWNLOAD_SOURCE" ] && rm -f "$SOURCE_DIR/$FILENAME.partial"
				if [ -f "$SOURCE_DIR/$FILENAME.partial" ]; then
					msg "Resuming '$SRCURL'."
				else
					msg "Downloading '$SRCURL'."
				fi
				$DLCMD $SRCURL
				if [ $? = 0 ]; then
					[ "$REDOWNLOAD_SOURCE" ] && rm -f "$SOURCE_DIR/$FILENAME"
					mv $SOURCE_DIR/$FILENAME.partial $SOURCE_DIR/$FILENAME
				else
					msgerr "Failed downloading '$FILENAME'."
					exit 1
				fi
			fi
		else
			if [ ! -f "$FILENAME" ]; then
				msgerr "Source '$FILENAME' not found."
				exit 1
			else
				msg "Source '$FILENAME' found."
			fi
		fi
	done
}

for dir in */; do
   cd $dir

   rm -f sha256sums || true

   . ./spkgbuild

   download_src

   migratesums

   cd ..
done
