function parseEncoder = fcn_DataClean_loadRawDataFromFile_parse_Encoder(file_path,datatype,fid)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the parse Encoder data, whose data type is encoder
% Input Variables:
%      file_path = file path of the parse encoder data
%      datatype  = the datatype should be encoder
% Returned Results:
%      parseEncoder

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
% 2024_11_21 xfc5113@psu.edu
% -- change field "Mode" to "mode" to match Trigger_Box fields
% 2024-11-29 by X. Cao
% -- renamed 'ROS_Time' to 'Bag_Time' and the 'Header_Time' was
%   renamed to 'ROS_Time'

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


if strcmp(datatype,'encoder')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    Npoints = height(datatable);
    parseEncoder = fcn_DataClean_initializeDataByType(datatype);
    time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp

    parseEncoder.Bag_Time           = time_stamp;  % This is the ROS time that the data arrived into the bag
    parseEncoder.centiSeconds       = 1;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    header_time_secs = datatable.secs;
    header_time_nsecs = datatable.nsecs;
    header_time = header_time_secs + header_time_nsecs*(1E-9);
    parseEncoder.ROS_Time = header_time;
    parseEncoder.Npoints            = Npoints;  % This is the number of data points in the array
    % parseEncoder.CountsPerRev       = default_value;  % How many counts are in each revolution of the encoder (with quadrature)
    parseEncoder.C1Counts             = datatable.C1;  % A vector of the counts measured by the encoder, Npoints long
    parseEncoder.C2Counts             = datatable.C2;   % A vector of the counts measured by the encoder, Npoints long
    % parseEncoder.DeltaCounts        = default_value;  % A vector of the change in counts measured by the encoder, with first value of zero, Npoints long
    % parseEncoder.LastIndexCount     = default_value;  % Count at which last index pulse was detected, Npoints long
    % parseEncoder.AngularVelocity    = default_value;  % Angular velocity of the encoder
    % parseEncoder.AngularVelocity_Sigma    = default_value; 
    parseEncoder.mode = string(erase((datatable.mode),"""")); % A vector of the mode of the encoder box, T indicaes triggered.

else
    error('Wrong data type requested: %s',dataType)
end



% Close out the loading process
if flag_do_debug
    fprintf(fid,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end
