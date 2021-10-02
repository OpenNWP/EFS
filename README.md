# Experimental Forecasting System (EFS)

This is a collection of bash scripts needed for running GAME operationally (for numerical weather prediction). A formal documentation is not included and not necessary. This README provides an overview of the structure and contents of the scripts.

## General purpose

The general purpose of the `EFS` is to

* call the `obs_collector` of `GAME-DA` to download observations from the latest analysis time window,
* call `GAME-DA` for data assimilation,
* run `GAME`,
* execute the plot scripts of `GAME` to produce visual products,
* manage uploading the data to a website and removing old data.

## Directory structure

* The file `sh/root_script.sh` is the main script, it manages the execution of tasks.
* The directory `op_configs` contains scripts defining the general configuration of the operational setup (directoris of the relevant software components, analysis times, etc.).
* The directory `run_scripts` contains run scripts of `GAME` with bash arguments. If you want to change the runtime configuration of the model, do it here.
* The directory `plot_scripts` contains the list of variables to be plotted.

The rest is rather self-explanatory.
