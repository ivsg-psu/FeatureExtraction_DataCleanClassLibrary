% script_test_fcn_DataClean_cleanData.m
% tests fcn_DataClean_cleanData.m

% Revision history
% 2024_09_09 - sbrennan@psu.edu
% -- wrote the code originally

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

%% Test 1: Load and clean a single bag file
fig_num = 1;
figure(fig_num);
clf;

fid = 1;
dataFolderString = "LargeData";
dateString = '2024-07-10';
bagName = "mapping_van_2024-07-10-19-31-08_0";
bagPath = fullfile(pwd, dataFolderString,dateString, bagName);
Flags = [];
[rawDataStruct, subPathStrings] = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), ([]));

% Check the result
assert(isstruct(rawDataStruct))


ref_baseStationLLA = [40.44181017, -79.76090840, 327.428]; % Pittsburgh
cleanDataStruct = fcn_DataClean_cleanData(rawDataStruct, (ref_baseStationLLA), (fid), (Flags), (fig_num));

% Check the data
assert(strcmp(subPathStrings,''))

%%

%% Fail conditions
if 1==0
    %% ERROR situation: 
end
