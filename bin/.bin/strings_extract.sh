#!/usr/bin/env sh
cat - | grep -Eo '\S+' | tr -d '[:blank:]' | sort | uniq