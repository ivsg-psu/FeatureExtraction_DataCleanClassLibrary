%% History
% Created by Mariam Abdellatief on 6/14/2023

%% Function 
% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Sparkfun GPS (format:struct)
%      data_source = mat_file
% Returned Results:
%      Sparkfun_rear_diag_left

function Sparkfun_rear_diag_right = fcn_DataClean_loadRawData_Sparkfun_GPS_rear_diag_right(data_structure,data_source)

if strcmp(data_source,'mat_file')
    Sparkfun_rear_right.rosbagTimestamp  = data_structure.Time';
    Sparkfun_rear_right.GPS_Time         = data_structure.GPSTimeOfWeek';
    Sparkfun_rear_right.nsecs            = data_structure.nanoSeconds; 
    Sparkfun_rear_right.frame_id         = data_structure.id';
    Sparkfun_rear_right.LockStatus       = data_structure.LockStatus';
    Sparkfun_rear_right.NumOfStats       = data_structure.NumOfStats';
    Sparkfun_rear_right.HDOP             = data_structure.HDOP';
    Sparkfun_rear_right.AgeOfDiff        = data_structure.AgeOfDiff';
    Sparkfun_rear_right.BaseStationID    = data_structure.BaseStationID';
    Sparkfun_rear_right.NTRIP_Status     = data_structure.NTRIP_Status';
    Sparkfun_rear_right.MessageDisplay   = data_structure.MessageDisplay';
else
    error('Please upload data structure in ".mat" format')
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