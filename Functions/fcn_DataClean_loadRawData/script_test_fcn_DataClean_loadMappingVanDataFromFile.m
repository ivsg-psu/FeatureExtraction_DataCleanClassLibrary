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


%% Test 1: Load the bag file with defaults (no LIDARs)
fig_num = 1;
figure(fig_num);
clf;

clear rawData


fid = 1;
dataFolderString = "LargeData";
dateString = '2024-07-10';
bagName = "mapping_van_2024-07-10-19-41-49_0";
bagPath = fullfile(pwd, dataFolderString,dateString, bagName);
Flags = [];
[rawData, subPathStrings] = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), (fig_num));

% Check the data
assert(isstruct(rawData))
assert(strcmp(subPathStrings,''))

%% Test 2: Load part of the bag file
fig_num = 2;
figure(fig_num);
clf;

clear rawData


fid = 1;
dataFolderString = "LargeData";
dateString = '2024-06-20';
bagName = "mapping_van_2024-06-20-15-21-04_0";
bagPath = fullfile(pwd, dataFolderString, dateString, bagName);
Flags = struct;
Flags.flag_do_load_sick = 0;
Flags.flag_do_load_velodyne = 1;
Flags.flag_do_load_cameras = 0;
rawData = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), (fig_num));

% Check the data
assert(isstruct(rawData))
assert(strcmp(subPathStrings,''))

%% Test 3: Load all bag files from a given directory and all subdirectories
fig_num = 3;
figure(fig_num);
clf;

clear rawData

%%%%%%
% Load the data
% Query which directories need to be loaded
rootdir = fullfile(cd,'LargeData');
filelist = dir(fullfile(rootdir, '**','mapping_van_*'));  % gets list of files and folders in any subfolder that start with name 'mapping_van_'
only_directory_filelist = filelist([filelist.isdir]);  % keep only directories from list
NdataSets = length(only_directory_filelist);

% Set up the loading parameters
fid = 1;
Flags = [];


% Loop through all the directories to be queried
rawData{NdataSets} = struct;
for ith_folder = 1:NdataSets

    % Load the raw data
    bagName = only_directory_filelist(ith_folder).name;
    dataFolderString = only_directory_filelist(ith_folder).folder;
    bagPath = fullfile(dataFolderString, bagName);
    rawData{ith_folder} = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), (-1)); 


end

%%%%%
% When did each data set start and stop in time?
% Get the max and min GPS times in each data set
earliestTimeGPS = nan(NdataSets,1);
latestTimeGPS   = nan(NdataSets,1);
for ith_folder = 1:NdataSets
    % Get all the GPS_time data, keeping only first row from sensors that
    % have "GPS" in name
    [dataArray,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(rawData{ith_folder}, 'GPS_Time','GPS', 'first_row');
    earliestTimeGPS(ith_folder,1) = min(cell2mat(dataArray));

    % Get all the GPS_time data, keeping only last row from sensors that
    % have "GPS" in name
    [dataArray,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(rawData{ith_folder}, 'GPS_Time','GPS', 'last_row');
    latestTimeGPS(ith_folder,1) = max(cell2mat(dataArray));
end

%%
% Merge data?

% Find how all the sequences are numbered
sequenceNumbers = nan(NdataSets,1);
for ith_folder = 1:NdataSets
    sequenceNumbers(ith_folder,1) = fcn_INTERNAL_findSequenceNumber(only_directory_filelist(ith_folder).name);
end

% Find all the data folders that end in '_0'. These are the first in
% sequences. For each, check for data with _1 that starts near to time of
% _0, then _2 for those that end with _1, etc.
firstInSequenceIndicies = find(sequenceNumbers==0);
NmergedFiles = length(firstInSequenceIndicies);
thresholdTimeNearby = 2; % 2 seconds is allowed between the start of one and end of another
maxClips = 9;

% Loop through all the files that are "merge" files

shortMergedName{NmergedFiles} = '';
mergeIndexList{NmergedFiles}  = [];
for ith_merged = 1:NmergedFiles
    thisMergedIndex = firstInSequenceIndicies(ith_merged);
    mergeName = only_directory_filelist(thisMergedIndex).name;
    shortMergedName = mergeName(1:end-2); % Cut off the '_0' at end

    % Build up the merge list
    Nmerged = 1;
    mergeIndexList{Nmerged} = thisMergedIndex;
    nextEndingTime = latestTimeGPS(thisMergedIndex);
    flag_keepGoing = 1;
    while 1==flag_keepGoing

        URHERE
    end
end

%%

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