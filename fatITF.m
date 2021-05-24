
% alter topography and mask files to widen ITF in ACCESS-OM2 1-degree
% run. This matlab file produces the topog.nc file in mom-1deg/
%
% Run this first, then:
%
% Note: For the mask and kmt it's better to use topogtools from
% github like:
%
% clone COSIMA/topogtools.git
%
% Run ./topog2mask.py topog.nc ../cice_1deg/kmt.nc ocean_mask.nc
%
% Then copy the ssw, chl, ocean_hgrid etc. files (that aren't altered)
% from the original fatITF exp (for ssw, chl these just have proper
% values over previous land, see bottom section of this script.)
%
% Then create OASIS weights as described here
% https://github.com/COSIMA/access-om2/wiki/Tutorials#Changing-the-bathymetry,-land-sea-mask-and-OASIS-remapping-weights
%
% I.e. with an interactive job on Gadi:
% qsub -I -l ncpus=24,mem=192GB,wd,storage=gdata/e14+gdata/ua8+gdata/ik11+gdata/hh5 -q express -lsoftware=matlab_unsw
%
% In the /g/data/e14/rmh561/access-om2/input/fatITF/shutN2/ folder
% do:
%
% ../../../tools/make_remap_weights.py ./ /g/data/ua8/JRA55-do/RYF/v1-3/ ../../yatm_1deg/ --atm JRA55 --ocean MOM1 --npes 16
%
% Then move the resulting 3 files into the common_1deg_jra55
% folder.


base_in = '/g/data/ik11/inputs/access-om2/input_236a3011/';
base_out = '/g/data/e14/rmh561/access-om2/input/fatITF/shutN2/';
% $$$ base_in = 'in/';
% $$$ base_out = './';

ftopo_in = [base_in 'mom_1deg/topog.nc'];
fmask_in = [base_in 'mom_1deg/ocean_mask.nc'];
depth = ncread(ftopo_in,'depth');
mask = ncread(fmask_in,'mask');
ftopo_out = [base_out 'mom_1deg/topog.nc'];
depth_out = depth;

[xL,yL] = size(depth);
[X,Y] = ndgrid(1:xL,1:yL);

fattenITF = 1; % 0 = original fatITF experiment,
               % 1 = shutoff N2

if (fattenITF==0)

    regi = [40 52 104 155];
    reg = X>=regi(1) & X<=regi(2) & Y>=regi(3) & Y<=regi(4);

    plot([regi(1) regi(2) regi(2) regi(1) regi(1)],[regi(3) regi(3) regi(4) regi(4) regi(3)],'-k');

    dp_int = 250;
    depths = depth_out(reg);
    depths(depths<1000) = min(depths(depths<1000)+dp_int,1000);

    depth_temp = depth_out;
    depth_temp(reg) = depths;

    % Smooth twice:
    depth_temp((regi(1)-5:regi(2)+5),regi(3)-5:regi(4)+5) = (depth_temp((regi(1)-5:regi(2)+5)+1,regi(3)-5:regi(4)+5) + ...
                                              depth_temp((regi(1)-5:regi(2)+5),regi(3)-5:regi(4)+5) + ...
                                              depth_temp((regi(1)-5:regi(2)+5)-1,regi(3)-5:regi(4)+5) + ...
                                              depth_temp((regi(1)-5:regi(2)+5),(regi(3)-5:regi(4)+5)+1) + ...
                                              depth_temp((regi(1)-5:regi(2)+5),(regi(3)-5:regi(4)+5)-1))/5;
    depth_temp((regi(1)-5:regi(2)+5),regi(3)-5:regi(4)+5) = (depth_temp((regi(1)-5:regi(2)+5)+1,regi(3)-5:regi(4)+5) + ...
                                              depth_temp((regi(1)-5:regi(2)+5),regi(3)-5:regi(4)+5) + ...
                                              depth_temp((regi(1)-5:regi(2)+5)-1,regi(3)-5:regi(4)+5) + ...
                                              depth_temp((regi(1)-5:regi(2)+5),(regi(3)-5:regi(4)+5)+1) + ...
                                              depth_temp((regi(1)-5:regi(2)+5),(regi(3)-5:regi(4)+5)-1))/5;
    depth_temp = max(depth_temp,depth_out);

    depth_out(regi(1):regi(2),regi(3):regi(4)) = depth_temp(regi(1):regi(2),regi(3):regi(4));

    xlims = [15 90];
    ylims = [70 190];

elseif (fattenITF == 1)
    regi = [38 42 136 136];
    depth_out(regi(1):regi(2),regi(3):regi(4)) = 0;

% $$$     xlims = [30 60];
% $$$     ylims = [110 150];
    xlims = [35 45];
    ylims = [134 138];

else
    'ERROR'
end

subplot(2,2,1);
depth_plot = depth;
depth_plot(~mask) = NaN;
pcolor(depth_plot');
shading flat;
xlim(xlims);
ylim(ylims);
colorbar;
caxis([0 2000]);
hold on;

subplot(2,2,2);
depth_plot = depth_out;
%depth_plot(~mask_out) = NaN;
pcolor(depth_plot');
shading flat;
xlim(xlims);
ylim(ylims);
colorbar;
caxis([0 2000]);
hold on;
plot([regi(1) regi(2) regi(2) regi(1) regi(1)],[regi(3) regi(3) regi(4) regi(4) regi(3)],'-k');

subplot(2,2,3);
depth_plot = depth_out-depth;
%depth_plot(~mask_out) = NaN;
pcolor(depth_plot');
shading flat;
xlim(xlims);
ylim(ylims);
colorbar;
caxis([-500 500]);
hold on;
plot([regi(1) regi(2) regi(2) regi(1) regi(1)],[regi(3) regi(3) regi(4) regi(4) regi(3)],'-k');

copyfile(ftopo_in,ftopo_out);
ncwrite(ftopo_out,'depth',depth_out);

% Note: SSW and CHL only needed if regions that were previously
% land are now ocean:
% $$$ 
% $$$ % ssw and chl:
% $$$ fssw_in = [base_in 'mom_1deg/ssw_atten_depth.nc'];
% $$$ fchl_in = [base_in 'mom_1deg/chl.nc'];
% $$$ ssw = ncread(fssw_in,'ssw_atten_depth');
% $$$ chl = ncread(fchl_in,'chl');
% $$$ fssw_out = [base_out 'mom_1deg/ssw_atten_depth.nc'];
% $$$ fchl_out = [base_out 'mom_1deg/chl.nc'];
% $$$ 
% $$$ ssw(abs(ssw)>1000) = NaN;
% $$$ chl(chl==0) = NaN;
% $$$ ssw_out = ssw;
% $$$ chl_out = chl;
% $$$ for i=1:length(ssw(1,1,:))
% $$$     ssw_in = ssw(:,:,i);
% $$$     ssw_mean = nanmean(ssw_in(reg));
% $$$     tmp = ssw_in;
% $$$     tmp(isnan(tmp)) = ssw_mean;
% $$$     ssw_out(:,:,i) = tmp;
% $$$ 
% $$$     chl_in = chl(:,:,i);
% $$$     chl_mean = nanmean(chl_in(reg));
% $$$     tmp = chl_in;
% $$$     tmp(isnan(tmp)) = chl_mean;
% $$$     chl_out(:,:,i) = tmp;
% $$$ end
% $$$ 
% $$$ subplot(2,2,4);
% $$$ pcolor(ssw_out(:,:,1)');
% $$$ shading flat;
% $$$ xlim([15 90]);
% $$$ ylim([70 190]);
% $$$ colorbar;
% $$$ caxis([0 50]);
% $$$ hold on;
% $$$ plot([regi(1) regi(2) regi(2) regi(1) regi(1)],[regi(3) regi(3) regi(4) regi(4) regi(3)],'-k');
% $$$ 
% $$$ 
% $$$ copyfile(fssw_in,fssw_out);
% $$$ ncwrite(fssw_out,'ssw_atten_depth',ssw_out);
% $$$ copyfile(fchl_in,fchl_out);
% $$$ ncwrite(fchl_out,'chl',chl_out);
% $$$ 
% $$$ 
% $$$ 
