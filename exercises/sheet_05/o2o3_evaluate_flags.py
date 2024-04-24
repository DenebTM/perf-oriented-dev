#!/usr/bin/env python3
import json
import statistics
import sys

base = sys.argv[1]

progs = ['delannoy', 'mmul', 'nbody', 'qap', 'npb_bt_w', 'ssca2']
flags = [
    '-fgcse-after-reload',
    '-fipa-cp-clone',
    '-floop-interchange',
    '-floop-unroll-and-jam',
    '-fpeel-loops',
    '-fpredictive-commoning',
    '-fsplit-loops',
    '-fsplit-paths',
    '-ftree-loop-distribution',
    '-ftree-partial-pre',
    '-funswitch-loops',
    '-fvect-cost-model=dynamic',
    '-fversion-loops-for-strides'
]

relative = [
    dict((flag, json.load(open(f'{base}/{prog}/{flag}.json'))['mean']['wall']
        / json.load(open(f'{base}/{prog}/none.json'))['mean']['wall'])
     for flag in flags)
    for prog in progs]

median_relative = dict(
    sorted((
        (flag, statistics.median(d[flag] for d in relative)) for flag in flags),
        key=lambda item: item[1]
    )
)

print('Best flags by median relative performance:')
for i in range(3):
    flag, val = list(median_relative.items())[i]
    print('- {:<30} ({:8.6f})'.format(flag, val))

print('Worst flags:')
for i in range(3):
    flag, val = list(median_relative.items())[-1 - i]
    print('- {:<30} ({:8.6f})'.format(flag, val))
