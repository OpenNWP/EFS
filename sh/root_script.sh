#!/bin/bash

start=$(date +%s)

# This file manages model runs including pre- and postprocessing.

source $efs_home_dir/sh/determine_latest_analysis_time.sh

# deleting old data from the model output directory
directory=$output_destination/maps/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh

# setting the run ID
analysis_hour_extended_string=$analysis_hour
if [ $analysis_hour -lt 10 ]
then
  analysis_hour_extended_string="0$analysis_hour"
fi
run_id="EFS_$analysis_year$analysis_month$analysis_day$analysis_hour_extended_string"

start_initialization=$(date +%s)

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
background_file_candidate=$model_home_dir/output/$run_id_previous/$run_id_previous+${delta_t_between_analyses_min}min_hex.nc
if [ -f $background_file_candidate ]
then
  background_file=$background_file_candidate
fi

# executing real2GAME
$real2game_home_dir/run.sh $model_target_id $model_src_id $nsoillays $n_layers $res_id $omp_num_threads $real2game_home_dir $background_file 1 $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string $model_home_dir
# the output of the previous run is not needed anymore now
rm -r $model_home_dir/output/$run_id_previous

# time keeping
end_initialization=$(date +%s)
diff_initialization=$(echo "$end_initialization - $start_initialization" | bc)

start_model=$(date +%s)
# executing the model
$model_home_dir/run_scripts/op.sh $omp_num_threads $delta_t_between_analyses_min 1 $run_id $run_span_min $model_home_dir $analysis_year $analysis_month $analysis_day $analysis_hour_extended_string
end_model=$(date +%s)
diff_model=$(echo "$end_model - $start_model" | bc)

# clean-up of FTP directories
directory=$output_destination/model_output/surface/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh
directory=$output_destination/model_output/pressure_levels/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh
directory=$output_destination/maps/$analysis_hour"UTC"
source $efs_home_dir/sh/cleanup.sh

# copying the output to a directory that is accessible by the webserver
cp $model_home_dir/output/$run_id/*surface.nc $output_destination/model_output/surface/$analysis_hour"UTC"/
cp $model_home_dir/output/$run_id/*pressure_levels.nc $output_destination/model_output/pressure_levels/$analysis_hour"UTC"/

start_pp=$(date +%s)

# creating the JSON files
python3 $model_home_dir/plotting/py/netcdf2json.py $model_home_dir/output/$run_id $run_id $backend_dir/json

if [ $plot_maps -eq 1 ]
then

  # creating the plots
  if [ $run_span_min -gt $((72*60)) ]
  then
    $model_home_dir/plotting/plot_maps_batch.sh $omp_num_threads 0 $map_plot_interval_early_min $figs_save_path/maps/$analysis_hour"UTC" $model_home_dir $run_id $((72*60))
    $model_home_dir/plotting/plot_maps_batch.sh $omp_num_threads $((72*60 + $map_plot_interval_late_min)) $map_plot_interval_late_min $figs_save_path/maps/$analysis_hour"UTC" $model_home_dir $run_id $run_span_min
  else
    $model_home_dir/plotting/plot_maps_batch.sh $omp_num_threads 0 $map_plot_interval_early_min $figs_save_path/maps/$analysis_hour"UTC" $model_home_dir $run_id $run_span_min
  fi
  
fi

# cleaning the output directory of GAME
rm $model_home_dir/output/$run_id/*surface.nc
rm $model_home_dir/output/$run_id/*pressure_levels.nc

end_pp=$(date +%s)
diff_pp=$(echo "$end_pp - $start_pp" | bc)

# deleting the input from the model's input directory apart from the standard background state
mv $model_home_dir/nwp_init/standard_oro1.nc $model_home_dir/standard_oro1.nc
rm $model_home_dir/nwp_init/*
mv $model_home_dir/standard_oro1.nc $model_home_dir/nwp_init/standard_oro1.nc

# time analysis
end=$(date +%s)
diff=$(echo "$end - $start" | bc)
initialization_percentage=$(python3 -c "print(round(100*$diff_initialization/$diff))")
model_percentage=$(python3 -c "print(round(100*$diff_model/$diff))")
pp_percentage=$(python3 -c "print(round(100*$diff_pp/$diff))")

echo ""
echo "Time usage analysis:"
echo "absolute (s):"
echo "total: $diff"
echo "relative (%):"
echo "initialization: $initialization_percentage "
echo "model: $model_percentage"
echo "post-processing: $pp_percentage"









