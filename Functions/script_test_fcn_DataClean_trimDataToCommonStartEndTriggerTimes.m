% script_test_fcn_DataClean_trimDataToCommonStartEndTriggerTimes.m
% tests fcn_DataClean_trimDataToCommonStartEndTriggerTimes.m

% Revision history
% 2023_06_25 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc
fid = 1;

% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;

%% Corrupt the GPS times on some of the sensors to mis-align them
BadDataStructure = dataStructure;
BadDataStructure.GPS_Sparkfun_RearRight.Trigger_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - 1.03; 
BadDataStructure.GPS_Sparkfun_RearLeft.Trigger_Time = BadDataStructure.GPS_Sparkfun_RearLeft.GPS_Time - 1.03; 
BadDataStructure.GPS_Sparkfun_Front.Trigger_Time = BadDataStructure.GPS_Sparkfun_Front.GPS_Time - 1.03; 

fprintf(fid,'\nData created with shifted up/down GPS_Time fields');

% Show that the data are not aligned by performing a consistency check. It
% should show that the GPS_Sparkfun_RearRight has the lowest time, and
% GPS_Hemisphere has the largest time

%% Fix the data
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndTriggerTimes(BadDataStructure,fid);

% Make sure it worked
sensor_names = fieldnames(trimmed_dataStructure); % Grab all the fields that are in dataStructure structure
start_time = trimmed_dataStructure.(sensor_names{1}).GPS_Time(1);
end_time = trimmed_dataStructure.(sensor_names{1}).GPS_Time(end);
for i_data = 2:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    
    % Make sure the sensor stops within one sampling period of start/end
    % times (it is 10 Hz)
    assert(trimmed_dataStructure.(sensor_name).GPS_Time(1,1)>= start_time-0.1);
    assert(trimmed_dataStructure.(sensor_name).GPS_Time(end,1)<= end_time+0.1);
end

%% Fail conditions
if 1==0
    
    %% ERROR for point-type, due to bad alignment
    % Note that this is 5 seconds of data, and the Hemisphere is starting
    % after all the other sensors ended
    BadDataStructure = dataStructure;
    BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - 1;
    BadDataStructure.GPS_Hemisphere.GPS_Time = BadDataStructure.GPS_Hemisphere.GPS_Time + 5.1;
    
    trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(BadDataStructure,fid);


end