% script_test_fcn_DataClean_stichStructures.m
% tests fcn_DataClean_stichStructures.m

% Revision history
% 2024_09_11 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all


%% Test 1: Basic example - merging level 1 fields that partially agree
fig_num = [];

s1.a = 1;
s1.b = 1;
s1.c = 1;
s1.e = 1;

s2.a = 2;
s2.c = 2;
s2.d = 2;

s3.a = 3;
s3.c = 3;
s3.e = 3;
s3.f = 3;


% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
cellArrayOfStructures{3} = s3;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isstruct(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
temp = fieldnames(stitchedStructure);
assert(strcmp(temp{1},'a'));
assert(strcmp(temp{2},'c'));
assert(strcmp(uncommonFields{1},'d'));
assert(strcmp(uncommonFields{2},'f'));

% Check field values
assert(isequal(stitchedStructure.a,[1 2 3]'))
assert(isequal(stitchedStructure.c,[1 2 3]'))

%% Test 2: Basic example - merging level 1 fields that do not agree
fig_num = [];

s1.a = 1;
s1.b = 1;
s1.e = 1;

s2.c = 2;
s2.d = 2;
s2.e = 2;

s3.a = 3;
s3.c = 3;
s3.d = 3;

% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
cellArrayOfStructures{3} = s3;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isstruct(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
temp = fieldnames(stitchedStructure);
assert(strcmp(temp{1},'a'));
assert(strcmp(temp{2},'c'));
assert(strcmp(uncommonFields{1},'d'));
assert(strcmp(uncommonFields{2},'f'));

% Check field values
assert(isequal(stitchedStructure.a,[1 2 3]'))
assert(isequal(stitchedStructure.c,[1 2 3]'))

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
% rawData = fcn_DataClean_stichStructures(bagPath, (bagName), (fid), (Flags), (fig_num));
% 
% % Check the data
% assert(isstruct(rawData))
% assert(strcmp(subPathStrings,''))

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
    rawData{ith_folder} = fcn_DataClean_stichStructures(bagPath, (bagName), (fid), (Flags), (-1)); 


end

%%
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
clear mergeIndexList shortMergedNames
mergeIndexList{NmergedFiles}  = [];
shortMergedNames{NmergedFiles}  = [];
for ith_merged = 1:NmergedFiles
    thisMergedIndex = firstInSequenceIndicies(ith_merged);
    mergeName = only_directory_filelist(thisMergedIndex).name;
    shortMergedName = mergeName(1:end-2); % Cut off the '_0' at end
    shortMergedNames{ith_merged} = shortMergedName;

    % Build up the merge list
    Nmerged = 1;
    mergeIndexList{ith_merged} = thisMergedIndex;
    nextEndingTime = latestTimeGPS(thisMergedIndex);

    flag_keepGoing = 1;
    while 1==flag_keepGoing
        % Find any files that are within the time nearby
        time_difference = (earliestTimeGPS-nextEndingTime);
        nextIndex = find((time_difference>=0).*(abs(time_difference)<=thresholdTimeNearby));
        
        if isempty(nextIndex)
            flag_keepGoing = 0;
        else
            % Find all files that are next in sequence
            indexDataFilesNextInSequence = find(sequenceNumbers==Nmerged);
            if isempty(indexDataFilesNextInSequence)
                flag_keepGoing = 0;
            else
                % Check that the nextIndex is within the list of the files
                % next in sequence
                if ismember(nextIndex, indexDataFilesNextInSequence)
                    Nmerged = Nmerged+1;
                    mergeIndexList{ith_merged} = [mergeIndexList{ith_merged}; nextIndex];
                    nextEndingTime = latestTimeGPS(nextIndex);
                else
                    flag_keepGoing = 0;
                end
            end

            
        end
        
    end
end

%%

%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_stichStructures(bagName, bagName);
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