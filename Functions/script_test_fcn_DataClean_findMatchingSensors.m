% script_test_fcn_DataClean_findMatchingSensors.m
% tests fcn_DataClean_findMatchingSensors.m

% Revision history
% 2023_06_26 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc
fid = 1;

%% Define a dataset
%% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.weight  = 4;

%% Basic call example - returns only fields that contain 'cow' in name
dataStructure = initial_test_structure;
sensor_identifier_string = 'COW'; % Using all-caps to show it is not case-sensitive
fid = 1;
[matchedSensorNames] = fcn_DataClean_findMatchingSensors(dataStructure, sensor_identifier_string, fid);
assert(strcmp(matchedSensorNames{1},'cow1'));
assert(strcmp(matchedSensorNames{2},'cow2'));
assert(strcmp(matchedSensorNames{3},'cow3'));


%% Basic call example - returns only fields that contain 'cow' in name, NOT verbose
dataStructure = initial_test_structure;
sensor_identifier_string = 'COW'; % Using all-caps to show it is not case-sensitive
fid = '';
[matchedSensorNames] = fcn_DataClean_findMatchingSensors(dataStructure, sensor_identifier_string, fid);
assert(strcmp(matchedSensorNames{1},'cow1'));
assert(strcmp(matchedSensorNames{2},'cow2'));
assert(strcmp(matchedSensorNames{3},'cow3'));

%% Empty call example - returns all sensors
dataStructure = initial_test_structure;
sensor_identifier_string = '';
fid = 1;
[matchedSensorNames] = fcn_DataClean_findMatchingSensors(dataStructure, sensor_identifier_string, fid);
assert(strcmp(matchedSensorNames{1},'cow1'));
assert(strcmp(matchedSensorNames{2},'cow2'));
assert(strcmp(matchedSensorNames{3},'cow3'));
assert(strcmp(matchedSensorNames{4},'pig1'));
assert(strcmp(matchedSensorNames{5},'quiet_pig'));

%% More typical call
dataStructure = fcn_DataClean_fillTestDataStructure;
sensor_identifier_string = 'gps';
fid = 1;
[matchedSensorNames] = fcn_DataClean_findMatchingSensors(dataStructure, sensor_identifier_string, fid);
assert(strcmp(matchedSensorNames{1},'GPS_Sparkfun_RearRight'));
assert(strcmp(matchedSensorNames{2},'GPS_Sparkfun_RearLeft'));
assert(strcmp(matchedSensorNames{3},'GPS_Hemisphere'));


%% Bad error cases go here
if 1==0 % BAD error cases start here



end
