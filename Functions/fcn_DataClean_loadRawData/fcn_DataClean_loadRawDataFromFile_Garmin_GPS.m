
function GPS_Garmin = fcn_DataClean_loadRawDataFromFile_Garmin_GPS(file_path,datatype,flag_do_debug)

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


if strcmp(datatype,'gps')

    
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);

    GPS_Garmin = fcn_DataClean_initializeDataByType(datatype);

    % GPS_Garmin.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
    % GPS_Garmin.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    % GPS_Garmin.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
    % GPS_Garmin.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    % GPS_Garmin.Npoints            = default_value;  % This is the number of data points in the array
    % GPS_Garmin.Latitude           = default_value;  % The latitude [deg]
    % GPS_Garmin.Longitude          = default_value;  % The longitude [deg]
    % GPS_Garmin.Altitude           = default_value;  % The altitude above sea level [m]
    % GPS_Garmin.xEast              = default_value;  % The xEast value (ENU) [m]
    % GPS_Garmin.xEast_Sigma        = default_value;  % Sigma in xEast [m]
    % GPS_Garmin.yNorth             = default_value;  % The yNorth value (ENU) [m]
    % GPS_Garmin.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
    % GPS_Garmin.zUp                = default_value;  % The zUp value (ENU) [m]
    % GPS_Garmin.zUp_Sigma          = default_value;  % Sigma in zUp [m]
    % GPS_Garmin.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
    % GPS_Garmin.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
    % GPS_Garmin.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
    % GPS_Garmin.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
    % GPS_Garmin.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
    % GPS_Garmin.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
    % GPS_Garmin.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s]
    % GPS_Garmin.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
    % GPS_Garmin.numSatellites      = default_value;  % Number of satelites visible
    % GPS_Garmin.DGPS_mode          = default_value;  % Mode indicating DGPS status (for example, navmode 6;
    % GPS_Garmin.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
    % GPS_Garmin.Roll_deg_Sigma     = default_value;  % Sigma in Roll
    % GPS_Garmin.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
    % GPS_Garmin.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
    % GPS_Garmin.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
    % GPS_Garmin.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
    % GPS_Garmin.OneSigmaPos        = default_value;  % Sigma in position
    % GPS_Garmin.HDOP                = default_value; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
    % GPS_Garmin.AgeOfDiff          = default_value;  % Age of correction data [s]
    % % Event functions
    % GPS_Garmin.EventFunctions = {}; % These are the functions to determine if something went wrong
    % 

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
