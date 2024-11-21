% script_test_fcn_DataClean_fillGPSTimeFromROSTime.m
% tests fcn_DataClean_fillGPSTimeFromROSTime.m

% Revision history
% 2024_11_20 - sbrennan@psu.edu
% -- wrote the code originally 

close all;



%% CASE 1: basic example - verbose
fig_num = 1;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


fullExampleFilePath = fullfile(cd,'Data','ExampleData_fitROSTime2GPSTime.mat');
load(fullExampleFilePath,'dataStructure');

flags = []; 
fid = 1;

[flags, fitting_parameters, fit_sensors, mean_fit, filtered_median_errors] =  fcn_DataClean_fitROSTime2GPSTime(dataStructure, (flags), (fid), (-1));

newDataStructure = fcn_DataClean_fillGPSTimeFromROSTime(mean_fit, filtered_median_errors, dataStructure);