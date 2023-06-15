function GPS_Garmin = fcn_DataClean_loadRawDataFromFile_Garmin_GPS(table,data_source,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the GPS_Novatel data
% Input Variables:
%      d = raw data from GPS_Garmin(format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
% Returned Results:
%      GPS_Garmin
% Author: Liming Gao
% Created Date: 2020_12_07
%
% Modified by Aneesh Batchu and Mariam Abdellatief on 2023_06_13
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 1.
%
%

%%

if strcmp(data_source,'mat_file')
%     GPS_Garmin.ROS_Time       = d.Time';
%     GPS_Garmin.centiSeconds  = 4; % This is sampled every 4 ms
% 
%     GPS_Garmin.Npoints        = length(GPS_Garmin.ROS_Time(:,1));
%     deltaTSample              = mean(diff(GPS_Garmin.ROS_Time));
%     GPS_Garmin.EmptyVector    = fcn_DataClean_fillEmptyStructureVector(GPS_Garmin); % Fill in empty vector (this is useful later)
% 
%     %GPS_Garmin.GPS_Time       = d.Time'*NaN;
%     GPS_Garmin.Latitude       = d.Latitude';
%     GPS_Garmin.Longitude      = d.Longitude';
%     GPS_Garmin.Altitude       = d.Height';
%     GPS_Garmin.xEast          = d.xEast';
%     GPS_Garmin.yNorth         = d.yNorth';
%     GPS_Garmin.zUp            = d.zUp';
%     GPS_Garmin.velNorth       = [0; diff(GPS_Garmin.yNorth)]/deltaTSample;
%     GPS_Garmin.velEast        = [0; diff(GPS_Garmin.xEast)]/deltaTSample;
%     GPS_Garmin.velUp          = [0; diff(GPS_Garmin.zUp)]/deltaTSample;
%     GPS_Garmin.velMagnitude   = sqrt(GPS_Garmin.velNorth.^2+GPS_Garmin.velEast.^2);
%     % GPS_Garmin.numSatellites  = GPS_Garmin.EmptyVector;
%     % GPS_Garmin.navMode        = GPS_Garmin.EmptyVector;
%     % GPS_Garmin.Roll_deg       = GPS_Garmin.EmptyVector;
%     % GPS_Garmin.Pitch_deg      = GPS_Garmin.EmptyVector;
%     % GPS_Garmin.Yaw_deg        = GPS_Garmin.EmptyVector;
%     % GPS_Garmin.Yaw_deg_Sigma  = GPS_Garmin.EmptyVector;
    
    secs = table.secs;
            nsecs = table.secs;
     
            Garmin_GPS = fcn_DataClean_initializeDataByType(datatype);
            % 
            % Garmin_GPS.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
            % Garmin_GPS.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            % Garmin_GPS.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
            % Garmin_GPS.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            % Garmin_GPS.Npoints            = default_value;  % This is the number of data points in the array
            % Garmin_GPS.Latitude           = default_value;  % The latitude [deg]
            % Garmin_GPS.Longitude          = default_value;  % The longitude [deg]
            % Garmin_GPS.Altitude           = default_value;  % The altitude above sea level [m]
            % Garmin_GPS.xEast              = default_value;  % The xEast value (ENU) [m]
            % Garmin_GPS.xEast_Sigma        = default_value;  % Sigma in xEast [m]
            % Garmin_GPS.yNorth             = default_value;  % The yNorth value (ENU) [m]
            % Garmin_GPS.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
            % Garmin_GPS.zUp                = default_value;  % The zUp value (ENU) [m]
            % Garmin_GPS.zUp_Sigma          = default_value;  % Sigma in zUp [m]
            % Garmin_GPS.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
            % Garmin_GPS.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
            % Garmin_GPS.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
            % Garmin_GPS.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
            % Garmin_GPS.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
            % Garmin_GPS.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
            % Garmin_GPS.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s] 
            % Garmin_GPS.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
            % Garmin_GPS.numSatellites      = default_value;  % Number of satelites visible 
            % Garmin_GPS.DGPS_mode          = default_value;  % Mode indicating DGPS status (for example, navmode 6;
            % Garmin_GPS.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
            % Garmin_GPS.Roll_deg_Sigma     = default_value;  % Sigma in Roll
            % Garmin_GPS.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
            % Garmin_GPS.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
            % Garmin_GPS.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
            % Garmin_GPS.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
            % Garmin_GPS.OneSigmaPos        = default_value;  % Sigma in position 
            % Garmin_GPS.HDOP                = default_value; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
            % Garmin_GPS.AgeOfDiff          = default_value;  % Age of correction data [s]
            rawdata.Garmin_GPS = Garmin_GPS;

else
    error('Please indicate the data source')
end


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
