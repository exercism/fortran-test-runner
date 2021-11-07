#!/bin/sh

for exp_res in $(find . -name expected_results.json); do
    res=$(echo $exp_res | sed 's/expected_//')
    cmd="cp $res $exp_res"
    echo $cmd
    $cmd
done
