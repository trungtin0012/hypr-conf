#!/bin/sh
# Changes the wallpaper to a randomly chosen image in a given directory

if [ $# -lt 1 ] || [ ! -d "$1" ]; then
	printf "Usage:\n\t\e[1m%s\e[0m \e[4mDIRECTORY\n" "$0"
	exit 1
fi

# See swww-img(1)
RESIZE_TYPE="fit"
export SWWW_TRANSITION_FPS="${SWWW_TRANSITION_FPS:-60}"
export SWWW_TRANSITION_STEP="${SWWW_TRANSITION_STEP:-2}"

#
#find "$1" -type f \
#| while read -r img; do
#	echo "$(</dev/urandom tr -dc a-zA-Z0-9 | head -c 8):$img"
#done \
#| sort -n | cut -d':' -f2- \

# Find all regular files in the folder (non-recursive)
files=($(find "$1" -maxdepth 1 -type f))

# Pick a random file
img="${files[RANDOM % ${#files[@]}]}"

echo $img
swww img --resize="$RESIZE_TYPE" "$img"
echo "done"

