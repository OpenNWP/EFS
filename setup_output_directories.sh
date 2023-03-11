#!/bin/bash

output_destination=~/website/data
cycle=(0 6 12 18)

# end of usual input section

if [ -d $output_destination ]
then
  rm -r $output_destination 
fi

mkdir $output_destination
mkdir $output_destination/model_output

cp disclaimer $output_destination
cp readme_server $output_destination/model_output/README.txt
mkdir $output_destination/maps
mkdir $output_destination/model_output/pressure_levels
mkdir $output_destination/model_output/surface
for hour in ${cycle[@]}
do
  mkdir $output_destination/model_output/pressure_levels/$hour"UTC"
  mkdir $output_destination/model_output/surface/$hour"UTC"
  mkdir $output_destination/model_output/surface/$hour"UTC"/json
  mkdir $output_destination/maps/$hour"UTC"
done
