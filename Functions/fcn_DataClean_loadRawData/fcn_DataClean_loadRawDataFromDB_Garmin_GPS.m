function GPS_Garmin = fcn_DataClean_loadRawDataFromDB_Garmin_GPS(field_data_struct,datatype,fid)

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

% UPDATES:
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
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


if strcmp(datatype,'gps')
    GPS_Garmin = fcn_DataClean_initializeDataByType(datatype);
    if isempty(field_data_struct.id)
        warning('Garmin GPS table is empty!')
    else
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
    end

else
    error('Wrong data type requested: %s',dataType)
end

% Close out the loading process
if flag_do_debug
    fprintf(fid,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end
end