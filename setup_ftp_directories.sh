#!/bin/bash

ftp_destination=~/website/data
cycle=(0 6 12 18)

# end of usual input section

if [ -d $ftp_destination ]
then
rm -r $ftp_destination 
fi

mkdir $ftp_destination
mkdir $ftp_destination/model_output

cp disclaimer $ftp_destination
cp readme_server $ftp_destination/model_output/README.txt
mkdir $ftp_destination/maps
mkdir $ftp_destination/model_output/surface
mkdir $ftp_destination/model_output/pressure_levels
for hour in ${cycle[@]}
do
mkdir $ftp_destination/model_output/surface/$hour"UTC"
mkdir $ftp_destination/model_output/pressure_levels/$hour"UTC"
mkdir $ftp_destination/maps/$hour"UTC"
done
