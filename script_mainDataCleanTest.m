%% Prep the workspace
close all
clc
clear all

%%
addpath(genpath('Data')); % add the data path
addpath(genpath('Functions')); % add the function path
addpath '.'/Utilities/ % add the Utilities path
%% Dependencies and Setup of the Code
% The code requires several other libraries to work, namely the following
% * DebugTools - the repo can be found at: https://github.com/ivsg-psu/Errata_Tutorials_DebugTools
% * PathClassLibrary - the repo can be found at: https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary
% * Database - this is a zip of a single file containing the Database class
% * GPS - this is a zip of a single file containing the GPS class
% * Map - this is a zip of a single file containing the Map class
% * MapDatabase - this is a zip of a single file containing the MapDatabase class
%
% The section below installs dependencies in a folder called "Utilities"
% under the root folder, namely ./Utilities/DebugTools/ ,
% ./Utilities/PathClassLibrary/ . If you wish to put these codes in
% different directories, the function below can be easily modified with
% strings specifying the different location.

% List what libraries we need, and where to find the codes for each
clear library_name library_folders library_url

ith_library = 1;
library_name{ith_library}    = 'DebugTools_v2023_04_22';
library_folders{ith_library} = {'Functions','Data'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/archive/refs/tags/DebugTools_v2023_04_22.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'PathClass_v2023_02_01';
library_folders{ith_library} = {'Functions'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary/blob/main/Releases/PathClass_v2023_02_01.zip?raw=true';

ith_library = ith_library+1;
library_name{ith_library}    = 'GPSClass_v2023_04_21';
library_folders{ith_library} = {'Functions'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/FieldDataCollection_GPSRelatedCodes_GPSClass/archive/refs/tags/GPSClass_v2023_04_21.zip';


% %% Clear paths and folders, if needed
% if 1==0
% 
%     fcn_INTERNAL_clearUtilitiesFromPathAndFolders;
% 
% end
% 
% %% Do we need to set up the work space?
% if ~exist('flag_DataClean_Folders_Initialized','var')
%     this_project_folders = {'Functions','Data'};
%     fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders);
%     flag_DataClean_Folders_Initialized = 1;
% end
%%
data_folder = "D:\GIT Files\FeatureExtraction_DataCleanClassLibrary\Data\";
bagname = "mapping_van_2023-06-05-1Lap";
folder_path = data_folder + bagname + "\"
addpath(folder_path)
file_list = dir(folder_path);
num_files = length(file_list);
TestTrack_base_lla = [40.86368573, -77.83592832, 344.189];
flag_do_debug = 0;
count_notused = 1;
rawdata = struct;
for file_idx = 3:num_files
    file_name = file_list(file_idx).name;
    file_name_noext = extractBefore(file_name,'.'); 
    topic_name = strrep(file_name_noext,'_slash_','/')
    datatype = fcn_DataClean_determineDataType(topic_name);
    
    topic_name_noslash = extractAfter(topic_name,'/');
    file_path = folder_path + file_name;
    opts = detectImportOptions(file_path);
    if contains(topic_name,'sick_lms500/scan')
        % 
        sick_lidar_data = readmatrix(file_path, opts);
        SickLiDAR = fcn_DataClean_initializeDataByType(datatype);
        secs = sick_lidar_data(:,2);
        nsecs = sick_lidar_data(:,3);
        SickLiDAR.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
        % SickLiDAR.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        SickLiDAR.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
        % SickLiDAR.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        SickLiDAR.Npoints            = length(secs);  % This is the number of data points in the array
        SickLiDAR.angle_min          = sick_lidar_data(:,4);  % This is the start angle of scan [rad]
        SickLiDAR.angle_max          = sick_lidar_data(:,5);  % This is the end angle of scan [rad]
        SickLiDAR.angle_increment    = sick_lidar_data(:,6);  % This is the angle increment between each measurements [rad]
        SickLiDAR.time_increment     = sick_lidar_data(:,7);  % This is the time increment between each measurements [s]
        SickLiDAR.scan_time          = sick_lidar_data(:,8);  % This is the time between scans [s]
        SickLiDAR.range_min          = sick_lidar_data(:,9);  % This is the minimum range value [m]
        SickLiDAR.range_max          = sick_lidar_data(:,10);  % This is the maximum range value [m]
        SickLiDAR.ranges             = sick_lidar_data(:,11:1151);  % This is the range data of scans [m]
        SickLiDAR.intensities        = sick_lidar_data(:,1152:2292);  % This is the intensities data of scans (Ranging from 0 to 255)
        SickLiDAR = fcn_DataClean_loadRawDataFromFile_sickLIDAR(file_path,datatype,flag_do_debug);
        rawdata.SickLiDAR = SickLiDAR;

    else
        opts = detectImportOptions(file_path);
        opts.PreserveVariableNames = true;
        table = readtable(file_path,opts);
        if contains(topic_name, 'Bin1')
            Hemisphere_DGPS = fcn_DataClean_initializeDataByType(datatype);
            secs = table.secs;
            nsecs = table.secs;
            % Hemisphere_DGPS.StdDevResid = table.StdDevResid;
            Hemisphere_DGPS.GPS_Time           = secs+nsecs*10^-9;;  % This is the GPS time, UTC, as reported by the unit
            % Hemisphere_DGPS.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            Hemisphere_DGPS.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            Hemisphere_DGPS.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            Hemisphere_DGPS.Npoints            = height(table);  % This is the number of data points in the array
            Hemisphere_DGPS.Latitude           = table.Latitude;  % The latitude [deg]
            Hemisphere_DGPS.Longitude          = table.Longitude;  % The longitude [deg]
            Hemisphere_DGPS.Altitude           = table.Height;  % The altitude above sea level [m]
            % Hemisphere_DGPS_LLA = [Hemisphere_DGPS.Latitude, Hemisphere_DGPS.Longitude, Hemisphere_DGPS.Altitude];
            % Hemisphere_DGPS_xyz = lla2enu(Hemisphere_DGPS_LLA,TestTrack_base_lla, 'ellipsoid');
            % Hemisphere_DGPS.xEast              = default_value;  % The xEast value (ENU) [m]
            % Hemisphere_DGPS.xEast_Sigma        = default_value;  % Sigma in xEast [m]
            % Hemisphere_DGPS.yNorth             = default_value;  % The yNorth value (ENU) [m]
            % Hemisphere_DGPS.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
            % Hemisphere_DGPS.zUp                = default_value;  % The zUp value (ENU) [m]
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
        elseif contains(topic_name, 'GPS_Novatel')
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
            rawdata.GPS_Novatel = GPS_Novatel;
    
        elseif contains(topic_name, 'Garmin_GPS')
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
        elseif contains(topic_name, 'Novatel_IMU')
    
            secs = table.secs;
            nsecs = table.secs;
            Novatel_IMU = fcn_DataClean_initializeDataByType(datatype);
            % Novatel_IMU.Time = secs+nsecs*10^-9;
            % Novatel_IMU.centiSeconds = '';
            % Novatel_IMU.XAccel = table.x;
            % Novatel_IMU.YAccel = table.y;
            % Novatel_IMU.ZAccel = table.z;
            % Novatel_IMU.XGyro = table.x_1;
            % Novatel_IMU.YGyro = table.y_2;
            % Novatel_IMU.ZGyro = table.z_2;
            % Novatel_IMU.ROSTime = table.rosbagTimestamp;
            rawdata.Novatel_IMU = Novatel_IMU;
    
        elseif contains(topic_name, 'Encoder')
            
            secs = table.secs;
            nsecs = table.secs;
            Raw_Encoder = fcn_DataClean_initializeDataByType(datatype);
            Raw_Encoder.GPS_Time         = secs + nsecs * 10^-9;  % This is the GPS time, UTC, as reported by the unit
            % Raw_Encoder.Trigger_Time         = default_value;  % This is the Trigger time, UTC, as calculated by sample
            Raw_Encoder.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % Raw_Encoder.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            Raw_Encoder.Npoints            = height(table);  % This is the number of data points in the array
            % 
            % Raw_Encoder.CountsPerRev       = default_value;  % How many counts are in each revolution of the encoder (with quadrature)
            % Raw_Encoder.Counts             = default_value;  % A vector of the counts measured by the encoder, Npoints long
            % Raw_Encoder.DeltaCounts        = default_value;  % A vector of the change in counts measured by the encoder, with first value of zero, Npoints long
            % Raw_Encoder.LastIndexCount     = default_value;  % Count at which last index pulse was detected, Npoints long
            % Raw_Encoder.AngularVelocity    = default_value;  % Angular velocity of the encoder
            % Raw_Encoder.AngularVelocity_Sigma    = default_value; 
            rawdata.Raw_Encoder = Raw_Encoder;
        % 
        % elseif contains(topic_name, 'tire_radius_rear_left')
        % 
        %     secs = table.secs;
        %     nsecs = table.secs;
        %     Tire_radius_rear_left_wheel.Time = secs+nsecs*10^-9;
        %     Tire_radius_rear_left_wheel.Counts = table.Counts;
        %     Tire_radius_rear_left_wheel.AngularVelocity = table.AngularVelocity;
        % 
        % elseif contains(topic_name, 'tire_radius_rear_right')
        % 
        %     secs = table.secs;
        %     nsecs = table.secs;
        %     Tire_radius_rear_right_wheel.Time = secs+nsecs*10^-9;
        %     Tire_radius_rear_right_wheel.Counts = table.Counts;
        %     Tire_radius_rear_right_wheel.AngularVelocity = table.AngularVelocity;
        elseif contains(topic_name, 'imu/data_raw')
            secs = table.secs;
            nsecs = table.nsecs;
            adis_IMU_dataraw = fcn_DataClean_initializeDataByType(datatype);
            adis_IMU_dataraw.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % adis_IMU_dataraw.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            adis_IMU_dataraw.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % adis_IMU_dataraw.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            adis_IMU_dataraw.Npoints            = height(table);  % This is the number of data points in the array
            % adis_IMU_dataraw.IMUStatus          = default_value;  
            adis_IMU_dataraw.XAccel             = table.x_2; 
            % adis_IMU_dataraw.XAccel_Sigma       = default_value; 
            adis_IMU_dataraw.YAccel             = table.y_2; 
            % adis_IMU_dataraw.YAccel_Sigma       = default_value; 
            adis_IMU_dataraw.ZAccel             = table.z_2; 
            % adis_IMU_dataraw.ZAccel_Sigma       = default_value; 
            adis_IMU_dataraw.XGyro              = table.x_1; 
            % adis_IMU_dataraw.XGyro_Sigma        = default_value; 
            adis_IMU_dataraw.YGyro              = table.y_1; 
            % adis_IMU_dataraw.YGyro_Sigma        = default_value; 
            adis_IMU_dataraw.ZGyro              = table.z_1; 
            % adis_IMU_dataraw.ZGyro_Sigma        = default_value; 
            rawdata.adis_IMU_dataraw = adis_IMU_dataraw;

        elseif contains(topic_name, 'imu/rpy/filtered')
            adis_IMU_filtered_rpy = fcn_DataClean_initializeDataByType(datatype);
            secs = table.secs;
            nsecs = table.nsecs;
            
            adis_IMU_filtered_rpy.GPS_Time           = secs+nsecs*10^-9;;  % This is the GPS time, UTC, as reported by the unit
            % adis_IMU_filtered_rpy.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            adis_IMU_filtered_rpy.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % adis_IMU_filtered_rpy.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            adis_IMU_filtered_rpy.Npoints            = height(table);  % This is the number of data points in the array
            % adis_IMU_filtered_rpy.IMUStatus          = default_value;  
            adis_IMU_filtered_rpy.XAccel             = table.x; 
            % adis_IMU_filtered_rpy.XAccel_Sigma       = default_value; 
            adis_IMU_filtered_rpy.YAccel             = table.y; 
            % adis_IMU_filtered_rpy.YAccel_Sigma       = default_value; 
            adis_IMU_filtered_rpy.ZAccel             = table.z; 
            % adis_IMU_filtered_rpy.ZAccel_Sigma       = default_value; 
            % adis_IMU_filtered_rpy.XGyro              = default_value; 
            % adis_IMU_filtered_rpy.XGyro_Sigma        = default_value; 
            % adis_IMU_filtered_rpy.YGyro              = default_value; 
            % adis_IMU_filtered_rpy.YGyro_Sigma        = default_value; 
            % adis_IMU_filtered_rpy.ZGyro              = default_value; 
            % adis_IMU_filtered_rpy.ZGyro_Sigma        = default_value; 

            rawdata.adis_IMU_filtered_rpy = adis_IMU_filtered_rpy;
    
        elseif contains(topic_name, 'imu/data')
           
            adis_IMU_data = fcn_DataClean_initializeDataByType(datatype);
            
            secs = table.secs;
            nsecs = table.nsecs;
            adis_IMU_data.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % adis_IMU_data.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            adis_IMU_data.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % adis_IMU_data.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            % adis_IMU_data.Npoints            = default_value;  % This is the number of data points in the array
            % adis_IMU_data.IMUStatus          = default_value;  
            adis_IMU_data.XAccel             = table.x_2; 
            % adis_IMU_data.XAccel_Sigma       = default_value; 
            adis_IMU_data.YAccel             = table.y_2; 
            % adis_IMU_data.YAccel_Sigma       = default_value; 
            adis_IMU_data.ZAccel             = table.z_2; 
            % adis_IMU_data.ZAccel_Sigma       = default_value; 
            adis_IMU_data.XGyro              = table.x_1; 
            % adis_IMU_data.XGyro_Sigma        = default_value; 
            adis_IMU_data.YGyro              = table.y_1; 
            % adis_IMU_data.YGyro_Sigma        = default_value; 
            adis_IMU_data.ZGyro              = table.z_1; 
            % adis_IMU_data.ZGyro_Sigma        = default_value; 
            rawdata.adis_IMU_data = adis_IMU_data;
        
        

        elseif contains(topic_name,'parseTrigger')
            secs = table.secs;
            nsecs = table.nsecs;
            parseTrigger = fcn_DataClean_initializeDataByType(datatype);
          
            parseTrigger.mode = table.mode;
            parseTrigger.GPS_Time                          = secs + nsecs*(10^-9);  % This is the GPS time, UTC, as reported by the unit
            % parseTrigger.Trigger_Time                      = default_value;  % This is the Trigger time, UTC, as calculated by sample
            parseTrigger.ROS_Time                          = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % parseTrigger.centiSeconds                      = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            parseTrigger.Npoints                           = height(table);  % This is the number of data points in the array
            parseTrigger.mode                              = table.mode;     % This is the mode of the trigger box (I: Startup, X: Freewheeling, S: Syncing, L: Locked)
            parseTrigger.adjone                            = table.adjone;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
            parseTrigger.adjtwo                            = table.adjtwo;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
            parseTrigger.adjthree                          = table.adjthree; % This is phase adjustment magnitude relative to the calculated period of the output pulse
            % Data below are error monitoring messages
            parseTrigger.err_failed_mode_count             = table.err_failed_mode_count;  
            parseTrigger.err_failed_XI_format              = table.err_failed_XI_format; 
            parseTrigger.err_failed_checkInformation       = table.err_failed_checkInformation; 
            parseTrigger.err_trigger_unknown_error_occured = table.err_trigger_unknown_error_occured; 
            parseTrigger.err_bad_uppercase_character       = table.err_bad_uppercase_character; 
            parseTrigger.err_bad_lowercase_character       = table.err_bad_lowercase_character; 
            parseTrigger.err_bad_three_adj_element         = table.err_bad_three_adj_element; 
            parseTrigger.err_bad_first_element             = table.err_bad_first_element; 
            parseTrigger.err_bad_character                 = table.err_bad_character; 
            parseTrigger.err_wrong_element_length          = table.err_wrong_element_length; 
            rawdata.RawTrigger = parseTrigger;

        elseif contains(topic_name, 'sparkfun_gps_rear_left')


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
            % SparkFun_GPS_RearLeft_LLA = [SparkFun_GPS_RearLeft.Latitude, SparkFun_GPS_RearLeft.Longitude, SparkFun_GPS_RearLeft.Altitude];
            % SparkFun_GPS_RearLeft_xyz = lla2enu(SparkFun_GPS_RearLeft_LLA, TestTrack_base_lla,'ellipsoid');
             
            % SparkFun_GPS_RearLeft.xEast = default_value;
            % SparkFun_GPS_RearLeft.xEast_Sigma        = default_value;  % Sigma in xEast [m]
            % SparkFun_GPS_RearLeft.yNorth = default_value;
            % SparkFun_GPS_RearLeft.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
            % SparkFun_GPS_RearLeft.zUp = default_value;
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

            rawdata.SparkFun_GPS_RearLeft = SparkFun_GPS_RearLeft;

        elseif contains(topic_name, 'sparkfun_gps_rear_right')
            SparkFun_GPS_RearRight = fcn_DataClean_initializeDataByType(datatype);
            secs = table.secs;
            nsecs = table.nsecs;
    
            SparkFun_GPS_RearRight.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % SparkFun_GPS_RearRight.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            SparkFun_GPS_RearRight.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            SparkFun_GPS_RearRight.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            SparkFun_GPS_RearRight.Npoints            = height(table);  % This is the number of data points in the array
            SparkFun_GPS_RearRight.Latitude           = table.Latitude;  % The latitude [deg]
            SparkFun_GPS_RearRight.Longitude          = table.Longitude;  % The longitude [deg]
            SparkFun_GPS_RearRight.Altitude           = table.Altitude;  % The altitude above sea level [m]
            % SparkFun_GPS_RearRight_LLA = [SparkFun_GPS_RearRight.Latitude, SparkFun_GPS_RearRight.Longitude, SparkFun_GPS_RearRight.Altitude];
            % SparkFun_GPS_RearRight_xyz = lla2enu(SparkFun_GPS_RearRight_LLA, TestTrack_base_lla,'ellipsoid');
            % SparkFun_GPS_RearRight.xEast = default_value;
            % SparkFun_GPS_RearRight.xEast_Sigma        = default_value;  % Sigma in xEast [m]
            % SparkFun_GPS_RearRight.yNorth = default_value;
            % SparkFun_GPS_RearRight.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
            % SparkFun_GPS_RearRight.zUp = default_value;
            % SparkFun_GPS_RearRight.zUp_Sigma          = default_value;  % Sigma in zUp [m]
            % 
            % SparkFun_GPS_RearRight.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
            % SparkFun_GPS_RearRight.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
            % SparkFun_GPS_RearRight.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
            % SparkFun_GPS_RearRight.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
            % SparkFun_GPS_RearRight.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
            % SparkFun_GPS_RearRight.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
            % SparkFun_GPS_RearRight.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s] 
            % SparkFun_GPS_RearRight.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
            SparkFun_GPS_RearRight.numSatellites      = table.NumOfSats;  % Number of satelites visible 
            SparkFun_GPS_RearRight.DGPS_mode          = table.LockStatus;  % Mode indicating DGPS status (for example, navmode 6;
            % SparkFun_GPS_RearRight.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
            % SparkFun_GPS_RearRight.Roll_deg_Sigma     = default_value;  % Sigma in Roll
            % SparkFun_GPS_RearRight.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
            % SparkFun_GPS_RearRight.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
            % SparkFun_GPS_RearRight.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
            % SparkFun_GPS_RearRight.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
            % SparkFun_GPS_RearRight.OneSigmaPos        = default_value;  % Sigma in position 
            SparkFun_GPS_RearRight.HDOP               = table.HDOP; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
            SparkFun_GPS_RearRight.AgeOfDiff          = table.AgeOfDiff;  % Age of correction data [s]
            rawdata.SparkFun_GPS_RearRight = SparkFun_GPS_RearRight;
        else
            topic_notused(count_notused,1) = string(topic_name);
            count_notused = count_notused + 1;
        end
    end
end