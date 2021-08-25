#!/bin/bash

# In this file, the time of the analysis to be executed is determined.

previous=$(($now - $delta_t_between_analyses))
analysis_year_prev=$(date --utc -d @$previous +%Y)
analysis_month_prev=$(date --utc -d @$previous +%m)
analysis_day_prev=$(date --utc -d @$previous +%d)
previous_hour=$(date --utc -d @$previous +%k)
# finding the correct analysis hour
analysis_hour_prev=${cycle[-1]}
for i in $(seq 0 1 $((${#cycle[@]} - 2)))
do
if [ ${cycle[$i]} -le $previous_hour ] && [ ${cycle[$(($i + 1))]} -gt $previous_hour ]
then
analysis_hour_prev=${cycle[$i]}
fi
done
