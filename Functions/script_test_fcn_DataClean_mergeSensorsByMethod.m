% script_test_fcn_DataClean_mergeSensorsByMethod.m
% tests fcn_DataClean_mergeSensorsByMethod.m

% Revision history
% 2023_07_01 - sbrennan@psu.edu
% -- wrote the code originally using INTERNAL function from
% checkTimeConsistency

%      [flags,offending_sensor] = fcn_DataClean_checkIfFieldInSensors(...
%          dataStructure,field_name,...
%          (flags),(string_any_or_all),(sensors_to_check),(fid))



%% Test the basic call
method_name = 'keep_all';

% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo';
initial_test_structure.cow3.sound = 'moo';
initial_test_structure.cow3.color = 'brown';
initial_test_structure.cow3.height = 1.2;
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.weight  = 4;
initial_test_structure.cow4.sound = 'mooooooooooo';

dataStructure = initial_test_structure;
sensors_to_merge = 'cow';
merged_sensor_name = 'all_cows';
fid = 1;

updated_dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);

assert(isfield(updated_dataStructure,'pig1'));
assert(isfield(updated_dataStructure,'quiet_pig'));
assert(isfield(updated_dataStructure,'all_cows'));

assert(isfield(updated_dataStructure.all_cows,'sound')); % Filled with 'moo'
assert(isfield(updated_dataStructure.all_cows,'sound2'));% Filled with 'moo'
assert(isfield(updated_dataStructure.all_cows,'sound3'));% Filled with 'moo'
assert(isfield(updated_dataStructure.all_cows,'sound4'));% Filled with 'mooooooooooo'
assert(isfield(updated_dataStructure.all_cows,'height'));
assert(isfield(updated_dataStructure.all_cows,'color'));

%% Demonstrate keep_unique
method_name = 'keep_unique';

% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo';
initial_test_structure.cow3.sound = 'moo';
initial_test_structure.cow3.color = 'brown';
initial_test_structure.cow3.height = 1.2;
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.weight  = 4;
initial_test_structure.cow4.sound = 'mooooooooooo';

dataStructure = initial_test_structure;
sensors_to_merge = 'cow';
merged_sensor_name = 'all_cows';
fid = 1;

updated_dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);

assert(isfield(updated_dataStructure,'pig1'));
assert(isfield(updated_dataStructure,'quiet_pig'));
assert(isfield(updated_dataStructure,'all_cows'));

assert(isfield(updated_dataStructure.all_cows,'sound')); % Filled with 'moo'
assert(~isfield(updated_dataStructure.all_cows,'sound2'));
assert(~isfield(updated_dataStructure.all_cows,'sound3'));
assert(isfield(updated_dataStructure.all_cows,'sound4')); % Filled with 'mooooooooooo'
assert(isfield(updated_dataStructure.all_cows,'height'));
assert(isfield(updated_dataStructure.all_cows,'color'));

%% Test with real world data
% Fill in the initial data
fullExampleFilePath = fullfile(cd,'Data','ExampleData_mergeSensorsByMethod.mat');
load(fullExampleFilePath,'dataStructure');

sensors_to_merge = 'GPS_SparkFun_RightRear';
merged_sensor_name = 'GPS_SparkFun_RightRear';
method_name = 'keep_unique';
fid = 1;

updated_dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);

assert(isfield(dataStructure,'GPS_SparkFun_RightRear_GGA'));
assert(isfield(dataStructure,'GPS_SparkFun_RightRear_GST'));
assert(isfield(dataStructure,'GPS_SparkFun_RightRear_VTG'));
assert(~isfield(dataStructure.GPS_SparkFun_RightRear_GGA,'ROS_Time2'));
assert(~isfield(dataStructure.GPS_SparkFun_RightRear_GGA,'ROS_Time3'));



assert(~isfield(updated_dataStructure,'GPS_SparkFun_RightRear_GGA'));
assert(~isfield(updated_dataStructure,'GPS_SparkFun_RightRear_GST'));
assert(~isfield(updated_dataStructure,'GPS_SparkFun_RightRear_VTG'));
assert(isfield(updated_dataStructure,'GPS_SparkFun_RightRear'));
assert(isfield(updated_dataStructure.GPS_SparkFun_RightRear,'ROS_Time'));
assert(isfield(updated_dataStructure.GPS_SparkFun_RightRear,'ROS_Time2'));
assert(isfield(updated_dataStructure.GPS_SparkFun_RightRear,'ROS_Time3'));


