#!/bin/bash
#
# mdjsoner: A program that has a codependency with ipmd
# v0.0.1a
#
# mdjsoner will iterate through every single subdirectories in the
# specified directory, reading through the metadata of the files.
#
# mdjsoner will attempt to read three tags: title, artist, & album.
# If any of these tags are unavailable or weirdly formatted, I'm not
# responsible for the lost of sleep hours.
#
# After reading through the tags, it will then attempt to update $TEMPLATE_FILE,
# which can be overridden by the same environment variable.
#
# Usage: mdjsoner.sh <directory> <output file>
#

if [ -z "$TEMPLATE_FILE" ]; then
   TEMPLATE_FILE=template.json
fi

if [ -z "$MDJS_PREFIX" ]; then
   MDJS_PREFIX=""
fi

probe_and_json() {
   if [ ! -f "$1" ]; then
      return # This path is invalid.
   fi
   
   title="$(ffprobe "$1" -show_entries format_tags=title -of compact=p=0:nk=1 -v 0)"
   artist="$(ffprobe "$1" -show_entries format_tags=artist -of compact=p=0:nk=1 -v 0)"
   album="$(ffprobe "$1" -show_entries format_tags=album -of compact=p=0:nk=1 -v 0)"
   id="$(jq '.entry.files | length' "$3")" # Hopefully will return 0 on a bad day.
   
   echo -e "\e[1mFound:\e[21m $title / $artist [$album]"
   
   path="$(echo $2$1 | sed 's/ /%20/g')"
   
   # Append to index
   jq --arg id "$((id+1))" \
      --arg path "$path" \
      --arg title "$title" \
      --arg artist "$artist" \
      --arg album "$album" \
      '.entry.files += [{"id": $id, "filePath": $path, "title": $title, "artist": $artist, "album": $album}]' "$3" > "$3".nyeh
   
   # Move our magic nyeh
   mv "$3".nyeh "$3"
};

export -f probe_and_json # TODO: NOT POSIX COMPLIANT

## Usual jq check
if ! command -v jq &> /dev/null
then
    echo -e "\e[1;31mError:\e[21;39m Can't find 'jq' in your PATH. This script will now exit."
    exit
fi

## Ffmpeg for ffprobe, duh
if ! command -v ffmpeg &> /dev/null
then
    echo -e "\e[1;31mError:\e[21;39m Can't find 'ffmpeg' in your PATH. This script will now exit."
    exit
fi

## Make sure we're sane
if [ ! -d "$1" ]; then
    echo -e "\e[1;31mError:\e[21;39m $1 is not a directory, or it doesn't exist. The script will now exit."
    exit
fi

## Also make sure our variable is sane
dir="$1"
cp "$TEMPLATE_FILE" "$2"
echo "Starting scan and probe..."; echo -e "\e[1mThis will take a lot of time\e[21m. Please wait."

## Use find to iterate through the directories
# Also run our custom function there too, why not.
find "$1" -print0 | sort -z | while IFS= read -r -d '' file; do probe_and_json "$file" "$MDJS_PREFIX" "$2"; done

## Update the count
echo -e "\e[1mFinished.\e[21m"
echo "Updating song count..."

count="$(jq '.entry.files | length' "$2")"
jq --arg count "$count" '.entry.count = $count' "$2" > "$2".nyeh
mv "$2".nyeh "$2"