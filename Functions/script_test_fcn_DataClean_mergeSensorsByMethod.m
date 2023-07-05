% script_test_fcn_DataClean_mergeSensorsByMethod.m
% tests fcn_DataClean_mergeSensorsByMethod.m

% Revision history
% 2023_07_01 - sbrennan@psu.edu
% -- wrote the code originally using INTERNAL function from
% checkTimeConsistency

%      [flags,offending_sensor] = fcn_DataClean_checkIfFieldInSensors(...
%          dataStructure,field_name,...
%          (flags),(string_any_or_all),(sensors_to_check),(fid))

%% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo';
initial_test_structure.cow3.sound = 'moo';
initial_test_structure.cow3.color = 'brown';
initial_test_structure.cow3.height = 1.2;
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.weight  = 4;
initial_test_structure.cow4.sound = 'mooooooooooo';


% Fill in the initial data
load('ExampleData_checkDataNameConsistency.mat','dataStructure')


%% Test the basic call
dataStructure = initial_test_structure;
sensors_to_merge = 'cow';
merged_sensor_name = 'all_cows';
method_name = 'keep_all';
fid = 1;
updated_dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);
assert(isfield(updated_dataStructure,'pig1'));
assert(isfield(updated_dataStructure,'quiet_pig'));
assert(isfield(updated_dataStructure,'all_cows'));
assert(isfield(updated_dataStructure.all_cows,'sound'));
assert(isfield(updated_dataStructure.all_cows,'sound2'));
assert(isfield(updated_dataStructure.all_cows,'sound3'));
assert(isfield(updated_dataStructure.all_cows,'sound4'));
assert(isfield(updated_dataStructure.all_cows,'height'));
assert(isfield(updated_dataStructure.all_cows,'color'));

%% Demonstrate keep_unique
method_name = 'keep_unique';

updated_dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);

assert(isfield(updated_dataStructure,'pig1'));
assert(isfield(updated_dataStructure,'quiet_pig'));
assert(isfield(updated_dataStructure,'all_cows'));
assert(isfield(updated_dataStructure.all_cows,'sound'));
assert(~isfield(updated_dataStructure.all_cows,'sound2'));
assert(~isfield(updated_dataStructure.all_cows,'sound3'));
assert(isfield(updated_dataStructure.all_cows,'sound4'));
assert(isfield(updated_dataStructure.all_cows,'height'));
assert(isfield(updated_dataStructure.all_cows,'color'));