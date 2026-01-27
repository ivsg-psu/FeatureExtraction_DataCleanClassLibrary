% script_test_fcn_DataClean_findMatchingSensors.m
% tests fcn_DataClean_findMatchingSensors.m

% Revision history
% 2023_06_26 - sbrennan@psu.edu
% -- wrote the code originally
% 2024_09_27 - sbrennan@psu.edu
% -- added better examples

%% Set up the workspace
close all


%% Basic call example - returns only fields that contain 'cow' in name
% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.weight  = 4;


dataStructure = initial_test_structure;
sensor_identifier_string = 'COW'; % Using all-caps to show it is not case-sensitive
fid = 1;

[matchedSensorNames] = fcn_DataClean_findMatchingSensors(dataStructure, sensor_identifier_string, fid);

assert(strcmp(matchedSensorNames{1},'cow1'));
assert(strcmp(matchedSensorNames{2},'cow2'));
assert(strcmp(matchedSensorNames{3},'cow3'));


%% Basic call example - returns only fields that contain 'cow' in name, NOT verbose
% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.weight  = 4;

dataStructure = initial_test_structure;
sensor_identifier_string = 'COW'; % Using all-caps to show it is not case-sensitive
fid = '';

[matchedSensorNames] = fcn_DataClean_findMatchingSensors(dataStructure, sensor_identifier_string, fid);

assert(strcmp(matchedSensorNames{1},'cow1'));
assert(strcmp(matchedSensorNames{2},'cow2'));
assert(strcmp(matchedSensorNames{3},'cow3'));

%% Empty call example - returns all sensors
% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.weight  = 4;

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

fullExampleFilePath = fullfile(cd,'Data','ExampleData_findMatchingSensors.mat');
load(fullExampleFilePath,'dataStructure')
sensor_identifier_string = 'gps';
fid = 1;

[matchedSensorNames] = fcn_DataClean_findMatchingSensors(dataStructure, sensor_identifier_string, fid);

expectedResults = [    
    {'GPS_SparkFun_Front_GGA'    }
    {'GPS_SparkFun_Front_VTG'    }
    {'GPS_SparkFun_LeftRear_GGA' }
    {'GPS_SparkFun_LeftRear_GST' }
    {'GPS_SparkFun_LeftRear_VTG' }
    {'GPS_SparkFun_RightRear_GGA'}
    {'GPS_SparkFun_RightRear_GST'}
    {'GPS_SparkFun_RightRear_VTG'}];

assert(length(expectedResults) == length(matchedSensorNames))

for ith_result = 1:length(expectedResults)
    assert(strcmp(matchedSensorNames{ith_result},expectedResults{ith_result}));
end

%% Bad error cases go here
if 1==0 % BAD error cases start here



end
