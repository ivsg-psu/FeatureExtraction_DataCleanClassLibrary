% script_test_fcn_DataClean_trimRepeatsFromField.m
% tests fcn_DataClean_trimRepeatsFromField.m

% Revision history
% 2023_06_26 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc
fid = 1;

%% Define a dataset with repeated values in the GPS_Hemisphere time
time_time_corruption_type = 2^20; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_has_no_repeats_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Fix the data using default call
fixed_dataStructure = fcn_DataClean_trimRepeatsFromField(BadDataStructure);

% Make sure it worked
sensor_names = fieldnames(fixed_dataStructure); % Grab all the fields that are in dataStructure structure

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};

    if contains(sensor_name,'GPS')
        sensor_data = fixed_dataStructure.(sensor_name);
        unique_values = unique(sensor_data.GPS_Time);
        assert(isequal(unique_values,sensor_data.GPS_Time));
    end
end % Ends for loop


%% Fix the data using specific call
fid = 1;
field_name = 'GPS_Time';
sensors_to_check = 'GPS';
fixed_dataStructure = fcn_DataClean_trimRepeatsFromField(BadDataStructure,fid, field_name,sensors_to_check);

% Make sure it worked
sensor_names = fieldnames(fixed_dataStructure); % Grab all the fields that are in dataStructure structure

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};

    if contains(sensor_name,'GPS')
        sensor_data = fixed_dataStructure.(sensor_name);
        unique_values = unique(sensor_data.GPS_Time);
        assert(isequal(unique_values,sensor_data.GPS_Time));
    end
end % Ends for loop

if 1==0 % BAD error cases start here



end
