function GPS_Novatel = fcn_DataClean_loadRawDataFromFile_Novatel_GPS(file_path,datatype,table,flag_do_debug)
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
% Modified by Aneesh Batchu and Mariam Abdellatief on 2023_06_13
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

if contains(file_path,'GPS_Novatel')
    % % Note: the Novatel and Hemisphere are almost perfectly time aligned, if
    % % dropping the first data point in Novatel (uncomment the following to
    % % see)
    % Hemisphere.GPS_Time(1,1)
    % % ans =
    % %           242007.249999977
    % d.Seconds(1,2)
    % % ans =
    % %              242007.248687
    % % This is why all the vectors below start at 2, not 1
%     GPS_Novatel.ROS_Time       = d.Time(2:end)';
%     GPS_Novatel.GPS_Time       = d.Seconds(2:end)';
%     GPS_Novatel.centiSeconds   = 5; % This is sampled every 5 ms
%     
%     GPS_Novatel.Npoints        = length(GPS_Novatel.ROS_Time(:,1));
%     GPS_Novatel.EmptyVector    = fcn_DataClean_fillEmptyStructureVector(GPS_Novatel); % Fill in empty vector (this is useful later)
%     
%     GPS_Novatel.Latitude       = d.Latitude(2:end)';
%     GPS_Novatel.Longitude      = d.Longitude(2:end)';
%     GPS_Novatel.Altitude       = d.Height(2:end)';
%     GPS_Novatel.xEast          = d.xEast(2:end)';
%     GPS_Novatel.yNorth         = d.yNorth(2:end)';
%     GPS_Novatel.zUp            = d.zUp(2:end)';
%     GPS_Novatel.velNorth       = d.NorthVelocity(2:end)';
%     GPS_Novatel.velEast        = d.EastVelocity(2:end)';
%     GPS_Novatel.velUp          = d.UpVelocity(2:end)';
%     GPS_Novatel.velMagnitude   = sqrt(d.NorthVelocity(2:end)'.^2+d.EastVelocity(2:end)'.^2);
%     GPS_Novatel.velMagnitude_Sigma = std(diff(GPS_Novatel.velMagnitude))*ones(length(GPS_Novatel.velMagnitude(:,1)),1);
%     GPS_Novatel.DGPS_is_active = zeros(GPS_Novatel.Npoints,1);
%     GPS_Novatel.numSatellites  = GPS_Novatel.EmptyVector;
%     GPS_Novatel.navMode        = GPS_Novatel.EmptyVector;
%     GPS_Novatel.Roll_deg       = d.Roll(2:end)';
%     GPS_Novatel.Pitch_deg      = d.Pitch(2:end)';
%     GPS_Novatel.Yaw_deg        = -d.Azimuth(2:end)'+360+90; % Notice sign flip and phase shift due to coord convention and mounting
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


secs = table.secs;
            nsecs = table.secs;
            

            GPS_Novatel = fcn_DataClean_initializeDataByType(datatype);

            % GPS_Novatel.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
            % GPS_Novatel.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            % GPS_Novatel.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
            % GPS_Novatel.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            % GPS_Novatel.Npoints            = default_value;  % This is the number of data points in the array
            % GPS_Novatel.Latitude           = default_value;  % The latitude [deg]
            % GPS_Novatel.Longitude          = default_value;  % The longitude [deg]
            % GPS_Novatel.Altitude           = default_value;  % The altitude above sea level [m]
            % GPS_Novatel.xEast              = default_value;  % The xEast value (ENU) [m]
            % GPS_Novatel.xEast_Sigma        = default_value;  % Sigma in xEast [m]
            % GPS_Novatel.yNorth             = default_value;  % The yNorth value (ENU) [m]
            % GPS_Novatel.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
            % GPS_Novatel.zUp                = default_value;  % The zUp value (ENU) [m]
            % GPS_Novatel.zUp_Sigma          = default_value;  % Sigma in zUp [m]
            % GPS_Novatel.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
            % GPS_Novatel.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
            % GPS_Novatel.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
            % GPS_Novatel.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
            % GPS_Novatel.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
            % GPS_Novatel.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
            % GPS_Novatel.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s] 
            % GPS_Novatel.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
            % GPS_Novatel.numSatellites      = default_value;  % Number of satelites visible 
            % GPS_Novatel.DGPS_mode          = default_value;  % Mode indicating DGPS status (for example, navmode 6;
            % GPS_Novatel.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
            % GPS_Novatel.Roll_deg_Sigma     = default_value;  % Sigma in Roll
            % GPS_Novatel.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
            % GPS_Novatel.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
            % GPS_Novatel.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
            % GPS_Novatel.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
            % GPS_Novatel.OneSigmaPos        = default_value;  % Sigma in position 
            % GPS_Novatel.HDOP                = default_value; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
            % GPS_Novatel.AgeOfDiff          = default_value;  % Age of correction data [s]
            
            
else
    error('Please indicate the data source')
end


clear d %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
