#!/bin/bash

echo "--importing data--"
find real_data -name "*.csv" -print0 | xargs -0 -n 1 ../tyra.rb -n 0 -i
