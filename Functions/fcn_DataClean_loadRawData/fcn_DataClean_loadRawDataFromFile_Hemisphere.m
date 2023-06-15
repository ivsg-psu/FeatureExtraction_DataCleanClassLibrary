function Hemisphere_DGPS = fcn_DataClean_loadRawDataFromFile_Hemisphere(table,data_source,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Hemisphere DGPS(format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
% Returned Results:
%      Hemisphere
% Author: Liming Gao
% Created Date: 2020_11_15
% Modify Date: 2019_11_22
%
% Modified by Aneesh Batchu and Mariam Abdellatief on 2023_06_13
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 1. check if it is reasonable for the calcualtion of Hemisphere.velMagnitude_Sigma
% 
%%

% the field name from mat_file is different from database, so we process
% them seperately
if strcmp(data_source,'mat_file')
%     Hemisphere.ROS_Time         = data_structure.Time';
%     Hemisphere.GPS_Time         = data_structure.GPSTimeOfWeek';
%     Hemisphere.centiSeconds     = 5; % This is sampled every 5 ms
%     
%     Hemisphere.Npoints          = length(Hemisphere.ROS_Time(:,1));
%     Hemisphere.EmptyVector      = fcn_DataClean_fillEmptyStructureVector(Hemisphere); % Fill in empty vector (this is useful later)
%     
%     Hemisphere.Latitude         = data_structure.Latitude';
%     Hemisphere.Longitude        = data_structure.Longitude';
%     Hemisphere.Altitude         = data_structure.Height';
%     Hemisphere.xEast            = data_structure.xEast';
%     Hemisphere.yNorth           = data_structure.yNorth';
%     Hemisphere.zUp              = data_structure.zUp';
%     Hemisphere.velNorth         = data_structure.VNorth';
%     Hemisphere.velEast          = data_structure.VEast';
%     Hemisphere.velUp            = data_structure.VUp';
%     Hemisphere.velMagnitude     = sqrt(Hemisphere.velNorth.^2 + Hemisphere.velEast.^2 + Hemisphere.velUp.^2);
%     % for debugging - shows that the Hemisphere's velocity signal is horribly bad
%     % figure;plot(Hemisphere.ROS_Time-Hemisphere.ROS_Time(1,1),Hemisphere.velMagnitude);
%     % figure;plot(Hemisphere.ROS_Time-Hemisphere.ROS_Time(1,1),Hemisphere.velNorth);
%     % figure;plot(Hemisphere.ROS_Time-Hemisphere.ROS_Time(1,1),Hemisphere.velEast);
%     % figure;plot(Hemisphere.ROS_Time-Hemisphere.ROS_Time(1,1),Hemisphere.velUp);
%     
%     Hemisphere.velMagnitude_Sigma = std(Hemisphere.velMagnitude)*ones(length(Hemisphere.velMagnitude(:,1)),1);
%     %Hemisphere.numSatellites    = Hemisphere.EmptyVector;
%     Hemisphere.DGPS_is_active   = 1.00*(data_structure.NavMode==6)';
%     %Hemisphere.Roll_deg         = Hemisphere.EmptyVector;
%     %Hemisphere.Pitch_deg        = Hemisphere.EmptyVector;
%     %Hemisphere.Yaw_deg          = Hemisphere.EmptyVector;
%     %Hemisphere.Yaw_deg_Sigma    = Hemisphere.EmptyVector;
%     Hemisphere.OneSigmaPos      = data_structure.StdDevResid';
Hemisphere_DGPS = fcn_DataClean_initializeDataByType(datatype);
            secs = table.secs;
            nsecs = table.secs;
            % Hemisphere_DGPS.StdDevResid = table.StdDevResid;
            Hemisphere_DGPS.GPS_Time           = secs+nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % Hemisphere_DGPS.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            Hemisphere_DGPS.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            Hemisphere_DGPS.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            Hemisphere_DGPS.Npoints            = height(table);  % This is the number of data points in the array
            Hemisphere_DGPS.Latitude           = table.Latitude;  % The latitude [deg]
            Hemisphere_DGPS.Longitude          = table.Longitude;  % The longitude [deg]
            Hemisphere_DGPS.Altitude           = table.Height;  % The altitude above sea level [m]
            Hemisphere_DGPS_LLA = [Hemisphere_DGPS.Latitude, Hemisphere_DGPS.Longitude, Hemisphere_DGPS.Altitude];
            Hemisphere_DGPS_xyz = lla2enu(Hemisphere_DGPS_LLA,TestTrack_base_lla, 'ellipsoid');
            Hemisphere_DGPS.xEast              = Hemisphere_DGPS_xyz(:,1);  % The xEast value (ENU) [m]
            % Hemisphere_DGPS.xEast_Sigma        = default_value;  % Sigma in xEast [m]
            Hemisphere_DGPS.yNorth             = Hemisphere_DGPS_xyz(:,2);  % The yNorth value (ENU) [m]
            % Hemisphere_DGPS.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
            Hemisphere_DGPS.zUp                = Hemisphere_DGPS_xyz(:,3);  % The zUp value (ENU) [m]
            % Hemisphere_DGPS.zUp_Sigma          = default_value;  % Sigma in zUp [m]
            Hemisphere_DGPS.velNorth           = table.VNorth;  % Velocity in north direction (ENU) [m/s]
            % Hemisphere_DGPS.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
            Hemisphere_DGPS.velEast            = table.VEast;  % Velocity in east direction (ENU) [m/s]
            % Hemisphere_DGPS.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
            Hemisphere_DGPS.velUp              = table.VUp;  % Velocity in up direction (ENU) [m/s]
            % Hemisphere_DGPS.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
            Hemisphere_DGPS.velMagnitude       = sqrt(Hemisphere_DGPS.velNorth.^2 + Hemisphere_DGPS.velEast.^2 + Hemisphere_DGPS.velUp.^2);  % Velocity magnitude (ENU) [m/s] 
            % Hemisphere_DGPS.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
            Hemisphere_DGPS.numSatellites      = table.NumOfSats;  % Number of satelites visible 
            Hemisphere_DGPS.DGPS_mode          = table.NavMode;  % Mode indicating DGPS status (for example, navmode 6;
            % Hemisphere_DGPS.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
            % Hemisphere_DGPS.Roll_deg_Sigma     = default_value;  % Sigma in Roll
            % Hemisphere_DGPS.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
            % Hemisphere_DGPS.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
            % Hemisphere_DGPS.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
            % Hemisphere_DGPS.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
            % Hemisphere_DGPS.OneSigmaPos        = default_value;  % Sigma in position 
            % Hemisphere_DGPS.HDOP                = default_value; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
            Hemisphere_DGPS.AgeOfDiff          = table.AgeOfDiff;

            rawdata.Hemisphere_DGPS = Hemisphere_DGPS;
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