% script_test_fcn_DataClean_calculateTriggerTime_AllSensors.m
% tests fcn_DataClean_calculateTriggerTime_AllSensors

% Revision history:   
% 2024_09_23: xfc5113@psu.edu
% -- wrote the code originally 

%% Set up the workspace
close all


 
%% CASE 1: Calculate the Trigger_Time in all sensors 


% Define a dataset with corrupted Trigger_Time where the field is missing
% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;
fid = 1;
flags = [];

% Show that initial structure all has trigger_time
%%%%
% COMMENTED OUT UNTIL FUNCTION IS DONE

% [flags, ~] = fcn_DataClean_checkAllSensorsHaveTriggerTime(dataStructure,fid,flags);
% assert(isequal(flags.all_sensors_have_trigger_time,1));
% 
% time_time_corruption_type = 2^9; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
% [BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
% fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);
% 
% [flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure);
% 
% [flags,sensors_without_Trigger_Time] = fcn_DataClean_checkAllSensorsHaveTriggerTime(BadDataStructure,fid,flags);
% 
% 
% fprintf(1,'\nCASE 1: fixing trigger time in all sensors, NOT verbose\n');
% fixed_dataStructure = fcn_DataClean_calculateTriggerTime_AllSensors(BadDataStructure,sensors_without_Trigger_Time);
% fprintf(1,'\nCASE 1: Done!\n\n');
% 
% % Make sure it worked
% [flags, ~] = fcn_DataClean_checkAllSensorsHaveTriggerTime(fixed_dataStructure,fid,flags);
% assert(isequal(flags.all_sensors_have_trigger_time,1));
