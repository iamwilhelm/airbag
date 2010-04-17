#!/bin/bash

echo "--importing data--"
find real_data -name "*.csv" -print0 | xargs -i__ -0 -n 1 ../tyra.rb -n 0 -i __ bend_csv.yaml
