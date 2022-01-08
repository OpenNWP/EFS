#!/bin/bash

START=$(date +%s)

# This file manages model runs including pre- and postprocessing.

source $efs_home_dir/sh/determine_latest_analysis_time.sh

# deleting old data from the model output directory
directory=$ftp_destination/visualizations/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh

# setting the run ID
analysis_hour_extended_string=$analysis_hour
if [ $analysis_hour -lt 10 ]
then
analysis_hour_extended_string="0$analysis_hour"
fi
run_id="EFS_$analysis_year$analysis_month$analysis_day$analysis_hour_extended_string"

START_ASSIMILATION=$(date +%s)

# executing the obs_collector
echo "Starting to collect observational data ..."
$da_home_dir/obs_collector/run.sh $da_home_dir $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string
echo "Collection of observational data completed."

# executing the formatter
echo "Starting to format observational data ..."
$da_home_dir/formatter/run_formatter.sh $da_home_dir $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string
grid_file_name=B5L26T${toa}_O${orography_id}_OL${orography_layers}_SCVT.nc

# finding the background_file
# default
background_file=$game_home_dir/nwp_init/test_2_$grid_file_name
# background state file from the previous run
source $efs_home_dir/sh/determine_previous_analysis_time.sh
analysis_hour_extended_string_prev=$analysis_hour_prev
if [ $analysis_hour_prev -lt 10 ]
then
analysis_hour_extended_string_prev="0$analysis_hour_prev"
fi
run_id_previous="EFS_$analysis_year_prev$analysis_month_prev$analysis_day_prev$analysis_hour_extended_string_prev"
background_file_candidate=$game_home_dir/output/$run_id_previous/$run_id_previous+${delta_t_between_analyses}s.nc
if [ -f $background_file_candidate ]
then
background_file=$background_file_candidate
fi

# executing GAME-DA
$da_home_dir/run_da.sh $omp_num_threads $toa $orography_layers $da_home_dir $background_file $orography_id $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string $game_home_dir

rm -r $game_home_dir/output/$run_id_previous
# cleaning the input directory of GAME-DA
rm $da_home_dir/input/*

END_ASSIMILATION=$(date +%s)
DIFF_ASSIMILATION=$(echo "$END_ASSIMILATION - $START_ASSIMILATION" | bc)

START_MODEL=$(date +%s)
# executing the model
$game_home_dir/run_scripts/op.sh $omp_num_threads $delta_t_between_analyses $orography_id $run_id $run_span $game_home_dir $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string $toa $orography_layers
END_MODEL=$(date +%s)
DIFF_MODEL=$(echo "$END_MODEL - $START_MODEL" | bc)

# clean-up of FTP directories
directory=$ftp_destination/model_output/surface/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh
directory=$ftp_destination/model_output/pressure_levels/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh
directory=$ftp_destination/visualizations/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh

# copying the output to the FTP server.
cp $game_home_dir/output/$run_id/*surface.grb2 $ftp_destination/model_output/surface/$analysis_hour"UTC"/
cp $game_home_dir/output/$run_id/*pressure_levels.grb2 $ftp_destination/model_output/pressure_levels/$analysis_hour"UTC"/

START_PP=$(date +%s)
if [ $plot_maps -eq 1 ]
then

# creating the JSON files
echo "Creating JSON files ..."
python3 $backend_home/py/grib2json.py $game_home_dir/output/$run_id/$run_id+$((6*3600))s_surface.grb2 ~/website/data/weather/current/current-wind-surface-level-gfs-1.0.json
echo "JSON files created."

# creating the plots
if [ $run_span -gt $((72*3600)) ]
then
$game_home_dir/plotting/plot_maps_batch.sh $omp_num_threads 0 $map_plot_interval_early $analysis_hour $analysis_day $analysis_month $analysis_year $figs_save_path/visualizations/$analysis_hour"UTC" $game_home_dir $run_id $((72*3600))
$game_home_dir/plotting/plot_maps_batch.sh $omp_num_threads $((72*3600 + $map_plot_interval_late)) $map_plot_interval_late $analysis_hour $analysis_day $analysis_month $analysis_year $figs_save_path/visualizations/$analysis_hour"UTC" $game_home_dir $run_id $run_span
else
$game_home_dir/plotting/plot_maps_batch.sh $omp_num_threads 0 $map_plot_interval_early $analysis_hour $analysis_day $analysis_month $analysis_year $figs_save_path/visualizations/$analysis_hour"UTC" $game_home_dir $run_id $run_span
fi

fi

END_PP=$(date +%s)
DIFF_PP=$(echo "$END_PP - $START_PP" | bc)

# deleting the input from the model's input directory
rm $game_home_dir/nwp_init/*

# time analysis
END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
assimilation_percentage=$(python3 -c "print(round(100*$DIFF_ASSIMILATION/$DIFF))")
model_percentage=$(python3 -c "print(round(100*$DIFF_MODEL/$DIFF))")
pp_percentage=$(python3 -c "print(round(100*$DIFF_PP/$DIFF))")

echo ""
echo "Time usage analysis:"
echo "absolute:"
echo "			reality	/ s	target / s":
echo "total:			$DIFF		$target"
echo "relative:"
echo "			reality	/ %	target / %":
echo "data assimilation:	$assimilation_percentage 		25"
echo "model:			$model_percentage 		50"
echo "post-processing:	$pp_percentage 		25"









