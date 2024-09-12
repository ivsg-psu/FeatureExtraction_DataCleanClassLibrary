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


fid = 1;
dataFolderString = "LargeData";
dateString = '2024-07-10';
bagName = "mapping_van_2024-07-10-19-41-49_0";
bagPath = fullfile(pwd, dataFolderString,dateString, bagName);
Flags = [];
rawData = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), (fig_num));

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

%% Test 3: Load all bag files from a given directory and all subdirectories
% fig_num = 3;
% figure(fig_num);
% clf;

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


%% Plot all of them together
fig_num = 1111;
figure(fig_num);
clf;

% Plot the base station
fcn_plotRoad_plotLL([],[],fig_num);

% Test the function
clear plotFormat
plotFormat.LineStyle = '-';
plotFormat.LineWidth = 2;
plotFormat.Marker = 'none';
plotFormat.MarkerSize = 5;

for ith_rawData = 1:length(rawData)
    bagName = only_directory_filelist(ith_rawData).name;
    plotFormat.Color = fcn_geometry_fillColorFromNumberOrName(ith_rawData);
    colorMap = plotFormat.Color;
    fcn_DataClean_plotRawData(rawData{ith_rawData}, (bagName), (plotFormat), (colorMap), (fig_num))
end

% h_legend = legend('Base station',bagName);
% set(h_legend,'Interpreter','none')


%% Plot all separately, and save all images

for ith_rawData = 1:length(rawData)
    fig_num = 1111+ith_rawData;
    figure(fig_num);
    clf;

    % Plot the base station
    fcn_plotRoad_plotLL([],[],fig_num);

    % Plot the data
    bagName = only_directory_filelist(ith_rawData).name;
    fcn_DataClean_plotRawData(rawData{ith_rawData}, (bagName), ([]), ([]), (fig_num))

    pause(1);

    % Save the image to file?
    if 1==0
        % Make sure bagName is good
        if contains(bagName,'.')
            bagName_clean = extractBefore(bagName,'.');
        else
            bagName_clean = bagName;
        end

        Image = getframe(gcf);
        image_fname = cat(2,char(bagName_clean),'.png');
        imagePath = fullfile(pwd, 'ImageSummaries',image_fname);
        if 2~=exist(imagePath,'file')
            imwrite(Image.cdata, imagePath);
        end
    end

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
    end % Ends while loop
end % Ends for loop that loops through "starting" bag files

%% For each of the groups of bag files, merge them
% Plot all of them together
fig_num_rawMerged = 2222;
figure(fig_num_rawMerged);
clf;

% Defined the mergedplotFormat
clear mergedplotFormat
mergedplotFormat.LineStyle = '-';
mergedplotFormat.LineWidth = 2;
mergedplotFormat.Marker = 'none';
mergedplotFormat.MarkerSize = 5;




clear legend_entries

for ith_merge = 1:NmergedFiles    
    indiciesToMerge = mergeIndexList{ith_merge};
    mergeName = cat(2,shortMergedNames{ith_merge},'_merged');
    
    clear cellArrayOfStructures
    NfilesToMerge = length(indiciesToMerge);
    cellArrayOfStructures{NfilesToMerge} = struct; %#ok<SAGROW>
    for ith_dataFile = 1:NfilesToMerge
        cellArrayOfStructures{ith_dataFile} = rawData{indiciesToMerge(ith_dataFile)};
    end
    [stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures);

    % Plot the data on the "together" plot
    bagName = only_directory_filelist(ith_rawData).name;
    mergedplotFormat.Color = fcn_geometry_fillColorFromNumberOrName(ith_merge);
    mergedplotFormat.LineWidth = 1*(NmergedFiles - ith_merge + 1);
    colorMap = mergedplotFormat.Color;
    fcn_DataClean_plotRawData(stitchedStructure, (mergeName), (mergedplotFormat), (colorMap), (fig_num_rawMerged))
    if ~exist('legend_entries','var')
        legend_entries{1} = mergeName;
    else
        legend_entries{end+1} = mergeName; %#ok<SAGROW>
    end

    title('Pittsburgh Site 1, W to E traces');
    subtitle('2024-07-10 to 2024-07-11')
    h_legend = legend(legend_entries);
    set(h_legend,'Interpreter','none')
    
    % Plot this individual trace?
    if 1==1
        fig_num = fig_num_rawMerged+ith_rawData;
        figure(fig_num);
        clf;

        % Plot the base station
        fcn_plotRoad_plotLL([],[],fig_num);

        % Plot the data
        fcn_DataClean_plotRawData(stitchedStructure, (mergeName), ([]), ([]), (fig_num))

        pause(1);

        % Save the image to file?
        if 1==1
            Image = getframe(gcf);
            image_fname = cat(2,char(mergeName),'.png');
            imagePath = fullfile(pwd, 'ImageSummaries',image_fname);
            if 2~=exist(imagePath,'file')
                imwrite(Image.cdata, imagePath);
            end
        end
    end
end

% Plot the base station
fcn_plotRoad_plotLL([],[],fig_num_rawMerged);
legend_entries{end+1} = 'Base Station';

figure(fig_num_rawMerged)
title('Pittsburgh Site 1, W to E traces');
subtitle('2024-07-10 to 2024-07-11')
h_legend = legend(legend_entries);
set(h_legend,'Interpreter','none')

% Save the image to file?
if 1==1
    Image = getframe(gcf);
    image_fname = cat(2,'mapping_van_allMerged','.png');
    imagePath = fullfile(pwd, 'ImageSummaries',image_fname);
    if 2~=exist(imagePath,'file')
        imwrite(Image.cdata, imagePath);
    end
end

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