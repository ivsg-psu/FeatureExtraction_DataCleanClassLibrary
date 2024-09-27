% script_test_fcn_DataClean_checkTimeRoundsCorrectly.m
% tests fcn_DataClean_checkTimeRoundsCorrectly.m

% Revision history
% 2023_07_02 - sbrennan@psu.edu
% -- wrote the code originally using INTERNAL function from
% checkTimeConsistency


close all

% [flags,offending_sensor,~] = fcn_DataClean_checkTimeRoundsCorrectly(dataStructure, 'ROS_Time',flags,'Trigger_Time','GPS',fid);
% if 0==flags.ROS_Time_rounds_correctly_to_Trigger_Time_in_GPS_sensors
%     return
% end



%% CASE 1: basic example - no inputs, not verbose
% Fill in some silly test data
initial_test_structure = struct;

initial_test_structure.sensor1.GPS_Time = (0:0.05:2)';
initial_test_structure.sensor1.Trigger_Time = (0:0.05:2)' + 0.006;
initial_test_structure.sensor1.ROS_Time = initial_test_structure.sensor1.GPS_Time; 
initial_test_structure.sensor1.centiSeconds = 5;

initial_test_structure.sensor2.GPS_Time = (0:0.01:2)';
initial_test_structure.sensor2.Trigger_Time = (0:0.01:2)' + 0.006;
initial_test_structure.sensor2.ROS_Time = initial_test_structure.sensor2.GPS_Time; 
initial_test_structure.sensor2.centiSeconds = 1;

initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.Trigger_Time = (0:0.1:2)' + 0.006;
initial_test_structure.car3.ROS_Time = initial_test_structure.car3.GPS_Time;
initial_test_structure.car3.centiSeconds = 10; 


flags = []; 
sensors_to_check = '';
fid = 0;

[flags,offending_sensor] = fcn_DataClean_checkTimeRoundsCorrectly(initial_test_structure,'ROS_Time',flags, 'GPS_Time', sensors_to_check,fid);
assert(isequal(flags.ROS_Time_rounds_correctly_to_GPS_Time_in_all_sensors,1));
assert(strcmp(offending_sensor,''));

modified_test_structure = initial_test_structure;
modified_test_structure.sensor1.ROS_Time = initial_test_structure.sensor1.GPS_Time+0.1;

[flags,offending_sensor] = fcn_DataClean_checkTimeRoundsCorrectly(modified_test_structure,'ROS_Time',flags, 'GPS_Time', sensors_to_check,fid);
assert(isequal(flags.ROS_Time_rounds_correctly_to_GPS_Time_in_all_sensors,0));
assert(isequal(offending_sensor,'sensor1'));

%% CASE 2: basic example - no inputs, verbose
% Fill in some silly test data
initial_test_structure = struct;

initial_test_structure.sensor1.GPS_Time = (0:0.05:2)';
initial_test_structure.sensor1.Trigger_Time = (0:0.05:2)' + 0.006;
initial_test_structure.sensor1.ROS_Time = initial_test_structure.sensor1.GPS_Time; 
initial_test_structure.sensor1.centiSeconds = 5;

initial_test_structure.sensor2.GPS_Time = (0:0.01:2)';
initial_test_structure.sensor2.Trigger_Time = (0:0.01:2)' + 0.006;
initial_test_structure.sensor2.ROS_Time = initial_test_structure.sensor2.GPS_Time; 
initial_test_structure.sensor2.centiSeconds = 1;

initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.Trigger_Time = (0:0.1:2)' + 0.006;
initial_test_structure.car3.ROS_Time = initial_test_structure.car3.GPS_Time;
initial_test_structure.car3.centiSeconds = 10; 


flags = []; 
sensors_to_check = '';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkTimeRoundsCorrectly(initial_test_structure,'ROS_Time',flags, 'GPS_Time', sensors_to_check,fid);
assert(isequal(flags.ROS_Time_rounds_correctly_to_GPS_Time_in_all_sensors,1));
assert(strcmp(offending_sensor,''));

modified_test_structure = initial_test_structure;
modified_test_structure.sensor1.ROS_Time = initial_test_structure.sensor1.GPS_Time+0.1;

[flags,offending_sensor] = fcn_DataClean_checkTimeRoundsCorrectly(modified_test_structure,'ROS_Time',flags, 'GPS_Time', sensors_to_check,fid);
assert(isequal(flags.ROS_Time_rounds_correctly_to_GPS_Time_in_all_sensors,0));
assert(isequal(offending_sensor,'sensor1'));

%% CASE 3: basic example - changing field_name, verbose
% This will only check GPS_Time now

% Fill in some silly test data
initial_test_structure = struct;

initial_test_structure.sensor1.GPS_Time = (0:0.05:2)';
initial_test_structure.sensor1.Trigger_Time = (0:0.05:2)';
initial_test_structure.sensor1.ROS_Time = initial_test_structure.sensor1.GPS_Time; 
initial_test_structure.sensor1.centiSeconds = 5;

initial_test_structure.sensor2.GPS_Time = (0:0.01:2)' + 0.006;
initial_test_structure.sensor2.Trigger_Time = (0:0.01:2)';
initial_test_structure.sensor2.ROS_Time = initial_test_structure.sensor2.GPS_Time; 
initial_test_structure.sensor2.centiSeconds = 1;

initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.Trigger_Time = (0:0.1:2)'+0.002;
initial_test_structure.car3.ROS_Time = initial_test_structure.car3.GPS_Time;
initial_test_structure.car3.centiSeconds = 10; 


flags = []; 
field_name = 'GPS_Time';
sensors_to_check = '';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkTimeRoundsCorrectly(initial_test_structure, field_name, flags, 'Trigger_Time', sensors_to_check, fid);

assert(isequal(flags.GPS_Time_rounds_correctly_to_Trigger_Time_in_all_sensors,0));
assert(strcmp(offending_sensor,'sensor2'));

% Nudge the data just a bit so that it rounds correctly. Note: the nudge
% does not force the time to match, so rounding must still occur.
modified_test_structure = initial_test_structure;
modified_test_structure.sensor2.GPS_Time = initial_test_structure.sensor2.GPS_Time-0.002;

[flags,offending_sensor] = fcn_DataClean_checkTimeRoundsCorrectly(modified_test_structure,field_name,flags, 'Trigger_Time', sensors_to_check,fid);
assert(isequal(flags.GPS_Time_rounds_correctly_to_Trigger_Time_in_all_sensors,1));
assert(isequal(offending_sensor,''));


%% CASE 4: basic example - changing sensors_to_check, verbose
% This now only checks the GPS_Time in the "car" sensor. NOTE: the actual
% sensor name is "car3", but it is still tested as it contains the "car"
% string in the sensor name.

% Fill in some silly test data
initial_test_structure = struct;

initial_test_structure.sensor1.GPS_Time = (0:0.05:2)';
initial_test_structure.sensor1.Trigger_Time = (0:0.05:2)' + 0.006;
initial_test_structure.sensor1.ROS_Time = initial_test_structure.sensor1.GPS_Time; 
initial_test_structure.sensor1.centiSeconds = 5;

initial_test_structure.sensor2.GPS_Time = (0:0.01:2)';
initial_test_structure.sensor2.Trigger_Time = (0:0.01:2)' + 0.006;
initial_test_structure.sensor2.ROS_Time = initial_test_structure.sensor2.GPS_Time; 
initial_test_structure.sensor2.centiSeconds = 1;

initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.Trigger_Time = (0:0.1:2)' + 0.004;
initial_test_structure.car3.ROS_Time = initial_test_structure.car3.GPS_Time;
initial_test_structure.car3.centiSeconds = 10; 

% Nudge the data just a bit so that it rounds correctly
modified_test_structure = initial_test_structure;
modified_test_structure.sensor2.GPS_Time = initial_test_structure.sensor2.GPS_Time+0.002;


flags = []; 
field_name = 'GPS_Time';
sensors_to_check = 'car';
time_field = 'Trigger_Time';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkTimeRoundsCorrectly(modified_test_structure,field_name,flags, time_field, sensors_to_check,fid);
assert(isequal(flags.GPS_Time_rounds_correctly_to_Trigger_Time_in_car_sensors,1));
assert(strcmp(offending_sensor,''));




