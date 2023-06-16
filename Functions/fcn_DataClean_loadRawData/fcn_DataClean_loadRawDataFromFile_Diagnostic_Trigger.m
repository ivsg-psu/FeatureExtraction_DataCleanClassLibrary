%% History
% Created by Mariam Abdellatief on 6/15/2023
%
% Modified by Aneesh Batchu on 2023_06_15
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.

%% Function 
% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Sparkfun GPS (format:struct)
%      data_source = mat_file
% Returned Results:
%      diagnostic_trigger

function diagnostic_Trigger = fcn_DataClean_loadRawDataFromFile_Diagnostic_Trigger(data_structure,data_source)

if strcmp(data_source,'mat_file')
    diagnostic_Trigger.GPS_Time                          = data_structure.GPS_Time;  % This is the GPS time, UTC, as reported by the unit
    diagnostic_Trigger.Trigger_Time                      = data_structure.Trigger_Time;  % This is the Trigger time, UTC, as calculated by sample
    diagnostic_Trigger.ROS_Time                          = data_structure.ROS_Time;  % This is the ROS time that the data arrived into the bag
    diagnostic_Trigger.centiSeconds                      = data_structure.centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    diagnostic_Trigger.Npoints                           = data_structure.Npoints;  % This is the number of data points in the array
    diagnostic_Trigger.mode                              = data_structure.mode;  % This is the mode of the trigger box (I: Startup, X: Freewheeling, S: Syncing, L: Locked)
    diagnostic_Trigger.adjone                            = data_structure.adjone;  % This is phase adjustment magnitude relative to the calculated period of the output pulse
    diagnostic_Trigger.adjtwo                            = data_structure.adjtwo;  % This is phase adjustment magnitude relative to the calculated period of the output pulse
    diagnostic_Trigger.adjthree                          = data_structure.adjthree;  % This is phase adjustment magnitude relative to the calculated period of the output pulse
    % Data below are error monitoring messages
    diagnostic_Trigger.err_failed_mode_count             = data_structure.err_failed_mode_count; 
    diagnostic_Trigger.err_failed_checkInformation       = data_structure.err_failed_checkInformation;  
    diagnostic_Trigger.err_failed_XI_format              = data_structure.err_failed_XI_format; 
    diagnostic_Trigger.err_trigger_unknown_error_occured = data_structure.err_trigger_unknown_error_occured; 
    diagnostic_Trigger.err_bad_uppercase_character       = data_structure.err_bad_uppercase_character; 
    diagnostic_Trigger.err_bad_lowercase_character       = data_structure.err_bad_lowercase_character; 
    diagnostic_Trigger.err_bad_three_adj_element         = data_structure.err_bad_three_adj_element; 
    diagnostic_Trigger.err_bad_first_element             = data_structure.err_bad_first_element; 
    diagnostic_Trigger.err_bad_character                 = data_structure.err_bad_character; 
    diagnostic_Trigger.err_wrong_element_length          = data_structure.err_wrong_element_length; 
    % Event functions
    diagnostic_Trigger.EventFunctions = {}; % These are the functions to determine if something went wrong
else
    error('Please upload data structure in ".mat" format or speify data source')
end

clear data_structure %clear temp variable

% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return