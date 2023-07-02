% script_test_fcn_DataClean_convertROSTimeToSeconds.m
% tests fcn_DataClean_convertROSTimeToSeconds.m

% Revision history
% 2023_07_01 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc
fid = 1;

%% Define a dataset where the ROS_Time has a nanosecond scaling error
time_time_corruption_type = 2^13; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure);
assert(isequal(flags.ROS_Time_scaled_correctly_as_seconds,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% Fix the data using default call
fixed_dataStructure = fcn_DataClean_convertROSTimeToSeconds(BadDataStructure);

% Make sure it worked
[flags, ~] = fcn_DataClean_checkDataTimeConsistency(fixed_dataStructure);
assert(isequal(flags.ROS_Time_scaled_correctly_as_seconds,1));

%% Fix the data using verbose call
fixed_dataStructure = fcn_DataClean_convertROSTimeToSeconds(BadDataStructure,'',fid);

% Make sure it worked
[flags, ~] = fcn_DataClean_checkDataTimeConsistency(fixed_dataStructure);
assert(isequal(flags.ROS_Time_scaled_correctly_as_seconds,1));

%% Fix the data using specific call, specifying GPS sensors as the ones to fix

fixed_dataStructure = fcn_DataClean_convertROSTimeToSeconds(BadDataStructure,'GPS',fid);

% Make sure it worked
[flags, ~] = fcn_DataClean_checkDataTimeConsistency(fixed_dataStructure);
assert(isequal(flags.ROS_Time_scaled_correctly_as_seconds,1));


if 1==0 % BAD error cases start here



end
