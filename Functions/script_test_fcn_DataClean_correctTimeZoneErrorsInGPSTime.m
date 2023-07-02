% script_test_fcn_DataClean_correctTimeZoneErrorsInGPSTime.m
% tests fcn_DataClean_correctTimeZoneErrorsInGPSTime.m

% Revision history
% 2023_06_25 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc
fid = 1;

% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;

%% Shifted time interval test - one of the sensors is very far off
% Simulate a time zone error 

BadDataStructure = dataStructure;
hours_off = 1;
BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - hours_off*60*60; 
clear hours_off
fprintf(1,'\nData created with following errors injected: shifted start point\n\n');

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);
assert(isequal(flags.start_time_GPS_sensors_agrees_to_within_5_seconds,0));
assert(strcmp(offending_sensor,'GPS_Sparkfun_RearRight GPS_Sparkfun_RearLeft'));



%% Fix the data
fixed_dataStructure = fcn_DataClean_correctTimeZoneErrorsInGPSTime(BadDataStructure,fid);

% Make sure it worked
[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(fixed_dataStructure,fid);
assert(isequal(flags.start_time_GPS_sensors_agrees_to_within_5_seconds,1));

%% Fail conditions
if 1==0
    
    %% ERROR for point-type, due to bad alignment
    % Note that this is 5 seconds of data, and the Hemisphere is starting
    % after all the other sensors ended
    BadDataStructure = dataStructure;
    BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - 1;
    BadDataStructure.GPS_Hemisphere.GPS_Time = BadDataStructure.GPS_Hemisphere.GPS_Time + 5.1;
    
    fixed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(BadDataStructure,fid);


end
