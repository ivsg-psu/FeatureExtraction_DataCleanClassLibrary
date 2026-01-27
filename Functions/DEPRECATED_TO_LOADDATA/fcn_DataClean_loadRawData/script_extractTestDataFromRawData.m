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
bagName = "mapping_van_2023-06-05-1Lap";
rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName, bagName);

%%
%%
rawdata_table = struct2table(rawdata);

fields = fieldnames(rawdata);
N_fields = length(fields);
start_sec = 20;
end_sec = 21;
rawdata_test = struct;
cur_struct_test = struct;

for idx_field = 1:N_fields
    cur_struct = rawdata.(fields{idx_field});
    cur_struct = rmfield(cur_struct,"EventFunctions");
    sub_fields = fieldnames(cur_struct);
    N_sub_fields = length(sub_fields);
    Npoints = cur_struct.Npoints;
    GPS_Time = cur_struct.GPS_Time;
    GPS_Time_ref = GPS_Time - min(GPS_Time);
    test_range = find(GPS_Time_ref >= start_sec & GPS_Time_ref < end_sec);
    for idx_sub_field = 1:N_sub_fields
        sub_struct = cur_struct.(sub_fields{idx_sub_field});
        sz = size(sub_struct);
        if sz(1) == 1
            sub_struct = sub_struct*ones(Npoints,1);
        end
        sub_struct_test = sub_struct(test_range,:);
        cur_struct_test.(sub_fields{idx_sub_field}) = sub_struct_test;
        
        clear sub_struct sub_struct_test
    end
 
    % cur_table = struct2table(cur_struct);
    
    % cur_table_test = cur_table(test_range,:);
    % cur_struct_test = table2struct(cur_table_test);
    rawdata_test.(fields{idx_field}) = cur_struct_test;
    clear cur_struct_test
    ss = 2;
end
% GPS_Hemisphere = rawdata.Hemisphere_DGPS;
% adis_IMU_data = rawdata.adis_IMU_data;
% adis_IMU_dataraw = rawdata.adis_IMU_dataraw;
% adis_IMU_filtered_rpy = rawdata.adis_IMU_filtered_rpy;
% RawEncoder = rawdata.Raw_Encoder;
% RawTrigger = rawdata.RawTrigger;
% SickLidar = rawdata.SickLiDAR;
% GPS_SparkFun_RearLeft = rawdata.SparkFun_GPS_RearLeft;
% GPS_SparkFun_RearRight = rawdata.SparkFun_GPS_RearRight;
% %%
% %%
% GPS_Hemisphere_refTime = GPS_Hemisphere.GPS_Time - min(GPS_Hemisphere.GPS_Time);
% adis_IMU_data_refTime = adis_IMU_data.GPS_Time - min(adis_IMU_data.GPS_Time);
% GPS_SparkFun_RearLeft_refTime = GPS_SparkFun_RearLeft.GPS_Time - min(GPS_SparkFun_RearLeft.GPS_Time);
% %%
% 
% GPS_Hemisphere_table = struct2table(GPS_Hemisphere,'AsArray',true);
% test_idxs = find(GPS_Hemisphere_refTime >= 10 & GPS_Hemisphere_refTime < 11);
%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagFolderName = "badData";
    bagName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName, bagName);
end
