function parseEncoder = fcn_DataClean_loadRawDataFromFile_parse_Encoder(data_structure,data_source,flag_do_debug)

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
    
    parseEncoder.GPS_Time           = data_structure.GPS_time;  % This is the GPS time, UTC, as reported by the unit
    parseEncoder.Trigger_Time       = data_structure.Trigger_Time;  % This is the Trigger time, UTC, as calculated by sample
    parseEncoder.ROS_Time           = data_structure.ROS_Time;  % This is the ROS time that the data arrived into the bag
    parseEncoder.centiSeconds       = data_structure.centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    parseEncoder.Npoints            = data_structure.Npoints;  % This is the number of data points in the array

    parseEncoder.CountsPerRev       = data_structure.CountsPerRev;  % How many counts are in each revolution of the encoder (with quadrature)
    parseEncoder.Counts             = data_structure.Counts;  % A vector of the counts measured by the encoder, Npoints long
    parseEncoder.DeltaCounts        = data_structure.DeltaCounts;  % A vector of the change in counts measured by the encoder, with first value of zero, Npoints long
    parseEncoder.LastIndexCount     = data_structure.LastIndexCount;  % Count at which last index pulse was detected, Npoints long
    parseEncoder.AngularVelocity    = data_structure.AngularVelocity;  % Angular velocity of the encoder
    parseEncoder.AngularVelocity_Sigma    = default_value.AngularVelocity_Sigma;
    % Event functions
    parseEncoder.EventFunctions = {}; % These are the functions to determine if something went wrong
    

else
    error('Please indicate the data source')
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
