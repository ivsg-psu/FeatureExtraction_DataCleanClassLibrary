function parseTrigger = fcn_DataClean_loadRawDataFromFile_parse_Trigger(file_path,datatype,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the parse Encoder data, whose data type is imu
% Input Variables:
%      file_path = file path of the parseTrigger data
%      datatype  = the datatype should be trigger
% Returned Results:
%      parseTrigger

% Author: Liming Gao
% Created Date: 2020_11_15
% Modify Date: 2023_06_16
%
% Modified by Xinyu Cao, Aneesh Batchu and Mariam Abdellatief on 2023_06_16
% 
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 
% Reference:
% 
%%

if strcmp(datatype,'trigger')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    parseTrigger = fcn_DataClean_initializeDataByType(datatype);
    secs = datatable.secs;
    nsecs = datatable.secs;
    parseTrigger.mode = datatable.mode;
    parseTrigger.GPS_Time                          = secs + nsecs*(10^-9);  % This is the GPS time, UTC, as reported by the unit
    % parseTrigger.Trigger_Time                      = default_value;  % This is the Trigger time, UTC, as calculated by sample
    parseTrigger.ROS_Time                          = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
    % parseTrigger.centiSeconds                      = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    parseTrigger.Npoints                           = height(datatable);  % This is the number of data points in the array
    parseTrigger.mode                              = datatable.mode;     % This is the mode of the trigger box (I: Startup, X: Freewheeling, S: Syncing, L: Locked)
    parseTrigger.adjone                            = datatable.adjone;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
    parseTrigger.adjtwo                            = datatable.adjtwo;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
    parseTrigger.adjthree                          = datatable.adjthree; % This is phase adjustment magnitude relative to the calculated period of the output pulse
    % Data below are error monitoring messages
    parseTrigger.err_failed_mode_count             = datatable.err_failed_mode_count;
    parseTrigger.err_failed_XI_format              = datatable.err_failed_XI_format;
    parseTrigger.err_failed_checkInformation       = datatable.err_failed_checkInformation;
    parseTrigger.err_trigger_unknown_error_occured = datatable.err_trigger_unknown_error_occured;
    parseTrigger.err_bad_uppercase_character       = datatable.err_bad_uppercase_character;
    parseTrigger.err_bad_lowercase_character       = datatable.err_bad_lowercase_character;
    parseTrigger.err_bad_three_adj_element         = datatable.err_bad_three_adj_element;
    parseTrigger.err_bad_first_element             = datatable.err_bad_first_element;
    parseTrigger.err_bad_character                 = datatable.err_bad_character;
    parseTrigger.err_wrong_element_length          = datatable.err_wrong_element_length;

else
    error('Wrong data type requested: %s',dataType)
end


clear datatable %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
