#!/bin/bash

# In this file, the time of the analysis to be executed is determined.

now=$(date +%s)
now=$(($now - 60*$analysis_delay_min))
analysis_year=$(date --utc -d @$now +%Y)
analysis_month=$(date --utc -d @$now +%m)
analysis_day=$(date --utc -d @$now +%d)
now_hour=$(date --utc -d @$now +%k)
# finding the correct analysis hour
run_span_min=${run_spans_min[-1]}
analysis_hour=${cycle[-1]}
for i in $(seq 0 1 $((${#cycle[@]} - 2)))
do
  if [ ${cycle[$i]} -le $now_hour ] && [ ${cycle[$(($i + 1))]} -gt $now_hour ]
  then
    analysis_hour=${cycle[$i]}
    run_span_min=${run_spans_min[$i]}
  fi
done
