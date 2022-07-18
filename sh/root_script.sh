#!/bin/bash

START=$(date +%s)

# This file manages model runs including pre- and postprocessing.

source $efs_home_dir/sh/determine_latest_analysis_time.sh

# deleting old data from the model output directory
directory=$ftp_destination/maps/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh

# setting the run ID
analysis_hour_extended_string=$analysis_hour
if [ $analysis_hour -lt 10 ]
then
	analysis_hour_extended_string="0$analysis_hour"
fi
run_id="EFS_$analysis_year$analysis_month$analysis_day$analysis_hour_extended_string"

START_ASSIMILATION=$(date +%s)

# finding the background_file
# default
background_file=$model_home_dir/nwp_init/standard_oro1.nc
# background state file from the previous run
source $efs_home_dir/sh/determine_previous_analysis_time.sh
analysis_hour_extended_string_prev=$analysis_hour_prev
if [ $analysis_hour_prev -lt 10 ]
then
  analysis_hour_extended_string_prev="0$analysis_hour_prev"
fi
run_id_previous="EFS_$analysis_year_prev$analysis_month_prev$analysis_day_prev$analysis_hour_extended_string_prev"
background_file_candidate=$model_home_dir/output/$run_id_previous/$run_id_previous+${delta_t_between_analyses_min}min.nc
if [ -f $background_file_candidate ]
then
  background_file=$background_file_candidate
fi

# executing real2GAME
$real2game_home_dir/run.sh $omp_num_threads $real2game_home_dir $background_file 1 $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string $model_home_dir
# the output of the previous run is not needed anymore now
rm -r $model_home_dir/output/$run_id_previous

# time keeping
END_ASSIMILATION=$(date +%s)
DIFF_ASSIMILATION=$(echo "$END_ASSIMILATION - $START_ASSIMILATION" | bc)

START_MODEL=$(date +%s)
# executing the model
$model_home_dir/run_scripts/op.sh $omp_num_threads $delta_t_between_analyses_min 1 $run_id $run_span $model_home_dir $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string
END_MODEL=$(date +%s)
DIFF_MODEL=$(echo "$END_MODEL - $START_MODEL" | bc)

# clean-up of FTP directories
directory=$ftp_destination/model_output/surface/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh
directory=$ftp_destination/model_output/pressure_levels/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh
directory=$ftp_destination/maps/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh

# copying the output to the FTP server
cp $model_home_dir/output/$run_id/*surface.nc $ftp_destination/model_output/surface/$analysis_hour"UTC"/
cp $model_home_dir/output/$run_id/*pressure_levels.nc $ftp_destination/model_output/pressure_levels/$analysis_hour"UTC"/

START_PP=$(date +%s)
if [ $plot_maps -eq 1 ]
then

  # creating the plots
  if [ $run_span -gt $((72*3600)) ]
  then
    $model_home_dir/plotting/plot_maps_batch.sh $omp_num_threads 0 $map_plot_interval_early_min $figs_save_path/maps/$analysis_hour"UTC" $model_home_dir $run_id $((72*3600))
    $model_home_dir/plotting/plot_maps_batch.sh $omp_num_threads $((72*3600 + $map_plot_interval_late_min)) $map_plot_interval_late_min $figs_save_path/maps/$analysis_hour"UTC" $model_home_dir $run_id $run_span
  else
    $model_home_dir/plotting/plot_maps_batch.sh $omp_num_threads 0 $map_plot_interval_early_min $figs_save_path/maps/$analysis_hour"UTC" $model_home_dir $run_id $run_span
  fi
	
fi

# cleaning the output directory of GAME
rm $model_home_dir/output/$run_id/*surface.nc
rm $model_home_dir/output/$run_id/*pressure_levels.nc

END_PP=$(date +%s)
DIFF_PP=$(echo "$END_PP - $START_PP" | bc)

# deleting the input from the model's input directory apart from the standard background state
mv $model_home_dir/nwp_init/standard_oro1.nc $model_home_dir/standard_oro1.nc
rm $model_home_dir/nwp_init/*
mv $model_home_dir/standard_oro1.nc $model_home_dir/nwp_init/standard_oro1.nc

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
echo "initialization:		$assimilation_percentage 		2"
echo "model:			$model_percentage 		73"
echo "post-processing:	$pp_percentage 		25"









