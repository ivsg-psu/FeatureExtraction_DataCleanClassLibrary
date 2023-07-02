% script_test_fcn_DataClean_fillTestDataStructure.m
% tests fcn_DataClean_fillTestDataStructure.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc

%% Basic call
testDataStructure = fcn_DataClean_fillTestDataStructure;

% Make sure its type is correct
assert(isstruct(testDataStructure));

fprintf(1,'The data structure for testDataStructure: \n')
disp(testDataStructure)

%% Basic call in verbose mode
fprintf(1,'\n\n Demonstrating "verbose" mode by printing to console: \n');
error_type = [];
fid = 1;
testDataStructure = fcn_DataClean_fillTestDataStructure(error_type,fid);

% Make sure its type is correct
assert(isstruct(testDataStructure));

fprintf(1,'The data structure for testDataStructure: \n')
disp(testDataStructure)

%% Standard noise call
testDataStructure = fcn_DataClean_fillTestDataStructure(1);

% Make sure its type is correct
assert(isstruct(testDataStructure));

fprintf(1,'The data structure for testDataStructure: \n')
disp(testDataStructure)

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
