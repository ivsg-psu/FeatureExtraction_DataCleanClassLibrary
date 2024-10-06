% script_mainDataClean_loadAndSaveAllSitesRawData.m.m
% Loads and saves all site data. 
% Based on test script for: script_test_fcn_DataClean_mergeRawDataStructures.m

% Revision history
% 2024_09_28 - sbrennan@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter

%% Set up the workspace
close all

%% Prepare bag file listings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _____                                 ____                ______ _ _        _      _     _   _
% |  __ \                               |  _ \              |  ____(_) |      | |    (_)   | | (_)
% | |__) | __ ___ _ __   __ _ _ __ ___  | |_) | __ _  __ _  | |__   _| | ___  | |     _ ___| |_ _ _ __   __ _ ___
% |  ___/ '__/ _ \ '_ \ / _` | '__/ _ \ |  _ < / _` |/ _` | |  __| | | |/ _ \ | |    | / __| __| | '_ \ / _` / __|
% | |   | | |  __/ |_) | (_| | | |  __/ | |_) | (_| | (_| | | |    | | |  __/ | |____| \__ \ |_| | | | | (_| \__ \
% |_|   |_|  \___| .__/ \__,_|_|  \___| |____/ \__,_|\__, | |_|    |_|_|\___| |______|_|___/\__|_|_| |_|\__, |___/
%                | |                                  __/ |                                              __/ |
%                |_|                                 |___/                                              |___/
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Prepare%20Bag%20File%20Listings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find all bag files in a given directory, and sort them, then print


% List which directory/directories need to be loaded
clear sourceUnsortedBagDirectory
dateToProcess = '2024-08-13';
identifierString = '\\RawBags\TestTrack\Base';
sourceUnsortedBagDirectory{1} = 'C:\Users\snb10\ReadyToParse\Base_2024-08-13';
destinationSortedBagDirectory = cat(2,sourceUnsortedBagDirectory{1},filesep,dateToProcess);
flag_printMarkdownReady = 1;

% Set up the README file?
if 1==flag_printMarkdownReady

    % Make sure folder exists!
    if 7~=exist(destinationSortedBagDirectory,'dir')
        warning('on','backtrace');
        warning('Unable to find folder: \n\t%s',destinationSortedBagDirectory);
        error('Desired directory: %s does not exist!',destinationSortedBagDirectory);
    end


    readmeFilename = fullfile(destinationSortedBagDirectory,cat(2,'README_runDetails_',dateToProcess,'.md'));
    templateReadmeFile = fullfile(cd,'Data','README_bagHeader.txt');

    % Make sure templateReadmeFile exists!
    if 2~=exist(templateReadmeFile,'file')
        warning('on','backtrace');
        warning('Unable to find template file: \n\t%s',templateReadmeFile);
        error('Desired template: %s does not exist!',templateReadmeFile);
    end

    % Attempt copy of template into current README
    [status,message] = copyfile(templateReadmeFile,readmeFilename,'f');
    if 1~=status
        warning('on','backtrace');
        warning('Unable to copy templateReadmeFile: \n\t%s \nto file: \n\t%s',templateReadmeFile,readmeFilename);
        warning('Message given was: \n\t%s',message);
        error('Unable to complete copy of file?');
    else
        fprintf(1,'Copying template file to start new README for the directory: ');
        fcn_DebugTools_cprintf('*green','(success)\n');
    end

    fid = fopen(readmeFilename,'a'); % Open file for writing, append mode
else
    fid = 1;
end

% Specify the bagQueryString
fileQueryString = '*.bag'; % The more specific, the better to avoid accidental loading of wrong information

% Specify the flag_fileOrDirectory
flag_fileOrDirectory = 0; % A file

% Call the function
directory_filelist = fcn_DataClean_listDirectoryContents(sourceUnsortedBagDirectory, (fileQueryString), (flag_fileOrDirectory), (-1));

% Check the results
assert(isstruct(directory_filelist));
assert(length(directory_filelist)>1);

%%%%%
% Sort them by time
Nfiles = length(directory_filelist);
timeNumbers = datetime(zeros(Nfiles,1), 0, 0);
for ith_file = 1:Nfiles
    fileName = directory_filelist(ith_file).name;
    timeNumbers(ith_file,1) = fcn_INTERNAL_findTimeFromName(fileName);
end

% Sort them
[~,sortedIndex] = sort(timeNumbers);

sorted_directory_filelist = directory_filelist(sortedIndex);

%%%%
% Print the results
if 1==flag_printMarkdownReady
    fprintf(fid,'Folder: %s\n',identifierString);
else
    fprintf(fid,'\nCONTENTS FOUND:\n');
end

% Print the fields
previousDirectory = '';
for jth_file = 1:length(sorted_directory_filelist)
    thisFolder = sorted_directory_filelist(jth_file).folder;

    % If directory is NOT the same as the previous print, print the
    % directory name. This print will have different formats depending on
    % whether it is to a README or to the console.
    if ~strcmp(thisFolder,previousDirectory)
        % Update the previous directory variable for this new directory
        previousDirectory = thisFolder;

        % Are we printing to a README?
        if 1==flag_printMarkdownReady

            % Yes - printing to a README. Need to make a "clean" header
            % string, one that converts the subdirectories into a good
            % print string.
            subFolderName = extractAfter(thisFolder,sourceUnsortedBagDirectory{1});
            directoryParts = split(subFolderName,filesep);
            if iscell(directoryParts)
                cleanString = '';
                for ith_part = 1:length(directoryParts)
                    if ~isempty(directoryParts{ith_part})
                        cleanString = cat(2,cleanString,directoryParts{ith_part},' ');
                    end
                end
            else
                cleanString = directoryParts;
            end
            fprintf(fid,'\n## %s\n',cleanString);
        else
            fprintf(fid,'Folder: %s\n',thisFolder);
        end
    end
    if (0==flag_fileOrDirectory) || (2==flag_fileOrDirectory)
        fprintf(fid,'\t%s\n',sorted_directory_filelist(jth_file).name);
    end
end


if 1==flag_printMarkdownReady
    fclose(fid);
    fid = 1;
end

%%%%
% Move/copy the files to root?
flag_moveNotCopy = 1; % Set to 1 to move, not copy. Set to 0 to copy (slower, but safer)

if 1==1
    fprintf(fid,'\nMOVING FILES:\n');

    % Move files into folders
    previousDirectory = '';
    for jth_file = 1:length(sorted_directory_filelist)
        thisFolder = sorted_directory_filelist(jth_file).folder;
        if ~strcmp(thisFolder,previousDirectory)
            previousDirectory = thisFolder;
            fprintf(fid,'Clearing folder: %s\n',thisFolder);
        end
        if (0==flag_fileOrDirectory) || (2==flag_fileOrDirectory)
            if 1==flag_moveNotCopy
                fprintf(fid,'\tMoving: %s  ',sorted_directory_filelist(jth_file).name);
            else
                fprintf(fid,'\tCopying: %s  ',sorted_directory_filelist(jth_file).name);
            end
        end

        thisFile = sorted_directory_filelist(jth_file).name;
        fullPathFile = fullfile(thisFolder,thisFile);

        if ~strcmp(destinationSortedBagDirectory,thisFolder)
            if 1==flag_moveNotCopy
                [status,message] = movefile(fullPathFile,destinationSortedBagDirectory,'f');
            else
                [status,message] = copyfile(fullPathFile,destinationSortedBagDirectory,'f');
            end
            if 1~=status
                warning('on','backtrace');
                warning('Unable to move/copy file: \n\t%s \nto folder: \n\t%s',fullPathFile,destinationSortedBagDirectory);
                warning('Message given was: \n\t%s',message);
                error('Unable to complete move/copy of file?');
            else
                fcn_DebugTools_cprintf('*green','(success)\n');
            end
        else
            fcn_DebugTools_cprintf('*blue','(no move needed)\n');
        end
    end
end




%% Test 1: Simple merge using data from Site 1 - Pittsburgh 
% Location for Pittsburgh, site 1
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.44181017');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-79.76090840');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','327.428');

%%%%
% Load the data

% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.

% For details on identifiers, see https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

% Specify the bagQueryString
bagQueryString = 'mapping_van_2024-07-1*'; % The more specific, the better to avoid accidental loading of wrong information

% Spedify the fid
fid = 0; % 1 --> print to console

% Specify the Flags
Flags = []; 

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'LargeData','2024-07-10'); % There are 5 data here
rootdirs{2} = fullfile(cd,'LargeData','2024-07-11');  % There are 52 data here

% List what will be saved
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = [];
plotFlags.fig_num_plotAllRawIndividually = [];

% Call the data loading function
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

%%%%
% Prepare for merging
% Specify the nearby time
thresholdTimeNearby = 10;

% Spedify the fid
fid = 1; % 1 --> print to console
readmeFilename = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario,'MergeProcessingMessages.txt');
fid = fopen(readmeFilename,'w');

% List what will be saved
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages_name = cat(2,Identifiers.WorkZoneScenario,'_merged');
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllMergedTogether = [];
plotFlags.fig_num_plotAllMergedIndividually = [];
    
plotFlags.mergedplotFormat.LineStyle = '-';
plotFlags.mergedplotFormat.LineWidth = 2;
plotFlags.mergedplotFormat.Marker = 'none';
plotFlags.mergedplotFormat.MarkerSize = 5;


% Call the function
[mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));

% Check the results
assert(iscell(mergedRawDataCellArray));
assert(iscell(uncommonFieldsCellArray));

%% Test 2: Simple merge using data from Site 2 - Falling Water

% Location for Site 2, Falling water
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','39.995339');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-79.445472');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');

%%%%
% Load the data

% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.

% For details on identifiers, see https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'PA653Normalville'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithTemporarySignals'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

% Specify the bagQueryString
bagQueryString = 'mapping_van_2024-08-22*'; % The more specific, the better to avoid accidental loading of wrong information

% Spedify the fid
fid = 1; % 1 --> print to console

% Specify the Flags
Flags = []; 

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'LargeData','ParsedBags_PoseOnly', 'OnRoad', 'PA653Normalville', '2024-08-22'); % Pre

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = 3333; % [];
plotFlags.fig_num_plotAllRawIndividually = 4444; %[];

% Call the data loading function
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

%%%%%%%%%%%%%%
% Prepare for merging
% Specify the nearby time
thresholdTimeNearby = 10;

% Spedify the fid
% fid = 1; % 1 --> print to console
readmeFilename = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario,'MergeProcessingMessages.txt');
fid = fopen(readmeFilename,'w');

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages_name = cat(2,Identifiers.WorkZoneScenario,'_merged');
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllMergedTogether = 1111; %[];
plotFlags.fig_num_plotAllMergedIndividually = 2222; %[];
    
plotFlags.mergedplotFormat.LineStyle = '-';
plotFlags.mergedplotFormat.LineWidth = 2;
plotFlags.mergedplotFormat.Marker = 'none';
plotFlags.mergedplotFormat.MarkerSize = 5;


% Call the function
[mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));

% Check the results
assert(iscell(mergedRawDataCellArray));
assert(iscell(uncommonFieldsCellArray));

%% Test 3: Simple merge using data from Site 3 - Line Painting - PRE
% Location for Aliquippa, site 3
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.694871');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-80.263755');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','223.294');

%%%%
% Load the data for the "PRE" portion

% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.

% For details on identifiers, see https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'PA51Aliquippa'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzone'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

% Specify the bagQueryString
bagQueryString = 'mapping_van_2024-09-19*'; % The more specific, the better to avoid accidental loading of wrong information
% bagQueryString = 'mapping_van_2024-09-19-13-04-*'; % The more specific, the better to avoid accidental loading of wrong information


% Spedify the fid
fid = 1; % 1 --> print to console

% Specify the Flags
Flags = []; 

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'LargeData','ParsedBags_PoseOnly', 'OnRoad', 'PA51Aliquippa', '2024-09-19'); % Pre
% rootdirs{1} = fullfile(cd,'LargeData','2024-09-20'); % Post

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = 1111; %[];
plotFlags.fig_num_plotAllRawIndividually = 2222; %[];

% Call the data loading function
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

%%%%
% Prepare for merging
% Specify the nearby time
thresholdTimeNearby = 10;

% Spedify the fid
% fid = 1; % 1 --> print to console
readmeFilename = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario,'MergeProcessingMessages.txt');
fid = fopen(readmeFilename,'w');

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages_name = cat(2,Identifiers.WorkZoneScenario,'_merged');
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllMergedTogether = 3333; %[];
plotFlags.fig_num_plotAllMergedIndividually = 4444; %[];
    
plotFlags.mergedplotFormat.LineStyle = '-';
plotFlags.mergedplotFormat.LineWidth = 2;
plotFlags.mergedplotFormat.Marker = 'none';
plotFlags.mergedplotFormat.MarkerSize = 5;


% Call the function
[mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));

% Check the results
assert(iscell(mergedRawDataCellArray));
assert(iscell(uncommonFieldsCellArray));

%% Test 3: Simple merge using data from Site 3 - Line Painting - POST
% Location for Aliquippa, site 3
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.694871');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-80.263755');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','223.294');

%%%%
% Load the data for the "PRE" portion

% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.

% For details on identifiers, see https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'PA51Aliquippa'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzone'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

% Specify the bagQueryString
bagQueryString = 'mapping_van_2024-09-20*'; % The more specific, the better to avoid accidental loading of wrong information

% Spedify the fid
fid = 1; % 1 --> print to console

% Specify the Flags
Flags = []; 

% List which directory/directories need to be loaded
clear rootdirs
% rootdirs{1} = fullfile(cd,'LargeData','ParsedBags_PoseOnly', 'OnRoad', 'PA51Aliquippa', '2024-09-19'); % Pre
rootdirs{1} = fullfile(cd,'LargeData','ParsedBags_PoseOnly', 'OnRoad', 'PA51Aliquippa', '2024-09-20'); % Post

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = 111; %[];
plotFlags.fig_num_plotAllRawIndividually = 2222; %[];

% Call the data loading function
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

%%%%
% Prepare for merging
% Specify the nearby time
thresholdTimeNearby = 10;

% Spedify the fid
% fid = 1; % 1 --> print to console
readmeFilename = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario,'MergeProcessingMessages.txt');
fid = fopen(readmeFilename,'w');

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages_name = cat(2,Identifiers.WorkZoneScenario,'_merged');
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllMergedTogether = 333; % [];
plotFlags.fig_num_plotAllMergedIndividually = 4444; %[];
    
plotFlags.mergedplotFormat.LineStyle = '-';
plotFlags.mergedplotFormat.LineWidth = 2;
plotFlags.mergedplotFormat.Marker = 'none';
plotFlags.mergedplotFormat.MarkerSize = 5;


% Call the function
[mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));

% Check the results
assert(iscell(mergedRawDataCellArray));
assert(iscell(uncommonFieldsCellArray));

%% Test 3: Simple merge using data from Site 3 - Line Painting - ALL
% Location for Aliquippa, site 3
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.694871');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-80.263755');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','223.294');

%%%%
% Load the data for the "PRE" portion

% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.

% For details on identifiers, see https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'PA51Aliquippa'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzone'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

% Specify the bagQueryString
bagQueryString = 'mapping_van_2024-09-*'; % The more specific, the better to avoid accidental loading of wrong information

% Spedify the fid
fid = 1; % 1 --> print to console

% Specify the Flags
Flags = []; 

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'LargeData','ParsedBags_PoseOnly', 'OnRoad', 'PA51Aliquippa', '2024-09-19'); % Pre
rootdirs{2} = fullfile(cd,'LargeData','ParsedBags_PoseOnly', 'OnRoad', 'PA51Aliquippa', '2024-09-20'); % Post

% List what will be saved
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = []; % 3333;
plotFlags.fig_num_plotAllRawIndividually = []; %4444;

% Call the data loading function
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

%%%%
% Prepare for merging
% Specify the nearby time
thresholdTimeNearby = 10;

% Spedify the fid
fid = 1; % 1 --> print to console
% consoleFname = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario,'MergeProcessingMessages.txt');
% fid = fopen(consoleFname,'w');

% List what will be saved
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages_name = cat(2,Identifiers.WorkZoneScenario,'_merged');
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllMergedTogether = [];
plotFlags.fig_num_plotAllMergedIndividually = []; %2222;
    
plotFlags.mergedplotFormat.LineStyle = '-';
plotFlags.mergedplotFormat.LineWidth = 2;
plotFlags.mergedplotFormat.Marker = 'none';
plotFlags.mergedplotFormat.MarkerSize = 5;


% Call the function
[mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));

% Check the results
assert(iscell(mergedRawDataCellArray));
assert(iscell(uncommonFieldsCellArray));

%% Test 10016: Test track scenario 1.6
% Location for Test Track base station
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');


%%%%
% Load the data

% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.

% For details on identifiers, see https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'TestTrack'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = '1.6'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

% Specify the bagQueryString
mappingDate = '2024-09-17';
bagQueryString = cat(2,'mapping_van_',mappingDate,'*'); % The more specific, the better to avoid accidental loading of wrong information

% Spedify the fid
fid = 1; % 1 --> print to console

% Specify the Flags
Flags = []; 

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'LargeData','ParsedBags_PoseOnly',Identifiers.ProjectStage,cat(2,'Scenario ',Identifiers.WorkZoneScenario),mappingDate); 

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,cat(2,'Scenario ',Identifiers.WorkZoneScenario));
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,cat(2,'Scenario ',Identifiers.WorkZoneScenario));
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = 10016;
plotFlags.fig_num_plotAllRawIndividually = 11016;

% Call the data loading function
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

%%%%%
% Prepare for merging
% Specify the nearby time
thresholdTimeNearby = 10;

% Spedify the fid
fid = 1; % 1 --> print to console
% consoleFname = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario,'MergeProcessingMessages.txt');
% fid = fopen(consoleFname,'w');

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,cat(2,'Scenario ',Identifiers.WorkZoneScenario));
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,cat(2,'Scenario ',Identifiers.WorkZoneScenario));
saveFlags.flag_saveImages_name = cat(2,Identifiers.WorkZoneScenario,'_merged');
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllMergedTogether = 1111;
plotFlags.fig_num_plotAllMergedIndividually = 2222;
    
plotFlags.mergedplotFormat.LineStyle = '-';
plotFlags.mergedplotFormat.LineWidth = 2;
plotFlags.mergedplotFormat.Marker = 'none';
plotFlags.mergedplotFormat.MarkerSize = 5;
plotFlags.mergedplotFormat.Color = [1 1 0];


% Call the function
[mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));

% Check the results
assert(iscell(mergedRawDataCellArray));
assert(iscell(uncommonFieldsCellArray));



%% Load all raw data from bag files into MAT files
testingConditions = {
    '2024-07-10','I376ParkwayPitt';
    '2024-07-11','I376ParkwayPitt';
    '2024-08-15','4.1a';
    '2024-08-15','4.3'; % NOT done
    '2024-08-22','PA653Normalville';
    '2024-09-04','5.1a';
    '2024-09-13','5.2';
    '2024-09-17','1.6';
    '2024-09-19','PA51Aliquippa';
    '2024-09-20','PA51Aliquippa';
    };

sizeConditions = size(testingConditions);
allData = cell(sizeConditions(1),1);
for ith_scenarioTest = 1:sizeConditions(1)
    mappingDate = testingConditions{ith_scenarioTest,1};
    scenarioString = testingConditions{ith_scenarioTest,2};

    
    % Grab the identifiers. NOTE: this also sets the reference location for
    % plotting.
    Identifiers = fcn_INTERNAL_identifyDataByScenarioDate(scenarioString, mappingDate);

    % Specify the bagQueryString
    bagQueryString = cat(2,'mapping_van_',mappingDate,'*'); % The more specific, the better to avoid accidental loading of wrong information

    % Spedify the fid
    fid = 1; % 1 --> print to console

    % Specify the Flags
    Flags = [];

    % List which directory/directories need to be loaded
    clear rootdirs
    if ~isnan(str2double(scenarioString(1)))
        fullScenarioString = cat(2,'Scenario ',Identifiers.WorkZoneScenario);
    else
        fullScenarioString = scenarioString;
    end
    rootdirs{1} = fullfile(cd,'LargeData','ParsedBags_PoseOnly',Identifiers.ProjectStage,fullScenarioString,mappingDate);

    % List what will be saved
    saveFlags.flag_saveMatFile = 1;
    saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,cat(2,'Scenario ',Identifiers.WorkZoneScenario));
    saveFlags.flag_saveImages = 1;
    saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,cat(2,'Scenario ',Identifiers.WorkZoneScenario));
    saveFlags.flag_forceDirectoryCreation = 1;
    saveFlags.flag_forceImageOverwrite = 1;
    saveFlags.flag_forceMATfileOverwrite = 1;

    % List what will be plotted, and the figure numbers
    plotFlags.fig_num_plotAllRawTogether = 10016;
    plotFlags.fig_num_plotAllRawIndividually = 11016;

    % Call the data loading function
    allData{ith_scenarioTest}.rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));
end

%% Test 999: Simple merge, not verbose
% fig_num = 1;
% figure(fig_num);
% clf;

%%%%
% Load the data

% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.

clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

% Specify the bagQueryString
bagQueryString = 'mapping_van_2024-07-1*'; % The more specific, the better to avoid accidental loading of wrong information

% Spedify the fid
fid = 0; % 1 --> print to console

% Specify the Flags
Flags = []; 

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'LargeData','2024-07-10');
rootdirs{2} = fullfile(cd,'LargeData','2024-07-11');

% List what will be saved
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_forceDirectoryCreation = 0;
saveFlags.flag_forceImageOverwrite = 0;
saveFlags.flag_forceMATfileOverwrite = 0;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = [];
plotFlags.fig_num_plotAllRawIndividually = [];

% Call the data loading function
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));


%%
% Prepare for merging
% Specify the nearby time
thresholdTimeNearby = 10;

% Spedify the fid
fid = []; % 1 --> print to console

% List what will be saved
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages_name = cat(2,Identifiers.WorkZoneScenario,'_merged');
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllMergedTogether = [];
plotFlags.fig_num_plotAllMergedIndividually = [];
    
plotFlags.mergedplotFormat.LineStyle = '-';
plotFlags.mergedplotFormat.LineWidth = 2;
plotFlags.mergedplotFormat.Marker = 'none';
plotFlags.mergedplotFormat.MarkerSize = 5;


% Call the function
[mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));

% Check the results
assert(iscell(mergedRawDataCellArray));
assert(iscell(uncommonFieldsCellArray));


%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagName, bagName);
end


%% fcn_INTERNAL_identifyDataByScenarioDate
function Identifiers = fcn_INTERNAL_identifyDataByScenarioDate(scenarioString, dateString)

Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

if ~isnan(str2double(scenarioString(1)))
    % Location for Test Track base station
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');
    Identifiers.ProjectStage = 'TestTrack'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
elseif strcmp(scenarioString,'I376ParkwayPitt')
    % Location for Pittsburgh, site 1
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.44181017');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-79.76090840');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','327.428');
    Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
elseif strcmp(scenarioString,'PA653Normalville')
    % Location for Site 2, Falling water
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','39.995339');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-79.445472');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');
    Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
elseif strcmp(scenarioString,'PA51Aliquippa')
    % Location for Aliquippa, site 3
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.694871');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-80.263755');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','223.294');
    Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
else
    error('Unknown site: %s',scenarioString);    
end


%%%%
% Set the Identifiers
% For details on identifiers, see https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone

Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.WorkZoneScenario = scenarioString; % Can be one of the ~20 scenarios, see key

switch scenarioString
    case '1.1'
        Identifiers.WorkZoneDescriptor = 'ShoulderWorkWithMinorEncroachment'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.2'
        Identifiers.WorkZoneDescriptor = 'RoadClosureWithDetour'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.3'
        Identifiers.WorkZoneDescriptor = 'SelfRegulatingLaneShiftIntoOpposingLane'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.4'
        Identifiers.WorkZoneDescriptor = 'SelfRegulatingLaneShiftIntoCenterOfTurnLane'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.5'
        Identifiers.WorkZoneDescriptor = 'WorkInCenterTurnLane'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.6'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-09-17'};
    case '2.1'
        Identifiers.WorkZoneDescriptor = 'RoadClosureWithDetourAndNumberedTrafficRoute'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '2.2'
        Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithSelfRegulatingStopControl'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '2.3'
        Identifiers.WorkZoneDescriptor = 'LaneShiftToTemporaryRoadway'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '2.4'
        Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithTemporarySignals'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '3.1'
        Identifiers.WorkZoneDescriptor = 'MovingLaneClosure'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '4.1a'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLane'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '4.1b'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLanePennTurnpike'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '4.2'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneNearExitRamp'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};        
    case '4.3'
        Identifiers.WorkZoneDescriptor = 'WorkInEntranceRampWithStopControl'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-08-15'};
    case '5.1a'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzone'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '5.1b'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzonePennTurnpike'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '5.2'
        Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithTemporarySignals'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '6.1'
        Identifiers.WorkZoneDescriptor = 'LongTermShoulderUse'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case 'I376ParkwayPitt'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case 'PA653Normalville'
        Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithTemporarySignals'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case 'PA51Aliquippa'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzone'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-09-19','2024-09-20'};
        if strcmp(validDateStrings{1},dateString)
            Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        end
    otherwise
        warning('on','backtrace');
        warning('Unknown scenario given: %s',scenarioString);
        error('Unknown scenario given. Unable to continue.');
end

% Make sure the date string is valid
if ~any(strcmp(dateString,validDateStrings))
    warning('on','backtrace');
    warning('Invalid date string, %s, given for scenario: %s. Expecting one of:', dateString, scenarioString);    
    for ith_valid = 1:length(validDateStrings)
        fprintf(1,'\t%s\n',validDateStrings{ith_valid});
    end
    error('Unknown scenario given. Unable to continue.');
end
end % Ends fcn_INTERNAL_identifyDataByScenarioDate

%% fcn_INTERNAL_findTimeFromName
function timeNumber = fcn_INTERNAL_findTimeFromName(fileName)

timeString = [];
if length(fileName)>4
    splitName = strsplit(fileName,{'_','.'});
    for ith_split = 1:length(splitName)
        if contains(splitName{ith_split},'-')
            timeString = splitName{ith_split};
        end
    end
end
timeNumber = datetime(timeString,'InputFormat','yyyy-MM-dd-HH-mm-ss');
end % Ends fcn_INTERNAL_findTimeFromName