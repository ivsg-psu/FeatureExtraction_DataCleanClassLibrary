function SparkFun_GPS_data_structure = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(file_path,datatype,flag_do_debug)

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



if strcmp(datatype,'gps')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    Npoints = height(datatable);
    SparkFun_GPS_data_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    secs = datatable.GPSSecs; % For data collected after 2023-06-06, new fields GPSSecs are added
    microsecs = datatable.GPSMicroSecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added
    
    SparkFun_GPS_data_structure.GPS_Time           = secs + microsecs*10^-6;  % This is the GPS time, UTC, as reported by the unit
    % SparkFun_GPS_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    SparkFun_GPS_data_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
    SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    SparkFun_GPS_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
    SparkFun_GPS_data_structure.Latitude           = datatable.Latitude;  % The latitude [deg]
    SparkFun_GPS_data_structure.Longitude          = datatable.Longitude;  % The longitude [deg]
    SparkFun_GPS_data_structure.Altitude           = datatable.Altitude;  % The altitude above sea level [m]

    % SparkFun_GPS_data_structure.xEast = default_value;
    % SparkFun_GPS_data_structure.xEast_Sigma        = default_value;  % Sigma in xEast [m]
    % SparkFun_GPS_data_structure.yNorth = default_value;
    % SparkFun_GPS_data_structure.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
    % SparkFun_GPS_data_structure.zUp = default_value;
    % SparkFun_GPS_data_structure.zUp_Sigma          = default_value;  % Sigma in zUp [m]

    % SparkFun_GPS_data_structure.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
    % SparkFun_GPS_data_structure.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
    % SparkFun_GPS_data_structure.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
    % SparkFun_GPS_data_structure.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
    % SparkFun_GPS_data_structure.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
    % SparkFun_GPS_data_structure.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
    % SparkFun_GPS_data_structure.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s]
    % SparkFun_GPS_data_structure.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
    SparkFun_GPS_data_structure.numSatellites      = datatable.NumOfSats;  % Number of satelites visible
    SparkFun_GPS_data_structure.DGPS_mode          = datatable.LockStatus;  % Mode indicating DGPS status (for example, navmode 6;
    % SparkFun_GPS_data_structure.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
    % SparkFun_GPS_data_structure.Roll_deg_Sigma     = default_value;  % Sigma in Roll
    % SparkFun_GPS_data_structure.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
    % SparkFun_GPS_data_structure.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
    % SparkFun_GPS_data_structure.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
    % SparkFun_GPS_data_structure.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
    % SparkFun_GPS_data_structure.OneSigmaPos        = default_value;  % Sigma in position
    SparkFun_GPS_data_structure.HDOP               = datatable.HDOP; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
    SparkFun_GPS_data_structure.AgeOfDiff          = datatable.AgeOfDiff;  % Age of correction data [s]
    % Event functions
    % dataStructure.EventFunctions = {}; % These are the functions to determine if something went wrong
     %rawdata.SparkFun_GPS_RearLeft = SparkFun_GPS_RearLeft;

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