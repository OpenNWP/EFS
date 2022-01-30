#!/bin/bash

efs_home_dir=~/EFS # directory of EFS
cycle=(0 6 12 18) # the UTC times of the analyses
delta_t_between_analyses=21600 # the temporal distance between two analyses
run_spans=($((168*3600)) $((168*3600)) $((168*3600)) $((168*3600))) # the lengths of the runs
target=4200 # time length we target for the whole procedure
da_home_dir=~/GAME-DA # the directory where ndvar resides
game_home_dir=~/GAME # the home directory of GAME
ftp_destination=~/website/data # The FTP directory.
backend_home=~/backend # the directory of the backend
res_id=5 # resolution ID (number of bisections of basic icosahedral triangles)
number_of_layers=26
toa=41152 # top of atmosphere
analysis_delay_min=175 # the number of minutes after which an analysis becomes available
orography_id=1 # the ID of the orography field you want to use (see the game orography generator to find out about the meaning of the IDs)
plot_maps=1 # set this to one if you want to plot maps
map_plot_interval_early=$((3*3600)) # the temporal distance between two plots before 72 hrs
map_plot_interval_late=$((6*3600)) # the temporal distance between two plots after 72 hrs
figs_save_path=~/website/data # the path to which the maps will be saved
omp_num_threads=2 # number of OMP threads

# That's it, now the procedure will be started.
source $efs_home_dir/sh/root_script.sh

# associated crontab:
## m h  dom mon dow   command
#SHELL=/bin/bash
#PYTHONPATH=/usr/bin
#20 3 * * * /home/ubuntu/EFS/op_configs/server_0.sh > /home/ubuntu/log_0Z 2>&1
#20 9 * * * /home/ubuntu/EFS/op_configs/server_0.sh > /home/ubuntu/log_6Z 2>&1
#20 15 * * * /home/ubuntu/EFS/op_configs/server_0.sh > /home/ubuntu/log_12Z 2>&1
#20 21 * * * /home/ubuntu/EFS/op_configs/server_0.sh > /home/ubuntu/log_18Z 2>&1
#50 2 * * * /home/ubuntu/updating/update_procedure.sh > /home/ubuntu/log_updating 2>&1
#

