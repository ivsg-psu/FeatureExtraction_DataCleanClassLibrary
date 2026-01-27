function Hemisphere_DGPS = fcn_DataClean_loadRawDataFromDB_Hemisphere(field_data_struct,datatype,fid)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere GPS data, whose data type is gps

% Input Variables:
%      file_path = file path of the Sick Lidar data (format txt)
%      datatype  = the datatype should be lidar2d
% Returned Results:
%      Hemisphere_DGPS
% Author: Liming Gao

% Created Date: 2020_11_15

% Revisions:
% 2023_06_16 by Xinyu Cao, Aneesh Batchu and Mariam Abdellatief
% -- Edited for new GPS systems (Sparkfun)
% 2023_06_25 by Sean Brennan
% -- Fixed centiSeconds to 5, not 10, to agree with the data.
% 2023_07_04 sbrennan@psu.edu
% -- fixed return at end of function to be 'end', keeping in function
% format
% -- added fid to fprint to allow printing to file

% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 
% Reference:
% To be added


flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


%%

% the field name from mat_file is different from database, so we process
% them seperately
% Unknown value are remained as default_value = NaN


if strcmp(datatype,'gps')
    Hemisphere_DGPS = fcn_DataClean_initializeDataByType(datatype);
    if (isempty(field_data_struct.id))
        warning('Hemisphere GPS table empty!')
    else 
        secs = field_data_struct.seconds;
        nsecs = field_data_struct.nanoseconds;
        Hemisphere_DGPS.StdDevResid = field_data_struct.stddevresid;
        Hemisphere_DGPS.GPS_Time           = secs+nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
        % data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        Hemisphere_DGPS.ROS_Time           = field_data_struct.time;  % This is the ROS time that the data arrived into the bag
        Hemisphere_DGPS.centiSeconds       = 5;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        Hemisphere_DGPS.Npoints            = length(field_data_struct.id);  % This is the number of data points in the array
        Hemisphere_DGPS.Latitude           = field_data_struct.latitude;  % The latitude [deg]
        Hemisphere_DGPS.Longitude          = field_data_struct.longitude;  % The longitude [deg]
        Hemisphere_DGPS.Altitude           = field_data_struct.altitude;  % The altitude above sea level [m]
        % Hemisphere_DGPS_LLA = [data_structure.Latitude, data_structure.Longitude, data_structure.Altitude];
        % Hemisphere_DGPS_xyz = lla2enu(Hemisphere_DGPS_LLA,TestTrack_base_lla, 'ellipsoid');
        % Hemisphere_DGPS.xEast              = default_value;  % The xEast value (ENU) [m]
        % Hemisphere_DGPS.xEast_Sigma        = default_value;  % Sigma in xEast [m]
        % Hemisphere_DGPS.yNorth             = default_value;  % The yNorth value (ENU) [m]
        % Hemisphere_DGPS.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
        % Hemisphere_DGPS.zUp                = default_value;  % The zUp value (ENU) [m]
        % Hemisphere_DGPS.zUp_Sigma          = default_value;  % Sigma in zUp [m]
        Hemisphere_DGPS.velNorth           = field_data_struct.vnorth;  % Velocity in north direction (ENU) [m/s]
        % Hemisphere_DGPS.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
        Hemisphere_DGPS.velEast            = field_data_struct.veast;  % Velocity in east direction (ENU) [m/s]
        % Hemisphere_DGPS.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
        Hemisphere_DGPS.velUp              = field_data_struct.vup;  % Velocity in up direction (ENU) [m/s]
        % Hemisphere_DGPS.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
        % Hemisphere_DGPS.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s]
        % Hemisphere_DGPS.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
        Hemisphere_DGPS.numSatellites      = field_data_struct.numofsats;  % Number of satelites visible
        Hemisphere_DGPS.DGPS_mode          = field_data_struct.navmode;  % Mode indicating DGPS status (for example, navmode 6;
        % Hemisphere_DGPS.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
        % Hemisphere_DGPS.Roll_deg_Sigma     = default_value;  % Sigma in Roll
        % Hemisphere_DGPS.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
        % Hemisphere_DGPS.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
        % Hemisphere_DGPS.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
        % Hemisphere_DGPS.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
        % Hemisphere_DGPS.OneSigmaPos        = default_value;  % Sigma in position
        % Hemisphere_DGPS.HDOP                = default_value; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
        Hemisphere_DGPS.AgeOfDiff          = field_data_struct.ageofdiff;
    end
else
    error('Wrong data type requested: %s',dataType)
end

% Close out the loading process
if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end