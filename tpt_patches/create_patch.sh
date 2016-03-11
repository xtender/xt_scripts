#!/bin/bash

FILES=tpt_patches/tpt_modified/*
PATCHFILE=tpt_patches/tpt.patch
PREFIX=tpt_patches/tpt_modified
for new in $FILES
do
  echo "Processing $new file..."
  fname=$(basename $new)
  #echo "Filename $fname"
  old=tpt/${new#$PREFIX/}
  #echo "old: $old"
  # take action on each file. $f store current file name
  diff -u "$old" "$new" >>tpt_patches/tpt.patch
  #cat $f
done