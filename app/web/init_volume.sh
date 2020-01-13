#!/bin/sh

from=/www_init
to=/www

if [ -d "$to" ] && files=$(ls -AL -- "$to") && [ -z "$files" ]; then
  echo "$to is an empty directory"
  echo "copy volume init data to $to";
  cp -rf $from/* $to
else
  echo "$to is not empty, nothing to do."
fi