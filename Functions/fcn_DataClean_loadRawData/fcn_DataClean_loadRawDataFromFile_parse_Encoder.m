function parseEncoder = fcn_DataClean_loadRawDataFromFile_parse_Encoder(d,data_source,flag_do_debug)

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
% Modified by Aneesh Batchu on 2023_06_13
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

if strcmp(data_source,'mat_file')
    % % Note: the Novatel and Hemisphere are almost perfectly time aligned, if
    % % dropping the first data point in Novatel (uncomment the following to
    % % see)
    % Hemisphere.GPS_Time(1,1)
    % % ans =
    % %           242007.249999977
    % d.Seconds(1,2)
    % % ans =
    % %              242007.248687
    % % This is why all the vectors below start at 2, not 1
    parseEncoder.ROS_Time                       = d.rosbagTimestamp;
    parseEncoder.header                         = d.header;
    parseEncoder.seq                            = d.seq;
    parseEncoder.Stamp                          = d.stamp;
    parseEncoder.sec                            = d.secs;
    parseEncoder.nsec                           = d.nsecs;
    parseEncoder.Frame_id                       = d.frame_id;
    parseEncoder.note_current_output            = d.note_current_output;
    parseEncoder.mode                           = d.mode;
    parseEncoder.time                           = d.time;
    parseEncoder.C1                             = d.C1;
    parseEncoder.C2                             = d.C2;
    parseEncoder.C3                             = d.C3;
    parseEncoder.C4                             = d.C4;
    parseEncoder.P1                             = d.P1;
    parseEncoder.E1                             = d.E1;
    parseEncoder.note_accumulated_error_counts  = d.note_accumulated_error_counts;
    parseEncoder.err_wrong_element_length       = d.err_wrong_element_length;
    parseEncoder.err_bad_element_structure      = d.err_bad_element_structure;
    parseEncoder.err_failed_time                = d.err_failed_time;
    parseEncoder.err_bad_uppercase_character    = d.err_bad_uppercase_character;
    parseEncoder.err_bad_lowercase_character    = d.err_bad_lowercase_character;
    parseEncoder.err_bad_character              = d.err_bad_character;

else
    error('Please indicate the data source')
end


clear d %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
