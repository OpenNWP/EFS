# Experimental Forecasting System (EFS)

This is a collection of bash scripts needed for running GAME operationally (for numerical weather prediction). A formal documentation is not included and not necessary. This README provides an overview of the structure and contents of the scripts.

## General purpose

The general purpose of the `EFS` is to

* call the `obs_collector` of `GAME-DA` to download observations from the latest analysis time window,
* call `GAME-DA` for data assimilation,
* run `GAME`,
* execute the plot scripts of `GAME` to produce visual products,
* manage uploading the data to a website and removing old data.
