% script_test_fcn_DataClean_loadMappingVanDataFromFile.m
% tests fcn_DataClean_loadMappingVanDataFromFile.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter
% 2023_06_25 - sbrennan@psu.edu
% -- fixed typo in comments where script had wrong name! 
% 2023_06_26 - xfc5113@psu.edu
% -- Update the default data information
% 2024_09_05 - sbrennan@psu.edu
% -- Updated function call for new arguments

%% Set up the workspace
close all


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


%% Test 1: Load the bag file with defaults (no LIDARs)
fig_num = 1;
figure(fig_num);
clf;

clear rawData


% Add Identifiers to the data that will be loaded
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

fid = 1;
dataFolderString = "LargeData";
dateString = '2024-07-10';
bagName = "mapping_van_2024-07-10-19-41-49_0";
bagPath = fullfile(pwd, dataFolderString,dateString, bagName);
Flags = [];
rawData = fcn_DataClean_loadMappingVanDataFromFile(bagPath, Identifiers, (bagName), (fid), (Flags), (fig_num));

% Check the data
assert(isstruct(rawData))



%% Test 2: Load part of the bag file
% fig_num = 2;
% figure(fig_num);
% clf;
% 
% clear rawData
% 
% 
% fid = 1;
% dataFolderString = "LargeData";
% dateString = '2024-06-20';
% bagName = "mapping_van_2024-06-20-15-21-04_0";
% bagPath = fullfile(pwd, dataFolderString, dateString, bagName);
% Flags = struct;
% Flags.flag_do_load_sick = 0;
% Flags.flag_do_load_velodyne = 1;
% Flags.flag_do_load_cameras = 0;
% rawData = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), (fig_num));
% 
% % Check the data
% assert(isstruct(rawData))
% 



%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagName, bagName);
end

%% Functions
function lastPart = fcn_INTERNAL_findSequenceNumber(nameString)
if ~contains(nameString,'_')
    lastPart = nan;
else
    stringLeft = nameString;
    while contains(stringLeft,'_')
        stringLeft = extractAfter(stringLeft,'_');
    end
    lastPart = str2double(stringLeft);
end
end