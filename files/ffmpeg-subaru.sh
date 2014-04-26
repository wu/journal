#!/usr/bin/env bash

# path to ffmpeg
ffmpeg="ffmpeg"

usage="$0 <infile> <outfile>"

infile="$1"
[ -z "$infile" ] && echo $usage >&2 && exit 1
[ ! -r "$infile" ] && echo "ERROR: source file is not readable: $infile" >&2 && exit 1

outfile="$2"
[ -z "$outfile" ] && echo $usage >&2
[ -e "$outfile" ] && echo "ERROR: target file already exists: $outfile" >&2 && exit 1

$ffmpeg -i "$infile" -c:v mpeg4 -vtag xvid -vf scale=720:480 -b:v 1.5M -b:a 192k "$outfile"
