function parseTrigger = fcn_DataClean_loadRawDataFromFile_parse_Trigger(file_path,datatype,table,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the GPS_Novatel data
% Input Variables:
%      d = raw data from GPS_Novatel(format:struct)
%      Hemisphere = the data from Hemisphere GPS, used to estimate the
%                   GPS_Novatel sigma (format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
% Returned Results:
%      GPS_Novatel
% Author: Liming Gao
% Created Date: 2020_12_07
%
% Modified by Aneesh Batchu on 2023_06_15
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 1. check if it is reasonable to select data from the second d.Time(2:end)';
% 2. check the Yaw_deg between matfile and database
% 3. Hemisphere = d_out;  %%update the interpolated values to raw data?
%%

if contains(file_path,'trigger')

    secs = table.secs;
    nsecs = table.nsecs;
    parseTrigger = fcn_DataClean_initializeDataByType(datatype);

    parseTrigger.mode = table.mode;
    parseTrigger.GPS_Time                          = secs + nsecs*(10^-9);  % This is the GPS time, UTC, as reported by the unit
    % parseTrigger.Trigger_Time                      = default_value;  % This is the Trigger time, UTC, as calculated by sample
    parseTrigger.ROS_Time                          = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
    % parseTrigger.centiSeconds                      = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    parseTrigger.Npoints                           = height(table);  % This is the number of data points in the array
    parseTrigger.mode                              = table.mode;     % This is the mode of the trigger box (I: Startup, X: Freewheeling, S: Syncing, L: Locked)
    parseTrigger.adjone                            = table.adjone;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
    parseTrigger.adjtwo                            = table.adjtwo;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
    parseTrigger.adjthree                          = table.adjthree; % This is phase adjustment magnitude relative to the calculated period of the output pulse
    % Data below are error monitoring messages
    parseTrigger.err_failed_mode_count             = table.err_failed_mode_count;
    parseTrigger.err_failed_XI_format              = table.err_failed_XI_format;
    parseTrigger.err_failed_checkInformation       = table.err_failed_checkInformation;
    parseTrigger.err_trigger_unknown_error_occured = table.err_trigger_unknown_error_occured;
    parseTrigger.err_bad_uppercase_character       = table.err_bad_uppercase_character;
    parseTrigger.err_bad_lowercase_character       = table.err_bad_lowercase_character;
    parseTrigger.err_bad_three_adj_element         = table.err_bad_three_adj_element;
    parseTrigger.err_bad_first_element             = table.err_bad_first_element;
    parseTrigger.err_bad_character                 = table.err_bad_character;
    parseTrigger.err_wrong_element_length          = table.err_wrong_element_length;
    
else
    error('Please use the correct file path')
end


%clear table %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
