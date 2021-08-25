#!/bin/bash

START=$(date +%s)

# This file manages model runs including pre- and postprocessing.

source $opennwp_home_dir/sh/determine_latest_analysis_time.sh

# deleting old data from the model output directory
directory=$ftp_destination/visualizations/$analysis_hour"UTC"
source $opennwp_home_dir/sh/cleanup.sh

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
$ndvar_home_dir/obs_collector/run.sh $ndvar_home_dir $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string
echo "Collection of observational data completed."

# executing the formatter
echo "Starting to format observational data ..."
$ndvar_home_dir/formatter/run_formatter.sh $ndvar_home_dir $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string
# executing ndvar
grid_file_name=B5L26T${toa}_O${orography_id}_OL${orography_layers}_SCVT.nc

# finding the background_file
# default
background_file=$game_home_dir/test_generator/test_states/test_2_$grid_file_name
# background state file from the previous run
source $opennwp_home_dir/sh/determine_previous_analysis_time.sh
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

$ndvar_home_dir/run_ndvar.sh $omp_num_threads $toa $orography_layers $ndvar_home_dir $background_file $orography_id $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string $game_home_dir

rm -r $game_home_dir/output/$run_id_previous
# cleaning the input directory of ndvar
rm $ndvar_home_dir/input/*

END_ASSIMILATION=$(date +%s)
DIFF_ASSIMILATION=$(echo "$END_ASSIMILATION - $START_ASSIMILATION" | bc)

cp $opennwp_home_dir/run_scripts/$run_script $game_home_dir/run_scripts/nwp.sh
# making the model input file executable
chmod +x $game_home_dir/run_scripts/nwp.sh

START_MODEL=$(date +%s)
# executing the model
$game_home_dir/run_scripts/nwp.sh $omp_num_threads $delta_t_between_analyses $orography_id $run_id $run_span $game_home_dir $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string $toa $orography_layers
END_MODEL=$(date +%s)
DIFF_MODEL=$(echo "$END_MODEL - $START_MODEL" | bc)

# clean-up of FTP directories
directory=$ftp_destination/model_output/surface/$analysis_hour"UTC"
source $opennwp_home_dir/sh/cleanup.sh
directory=$ftp_destination/model_output/pressure_levels/$analysis_hour"UTC"
source $opennwp_home_dir/sh/cleanup.sh
directory=$ftp_destination/visualizations/$analysis_hour"UTC"
source $opennwp_home_dir/sh/cleanup.sh

# copying the output to the FTP server.
cp $game_home_dir/output/$run_id/*surface.grb2 $ftp_destination/model_output/surface/$analysis_hour"UTC"/
cp $game_home_dir/output/$run_id/*pressure_levels.grb2 $ftp_destination/model_output/pressure_levels/$analysis_hour"UTC"/

START_PP=$(date +%s)
if [ $plot_maps -eq 1 ]
then
# creating the plots

if [ $run_span -gt $((72*3600)) ]
then
$opennwp_home_dir/plot_scripts/maps_server_0.sh 0 $map_plot_interval_early $analysis_hour $analysis_day $analysis_month $analysis_year $figs_save_path/visualizations/$analysis_hour"UTC" $game_home_dir $run_id $((72*3600))
$opennwp_home_dir/plot_scripts/maps_server_0.sh $((72*3600 + $map_plot_interval_late)) $map_plot_interval_late $analysis_hour $analysis_day $analysis_month $analysis_year $figs_save_path/visualizations/$analysis_hour"UTC" $game_home_dir $run_id $run_span
else
$opennwp_home_dir/plot_scripts/maps_server_0.sh 0 $map_plot_interval_early $analysis_hour $analysis_day $analysis_month $analysis_year $figs_save_path/visualizations/$analysis_hour"UTC" $game_home_dir $run_id $run_span
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









