
% alter topography and mask files to widen ITF in ACCESS-OM2
% 1-degree run.
%
% Note: For the mask and kmt it's better to use topogtools from
% github like:
%
% clone COSIMA/topogtools.git
%
% Run ./topog2mask.py topog.nc kmt.nc ocean_mask.nc
%

base_in = '/short/public/access-om2/input_236a3011/';
base_out = '/short/e14/rmh561/access-om2/input/fatITF/';

fmask_in = [base_in 'mom_1deg/ocean_mask.nc'];
fkmt_in = [base_in 'cice_1deg/kmt.nc'];
ftopo_in = [base_in 'mom_1deg/topog.nc'];
fssw_in = [base_in 'mom_1deg/ssw_atten_depth.nc'];
fchl_in = [base_in 'mom_1deg/chl.nc'];
mask  = ncread(fmask_in,'mask');
depth = ncread(ftopo_in,'depth');
kmt  = ncread(fkmt_in,'kmt');
ssw = ncread(fssw_in,'ssw_atten_depth');
chl = ncread(fchl_in,'chl');

fmask_out = [base_out 'mom_1deg/ocean_mask.nc'];
ftopo_out = [base_out 'mom_1deg/topog.nc'];
fssw_out = [base_out 'mom_1deg/ssw_atten_depth.nc'];
fchl_out = [base_out 'mom_1deg/chl.nc'];
fkmt_out = [base_out 'cice_1deg/kmt.nc'];

mask_out = mask;
depth_out = depth;

[xL,yL] = size(depth);

subplot(2,2,1);
depth_plot = depth;
depth_plot(~mask) = NaN;
pcolor(depth_plot');
shading flat;
xlim([15 90]);
ylim([70 190]);
colorbar;
caxis([0 2000]);
hold on;

[X,Y] = ndgrid(1:xL,1:yL);
regi = [34 55 104 160];
reg = X>=regi(1) & X<=regi(2) & Y>=regi(3) & Y<=regi(4);

plot([regi(1) regi(2) regi(2) regi(1) regi(1)],[regi(3) regi(3) regi(4) regi(4) regi(3)],'-k');


mask_filt = (mask((regi(1):regi(2))+1,regi(3):regi(4)) + ...
                                              mask((regi(1):regi(2)),regi(3):regi(4)) + ...
                                              mask((regi(1):regi(2))-1,regi(3):regi(4)) + ...
                                              mask((regi(1):regi(2)),(regi(3):regi(4))+1) + ...
                                              mask((regi(1):regi(2)),(regi(3):regi(4))-1))/5;
mask_filt(mask_filt>0) = 1;
mask_out(regi(1):regi(2),regi(3):regi(4)) = mask_filt;

dp_int = 250;
depth_temp = depth_out;
depth_temp(regi(1):regi(2),regi(3):regi(4)) = depth_temp(regi(1):regi(2),regi(3):regi(4))+dp_int;

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

subplot(2,2,2);
depth_plot = depth_out;
depth_plot(~mask_out) = NaN;
pcolor(depth_plot');
shading flat;
xlim([15 90]);
ylim([70 190]);
colorbar;
caxis([0 2000]);
hold on;
plot([regi(1) regi(2) regi(2) regi(1) regi(1)],[regi(3) regi(3) regi(4) regi(4) regi(3)],'-k');

subplot(2,2,3);
depth_plot = depth_out-depth;
depth_plot(~mask_out) = NaN;
pcolor(depth_plot');
shading flat;
xlim([15 90]);
ylim([70 190]);
colorbar;
caxis([-500 500]);
hold on;
plot([regi(1) regi(2) regi(2) regi(1) regi(1)],[regi(3) regi(3) regi(4) regi(4) regi(3)],'-k');

copyfile(fmask_in,fmask_out);
ncwrite(fmask_out,'mask',mask_out);
copyfile(fkmt_in,fkmt_out);
ncwrite(fkmt_out,'kmt',mask_out);
copyfile(ftopo_in,ftopo_out);
ncwrite(ftopo_out,'depth',depth_out);

% ssw and chl:
ssw(abs(ssw)>1000) = NaN;
chl(chl==0) = NaN;
ssw_out = ssw;
chl_out = chl;
for i=1:length(ssw(1,1,:))
    ssw_in = ssw(:,:,i);
    ssw_mean = nanmean(ssw_in(reg));
    tmp = ssw_in;
    tmp(isnan(tmp)) = ssw_mean;
    ssw_out(:,:,i) = tmp;

    chl_in = chl(:,:,i);
    chl_mean = nanmean(chl_in(reg));
    tmp = chl_in;
    tmp(isnan(tmp)) = chl_mean;
    chl_out(:,:,i) = tmp;
end

subplot(2,2,4);
pcolor(ssw_out(:,:,1)');
shading flat;
xlim([15 90]);
ylim([70 190]);
colorbar;
caxis([0 50]);
hold on;
plot([regi(1) regi(2) regi(2) regi(1) regi(1)],[regi(3) regi(3) regi(4) regi(4) regi(3)],'-k');


copyfile(fssw_in,fssw_out);
ncwrite(fssw_out,'ssw_atten_depth',ssw_out);
copyfile(fchl_in,fchl_out);
ncwrite(fchl_out,'chl',chl_out);



