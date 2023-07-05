function NTRIP_data_structure = fcn_DataClean_loadRawDataFromFile_NTRIP(file_path,datatype,fid)

%% History
% Created by Xinyu Cao on 6/20/2023

%% Function 
% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Sparkfun GPS (format:struct)
%      data_source = mat_file
% Returned Results:
%      Sparkfun_rear_left

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
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

if strcmp(datatype,'ntrip')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    Npoints = height(datatable);
    NTRIP_data_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    secs = datatable.secs;
    nsecs = datatable.nsecs;

    NTRIP_data_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % NTRIP_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    NTRIP_data_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
    NTRIP_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    NTRIP_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
    % NTRIP_data_structure.RTCM_Type          = default_value;  % This is the type of the RTCM correction data that was used.
    NTRIP_data_structure.BaseStationID      = datatable.BaseStationID;  % Base station that was used for correction
    NTRIP_data_structure.NTRIP_Status       = datatable.NTRIP_Connection;  % The status of NTRIP connection (Ture, conencted, False, disconencted)
    % Event functions
    % NTRIP_data_structure.EventFunctions = {}; % These are the functions to determine if something went wrong

else
    error('Wrong data type requested: %s',dataType)
end

% Close out the loading process
if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end
