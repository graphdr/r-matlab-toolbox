% obtain genpath_exclude() from MATLAB file exchange
% https://www.mathworks.com/matlabcentral/fileexchange/22209-genpath-exclude?s_tid=srchtitle
% save in scripts directory

clc
restoredefaultpath

% assume cd = R project working directory
% add scripts to path so MATLAB can find the genpath_exclude()

 
% exclude_directories is a cell-array of strings 
% '\..*' is regex for directories that start with a period
% to ignore, e.g., hidden folders .git and .Rproj.user

addpath(fullfile(cd, 'scripts'), '-end');
exclude_directories = {'\..*', '*\holding'};
addpath(genpath_exclude(cd, exclude_directories), '-end')
savepath


path