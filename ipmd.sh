#!/bin/bash

# Usage: ipmd <JSON address>
#
# This script is configurable using these environment variables:
# - IPMD_PLAYER: the music player that ipmd will try to pipe its to; defaults to 'cat'
# - IPMD_PATH  : when downloading, this is the path ipmd will default to

while :
do
   ## Set a sane default for our variables
   if [ -z $IPMD_PLAYER ]; then
      IPMD_PLAYER="mpv"
   fi

   if [ -z $IPMD_PATH ]; then
      IPMD_PATH="$(pwd)"
   fi

   ## Check for our necessities
   # We need jq to function, so check for that
   # TODO: Stop reusing these but somehow make them POSIX generic
   if ! command -v jq &> /dev/null
   then
      echo -e "\e[1;31mError:\e[21;39m Can't find 'jq' in your PATH. This script will now exit."
      exit
   fi

   ## Download the JSON
   # For now, this suffices.
   echo "Fetching index..."
   file="$(curl -s "$1")"

   ## Read the JSON with jq
   # Hopefully this is less janky than I anticipated
   # First, get the count.
   count=$(echo "$file" | jq -r '.entry.count')
   n=0

   # Loop through the file like the jank that we are.
   # TODO: This is SLOW as hell.
   while [ $n -ne $count ]; do
      n=$((n+1))
      urls[$n]=$(echo "$file" | jq -r --argjson num $((n-1)) '.entry.files[$num].filePath')
      title=$(echo "$file" | jq -r --argjson num $((n-1)) '.entry.files[$num].title')
      artist=$(echo "$file" | jq -r --argjson num $((n-1)) '.entry.files[$num].artist')
      album=$(echo "$file" | jq -r --argjson num $((n-1)) '.entry.files[$num].album')
      echo "$n. $title / $artist [$album]" 
   done
   echo "Press CTRL + C to exit!"
   echo "Play which [1-$n]? "; read input # TODO: NOT POSIX COMPLIANT
   echo; echo "Starting stream..."
   curl -s -L "${urls[$input]}" | $IPMD_PLAYER -
done


