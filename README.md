# Experimental Forecasting System (EFS)

This is a collection of bash scripts needed for running GAME operationally (for numerical weather prediction). A formal documentation is not included and not necessary. This README provides an overview of the structure and contents of the scripts.

## General purpose

The general purpose of the EFS is to

* call real2GAME for interpolating the analysis of another model to the model grid of GAME,
* run GAME,
* execute the plot scripts of GAME to produce visual products,
* manage uploading the data to a website and removing old data.

## Directory structure

* The file `sh/root_script.sh` is the main script, it manages the execution of the tasks.
* The directory `op_configs` contains scripts defining the general configuration of the operational setup (directories of the relevant software components, analysis times, etc.).

## Background state file generation

Normally, EFS will pick the result of the previous model run as the background state of the data assimilation. In the case of the first run of a forecast cycle, however, this is not possible. Instead, the standard atmosphere is used as the background state. In order to create the required file, a run script called `create_da_background.sh` is included in GAME. Execute this script in order to generate the required netcdf file, move it from the output directory of GAME to the home directory of GAME and rename it to `standard_oro2.nc`.

The rest is rather self-explanatory.
