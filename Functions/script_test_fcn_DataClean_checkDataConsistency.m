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

%% Missing Time field test - the GPS_Time field is completely missing
fid = 1;
BadDataStructure = dataStructure;
BadGPSSensor = rmfield(BadDataStructure.GPS_Hemisphere, 'GPS_Time');
BadDataStructure.GPS_Hemisphere = BadGPSSensor;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing Time field test - the GPS_Time field is empty
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.GPS_Time = [];

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Missing Time field test - the GPS_Time field is only NaNs
fid = 1;
BadDataStructure = dataStructure;
BadDataStructure.GPS_Hemisphere.GPS_Time = BadDataStructure.GPS_Hemisphere.GPS_Time*NaN;

[flags, offending_sensor] = fcn_DataClean_checkDataConsistency(BadDataStructure,fid);
assert(isequal(flags.GPS_Time_exists,0));
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
