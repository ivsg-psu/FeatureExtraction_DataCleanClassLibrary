% script_test_fcn_DataClean_checkDataPoseConsistency.m
% tests fcn_DataClean_checkDataPoseConsistency.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally
% 2023_06_30 - sbrennan@psu.edu
% -- fixed verbose mode bug


%% Set up the workspace
close all



%% CASE 1: Basic call - NOT verbose
% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;


fprintf(1,'\nCASE 1: basic consistency check, no errors, NOT verbose\n');
[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(dataStructure);
fprintf(1,'\nCASE 1: Done!\n\n');

assert(isequal(flags.GPS_Time_exists_in_at_least_one_GPS_sensor,1));
assert(strcmp(offending_sensor,''));

%% CASE 2: Basic call - verbose mode
% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;
fid = 1;

fprintf(1,'\nCASE 2: basic consistency check, no errors, verbose\n');
[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(dataStructure,fid);
fprintf(1,'\nCASE 2: Done!\n\n');

assert(isequal(flags.GPS_Time_exists_in_at_least_one_GPS_sensor,1));
assert(strcmp(offending_sensor,''));

%% Missing GPS_Time field test - the GPS_Time field is completely missing in all sensors
% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;
fid = 1;

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


[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists_in_at_least_one_GPS_sensor,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight'));

%% Missing GPS_Time field test - the GPS_Time field is missing in at least one GPS sensor

% Define a dataset with corrupted GPS_Time where the field is missing
time_time_corruption_type = 2^1; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing GPS_Time field test - the GPS_Time field is empty

% Define a dataset with corrupted GPS_Time where the field is empty
time_time_corruption_type = 2^2; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearLeft'));

%% Missing GPS_Time field test - the GPS_Time field is only NaNs

% Define a dataset with corrupted GPS_Time where the field is NaN
time_time_corruption_type = 2^3; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight'));

%% Missing centiSeconds field test - the centiSeconds field is completely missing

% Define a dataset with corrupted centiSeconds where the field is missing
time_time_corruption_type = 2^4; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing centiSeconds field test - the centiSeconds field is empty

% Define a dataset with corrupted centiSeconds where the field is empty
time_time_corruption_type = 2^5; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing centiSeconds field test - the centiSeconds field is only NaNs
 
% Define a dataset with corrupted centiSeconds where the field is NaNs only
time_time_corruption_type = 2^6; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight'));

%% Duplicated time values - the GPS_Time field in the GPS sensors has repeats

% Define a dataset with corrupted centiSeconds where the field is NaNs only
time_time_corruption_type = 2^20; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_has_no_repeats_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));



%% Bad time interval test - the centiSeconds field is inconsistent with GPS_Time data
 
% Define a dataset with corrupted centiSeconds where the field is
% inconsistent with GPS_Time data
time_time_corruption_type = 2^7; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_sample_modes_match_centiSeconds_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight'));


%% Shifted time interval test - one of the sensors is very far off
% Simulate a time zone error 

BadDataStructure = dataStructure;
hours_off = 1;
BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - hours_off*60*60; 
clear hours_off
fprintf(1,'\nData created with following errors injected: shifted start point');

error('Need to fix this. The function below changed and so this test case needs to be checked.')

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_has_consistent_start_end_across_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight GPS_Sparkfun_RearLeft'));


%% Shifted time interval test - the start/end of a GPS system does not match slightly
 
BadDataStructure = dataStructure;
BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - 1; 
fprintf(1,'\nData created with following errors injected: shifted start point');

field_name = 'GPS_Time';
flags = []; 
sensors_to_check = 'GPS';
flag_name_suffix = '_to_half_second';
agreement_threshold = 0.5;
fid = 1;
fig_num = [];

error('Need to fix this. The function below changed and so this test case needs to be checked.')
[flags, offending_sensor, return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(BadDataStructure, field_name, (flags), (sensors_to_check), (flag_name_suffix), (agreement_threshold), (fid), (fig_num));

assert(isequal(flags.GPS_Time_has_consistent_start_end_across_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight GPS_Sparkfun_RearLeft'));


%% Bad time interval test - the centiSeconds field is inconsistent with ROS_Time data
warning('on','backtrace');
warning('This test needs to be finished!');
% Define a dataset with corrupted centiSeconds where the field is
% inconsistent with ROS_Time data
time_time_corruption_type = 2^8; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, ~] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_sample_modes_match_centiSeconds_in_GPS_sensors,1));

%% Missing Trigger_Time field test - the Trigger_Time field is completely missing
 
% Define a dataset with corrupted Trigger_Time where the field is missing
time_time_corruption_type = 2^9; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing Trigger_Time field test - the Trigger_Time field is empty
 
% Define a dataset with corrupted Trigger_Time where the field is empty
time_time_corruption_type = 2^10; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing Trigger_Time field test - the Trigger_Time field is only NaNs
 
% Define a dataset with corrupted Trigger_Time where the field is only NaNs
time_time_corruption_type = 2^11; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Bad time ordering test - the GPS_Time is not increasing 
 
% Define a dataset with corrupted GPS_Time where the GPS_Time is not increasing 
time_time_corruption_type = 2^12; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_strictly_ascends_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));


%% Missing ROS_Time field test - the ROS_Time field is completely missing

 
% Define a dataset with corrupted ROS_Time where the field is missing
time_time_corruption_type = 2^14; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearLeft'));

%% Missing ROS_Time field test - the ROS_Time field is empty
 
% Define a dataset with corrupted ROS_Time where the field is empty
time_time_corruption_type = 2^15; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing ROS_Time field test - the ROS_Time field is only NaNs
 
% Define a dataset with corrupted ROS_Time where it contains only NaNs
time_time_corruption_type = 2^16; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));


%% Bad ROS_Time scaling - the ROS_Time field is still in nanoseconds 
 
% Define a dataset with corrupted ROS_Time where the ROS_Time has a
% nanosecond scaling
time_time_corruption_type = 2^13; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_scaled_correctly_as_seconds,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Bad time ordering test - the ROS_Time is not increasing 
 
% Define a dataset with corrupted ROS_Time where it is not increasing
time_time_corruption_type = 2^17; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_strictly_ascends,0));
assert(strcmp(offending_sensor,'ENCODER_RearLeft'));

%% Bad time ordering test - the ROS_Time has a repeat 
 
% Define a dataset with corrupted ROS_Time via repeat
time_time_corruption_type = 2^18; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_strictly_ascends,0));
assert(strcmp(offending_sensor,'TRIGGER'));

%% Bad time length test - the ROS_Time has wrong length 

% Define a dataset with corrupted ROS_Time length
time_time_corruption_type = 2^19; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_has_correct_length,0));
assert(strcmp(offending_sensor,'ENCODER_RearLeft'));



%% Bad data - there is a NaN inside one of the Sigma fields
 
BadDataStructure = dataStructure;
% Add bad data to the end
BadDataStructure.ENCODER_RearLeft.ROS_Time(end+1) = BadDataStructure.ENCODER_RearLeft.ROS_Time(end)+0.01;

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_has_correct_length,0));
assert(strcmp(offending_sensor,'ENCODER_RearLeft'));

%% Bad data - there is a NaN inside the data
 
BadDataStructure = dataStructure;
% Put a NaN into the data
BadDataStructure.ENCODER_RearLeft.Counts(end) = NaN;

[flags, offending_sensor] = fcn_DataClean_checkDataPoseConsistency(BadDataStructure,fid);
assert(isequal(flags.sensor_fields_have_no_NaN,0));
assert(strcmp(offending_sensor,'ENCODER_RearLeft Counts'));



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
