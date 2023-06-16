% script_example_DataClean_loadRawDataFromFile.m


% Revision history
% 2023_06_16 - Xinyu Cao
% -- wrote the code originally, using data from mapping_van_2023-06-05-1Lap
% as starter, the main part of the code will be functionalized as the
% function fcn_DataClean_loadRawDataFromFile
% The result of the code will be a structure store raw data from bag file


%% Prep the workspace
close all
clc
clear all


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

%% Choose data folder and bag name

% Data from "mapping_van_2023-06-05-1Lap.bag" is set as the default value
% used in this test script.
% All files are saved on OneDrive, in
% IVSG\GitHubMirror\MappingVanDataCollection\ParsedData, to use data from other files,
% change the data_folder variable and bagname variable to corresponding path and bag
% name.
data_folder = "D:\OneDrive - The Pennsylvania State University\IVSG\GitHubMirror\MappingVanDataCollection\ParsedData\2023-06-05\";
bagname = "mapping_van_2023-06-05-SCR2TestTrack";

%% Add path
addpath(genpath('Functions')); % add the function path
folder_path = data_folder + bagname + "\";
addpath(folder_path)
%% Main script
% This part will be functionalized later
file_list = dir(folder_path);
num_files = length(file_list);
flag_do_debug = 1;

count_notused = 1;
rawdata = struct;
% Start from the 3rd row
for file_idx = 3:num_files
    file_name = file_list(file_idx).name;
    file_name_noext = extractBefore(file_name,'.'); 

    topic_name = strrep(file_name_noext,'_slash_','/');
 

    datatype = fcn_DataClean_determineDataType(topic_name);
    file_path = folder_path + file_name;
    % topic name is used to decide the sensor
    if contains(topic_name,'sick_lms500/scan')

        SickLiDAR = fcn_DataClean_loadRawDataFromFile_SickLidar(file_path,datatype,flag_do_debug);
        rawdata.SickLiDAR = SickLiDAR;

    else
        if contains(topic_name, 'Bin1')
            Hemisphere_DGPS = fcn_DataClean_loadRawDataFromFile_Hemisphere(file_path,datatype,flag_do_debug);
            rawdata.Hemisphere_DGPS = Hemisphere_DGPS;

        elseif contains(topic_name, 'GPS_Novatel')
   

            GPS_Novatel = fcn_DataClean_loadRawDataFromFile_Novatel_GPS(file_path,datatype,flag_do_debug);
            
            rawdata.GPS_Novatel = GPS_Novatel;
    
        elseif contains(topic_name, 'Garmin_GPS')
 
            
            GPS_Garmin = fcn_DataClean_loadRawDataFromFile_Garmin_GPS(file_path,datatype,flag_do_debug);
            rawdata.Garmin_GPS = GPS_Garmin;

        elseif contains(topic_name, 'Novatel_IMU')
    
            Novatel_IMU = fcn_DataClean_loadRawDataFromFile_IMU_Novatel(file_path,datatype,flag_do_debug);
            rawdata.Novatel_IMU = Novatel_IMU;
    
        elseif contains(topic_name, 'Encoder')
           
            parseEncoder = fcn_DataClean_loadRawDataFromFile_parse_Encoder(file_path,datatype,flag_do_debug);
            rawdata.Raw_Encoder = parseEncoder;

        elseif contains(topic_name, 'imu/data_raw')
        
            adis_IMU_dataraw = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(file_path,datatype,flag_do_debug,topic_name);
            rawdata.adis_IMU_dataraw = adis_IMU_dataraw;


        elseif contains(topic_name, 'imu/rpy/filtered')
            
            adis_IMU_filtered_rpy = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(file_path,datatype,flag_do_debug,topic_name);
            rawdata.adis_IMU_filtered_rpy = adis_IMU_filtered_rpy;
    
        elseif contains(topic_name, 'imu/data')
           
            adis_IMU_data = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(file_path,datatype,flag_do_debug,topic_name);
            rawdata.adis_IMU_data = adis_IMU_data;

       
        elseif contains(topic_name,'parseTrigger')
           
            parseTrigger = fcn_DataClean_loadRawDataFromFile_parse_Trigger(file_path,datatype,flag_do_debug);
            rawdata.RawTrigger = parseTrigger;

        elseif contains(topic_name, 'sparkfun_gps_rear_left')

            SparkFun_GPS_RearLeft = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(file_path,datatype,flag_do_debug);
            rawdata.SparkFun_GPS_RearLeft = SparkFun_GPS_RearLeft;

        elseif contains(topic_name, 'sparkfun_gps_rear_right')
            SparkFun_GPS_RearRight = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(file_path,datatype,flag_do_debug);
            rawdata.SparkFun_GPS_RearRight = SparkFun_GPS_RearRight;
        else
            fprintf(1,'\nTopic not processed: %s\n',topic_name)
        end
    end
end

%%
fprintf(1,'\nLoading completed\n')