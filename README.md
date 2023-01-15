# Experimental Forecasting System (EFS)

This is a collection of bash scripts needed for running GAME and L-GAME operationally (for numerical weather prediction). A formal documentation is not included and not necessary. This README provides an overview of the structure and contents of the scripts.

## General purpose

The general purpose of the EFS is to

* call real2GAME for interpolating the analysis of another model to the model grid of (L-)GAME and, if necesary, boundary conditions for L-GAME,
* run GAME and/or L-GAME,
* execute the plot scripts of GAME to produce visual products,
* manage uploading the data to a website and removing old data.

## Directory structure

* The file `sh/root_script.sh` is the main script, it manages the execution of the tasks.
* The directory `op_configs` contains scripts defining the general configuration of the operational setup (directories of the relevant software components, analysis times, etc.).

## Background state file generation

Normally, EFS will pick the result of the previous model run as the background state of the data assimilation. In the case of the first run of a forecast cycle, however, this is not possible. Instead, the standard atmosphere is used as the background state. In order to create the required file, a run script called `write_icao_atmosphere.sh` is included in GAME, which needs to be executed once.

The rest is rather self-explanatory.

## First try for an execution

If GAME and real2GAME are properly installed,

	./op_configs/game.sh

will execute an NWP run of GAME. Modify the directories according to your directory structure.

