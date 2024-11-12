% script_test_fcn_DataClean_checkTimeSamplingConsistency.m
% tests fcn_DataClean_checkTimeSamplingConsistency.m

% Revision history
% 2023_07_01 - sbrennan@psu.edu
% -- wrote the code originally using INTERNAL function from
% checkTimeConsistency
% 2024_11_11 - sbrennan@psu.edu
% -- updated test scripts for new consistency testing

close all

%% CASE 1: basic example - no inputs, not verbose, PASS, partial FAIL, and full FAIL
fig_num = 1;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end

% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.sensor1.GPS_Time = (0:0.05:2)';
initial_test_structure.sensor1.ROS_Time = (0:0.05:2)'; 
initial_test_structure.sensor1.centiSeconds = 5;
initial_test_structure.sensor2.GPS_Time = (0:0.01:2)';
initial_test_structure.sensor2.ROS_Time = (0:0.01:2)'; 
initial_test_structure.sensor2.centiSeconds = 1;
initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.ROS_Time = (0:0.1:2)';
initial_test_structure.car3.centiSeconds = 10; 

flags = []; 
sensors_to_check = '';
fid = 0;

% Pass
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(initial_test_structure,'GPS_Time',flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.GPS_Time_has_same_sample_rate_as_centiSeconds,1));
assert(strcmp(offending_sensor,''));

% Partial fail
modified_test_structure = initial_test_structure;
% Force one time sample to be bad
modified_test_structure.sensor2.GPS_Time(5)  = modified_test_structure.sensor2.GPS_Time(5)+(0.01)*0.8;
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(modified_test_structure,'GPS_Time',flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.GPS_Time_has_same_sample_rate_as_centiSeconds,0));
assert(isequal(offending_sensor,'sensor2'));

% Full fail
modified_test_structure = initial_test_structure;
modified_test_structure.sensor1.centiSeconds = 50;
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(modified_test_structure,'GPS_Time',flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.GPS_Time_has_same_sample_rate_as_centiSeconds,0));
assert(isequal(offending_sensor,'sensor1'));


%% CASE 2: basic example - no inputs, verbose, PASS and FAIL
fig_num = 2;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end

% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.sensor1.GPS_Time = (0:0.05:2)';
initial_test_structure.sensor1.ROS_Time = (0:0.05:2)'; 
initial_test_structure.sensor1.centiSeconds = 5;
initial_test_structure.sensor2.GPS_Time = (0:0.01:2)';
initial_test_structure.sensor2.ROS_Time = (0:0.01:2)'; 
initial_test_structure.sensor2.centiSeconds = 1;
initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.ROS_Time = (0:0.1:2)';
initial_test_structure.car3.centiSeconds = 10; 

flags = []; 
sensors_to_check = '';
fid = 1;

% Pass
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(initial_test_structure,'GPS_Time',flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.GPS_Time_has_same_sample_rate_as_centiSeconds,1));
assert(strcmp(offending_sensor,''));

% Partial fail
modified_test_structure = initial_test_structure;
% Force one time sample to be bad
modified_test_structure.sensor2.GPS_Time(5)  = modified_test_structure.sensor2.GPS_Time(5)+(0.01)*0.8;
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(modified_test_structure,'GPS_Time',flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.GPS_Time_has_same_sample_rate_as_centiSeconds,0));
assert(isequal(offending_sensor,'sensor2'));

% Full fail
modified_test_structure = initial_test_structure;
modified_test_structure.sensor1.centiSeconds = 50;
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(modified_test_structure,'GPS_Time',flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.GPS_Time_has_same_sample_rate_as_centiSeconds,0));
assert(isequal(offending_sensor,'sensor1'));


%% CASE 3: basic example - changing field_name, verbose
fig_num = 3;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.sensor1.GPS_Time = (0:0.05:2)';
initial_test_structure.sensor1.ROS_Time = (0:0.05:2)'; 
initial_test_structure.sensor1.centiSeconds = 5;
initial_test_structure.sensor2.GPS_Time = (0:0.01:2)';
initial_test_structure.sensor2.ROS_Time = (0:0.01:2)'; 
initial_test_structure.sensor2.centiSeconds = 1;
initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.ROS_Time = (0:0.1:2)';
initial_test_structure.car3.centiSeconds = 10; 

flags = []; 
field_name = 'ROS_Time';
sensors_to_check = '';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(initial_test_structure,field_name,flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.ROS_Time_has_same_sample_rate_as_centiSeconds,1));
assert(strcmp(offending_sensor,''));

flags = [];
modified_test_structure = initial_test_structure;
modified_test_structure.sensor1.centiSeconds = 8;
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(modified_test_structure,field_name,flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.ROS_Time_has_same_sample_rate_as_centiSeconds,0));
assert(isequal(offending_sensor,'sensor1'));


%% CASE 4: basic example - changing sensors_to_check, verbose
fig_num = 4;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.sensor1.GPS_Time = (0:0.05:2)';
initial_test_structure.sensor1.ROS_Time = (0:0.05:2)'; 
initial_test_structure.sensor1.centiSeconds = 5;
initial_test_structure.sensor2.GPS_Time = (0:0.01:2)';
initial_test_structure.sensor2.ROS_Time = (0:0.01:2)'; 
initial_test_structure.sensor2.centiSeconds = 1;
initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.ROS_Time = (0:0.1:2)';
initial_test_structure.car3.centiSeconds = 10; 

flags = []; 
field_name = 'ROS_Time';
sensors_to_check = 'car';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(initial_test_structure,field_name,flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.ROS_Time_has_same_sample_rate_as_centiSeconds_in_car_sensors,1));
assert(strcmp(offending_sensor,''));

modified_test_structure = initial_test_structure;
modified_test_structure.sensor1.centiSeconds = 6;
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(modified_test_structure,field_name,flags, sensors_to_check, (fid),(fig_num));
assert(isequal(flags.ROS_Time_has_same_sample_rate_as_centiSeconds_in_car_sensors,1));
assert(isequal(offending_sensor,''));

%% CASE 900: Real world data
fig_num = 900;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end

fullExampleFilePath = fullfile(cd,'Data','ExampleData_checkDataTimeConsistency.mat');
load(fullExampleFilePath,'dataStructure');

flags = []; 
field_name = 'ROS_Time';
sensors_to_check = 'GPS';
fid = 1;


[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(dataStructure, field_name, flags, sensors_to_check, fid, (fig_num));
assert(isequal(flags.ROS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_SparkFun_RightRear GPS_SparkFun_LeftRear GPS_SparkFun_Front'));




