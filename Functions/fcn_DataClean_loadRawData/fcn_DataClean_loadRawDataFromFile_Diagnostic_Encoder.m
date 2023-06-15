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
%      diagnostic_encoder

function diagnostic_Encoder = fcn_DataClean_loadRawDataFromFile_Diagnostic_Encoder(data_structure,data_source)

if strcmp(data_source,'mat_file')
    diagnostic_Encoder.GPS_Time           = data_structure.GPS_time;  % This is the GPS time, UTC, as reported by the unit
    diagnostic_Encoder.Trigger_Time       = data_structure.Trigger_Time;  % This is the Trigger time, UTC, as calculated by sample
    diagnostic_Encoder.ROS_Time           = data_structure.ROS_Time;  % This is the ROS time that the data arrived into the bag
    diagnostic_Encoder.centiSeconds       = data_structure.centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    diagnostic_Encoder.Npoints            = data_structure.Npoints;  % This is the number of data points in the array

    diagnostic_Encoder.CountsPerRev       = data_structure.CountsPerRev;  % How many counts are in each revolution of the encoder (with quadrature)
    diagnostic_Encoder.Counts             = data_structure.Counts;  % A vector of the counts measured by the encoder, Npoints long
    diagnostic_Encoder.DeltaCounts        = data_structure.DeltaCounts;  % A vector of the change in counts measured by the encoder, with first value of zero, Npoints long
    diagnostic_Encoder.LastIndexCount     = data_structure.LastIndexCount;  % Count at which last index pulse was detected, Npoints long
    diagnostic_Encoder.AngularVelocity    = data_structure.AngularVelocity;  % Angular velocity of the encoder
    diagnostic_Encoder.AngularVelocity_Sigma    = default_value.AngularVelocity_Sigma;
    % Event functions
    diagnostic_Encoder.EventFunctions = {}; % These are the functions to determine if something went wrong
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