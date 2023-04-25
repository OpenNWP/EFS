#!/bin/bash

efs_home_dir=~/EFS # directory of EFS
model_src_id=3 # 1: ICON-Global, 2: GAME, 3: ICON-D2
model_target_id=2 # 1: GAME, 2: L-GAME
n_layers=26 #  number of layers of the model
nsoillays=5 # number of soil layers of the model
cycle=(0 3 6 9 12 15 18 21) # the UTC times of the analyses
delta_t_between_analyses_min=360 # the temporal distance between two analysesin minutes
run_spans_min=($((27*60)) $((27*60)) $((27*60)) $((27*60))) # the lengths of the runs in minutes
real2game_home_dir=~/real2GAME # the directory where real2GAME resides
model_home_dir=~/GAME # the home directory of the model
output_destination=~/opennwp/data # the directory where to place the output files
backend_dir=~/opennwp_backend # root directory of the backend
analysis_delay_min=70 # the number of minutes after which an analysis becomes available
plot_maps=1 # set this to one if you want to plot maps
map_plot_interval_early_min=$((1*60)) # the temporal distance between two plots before 72 hrs
map_plot_interval_late_min=$((6*60)) # the temporal distance between two plots after 72 hrs
figs_save_path=~/opennwp/data # the path to which the maps will be saved
omp_num_threads=2 # number of OMP threads

# this quantity is only relevant for GAME
res_id=5 # resolution ID of GAME

# these quantities are only relevant for L-GAME
ny=35 # number of gridpoints in y-direction
nx=35 # number of gridpoints in x-direction

# That's it, now the procedure will be started.
source $efs_home_dir/sh/root_script.sh

# associated crontab:
## m h  dom mon dow   command
#SHELL=/bin/bash
#PYTHONPATH=/usr/bin
#20 3 * * * /home/ubuntu/EFS/op_configs/l-game_in_icon-d2.sh > /home/ubuntu/logs/log_0Z 2>&1
#20 9 * * * /home/ubuntu/EFS/op_configs/l-game_in_icon-d2.sh > /home/ubuntu/logs/log_6Z 2>&1
#20 15 * * * /home/ubuntu/EFS/op_configs/l-game_in_icon-d2.sh > /home/ubuntu/logs/log_12Z 2>&1
#20 21 * * * /home/ubuntu/EFS/op_configs/l-game_in_icon-d2.sh > /home/ubuntu/logs/log_18Z 2>&1
#30 0 * * * /home/ubuntu/update_procedure.sh > /home/ubuntu/logs/log_updating 2>&1
#

