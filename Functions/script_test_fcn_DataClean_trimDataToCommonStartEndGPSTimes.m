% script_test_fcn_DataClean_trimDataToCommonStartEndGPSTimes.m
% tests fcn_DataClean_trimDataToCommonStartEndGPSTimes.m

% Revision history
% 2023_06_25 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all



%% Corrupt the GPS times on some of the sensors to mis-align them
% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;
fid = 1;

BadDataStructure = dataStructure;
BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - 1.03; 
BadDataStructure.GPS_Hemisphere.GPS_Time = BadDataStructure.GPS_Hemisphere.GPS_Time + 1.11; 

fprintf(fid,'\nData created with shifted up/down GPS_Time fields');

% Show that the data are not aligned by performing a consistency check. It
% should show that the GPS_Sparkfun_RearRight has the lowest time, and
% GPS_Hemisphere has the largest time
[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);

assert(isequal(flags.GPS_Time_has_consistent_start_end_across_GPS_sensors,0));
assert(strcmp(offending_sensor,'Start values of: GPS_Sparkfun_RearRight GPS_Hemisphere'));

% Fix the data
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(BadDataStructure,fid);

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
    


end
