function NTRIP_data_structure = fcn_DataClean_loadRawDataFromFile_NTRIP(file_path,datatype,flag_do_debug)

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
    NTRIP_data_structure.EventFunctions = {}; % These are the functions to determine if something went wrong

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