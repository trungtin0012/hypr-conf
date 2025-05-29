#!/bin/bash
# save as convert_mp4_to_webp.sh

input_file="$1"
time="${2:-5}"

output_file="${input_file%.*}.webp"

# Get CPU core count
cores=$(nproc)

echo "Converting $input_file to $output_file using $cores CPU cores..."
#-t : ouput first x seconds 
ffmpeg -i "$input_file" \
    -vf "fps=12,scale=1920:1080" \
    -vcodec libwebp \
    -q:v 80 \
    -compression_level 6 -loop 0 \
    -an -vsync 0 -t $time\
    -threads $cores \
    "$output_file"

echo "Conversion complete!"
