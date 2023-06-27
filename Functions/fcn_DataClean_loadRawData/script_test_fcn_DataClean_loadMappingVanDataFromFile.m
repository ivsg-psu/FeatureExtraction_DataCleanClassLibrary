% script_test_fcn_DataClean_loadMappingVanDataFromFile.m
% tests fcn_DataClean_loadMappingVanDataFromFile.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter
% 2023_06_25 - sbrennan@psu.edu
% -- fixed typo in comments where script had wrong name! 
% 2023_06_26 - xfc5113@psu.edu
% -- Update the default data information

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

%% Choose data folder and bag name, read before running the script
% 2023_06_19
% Data from "mapping_van_2023-06-05-1Lap.bag" is set as the default value
% used in this test script.
% All files are saved on OneDrive, in
% \\IVSG\GitHubMirror\MappingVanDataCollection\ParsedData, to use data from other files,
% change the data_folder variable and bagname variable to corresponding path and bag
% name.

% 2023_06_24
% Data from "mapping_van_2023-06-22-1Lap_0.bag" and "mapping_van_2023-06-22-1Lap_1.bag"
% will be used as the default data used in this test script. 
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy mapping_van_2023-06-22-1Lap_0 and
% mapping_van_2023-06-22-1Lap_1 folder to the LargeData folder.

% 2023_06_26
% New test data 'mapping_van_2023-06-26-Parking5s.bag',
% 'mapping_van_2023-06-26-Parking10s.bag',
% 'mapping_van_2023-06-26-Parking20s.bag', and
% 'mapping_van_2023-06-26-Parking30s.bag' will be used as the default data
% in this script.
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.
% mapping_van_2023-06-26-Parking5s folder will also be placed in the Data
% folder and will be pushed to GitHub repo.

% bagFolderName = "mapping_van_2023-06-22-1Lap_0";
bagFolderName = "mapping_van_2023-06-26-Parking5s";
rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName);


%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagFolderName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName);
end
