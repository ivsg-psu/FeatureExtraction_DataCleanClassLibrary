%% History
% Created by Mariam Abdellatief on 6/14/2023

%% Function 
% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Sparkfun GPS (format:struct)
%      data_source = mat_file
% Returned Results:
%      Sparkfun_rear_right

function Sparkfun_rear_right = fcn_DataClean_loadRawData_Sparkfun_GPS_rear_right(data_structure,data_source)

if strcmp(data_source,'mat_file')
    Sparkfun_rear_right.rosbagTimestamp  = data_structure.Time';
    Sparkfun_rear_right.nsecs            = data_structure.nanoSeconds; 
    Sparkfun_rear_right.frame_id         = data_structure.id';
    Sparkfun_rear_right.MessageID        = data_structure.MessageID';
    Sparkfun_rear_right.Latitude         = data_structure.Latitude';
    Sparkfun_rear_right.Longitude        = data_structure.Longitude';
    Sparkfun_rear_right.Altitude         = data_structure.Altitude';
    Sparkfun_rear_right.NavMode          = data_structure.NavMode';
    Sparkfun_rear_right.NumOfStats       = data_structure.NumOfStats';
    Sparkfun_rear_right.HDOP             = data_structure.HDOP';
    Sparkfun_rear_right.AgeOfDiff        = data_structure.AgeOfDiff';
    Sparkfun_rear_right.TrueTrack        = data_structure.TrueTrack';
    Sparkfun_rear_right.MagTrack         = data_structure.MagTrack';
    Sparkfun_rear_right.SpdOverGrndKnots = data_structure.SpdOverGrndKnots';
    Sparkfun_rear_right.SpdOverGrndKmph  = data_structure.SpdOverGrndKmph';
    Sparkfun_rear_right.LockStatus       = data_structure.LockStatus';
    Sparkfun_rear_right.BaseStationID    = data_structure.BaseStationID';
    Sparkfun_rear_right.StdMajor         = data_structure.StdMajor';
    Sparkfun_rear_right.StdMinor         = data_structure.StdMinor';
    Sparkfun_rear_right.StdLat           = data_structure.StdLat';
    Sparkfun_rear_right.StdLon           = data_structure.StdLon';
    Sparkfun_rear_right.StdAlt           = data_structure.StdAlt';

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