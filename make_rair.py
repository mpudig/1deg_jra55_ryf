# Make relative humidity netcdf JRA-55 RYF forcing file
import xarray
import netCDF4 as nc
import os
import datetime
from glob import glob
from calendar import isleap
import numpy as np

# Location of input files (air temp, humidity and SLP):
JRAin = '/g/data/ik11/inputs/JRA-55/RYF/v1-4/'

# RYF years:
RYFyrs = '1990_1991'

# Output directory:
JRAout = '/g/data/e14/rmh561/access-om2/input/JRA-55/RYF/v1-4/'

tairfile = os.path.join(JRAin,'RYF.tas.' + RYFyrs + '.nc')
qairfile = os.path.join(JRAin,'RYF.huss.' + RYFyrs + '.nc')
slpfile = os.path.join(JRAin,'RYF.psl.' + RYFyrs + '.nc')

rairfile = os.path.join(JRAout,'RYF.rhuss.' + RYFyrs + '.nc')

# open data-sets:
qair_ds = xarray.open_dataset(qairfile,decode_coords=False)
tair_ds = xarray.open_dataset(tairfile,decode_coords=False)
slp_ds = xarray.open_dataset(slpfile,decode_coords=False)

# Copy specific humidity field and change names/meta-data:
rair_ds = qair_ds.rename({'huss':'rhuss'})
rair_ds["rhuss"].attrs["standard_name"] = "relative_humidity"
rair_ds["rhuss"].attrs["long_name"] = "Near-Surface Relative Humidity"
rair_ds["rhuss"].attrs["comment"] = "Near-surface (usually, 2 meter) relative humidity"
rair_ds["rhuss"].attrs["units"] = "percent"

# Calculate relative humidity as a percentage:
# psl in Pa
# huss in kg/kg
# tas in K

e_sat = 6.11e2*np.exp((2.5e6/462.52)*(1./273.15-1./tair_ds.tas))

e = qair_ds.huss*slp_ds.psl/(0.622+0.378*qair_ds.huss)

rair_ds.rhuss.values = e/e_sat*100.0

rair_ds.to_netcdf(rairfile)

