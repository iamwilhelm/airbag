#!/bin/bash

echo "--importing data--"
cd ..
find test/fixtures -name "*.csv" -print0 | xargs -0 -n 1 ./tyra.rb -n 2 -i
cd test
