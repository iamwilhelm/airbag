#!/bin/bash

echo "--clearing test db--"
redis-cli -n 2 flushdb
redis-cli -n 3 flushdb

echo "--importing data--"
find fixtures -name "*.csv" -print0 | xargs -i__ -0 -n 1 ../tyra.rb -n 2 -i __ bend_csv.yaml

