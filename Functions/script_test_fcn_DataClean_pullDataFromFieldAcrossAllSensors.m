% script_test_fcn_DataClean_trimRepeatsFromField.m
% tests fcn_DataClean_trimRepeatsFromField.m

% Revision history
% 2023_06_26 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc
fid = 1;

%% Define a dataset
dataStructure = fcn_DataClean_fillTestDataStructure;


%% Fix the data using default call
dataStructure = fcn_DataClean_trimRepeatsFromField(BadDataStructure);

% Make sure it worked
[data,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS');
for i_data = 1:length(sensorNames)
    unique_values = unique(data{i_data});
    assert(isequal(unique_values,data{i_data}));
end % Ends for loop

%% Fix the data using specific call
fid = 1;
field_name = 'GPS_Time';
sensors_to_check = 'GPS';
dataStructure = fcn_DataClean_trimRepeatsFromField(BadDataStructure,fid, field_name,sensors_to_check);

% Make sure it worked
[data,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS');
for i_data = 1:length(sensorNames)
    unique_values = unique(data{i_data});
    assert(isequal(unique_values,data{i_data}));
end % Ends for loop

if 1==0 % BAD error cases start here



end
