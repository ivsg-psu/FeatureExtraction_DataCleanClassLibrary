% script_test_fcn_DataClean_trimRepeatsFromField.m
% tests fcn_DataClean_trimRepeatsFromField.m

% Revision history
% 2023_06_26 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all


% DOES NOT WORK?
% dataStructure = fcn_DataClean_fillTestDataStructure;


%% Example call 1 - using only defaults, pull out GPS_Time

% Grab example data
fullExampleFilePath = fullfile(cd,'Data','ExampleData_pullDataFromFieldAcrossAllSensors.mat');
load(fullExampleFilePath,'dataStructure');

field_string = 'GPS_Time';
sensor_identifier_string = []; % 'GPS'
entry_location = [];
fid = [];

% Call the function
[dataArray,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,field_string,(sensor_identifier_string), (entry_location), (fid));

% Check that results are all cell arrays
assert(iscell(dataArray))
assert(iscell(sensorNames))

% Assert they have same length
assert(length(dataArray)==length(sensorNames))

%% Example call 2 - pull out GPS_Time from only sensors that have "GPS" in name

% Grab example data
fullExampleFilePath = fullfile(cd,'Data','ExampleData_pullDataFromFieldAcrossAllSensors.mat');
load(fullExampleFilePath,'dataStructure');

field_string = 'GPS_Time';
sensor_identifier_string = 'GPS';
entry_location = [];
fid = [];

% Call the function
[dataArray,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,field_string,(sensor_identifier_string), (entry_location), (fid));

% Check that results are all cell arrays
assert(iscell(dataArray))
assert(iscell(sensorNames))

% Assert they have same length
assert(length(dataArray)==length(sensorNames))

%% Example call 3 - pull out GPS_Time from only sensors that have "GPS" in name, keeping only 1st data and printing to console

% Grab example data
fullExampleFilePath = fullfile(cd,'Data','ExampleData_pullDataFromFieldAcrossAllSensors.mat');
load(fullExampleFilePath,'dataStructure');

field_string = 'GPS_Time';
sensor_identifier_string = 'GPS';
entry_location = [];
fid = [];

% Call the function
[dataArray,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,field_string,(sensor_identifier_string), (entry_location), (fid));

% Check that results are all cell arrays
assert(iscell(dataArray))
assert(iscell(sensorNames))

% Assert they have same length
assert(length(dataArray)==length(sensorNames))

%% Example call 4 - pull out GPS_Time from only sensors that have "GPS" in name, keeping only last data and printing to console

% Grab example data
fullExampleFilePath = fullfile(cd,'Data','ExampleData_pullDataFromFieldAcrossAllSensors.mat');
load(fullExampleFilePath,'dataStructure');

field_string = 'GPS_Time';
sensor_identifier_string = 'GPS';
entry_location = 'last_row';
fid = 1;

% Call the function
[dataArray,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,field_string,(sensor_identifier_string), (entry_location), (fid));

% Check that results are all cell arrays
assert(iscell(dataArray))
assert(iscell(sensorNames))

% Assert they have same length
assert(length(dataArray)==length(sensorNames))


if 1==0 % BAD error cases start here



end
