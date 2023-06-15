%% History
% Created by Mariam Abdellatief on 6/14/2023

%% Function 
% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Sparkfun GPS (format:struct)
%      data_source = mat_file
% Returned Results:
%      Sparkfun_rear_left

function SparkFun_GPS_RearLeft = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS_rear_left(table,data_source)

if strcmp(data_source,'mat_file')
%     Sparkfun_rear_left.rosbagTimestamp  = data_structure.Time';
%     Sparkfun_rear_left.nsecs            = data_structure.nanoSeconds; 
%     Sparkfun_rear_left.frame_id         = data_structure.id';
%     Sparkfun_rear_left.MessageID        = data_structure.MessageID';
%     Sparkfun_rear_left.Latitude         = data_structure.Latitude';
%     Sparkfun_rear_left.Longitude        = data_structure.Longitude';
%     Sparkfun_rear_left.Altitude         = data_structure.Altitude';
%     Sparkfun_rear_left.NavMode          = data_structure.NavMode';
%     Sparkfun_rear_left.NumOfStats       = data_structure.NumOfStats';
%     Sparkfun_rear_left.HDOP             = data_structure.HDOP';
%     Sparkfun_rear_left.AgeOfDiff        = data_structure.AgeOfDiff';
%     Sparkfun_rear_left.TrueTrack        = data_structure.TrueTrack';
%     Sparkfun_rear_left.MagTrack         = data_structure.MagTrack';
%     Sparkfun_rear_left.SpdOverGrndKnots = data_structure.SpdOverGrndKnots';
%     Sparkfun_rear_left.SpdOverGrndKmph  = data_structure.SpdOverGrndKmph';
%     Sparkfun_rear_left.LockStatus       = data_structure.LockStatus';
%     Sparkfun_rear_left.BaseStationID    = data_structure.BaseStationID';
%     Sparkfun_rear_left.StdMajor         = data_structure.StdMajor';
%     Sparkfun_rear_left.StdMinor         = data_structure.StdMinor';
%     Sparkfun_rear_left.StdLat           = data_structure.StdLat';
%     Sparkfun_rear_left.StdLon           = data_structure.StdLon';
%     Sparkfun_rear_left.StdAlt           = data_structure.StdAlt';
%     dataStructure.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
%         dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
%         dataStructure.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
%         dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
%         dataStructure.Npoints            = default_value;  % This is the number of data points in the array
%         dataStructure.Latitude           = default_value;  % The latitude [deg]
%         dataStructure.Longitude          = default_value;  % The longitude [deg]
%         dataStructure.Altitude           = default_value;  % The altitude above sea level [m]
%         dataStructure.xEast              = default_value;  % The xEast value (ENU) [m]
%         dataStructure.xEast_Sigma        = default_value;  % Sigma in xEast [m]
%         dataStructure.yNorth             = default_value;  % The yNorth value (ENU) [m]
%         dataStructure.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
%         dataStructure.zUp                = default_value;  % The zUp value (ENU) [m]
%         dataStructure.zUp_Sigma          = default_value;  % Sigma in zUp [m]
%         dataStructure.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
%         dataStructure.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
%         dataStructure.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
%         dataStructure.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
%         dataStructure.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
%         dataStructure.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
%         dataStructure.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s] 
%         dataStructure.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
%         dataStructure.numSatellites      = default_value;  % Number of satelites visible 
%         dataStructure.DGPS_mode          = default_value;  % Mode indicating DGPS status (for example, navmode 6;
%         dataStructure.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
%         dataStructure.Roll_deg_Sigma     = default_value;  % Sigma in Roll
%         dataStructure.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
%         dataStructure.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
%         dataStructure.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
%         dataStructure.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
%         dataStructure.OneSigmaPos        = default_value;  % Sigma in position 
%         dataStructure.HDOP                = default_value; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
%         % Event functions
%         dataStructure.EventFunctions = {}; % These are the functions to determine if something went wrong

SparkFun_GPS_RearLeft = fcn_DataClean_initializeDataByType(datatype);
            secs = table.secs;
            nsecs = table.nsecs;

            SparkFun_GPS_RearLeft.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % SparkFun_GPS_RearLeft.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            SparkFun_GPS_RearLeft.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            SparkFun_GPS_RearLeft.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            SparkFun_GPS_RearLeft.Npoints            = height(table);  % This is the number of data points in the array
            SparkFun_GPS_RearLeft.Latitude           = table.Latitude;  % The latitude [deg]
            SparkFun_GPS_RearLeft.Longitude          = table.Longitude;  % The longitude [deg]
            SparkFun_GPS_RearLeft.Altitude           = table.Altitude;  % The altitude above sea level [m]
            SparkFun_GPS_RearLeft_LLA = [SparkFun_GPS_RearLeft.Latitude, SparkFun_GPS_RearLeft.Longitude, SparkFun_GPS_RearLeft.Altitude];
            SparkFun_GPS_RearLeft_xyz = lla2enu(SparkFun_GPS_RearLeft_LLA, TestTrack_base_lla,'ellipsoid');
             
            SparkFun_GPS_RearLeft.xEast = SparkFun_GPS_RearLeft_xyz(:,1);
            % SparkFun_GPS_RearLeft.xEast_Sigma        = default_value;  % Sigma in xEast [m]
            SparkFun_GPS_RearLeft.yNorth = SparkFun_GPS_RearLeft_xyz(:,2);
            % SparkFun_GPS_RearLeft.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
            SparkFun_GPS_RearLeft.zUp = SparkFun_GPS_RearLeft_xyz(:,3);
            % SparkFun_GPS_RearLeft.zUp_Sigma          = default_value;  % Sigma in zUp [m]

            % SparkFun_GPS_RearLeft.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
            % SparkFun_GPS_RearLeft.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
            % SparkFun_GPS_RearLeft.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
            % SparkFun_GPS_RearLeft.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
            % SparkFun_GPS_RearLeft.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
            % SparkFun_GPS_RearLeft.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
            % SparkFun_GPS_RearLeft.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s] 
            % SparkFun_GPS_RearLeft.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
            SparkFun_GPS_RearLeft.numSatellites      = table.NumOfSats;  % Number of satelites visible 
            SparkFun_GPS_RearLeft.DGPS_mode          = table.LockStatus;  % Mode indicating DGPS status (for example, navmode 6;
            % SparkFun_GPS_RearLeft.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
            % SparkFun_GPS_RearLeft.Roll_deg_Sigma     = default_value;  % Sigma in Roll
            % SparkFun_GPS_RearLeft.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
            % SparkFun_GPS_RearLeft.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
            % SparkFun_GPS_RearLeft.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
            % SparkFun_GPS_RearLeft.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
            % SparkFun_GPS_RearLeft.OneSigmaPos        = default_value;  % Sigma in position 
            SparkFun_GPS_RearLeft.HDOP               = table.HDOP; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
            SparkFun_GPS_RearLeft.AgeOfDiff          = table.AgeOfDiff;  % Age of correction data [s]

            %rawdata.SparkFun_GPS_RearLeft = SparkFun_GPS_RearLeft;

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