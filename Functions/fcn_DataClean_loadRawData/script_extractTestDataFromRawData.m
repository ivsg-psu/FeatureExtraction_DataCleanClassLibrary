% script_extractTestDataFromRawData.m


% Revision history
% 2023_06_19 - xfc5113@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter

%% Set up the workspace
close all
clc


%% Check assertions for basic path operations and function testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              _   _                 
%      /\                     | | (_)                
%     /  \   ___ ___  ___ _ __| |_ _  ___  _ __  ___ 
%    / /\ \ / __/ __|/ _ \ '__| __| |/ _ \| '_ \/ __|
%   / ____ \\__ \__ \  __/ |  | |_| | (_) | | | \__ \
%  /_/    \_\___/___/\___|_|   \__|_|\___/|_| |_|___/
%                                                    
%                                                    
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Assertions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Choose data folder and bag name

% Data from "mapping_van_2023-06-05-1Lap.bag" is set as the default value
% used in this test script.
% All files are saved on OneDrive, in
% \\IVSG\GitHubMirror\MappingVanDataCollection\ParsedData, to use data from other files,
% change the data_folder variable and bagname variable to corresponding path and bag
% name.
bagFolderName = "mapping_van_2023-06-05-1Lap";
rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName);

%%
GPS_Hemisphere = rawdata.Hemisphere_DGPS;
adis_IMU_data = rawdata.adis_IMU_data;
adis_IMU_dataraw = rawdata.adis_IMU_dataraw;
adis_IMU_filtered_rpy = rawdata.adis_IMU_filtered_rpy;
RawEncoder = rawdata.Raw_Encoder;
RawTrigger = rawdata.RawTrigger;
SickLidar = rawdata.SickLiDAR;
GPS_SparkFun_RearLeft = rawdata.SparkFun_GPS_RearLeft;
GPS_SparkFun_RearRight = rawdata.SparkFun_GPS_RearRight;
%%
%%
GPS_Hemisphere_refTime = GPS_Hemisphere.GPS_Time - min(GPS_Hemisphere.GPS_Time);
adis_IMU_data_refTime = adis_IMU_data.GPS_Time - min(adis_IMU_data.GPS_Time);
GPS_SparkFun_RearLeft_refTime = GPS_SparkFun_RearLeft.GPS_Time - min(GPS_SparkFun_RearLeft.GPS_Time);
%%

GPS_Hemisphere_table = struct2table(GPS_Hemisphere,'AsArray',true);
test_idxs = find(GPS_Hemisphere_refTime >= 10 & GPS_Hemisphere_refTime < 11);
%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagFolderName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName);
end
