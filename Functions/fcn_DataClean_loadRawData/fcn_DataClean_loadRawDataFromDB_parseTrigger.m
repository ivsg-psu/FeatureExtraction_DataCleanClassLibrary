function parseTrigger = fcn_DataClean_loadRawDataFromDB_parseTrigger(field_data_struct,datatype,fid)

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


% Updates:
% 2023_07_04 sbrennan@psu.edu
% -- fixed return at end of function to be 'end', keeping in function
% format
% -- added fid to fprint to allow printing to file
% -- added entry and exit debugging prints
% -- removed variable clearing at end of function because this is automatic


flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


if strcmp(datatype,'trigger')
    % Npoints = length(field_data_struct.id);
    parseTrigger = fcn_DataClean_initializeDataByType(datatype);
    if isempty(field_data_struct.id)
        warning('Trigger box table is empty!')
    else

        
        secs = field_data_struct.seconds;
        nsecs = field_data_struct.nanoseconds;
        parseTrigger.GPS_Time                          = secs + nsecs*(10^-9);  % This is the GPS time, UTC, as reported by the unit
        % parseTrigger.Trigger_Time                      = default_value;  % This is the Trigger time, UTC, as calculated by sample
        parseTrigger.ROS_Time                          = field_data_struct.time;  % This is the ROS time that the data arrived into the bag
        % parseTrigger.centiSeconds                      = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        parseTrigger.Npoints                           = length(field_data_struct.id);  % This is the number of data points in the array
        parseTrigger.mode                              = field_data_struct.mode;     % This is the mode of the trigger box (I: Startup, X: Freewheeling, S: Syncing, L: Locked)
        parseTrigger.mode_counts                       = field_data_struct.mode_counts;
        parseTrigger.adjone                            = field_data_struct.adjone;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
        parseTrigger.adjtwo                            = field_data_struct.adjtwo;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
        parseTrigger.adjthree                          = field_data_struct.adjthree; % This is phase adjustment magnitude relative to the calculated period of the output pulse
        % Data below are error monitoring messages
        parseTrigger.err_failed_mode_count             = field_data_struct.err_failed_mode_count;
        parseTrigger.err_failed_XI_format              = field_data_struct.err_failed_xi_format;
        parseTrigger.err_failed_checkInformation       = field_data_struct.err_failed_checkinformation;
        parseTrigger.err_trigger_unknown_error_occured = field_data_struct.err_trigger_unknown_error_occured;
        parseTrigger.err_bad_uppercase_character       = field_data_struct.err_bad_uppercase_character;
        parseTrigger.err_bad_lowercase_character       = field_data_struct.err_bad_lowercase_character;
        parseTrigger.err_bad_three_adj_element         = field_data_struct.err_bad_three_adj_element;
        parseTrigger.err_bad_first_element             = field_data_struct.err_bad_first_element;
        parseTrigger.err_bad_character                 = field_data_struct.err_bad_character;
        parseTrigger.err_wrong_element_length          = field_data_struct.err_wrong_element_length;
    end
else
    error('Wrong data type requested: %s',dataType)
end



% Close out the loading process
if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end
