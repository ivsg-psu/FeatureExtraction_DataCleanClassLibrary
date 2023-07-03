% script_test_fcn_DataClean_checkFieldCountMatchesTimeCount.m
% tests fcn_DataClean_checkFieldCountMatchesTimeCount.m

% Revision history
% 2023_07_02 - sbrennan@psu.edu
% -- wrote the code originally using INTERNAL function from
% checkTimeConsistency

%      [flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(...
%          dataStructure,field_name,...
%          (flags),(time_field),(sensors_to_check),(fid))

close all

%% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.sensor1.GPS_Time     = (0:0.05:2)';
initial_test_structure.sensor1.Trigger_Time = (0:0.05:2)';
initial_test_structure.sensor1.ROS_Time     = (0:0.1:2)'; 
initial_test_structure.sensor1.fakeData     = 5*initial_test_structure.sensor1.Trigger_Time;

initial_test_structure.sensor2.GPS_Time     = (0:0.01:2)';
initial_test_structure.sensor2.Trigger_Time = (0:0.05:2)';
initial_test_structure.sensor2.ROS_Time     = (0:0.01:2)'; 
initial_test_structure.sensor2.fakeData     = 5*initial_test_structure.sensor2.Trigger_Time;

initial_test_structure.car3.GPS_Time     = (0:0.01:2)';
initial_test_structure.car3.Trigger_Time = (0:0.01:2)';
initial_test_structure.car3.ROS_Time     = (0:0.01:2)';
initial_test_structure.car3.fakeData     = 5*initial_test_structure.car3.ROS_Time;

initial_test_structure.car4.GPS_Time     = (0:0.01:2)';
initial_test_structure.car4.Trigger_Time = (0:0.01:2)';
initial_test_structure.car4.ROS_Time     = (0:0.1:2)';
initial_test_structure.car4.fakeData     = 5*initial_test_structure.car4.ROS_Time;


%% CASE 1: basic example - no inputs, not verbose
field_name = 'fakeData';
flags = []; 
time_field = '';
sensors_to_check = '';
fid = 0;

[flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(initial_test_structure,field_name,flags,time_field,sensors_to_check,fid);
assert(isequal(flags.fakeData_has_same_length_as_Trigger_Time_in_all_sensors,0));
assert(strcmp(offending_sensor,'car4'));

% Fix the data, and now show it works
modified_test_structure = initial_test_structure;
modified_test_structure.car4.fakeData = 5*initial_test_structure.car4.Trigger_Time;

[flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(modified_test_structure,field_name,flags,time_field,sensors_to_check,fid);
assert(isequal(flags.fakeData_has_same_length_as_Trigger_Time_in_all_sensors,1));
assert(isequal(offending_sensor,''));

%% CASE 2: basic example - no inputs, verbose
field_name = 'fakeData';
flags = []; 
time_field = '';
sensors_to_check = '';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(initial_test_structure,field_name,flags,time_field,sensors_to_check,fid);
assert(isequal(flags.fakeData_has_same_length_as_Trigger_Time_in_all_sensors,0));
assert(strcmp(offending_sensor,'car4'));

% Fix the data, and now show it works
modified_test_structure = initial_test_structure;
modified_test_structure.car4.fakeData = 5*initial_test_structure.car4.Trigger_Time;

[flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(modified_test_structure,field_name,flags,time_field,sensors_to_check,fid);
assert(isequal(flags.fakeData_has_same_length_as_Trigger_Time_in_all_sensors,1));
assert(isequal(offending_sensor,''));

%% CASE 3: basic example - changing field_name, verbose
field_name = 'fakeData';
flags = []; 
time_field = 'ROS_Time';
sensors_to_check = '';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(initial_test_structure,field_name,flags,time_field,sensors_to_check,fid);
assert(isequal(flags.fakeData_has_same_length_as_ROS_Time_in_all_sensors,0));
assert(strcmp(offending_sensor,'sensor1'));


%% CASE 4: basic example - changing sensors_to_check, verbose
field_name = 'fakeData';
flags = []; 
time_field = 'ROS_Time';
fid = 1;

sensors_to_check = 'sensor';
[flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(initial_test_structure,field_name,flags,time_field,sensors_to_check,fid);
assert(isequal(flags.fakeData_has_same_length_as_ROS_Time_in_sensor_sensors,0));
assert(strcmp(offending_sensor,'sensor1'));

sensors_to_check = 'car';
[flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(initial_test_structure,field_name,flags,time_field,sensors_to_check,fid);
assert(isequal(flags.fakeData_has_same_length_as_ROS_Time_in_car_sensors,1));
assert(strcmp(offending_sensor,''));


