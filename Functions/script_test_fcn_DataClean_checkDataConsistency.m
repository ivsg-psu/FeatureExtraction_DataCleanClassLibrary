% script_test_fcn_DataClean_checkDataConsistency.m
% tests fcn_DataClean_checkDataConsistency.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc

% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;

%% Basic call
fid = 1;
[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(dataStructure,fid);
assert(isequal(flags.GPS_Time_exists,1));
assert(strcmp(offending_sensor,''));

%% Missing GPS_Time field test - the GPS_Time field is completely missing
fid = 1;
BadDataStructure = dataStructure;
BadGPSSensor = rmfield(BadDataStructure.GPS_Hemisphere, 'GPS_Time');
BadDataStructure.GPS_Hemisphere = BadGPSSensor;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing GPS_Time field test - the GPS_Time field is empty
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.GPS_Time = [];

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing GPS_Time field test - the GPS_Time field is only NaNs
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.GPS_Time = BadDataStructure.GPS_Hemisphere.GPS_Time*NaN;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing centiSeconds field test - the centiSeconds field is completely missing
fid = 1;
BadDataStructure = dataStructure;
BadGPSSensor = rmfield(BadDataStructure.GPS_Hemisphere, 'centiSeconds');
BadDataStructure.GPS_Hemisphere = BadGPSSensor;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing centiSeconds field test - the centiSeconds field is empty
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.centiSeconds = [];

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing centiSeconds field test - the centiSeconds field is only NaNs
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.centiSeconds = BadDataStructure.GPS_Hemisphere.centiSeconds*NaN;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.centiSeconds_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Bad time interval test - the centiSeconds field is inconsistent with GPS_Time data
fid = 1;
BadDataStructure = dataStructure;
% Copy time structure from encoder (100 Hz) to Trigger (1 Hz) to create bad
% time sample interval.
BadDataStructure.TRIGGER.GPS_Time = BadDataStructure.ENCODER_RearLeft.GPS_Time;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.dataTimeIntervalMatchesIntendedSamplingRate,0));
assert(strcmp(offending_sensor,'TRIGGER'));

%% Missing Trigger_Time field test - the Trigger_Time field is completely missing
fid = 1;
BadDataStructure = dataStructure;
BadGPSSensor = rmfield(BadDataStructure.GPS_Hemisphere, 'Trigger_Time');
BadDataStructure.GPS_Hemisphere = BadGPSSensor;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exist,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing Trigger_Time field test - the Trigger_Time field is empty
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.Trigger_Time = [];

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exist,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing Trigger_Time field test - the Trigger_Time field is only NaNs
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.Trigger_Time = BadDataStructure.GPS_Hemisphere.Trigger_Time*NaN;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.Trigger_Time_exist,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Bad time ordering test - the GPS_Time is not increasing 
fid = 1;
BadDataStructure = dataStructure;
% Swap order of first two time elements
BadDataStructure.ENCODER_RearLeft.GPS_Time(1,:) = dataStructure.ENCODER_RearLeft.GPS_Time(2,:);
BadDataStructure.ENCODER_RearLeft.GPS_Time(2,:) = dataStructure.ENCODER_RearLeft.GPS_Time(1,:);

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_strictly_ascends,0));
assert(strcmp(offending_sensor,'ENCODER_RearLeft'));

%% Bad time ordering test - the GPS_Time has a repeat 
fid = 1;
BadDataStructure = dataStructure;
% Swap order of first two time elements
BadDataStructure.ENCODER_RearLeft.GPS_Time(2,:) = dataStructure.ENCODER_RearLeft.GPS_Time(1,:);

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_strictly_ascends,0));
assert(strcmp(offending_sensor,'ENCODER_RearLeft'));

%% Missing ROS_Time field test - the ROS_Time field is completely missing

URHERE
fid = 1;
BadDataStructure = dataStructure;
BadGPSSensor = rmfield(BadDataStructure.GPS_Hemisphere, 'ROS_Time');
BadDataStructure.GPS_Hemisphere = BadGPSSensor;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing ROS_Time field test - the ROS_Time field is empty
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.ROS_Time = [];

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing ROS_Time field test - the ROS_Time field is only NaNs
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.ROS_Time = BadDataStructure.GPS_Hemisphere.ROS_Time*NaN;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.ROS_Time_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));


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
