#!/bin/bash
#PBS -N KrediP
#PBS -l walltime=01:00:00
#PBS -l ncpus=1
#PBS -l mem=32GB
#PBS -l wd
#PBS -q express
#PBS -M ryan.holmes@unsw.edu.au

module load nco

NAME=C6_2D_MLT
OUTP=049

echo "ncra ocean.nc"
ncra archive/output${OUTP}/ocean/ocean.nc archive/processed/ocean.${NAME}.out${OUTP}.ncra.nc
echo "ncra ocean_month.nc"
ncra archive/output${OUTP}/ocean/ocean_month.nc archive/processed/ocean_month.${NAME}.out${OUTP}.ncra.nc
echo "ncrcat ocean_scalar.nc"
ncrcat $(seq -f archive/output%03.0f/ocean/ocean_scalar.nc 0 ${OUTP}) archive/processed/ocean_scalar.${NAME}.out000-${OUTP}.ncrcat.nc
echo "ncra -v mld_max -y max ocean_month.nc"
ncra -v mld_max -y max archive/output${OUTP}/ocean/ocean_month.nc archive/processed/ocean_month.mld_max.${NAME}.out${OUTP}.ncra.nc
echo "Loop calculate ty_trans_xsum"
for out in $(seq -f %03.0f 0 ${OUTP})
do
    echo $out
    ncap2 -v -s 'ty_trans_rho_xsum=ty_trans_rho.total($grid_xt_ocean);ty_trans_rho_gm_xsum=ty_trans_rho_gm.total($grid_xt_ocean)' archive/output$out/ocean/ocean.nc archive/processed/ocean.$out.ty_trans_rho.xsum.nc
done
echo "concatenate xsums"
ncrcat archive/processed/ocean.*.ty_trans_rho.xsum.nc archive/processed/ocean.ty_trans_rho.xsum.${NAME}.out000-${OUTP}.ncrcat.nc
rm archive/processed/ocean.*.ty_trans_rho.xsum.nc

# echo "ncdiff ocean.ncra.nc"
# ncdiff archive/processed/ocean.${NAME}.out${OUTP}.ncra.nc /scratch/e14/rmh561/access-om2/archive/1deg_jra55_ryf_red3DSK/processed/ocean.cont.out${OUTP}.ncra.nc archive/processed/ocean.${NAME}.out${OUTP}.ncra.diff.nc
# echo "ncdiff ocean_month.ncra.nc"
# ncdiff archive/processed/ocean_month.${NAME}.out${OUTP}.ncra.nc /scratch/e14/rmh561/access-om2/archive/1deg_jra55_ryf_red3DSK/processed/ocean_month.cont.out${OUTP}.ncra.nc archive/processed/ocean_month.${NAME}.out${OUTP}.ncra.diff.nc
