% script_test_fcn_DataClean_checkDataTimeConsistency.m
% tests fcn_DataClean_checkDataTimeConsistency.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally
% 2023_06_30 - sbrennan@psu.edu
% -- fixed verbose mode bug


%% Set up the workspace
close all
clc
fid = 1;

% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;

% Clear flags
flags = struct;

%% CASE 1: Basic call - NOT verbose
fprintf(1,'\nCASE 1: basic consistency check, no errors, NOT verbose\n');
[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(dataStructure);
fprintf(1,'\nCASE 1: Done!\n\n');

assert(isequal(flags.GPS_Time_exists_in_at_least_one_GPS_sensor,1));
assert(strcmp(offending_sensor,''));

%% CASE 2: Basic call - verbose mode
fprintf(1,'\nCASE 2: basic consistency check, no errors, verbose\n');
[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(dataStructure,fid);
fprintf(1,'\nCASE 2: Done!\n\n');

assert(isequal(flags.GPS_Time_exists_in_at_least_one_GPS_sensor,1));
assert(strcmp(offending_sensor,''));


%% GPS_Time tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    _____ _____   _____            _______ _                   _______        _       
%   / ____|  __ \ / ____|          |__   __(_)                 |__   __|      | |      
%  | |  __| |__) | (___               | |   _ _ __ ___   ___      | | ___  ___| |_ ___ 
%  | | |_ |  ___/ \___ \              | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
%  | |__| | |     ____) |             | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
%   \_____|_|    |_____/              |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
%                          ______                                                      
%                         |______|                                                     
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=GPS%20_%20Time%20%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Check GPS_Time_exists_in_at_least_one_GPS_sensor - the GPS_Time field is completely missing in all sensors

% Define a dataset with no GPS_Time fields
BadDataStructure = dataStructure;
sensor_names = fieldnames(BadDataStructure); % Grab all the fields that are in dataStructure structure
for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = BadDataStructure.(sensor_name);
    sensor_data_removed_field = rmfield(sensor_data,'GPS_Time');
    BadDataStructure.(sensor_name) = sensor_data_removed_field;    
end
% Clean up variables
clear sensor_name sensor_data sensor_data_removed_field i_data sensor_names
    
error_type_string = 'All GPS_Time fields are missing on all sensors';
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists_in_at_least_one_GPS_sensor,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight'));

%% Check GPS_Time_exists_in_all_GPS_sensors - the GPS_Time field is missing in at least one GPS sensor

% Define a dataset with corrupted GPS_Time where the field is missing
time_time_corruption_type = 2^1; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check GPS_Time_exists_in_all_GPS_sensors - the GPS_Time field is empty

% Define a dataset with corrupted GPS_Time where the field is empty
time_time_corruption_type = 2^2; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearLeft'));

%% Check GPS_Time_exists_in_all_GPS_sensors - the GPS_Time field is only NaNs

% Define a dataset with corrupted GPS_Time where the field is NaN
time_time_corruption_type = 2^3; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight'));

%% Check centiSeconds_exists_in_all_GPS_sensors - the centiSeconds field is completely missing

% Define a dataset with corrupted centiSeconds where the field is missing
time_time_corruption_type = 2^4; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check centiSeconds_exists_in_all_GPS_sensors - the centiSeconds field is empty

% Define a dataset with corrupted centiSeconds where the field is empty
time_time_corruption_type = 2^5; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check centiSeconds_exists_in_all_GPS_sensors - the centiSeconds field is only NaNs
 
% Define a dataset with corrupted centiSeconds where the field is NaNs only
time_time_corruption_type = 2^6; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight'));

%% Check GPS_Time_has_no_repeats_in_GPS_sensors

% Define a dataset with corrupted centiSeconds where the field is NaNs only
time_time_corruption_type = 2^20; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_has_no_repeats_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));



%% Check GPS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
 
% Define a dataset with corrupted centiSeconds where the field is
% inconsistent with GPS_Time data
time_time_corruption_type = 2^7; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight'));


%% Check start_time_GPS_sensors_agrees_to_within_5_seconds
% Simulate a time zone error 

BadDataStructure = dataStructure;
hours_off = 1;
BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - hours_off*60*60; 
clear hours_off
fprintf(1,'\nData created with following errors injected: shifted start point');

[flags, ~] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.start_time_GPS_sensors_agrees_to_within_5_seconds,0));


%% Check consistent_start_and_end_times_across_GPS_sensors
 
BadDataStructure = dataStructure;
BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - 1; 
fprintf(1,'\nData created with following errors injected: shifted start point');

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.consistent_start_and_end_times_across_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight GPS_Sparkfun_RearLeft'));


%% Check if Trigger_Time_exists_in_all_GPS_sensors - the Trigger_Time field is completely missing
 
% Define a dataset with corrupted Trigger_Time where the field is missing
time_time_corruption_type = 2^9; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check if Trigger_Time_exists_in_all_GPS_sensors - the Trigger_Time field is empty
 
% Define a dataset with corrupted Trigger_Time where the field is empty
time_time_corruption_type = 2^10; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check if GPS_Time_strictly_ascends
 
% Define a dataset with corrupted GPS_Time where the GPS_Time is not increasing 
time_time_corruption_type = 2^12; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_strictly_ascends,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check no_jumps_in_differences_of_GPS_Time_in_any_GPS_sensors

% Define a dataset with jump discontinuity in GPS_Time data
time_time_corruption_type = 2^22; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.no_jumps_in_differences_of_GPS_Time_in_any_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));


%% Trigger_Time Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   _______   _                                  _______ _                   _______        _       
%  |__   __| (_)                                |__   __(_)                 |__   __|      | |      
%     | |_ __ _  __ _  __ _  ___ _ __              | |   _ _ __ ___   ___      | | ___  ___| |_ ___ 
%     | | '__| |/ _` |/ _` |/ _ \ '__|             | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
%     | | |  | | (_| | (_| |  __/ |                | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
%     |_|_|  |_|\__, |\__, |\___|_|                |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
%                __/ | __/ |            ______                                                      
%               |___/ |___/            |______|                                                     
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Trigger%20_%20Time%20%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check Trigger_Time_exists_in_all_GPS_sensors - the Trigger_Time field is only NaNs
 
% Define a dataset with corrupted Trigger_Time where the field is only NaNs
time_time_corruption_type = 2^11; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% ROS_Time Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   _____   ____   _____            _______ _                   _______        _       
%  |  __ \ / __ \ / ____|          |__   __(_)                 |__   __|      | |      
%  | |__) | |  | | (___               | |   _ _ __ ___   ___      | | ___  ___| |_ ___ 
%  |  _  /| |  | |\___ \              | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
%  | | \ \| |__| |____) |             | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
%  |_|  \_\\____/|_____/              |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
%                          ______                                                      
%                         |______|                                                     
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=ROS%20_%20Time%20%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check ROS_Time_exists_in_all_GPS_sensors- the ROS_Time field is completely missing

 
% Define a dataset with corrupted ROS_Time where the field is missing
time_time_corruption_type = 2^14; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearLeft'));

%% Check ROS_Time_exists_in_all_GPS_sensors - the ROS_Time field is empty
 
% Define a dataset with corrupted ROS_Time where the field is empty
time_time_corruption_type = 2^15; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check ROS_Time_exists_in_all_GPS_sensors - the ROS_Time field is only NaNs
 
% Define a dataset with corrupted ROS_Time where it contains only NaNs
time_time_corruption_type = 2^16; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));


%% Check ROS_Time_scaled_correctly_as_seconds
 
% Define a dataset with corrupted ROS_Time where the ROS_Time has a
% nanosecond scaling
time_time_corruption_type = 2^13; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_scaled_correctly_as_seconds,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));


%% Check ROS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors

% Define a dataset with corrupted centiSeconds where the field is
% inconsistent with ROS_Time data
time_time_corruption_type = 2^8; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, ~] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors,1));

%% Check ROS_Time_strictly_ascends
 
% Define a dataset with corrupted ROS_Time where it is not increasing
time_time_corruption_type = 2^17; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_strictly_ascends,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check ROS_Time_strictly_ascends
 
% Define a dataset with corrupted ROS_Time via repeat
time_time_corruption_type = 2^18; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_strictly_ascends,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors

% Define a dataset with corrupted ROS_Time length
time_time_corruption_type = 2^19; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Check ROS_Time_rounds_correctly_to_Trigger_Time

% Define a dataset with corrupted ROS_Time length
time_time_corruption_type = 2^21; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_rounds_correctly_to_Trigger_Time_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));


% 
% 
% %% Bad data - there is a NaN inside one of the Sigma fields
%  
% BadDataStructure = dataStructure;
% % Add bad data to the end
% BadDataStructure.ENCODER_RearLeft.ROS_Time(end+1) = BadDataStructure.ENCODER_RearLeft.ROS_Time(end)+0.01;
% 
% [flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
% assert(isequal(flags.ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors,0));
% assert(strcmp(offending_sensor,'ENCODER_RearLeft'));
% 
% %% Bad data - there is a NaN inside the data
%  
% BadDataStructure = dataStructure;
% % Put a NaN into the data
% BadDataStructure.ENCODER_RearLeft.Counts(end) = NaN;
% 
% [flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
% assert(isequal(flags.sensor_fields_have_no_NaN,0));
% assert(strcmp(offending_sensor,'ENCODER_RearLeft Counts'));



%% Fail conditions
if 1==0
    %% WARNING for point-type, due to 3D
    input_start_zone_definition = [2 3 0 0 0]; % Radius of 2, 3 points, centered at 0 0 0
    [flag_start_is_a_point_type, output_start_zone_definition] = ...
        fcn_Laps_checkZoneType(input_start_zone_definition, 'start_definition');
    
    % Make sure its type is correct
    assert(isequal(1,flag_start_is_a_point_type))
    
    % Make sure the output is correct
    assert(isequal(output_start_zone_definition,[2 3 0 0]))
    
    %% ERROR for point-type, due to bad array size
    input_start_zone_definition = [2 3]; % Radius of 2, 3 points, centered at ???
    [~, ~] = ...
        fcn_Laps_checkZoneType(input_start_zone_definition, 'start_definition');
    
   
    %% ERROR for point-type, due to bad array size
    input_start_zone_definition = [2 3 4 5 6 7 8]; % Radius of 2, 3 points, centered at ???
    [~, ~] = ...
        fcn_Laps_checkZoneType(input_start_zone_definition, 'start_definition');
    
    
    %% WARNING for segment-type, due to 3D
    input_start_zone_definition = [2 3 0; 0 0 0]; % starts at 2 3 0, ends at 0 0 0
    [flag_start_is_a_point_type, output_start_zone_definition] = ...
        fcn_Laps_checkZoneType(input_start_zone_definition, 'start_definition');
    
    % Make sure its type is correct
    assert(isequal(0,flag_start_is_a_point_type))
    
    % Make sure the output is correct
    assert(isequal(output_start_zone_definition,[2 3; 0 0]))
    
    %% ERROR for segment-type, due to bad array size
    input_start_zone_definition = [2 3 0 4; 0 0 0 0]; % starts at ???, ends at ???
    [~, ~] = ...
        fcn_Laps_checkZoneType(input_start_zone_definition, 'start_definition');
    
    
    %% ERROR for segment-type, due to bad array size
    input_start_zone_definition = [2; 3]; % starts at ????, ends at ????
    [~, ~] = ...
        fcn_Laps_checkZoneType(input_start_zone_definition, 'start_definition');
    

end