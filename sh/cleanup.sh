#!/bin/bash

# This file deletes old files from $directory.

year_yesterday=$(date --utc -d @$(($now - 86400)) +%Y)
month_yesterday=$(python3 -c "print(int('$(date --utc -d @$(($now - 86400)) +%m)'))")
day_yesterday=$(python3 -c "print(int('$(date --utc -d @$(($now - 86400)) +%d)'))")

files=$(ls $directory)
for file in $files
do
  year=${file:4:4}
  month=${file:8:2}
  day=${file:10:2}
  if [ $year -lt $year_yesterday ] || [ $month -lt $month_yesterday ] || ([ $day -lt $day_yesterday ] && [ $month -eq $month_yesterday ])
  then
    rm -r $directory/$file
  fi
done
