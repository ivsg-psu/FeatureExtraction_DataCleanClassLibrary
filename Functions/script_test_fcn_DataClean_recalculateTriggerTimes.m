% script_test_fcn_DataClean_recalculateTriggerTimes.m
% tests fcn_DataClean_recalculateTriggerTimes

% Revision history
% 2023_06_25 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all


 
%% Define a dataset with corrupted Trigger_Time where the field is missing
time_time_corruption_type = 2^9; % Type 'help fcn_DataClean_fillTestDataStructure' to ID corruption types
[BadDataStructure, error_type_string] = fcn_DataClean_fillTestDataStructure(time_time_corruption_type);
fprintf(1,'\nData created with following errors injected: %s\n\n',error_type_string);

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,0));
assert(strcmp(offending_sensor,'GPS_Hemisphere'));

%% CASE 1: Fix the Trigger_Time in all sensors - NOT verbose
fprintf(1,'\nCASE 1: fixing trigger time in all sensors, NOT verbose\n');
fixed_dataStructure = fcn_DataClean_recalculateTriggerTimes(BadDataStructure);
fprintf(1,'\nCASE 1: Done!\n\n');

% Make sure it worked
[flags, ~] = fcn_DataClean_checkDataTimeConsistency(fixed_dataStructure);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,1));


%% CASE 2: Fix the Trigger_Time in all sensors - NOT verbose
fprintf(1,'\nCASE 2: fixing trigger time in all sensors, verbose\n');
fixed_dataStructure = fcn_DataClean_recalculateTriggerTimes(BadDataStructure,'', fid);
fprintf(1,'\nCASE 2: Done!\n\n');

% Make sure it worked
[flags, ~] = fcn_DataClean_checkDataTimeConsistency(fixed_dataStructure);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,1));


%% Fix the data only in "GPS" sensors
fprintf(1,'\nCASE 3: fixing trigger time only in GPS sensors, verbose\n');
fixed_dataStructure = fcn_DataClean_recalculateTriggerTimes(BadDataStructure,'GPS', fid);
fprintf(1,'\nCASE 3: Done!\n\n');

% Make sure it worked
[flags, ~] = fcn_DataClean_checkDataTimeConsistency(fixed_dataStructure);
assert(isequal(flags.Trigger_Time_exists_in_all_GPS_sensors,1));



%% Fail conditions
if 1==0
    

end
