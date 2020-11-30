#!/bin/bash
#PBS -q copyq
#PBS -l ncpus=1
#PBS -l wd
#PBS -l walltime=2:00:00,mem=2GB
#PBS -P e14
#PBS -l storage=gdata/e14+scratch/e14
#PBS -N restarts_to_gdata

source sync_output_to_gdata.sh # to define GDATADIR and cd archive

rsync -av --safe-links --no-g restart* ${GDATADIR}
