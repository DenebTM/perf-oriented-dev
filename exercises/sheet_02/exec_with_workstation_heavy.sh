#!/usr/bin/env bash

killall loadgen &> /dev/null

dir="$1"
[[ -z "$dir" ]] && (echo "Usage: $0 <path/to/tools>"; exit 1)
shift

$dir/build/loadgen mc3 \
    $dir/load_generator/workstation/sys_load_profile_workstation_excerpt.txt &> /dev/null &
$dir/build/loadgen mc3 \
    $dir/load_generator/workstation/sys_load_profile_workstation_excerpt.txt &> /dev/null &
$dir/build/loadgen mc3 \
    $dir/load_generator/workstation/sys_load_profile_workstation_excerpt.txt &> /dev/null &
$dir/build/loadgen mc3 \
    $dir/load_generator/workstation/sys_load_profile_workstation_excerpt.txt &> /dev/null &
$dir/build/loadgen mc3 \
    $dir/load_generator/workstation/sys_load_profile_workstation_excerpt.txt &> /dev/null &
$dir/build/loadgen mc3 \
    $dir/load_generator/workstation/sys_load_profile_workstation_excerpt.txt &> /dev/null &
#time -p nice -n 100 $1
nice -n 1000 $*
killall loadgen &> /dev/null
