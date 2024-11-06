% script_test_fcn_DataClean_checkConsistencyOfStartEnd.m
% tests fcn_DataClean_checkConsistencyOfStartEnd.m

% Revision history
% 2024_11_06 - sbrennan@psu.edu
% -- wrote the code originally using INTERNAL function from
% checkTimeConsistency

close all

%% CASE 1: basic example - no inputs, not verbose, PASS
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

field_name = 'GPS_Time';
flags = []; 
sensors_to_check = [];
flag_name_suffix = [];
agreement_threshold = [];
fid = [];
fig_num = [];

[flags, offending_sensor, return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(initial_test_structure, field_name, (flags), (sensors_to_check), (flag_name_suffix), (agreement_threshold), (fid), (fig_num));

assert(isequal(flags.GPS_Time_has_consistent_start_end,1));
assert(strcmp(offending_sensor,''));
assert(return_flag==0)

%% CASE 2: basic example - no inputs, verbose, PASS
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

field_name = 'GPS_Time';
flags = []; 
sensors_to_check = [];
flag_name_suffix = [];
agreement_threshold = [];
fid = 1;
fig_num = [];

[flags, offending_sensor, return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(initial_test_structure, field_name, (flags), (sensors_to_check), (flag_name_suffix), (agreement_threshold), (fid), (fig_num));

assert(isequal(flags.GPS_Time_has_consistent_start_end,1));
assert(strcmp(offending_sensor,''));
assert(return_flag==0)


%% CASE 3: basic example - no inputs, verbose, FAIL
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
initial_test_structure.sensor2.GPS_Time = (0:0.01:2.2)';
initial_test_structure.sensor2.ROS_Time = (0:0.01:2.2)'; 
initial_test_structure.sensor2.centiSeconds = 1;
initial_test_structure.car3.GPS_Time = (0:0.1:2)';
initial_test_structure.car3.ROS_Time = (0:0.1:2)';
initial_test_structure.car3.centiSeconds = 10; 

field_name = 'GPS_Time';
flags = []; 
sensors_to_check = [];
flag_name_suffix = [];
agreement_threshold = [];
fid = 1;
fig_num = [];

[flags, offending_sensor, return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(initial_test_structure, field_name, (flags), (sensors_to_check), (flag_name_suffix), (agreement_threshold), (fid), (fig_num));

assert(isequal(flags.GPS_Time_has_consistent_start_end,0));
assert(strcmp(offending_sensor,'End values of: sensor1 sensor2'));
assert(return_flag==1)


%% CASE 4: basic example - sensor specified, verbose, PASS
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
initial_test_structure.car3.GPS_Time = (0:0.1:2.3)';
initial_test_structure.car3.ROS_Time = (0:0.1:2.3)';
initial_test_structure.car3.centiSeconds = 10; 

field_name = 'GPS_Time';
flags = []; 
sensors_to_check = 'sensor';
flag_name_suffix = [];
agreement_threshold = [];
fid = 1;
fig_num = [];

[flags, offending_sensor, return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(initial_test_structure, field_name, (flags), (sensors_to_check), (flag_name_suffix), (agreement_threshold), (fid), (fig_num));

assert(isequal(flags.GPS_Time_has_consistent_start_end,1));
assert(strcmp(offending_sensor,''));
assert(return_flag==0)

%% CASE 5: basic example - sensor specified, verbose, PASS with threshold
fig_num = 5;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end

% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.sensor1.GPS_Time = (0:0.05:2.1)';
initial_test_structure.sensor1.ROS_Time = (0:0.05:2)'; 
initial_test_structure.sensor1.centiSeconds = 5;
initial_test_structure.sensor2.GPS_Time = (0:0.01:2)';
initial_test_structure.sensor2.ROS_Time = (0:0.01:2)'; 
initial_test_structure.sensor2.centiSeconds = 1;
initial_test_structure.car3.GPS_Time = (0:0.1:2.3)';
initial_test_structure.car3.ROS_Time = (0:0.1:2.3)';
initial_test_structure.car3.centiSeconds = 10; 

field_name = 'GPS_Time';
flags = []; 
sensors_to_check = [];
flag_name_suffix = '_to_half_second';
agreement_threshold = 0.5;
fid = 1;
fig_num = [];

[flags, offending_sensor, return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(initial_test_structure, field_name, (flags), (sensors_to_check), (flag_name_suffix), (agreement_threshold), (fid), (fig_num));

assert(isequal(flags.GPS_Time_has_consistent_start_end_to_half_second,1));
assert(strcmp(offending_sensor,''));
assert(return_flag==0)


%% CASE 900: Real world data
fig_num = 900;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


fullExampleFilePath = fullfile(cd,'Data','ExampleData_checkDataTimeConsistency.mat');
load(fullExampleFilePath,'dataStructure');

field_name = 'GPS_Time';
flags = []; 
sensors_to_check = [];
flag_name_suffix = '_to_half_second';
agreement_threshold = 0.5;
fid = 1;
fig_num = [];

[flags, offending_sensor, return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(dataStructure, field_name, (flags), (sensors_to_check), (flag_name_suffix), (agreement_threshold), (fid), (fig_num));

assert(isequal(flags.GPS_Time_has_consistent_start_end_to_half_second,1));
assert(strcmp(offending_sensor,''));
assert(return_flag==0)




