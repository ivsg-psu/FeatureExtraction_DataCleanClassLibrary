function [mergedRawDataCellArray, uncommonFieldsCellArray]  = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, varargin)
% fcn_DataClean_mergeRawDataStructures
% given a cell array of rawData files where the bag files may be in
% sequence, finds the files in sequence and creates merged data structures.
%
% FORMAT:
%
%      [mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags))
%
% INPUTS:
%
%      rawDataCellArray: a cell array of data structures containing data
%      fields filled for each ROS topic
%
%      (OPTIONAL INPUTS)
%
%      thresholdTimeNearby: the time, in seconds, allowed after one bag
%      file ends and the next one starts, to allow a merge.
%
%      fid: the fileID where to print. Default is 1, to print results to
%      the console.
%
%      saveFlags: a structure of flags to determine how/where/if the
%      results are saved. The defaults are below:
%
%         saveFlags.flag_saveMatFile = 0; % Set to 1 to save each rawData
%         file into the directory
%
%         saveFlags.flag_saveMatFile_directory = ''; % String with full
%         path to the directory where to save mat files
%
%         saveFlags.flag_saveImages = 0; % Set to 1 to save each image
%         file into the directory
%
%         saveFlags.flag_saveImages_directory = ''; % String with full
%         path to the directory where to save image files
%
%      plotFlags: a structure of figure numbers to plot results. If set to
%      -1, skips any input checking or debugging, no figures will be
%      generated, and sets up code to maximize speed. The structure has the
%      following format:
%
%         plotFlags.fig_num_plotAllRawTogether = 1111; % This is the figure
%         where all the bag files are plotted together
%
%         plotFlags.fig_num_plotAllRawIndividually = 2222; % This is the
%         number starting the count for all the figures that open,
%         individually, for each bag file after it is loaded.
%
%     the default is to not plot the results
%
% OUTPUTS:
%
%      mergedRawDataCellArray: a cell array of merged data structures
%      containing data fields filled for each ROS topic
%
%      uncommonFieldsCellArray: a cell array that lists the names of
%      structures or fields that could not be merged, corresponding to the
%      same index of mergedRawDataCellArray
%
% DEPENDENCIES:
%
%      fcn_DataClean_pullDataFromFieldAcrossAllSensors
%
%      fcn_DebugTools_checkInputsToFunctions
%      fcn_DataClean_loadMappingVanDataFromFile
%      fcn_DataClean_plotRawData
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_mergeRawDataStructures
%     for a full test suite.
%
% This function was written on 2024_09_15 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history
% 2024_09_15 - Sean Brennan, sbrennan@psu.edu
% -- wrote the code originally

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==5 && isequal(varargin{end},-1))
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS");
    MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG = getenv("MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_fig_num = 999978; %#ok<NASGU>
else
    debug_fig_num = []; %#ok<NASGU>
end


%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(1,5);
        
    end
end

% Does user want to specify thresholdTimeNearby?
thresholdTimeNearby = 2; % 2 seconds is allowed between the start of one and end of another
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        thresholdTimeNearby = temp;
    end
end

% Does user want to specify fid?
fid = []; 
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        fid = temp; 
    end
end

% Does user specify saveFlags?
% Set defaults
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = '';
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory = '';
if 4 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        saveFlags = temp;
    end
end

% Does user want to specify plotFlags?
% Set defaults
plotFlags.fig_num_plotAllRawTogether = [];
plotFlags.fig_num_plotAllRawIndividually = [];
flag_do_plots = 0;
if (0==flag_max_speed) &&  (5<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        plotFlags = temp;
        flag_do_plots = 1;
    end
end

%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Make sure the image save directory is there if image save is requested.
if 1==saveFlags.flag_saveImages && 7~=exist(saveFlags.flag_saveImages_directory,'dir') && 0==saveFlags.flag_forceDirectoryCreation
    warning('on','backtrace');
    warning('Unable to find directory: %s',saveFlags.flag_saveImages_directory)
    error('Image save specified that copies image into a non-existing directory. Unable to continue.');
end

% Create the image save directory if needed
if 1==saveFlags.flag_saveImages && saveFlags.flag_forceDirectoryCreation 
    directoryName = saveFlags.flag_saveImages_directory;
    fcn_INTERNAL_makeDirectory(directoryName);
end

%% Make sure the MAT save directory is there if MAT file save is requested.
if 1==saveFlags.flag_saveMatFile &&  7~=exist(saveFlags.flag_saveMatFile_directory,'dir') && 0==saveFlags.flag_forceDirectoryCreation
    warning('on','backtrace');
    warning('Unable to find directory: %s',saveFlags.flag_saveMatFile_directory)
    error('MAT file save specified that copies files into a non-existing directory. Unable to continue.');
end

% Create the image save directory if needed
if  1==saveFlags.flag_saveMatFile && saveFlags.flag_forceDirectoryCreation 
    directoryName = saveFlags.flag_saveMatFile_directory;
    fcn_INTERNAL_makeDirectory(directoryName);
end


%% Find when did each data set starts and stops in time

% How much data are there
NdataSets = length(rawDataCellArray);

% Get the max and min GPS times in each data set
earliestTimeGPS = nan(NdataSets,1);
latestTimeGPS   = nan(NdataSets,1);
for ith_mergedData = 1:NdataSets
    % Get all the GPS_time data, keeping only first row from sensors that
    % have "GPS" in name
    [dataArray,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(rawDataCellArray{ith_mergedData}, 'GPS_Time','GPS', 'first_row');
    earliestTimeGPS(ith_mergedData,1) = min(cell2mat(dataArray));

    % Get all the GPS_time data, keeping only last row from sensors that
    % have "GPS" in name
    [dataArray,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(rawDataCellArray{ith_mergedData}, 'GPS_Time','GPS', 'last_row');
    latestTimeGPS(ith_mergedData,1) = max(cell2mat(dataArray));
end


%% Find how all the sequences are named and numbered
sequenceNumbers = nan(NdataSets,1);
sequenceNames = cell(NdataSets,1);
for ith_mergedData = 1:NdataSets
    sequenceNames{ith_mergedData} = rawDataCellArray{ith_mergedData}.Identifiers.SourceBagFileName;
    sequenceNumbers(ith_mergedData,1) = fcn_INTERNAL_findSequenceNumber(sequenceNames{ith_mergedData});
end


%% Identify data belonging to each merge sequence
% Loop through all the files that are first in sequence, and for each, make
% a list of the indicies of the files that are subsequent in that sequence.
% Save the indicies within mergeIndexList and keep the first sequence's
% "short name" as this will name the merged file and data


% Find all the data folders that end in '_0'. These are the first in
% sequences. For each, check for data with _1 that starts near to time of
% _0, then _2 for those that end with _1, etc.
firstInSequenceIndicies = find(sequenceNumbers==0);
NmergedFiles = length(firstInSequenceIndicies);

% Prep the data storage variables
clear mergeIndexList shortMergedNames
mergeIndexList   = cell(NmergedFiles,1);
shortMergedNames = cell(NmergedFiles,1);

% Loop through all the files
for ith_merged = 1:NmergedFiles
    thisMergedIndex = firstInSequenceIndicies(ith_merged);
    mergeName = sequenceNames{thisMergedIndex};
    shortMergedName = mergeName(1:end-2); % Cut off the '_0' at end
    shortMergedNames{ith_merged} = shortMergedName;

    % Build up the merge list. Start by initializing the variables for this
    % specific list
    Nmerged = 1;
    mergeIndexList{ith_merged} = thisMergedIndex;

    flag_keepGoing = 1;
    nextEndingTime = latestTimeGPS(thisMergedIndex); % This is the last time recorded on the current list
    Nloops = 0;
    while 1==flag_keepGoing
        Nloops = Nloops+1;
        % Find any files whose earliest times are within the time nearby,
        % but requiring that the earliest time is AFTER the previous ending
        % time.
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

        % Make sure code is not trapped in this while loop for some reason
        if Nloops>100
            error('Very large number of files merged (N>100). Error likely and so exiting');
        end

    end % Ends while loop
end % Ends for loop that loops through "starting" bag files



%% Perform merge
mergedRawDataCellArray  = cell(NmergedFiles,1);
uncommonFieldsCellArray = cell(NmergedFiles,1);



for ith_mergedData = 1:NmergedFiles
    indiciesToMerge = mergeIndexList{ith_mergedData};
    mergedName = cat(2,shortMergedNames{ith_mergedData},'_merged');

    clear cellArrayOfStructures bagFileNames
    NfilesToMerge = length(indiciesToMerge);
    cellArrayOfStructures{NfilesToMerge} = struct; %#ok<AGROW>
    bagFileNames{NfilesToMerge} = ''; %#ok<AGROW>
    for ith_dataFile = 1:NfilesToMerge
        bagFileNames{ith_dataFile} = rawDataCellArray{indiciesToMerge(ith_dataFile)}.Identifiers.SourceBagFileName;

        % Keep the identifiers for the first one
        if 1==ith_dataFile
            clear mergedIdentifiers
            mergedIdentifiers = rawDataCellArray{indiciesToMerge(1)}.Identifiers;            
        end

        cellArrayOfStructures{ith_dataFile} = rawDataCellArray{indiciesToMerge(ith_dataFile)};
    end
    [stitchedStructure, uncommonFields] = fcn_DataClean_stitchStructures(cellArrayOfStructures,fid);

    % Fill in the updated identifiers
    stitchedStructure.Identifiers = mergedIdentifiers;
    stitchedStructure.Identifiers.SourceBagFileName = bagFileNames;
    stitchedStructure.Identifiers.TimeRangesEachBagFile_earliestTimeGPS = earliestTimeGPS;
    stitchedStructure.Identifiers.TimeRangesEachBagFile_latestTimeGPS = latestTimeGPS;
    stitchedStructure.Identifiers.mergedName = mergedName;
    
    mergedRawDataCellArray{ith_mergedData} = stitchedStructure;
    uncommonFieldsCellArray{ith_mergedData} = uncommonFields;
end




%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (1==flag_do_plots)
    
    %% Plot all merged files together, and save image
    if ~isempty(plotFlags.fig_num_plotAllMergedTogether)
        fig_num_plotAllMergedTogether = plotFlags.fig_num_plotAllMergedTogether ;
        figure(fig_num_plotAllMergedTogether);
        clf;

        % Define the plotting style
        clear mergedplotFormat
        mergedplotFormat = plotFlags.mergedplotFormat;

        % For each merged file, plot it
        legend_entries = cell(NmergedFiles+1,1);
        for ith_mergedData = 1:NmergedFiles
            % Set up variables to do a raw data plot
            mergeName = mergedRawDataCellArray{ith_mergedData}.Identifiers.mergedName;

            % Set the format for the "together" plot
            mergedplotFormat.Color = fcn_geometry_fillColorFromNumberOrName(ith_mergedData);
            mergedplotFormat.LineWidth = 1*(NmergedFiles - ith_mergedData + 1);
            colorMap = mergedplotFormat.Color;

            % Do the plot
            fcn_DataClean_plotRawData(mergedRawDataCellArray{ith_mergedData}, (mergeName), (mergedplotFormat), (colorMap), (fig_num_plotAllMergedTogether))

            % Update the legend
            legend_entries{ith_mergedData} = mergeName;
            
        end % Ends for loop through mergedData

        % Plot the base station
        fcn_plotRoad_plotLL([],[],fig_num_plotAllMergedTogether);
        legend_entries{end} = 'Base Station'; 

        h_legend = legend(legend_entries);
        set(h_legend,'Interpreter','none','FontSize',6)

        % Force the plot to fit
        geolimits('auto');

        title(saveFlags.flag_saveImages_name,'interpreter','none','FontSize',12)

        % Save the image to file?
        if 1==saveFlags.flag_saveImages
            fcn_INTERNAL_saveImages(saveFlags.flag_saveImages_name, saveFlags);
        end
     
    end

    %% Plot all individually, and save all images and mat files
    if ~isempty(plotFlags.fig_num_plotAllMergedIndividually)
        fig_num_plotAllMergedIndividually = plotFlags.fig_num_plotAllMergedIndividually;


        % For each merged file, plot it        
        for ith_mergedData = 1:NmergedFiles
            fig_num = fig_num_plotAllMergedIndividually -1 +ith_mergedData;
            figure(fig_num);
            clf;

            % Set up variables to do a raw data plot
            mergeName = mergedRawDataCellArray{ith_mergedData}.Identifiers.mergedName;

            % Plot the data
            fcn_DataClean_plotRawData(mergedRawDataCellArray{ith_mergedData}, (mergeName), ([]), ([]), (fig_num))

            % Plot the base station
            fcn_plotRoad_plotLL([],[],fig_num);

            % Update the legend
            h_legend = legend({mergeName,'Base Station'});
            set(h_legend,'Interpreter','none','FontSize',6)

            % Force the plot to fit
            geolimits('auto');

            % Save to the name
            fcn_INTERNAL_saveImages(mergeName, saveFlags);


            % Save the mat file?
            if 1 == saveFlags.flag_saveMatFile
                fcn_INTERNAL_saveMATfile(mergedRawDataCellArray{ith_mergedData}, mergeName, saveFlags);
            end


        end % Ends for loop through mergedData

    end

end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function




%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

%% fcn_INTERNAL_makeDirectory
function fcn_INTERNAL_makeDirectory(targetDirectoryName)
if 7~=exist(targetDirectoryName,'dir')
    % Need to make the directory

    % Find full path
    full_path_directory_to_create = fullfile(targetDirectoryName);

    % Find part below current directory
    relativePath = extractAfter(full_path_directory_to_create,cat(2,cd(),filesep));

    [successFlag,message] = mkdir(cd,relativePath);
    if 1~=successFlag
        warning('on','backtrace');
        warning('Unable to create directory: %s. Message given:',fullPathDirectoryToCheck,message);
        error('Image save specified that directory be created, but cannot create directory. Unable to continue.');
    end

    % % Split the relativePath into parts
    % pathParts = split(relativePath,filesep);
    % previousParentPath = cd();
    % for ith_directory = 1:length(pathParts)
    %     directoryToCheck = pathParts{ith_directory};
    %     fullPathDirectoryToCheck = fullfile(previousParentPath,directoryToCheck);
    %
    %     % Does the directory exist, or do we need to make it?
    %     if 7~=exist(fullPathDirectoryToCheck,'dir')
    %         % Need to make the directory
    %         successFlag = mkdir(previousParentPath,directoryToCheck);
    %         if 1~=successFlag
    %             warning('on','backtrace');
    %             warning('Unable to create directory: %s',fullPathDirectoryToCheck)
    %             error('Image save specified that directory be created, but cannot create directory. Unable to continue.');
    %         end
    %     end
    %
    %     previousParentPath = fullfile(previousParentPath,directoryToCheck);
    %
    % end
end
end % Ends fcn_INTERNAL_makeDirectory

%% fcn_INTERNAL_findSequenceNumber
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
end % Ends fcn_INTERNAL_findSequenceNumber


%% fcn_INTERNAL_saveImages
function fcn_INTERNAL_saveImages(imageName, saveFlags)
Image = getframe(gcf);
PNG_image_fname = cat(2,imageName,'.png');
PNG_imagePath = fullfile(saveFlags.flag_saveImages_directory,PNG_image_fname);
if 2~=exist(PNG_imagePath,'file') || 1==saveFlags.flag_forceImageOverwrite
    imwrite(Image.cdata, PNG_imagePath);
end

FIG_image_fname = cat(2,imageName,'.fig');
FIG_imagePath = fullfile(saveFlags.flag_saveImages_directory,FIG_image_fname);
if 2~=exist(FIG_imagePath,'file') || 1==saveFlags.flag_forceImageOverwrite
    savefig(FIG_imagePath);
end
end % Ends fcn_INTERNAL_saveImages

%% fcn_INTERNAL_saveMATfile
function  fcn_INTERNAL_saveMATfile(rawDataMerged, MATfileName, saveFlags)

MAT_fname = cat(2,MATfileName,'.mat');
MAT_fullPath = fullfile(saveFlags.flag_saveMatFile_directory,MAT_fname);
if 2~=exist(MAT_fullPath,'file') || 1==saveFlags.flag_forceMATfileOverwrite
    save(MAT_fullPath,'rawDataMerged');
end

end % Ends fcn_INTERNAL_saveMATfile

