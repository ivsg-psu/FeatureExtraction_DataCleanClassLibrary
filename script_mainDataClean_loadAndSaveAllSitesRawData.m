% script_mainDataClean_loadAndSaveAllSitesRawData.m.m
% Loads and saves all site data. 
% Based on test script for: script_test_fcn_DataClean_mergeRawDataStructures.m

% Revision history
% 2024_09_28 - sbrennan@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter

%% Set up the workspace
close all

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____ _                 _        __  __                       ______                           _
%  / ____(_)               | |      |  \/  |                     |  ____|                         | |
% | (___  _ _ __ ___  _ __ | | ___  | \  / | ___ _ __ __ _  ___  | |__  __  ____ _ _ __ ___  _ __ | | ___  ___
%  \___ \| | '_ ` _ \| '_ \| |/ _ \ | |\/| |/ _ \ '__/ _` |/ _ \ |  __| \ \/ / _` | '_ ` _ \| '_ \| |/ _ \/ __|
%  ____) | | | | | | | |_) | |  __/ | |  | |  __/ | | (_| |  __/ | |____ >  < (_| | | | | | | |_) | |  __/\__ \
% |_____/|_|_| |_| |_| .__/|_|\___| |_|  |_|\___|_|  \__, |\___| |______/_/\_\__,_|_| |_| |_| .__/|_|\___||___/
%                    | |                              __/ |                                 | |
%                    |_|                             |___/                                  |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Simple%20Merge%20Examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
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
% fid = 1; % 1 --> print to console
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



%% Load all raw data and convert to MAT files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _                     _            _ _   _____                  _____        _          _       _          __  __       _______    __ _ _
% | |                   | |     /\   | | | |  __ \                |  __ \      | |        (_)     | |        |  \/  |   /\|__   __|  / _(_) |
% | |     ___   __ _  __| |    /  \  | | | | |__) |__ ___      __ | |  | | __ _| |_ __ _   _ _ __ | |_ ___   | \  / |  /  \  | |    | |_ _| | ___  ___
% | |    / _ \ / _` |/ _` |   / /\ \ | | | |  _  // _` \ \ /\ / / | |  | |/ _` | __/ _` | | | '_ \| __/ _ \  | |\/| | / /\ \ | |    |  _| | |/ _ \/ __|
% | |___| (_) | (_| | (_| |  / ____ \| | | | | \ \ (_| |\ V  V /  | |__| | (_| | || (_| | | | | | | || (_) | | |  | |/ ____ \| |    | | | | |  __/\__ \
% |______\___/ \__,_|\__,_| /_/    \_\_|_| |_|  \_\__,_| \_/\_/   |_____/ \__,_|\__\__,_| |_|_| |_|\__\___/  |_|  |_/_/    \_\_|    |_| |_|_|\___||___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Load%20All%20Raw%20Data%20into%20MAT%20files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% List which directory/directories need to be loaded
DriveRoot = 'F:\Adrive';
% rawBagRoot                  = cat(2,DriveRoot,'\MappingVanData\RawBags');
poseOnlyParsedBagRoot       = cat(2,DriveRoot,'\MappingVanData\ParsedBags_PoseOnly');
% fullParsedBagRoot           = cat(2,DriveRoot,'\MappingVanData\ParsedBags');
parsedMATLAB_PoseOnly       = cat(2,DriveRoot,'\MappingVanData\ParsedMATLAB_PoseOnly\RawData');
% parsedMATLAB_PoseOnlyMerged = cat(2,DriveRoot,'\MappingVanData\ParsedMATLAB_PoseOnly\RawDataMerged');
% mergedTimeCleaned           = cat(2,DriveRoot,'\MappingVanData\ParsedMATLAB_PoseOnly\Merged_01_TimeCleaned');
% mergedDataCleaned           = cat(2,DriveRoot,'\MappingVanData\ParsedMATLAB_PoseOnly\Merged_02_DataCleaned');
% mergedKalmanFiltered        = cat(2,DriveRoot,'\MappingVanData\ParsedMATLAB_PoseOnly\Merged_03_KalmanFiltered');

% Make sure folders exist!
% fcn_INTERNAL_confirmDirectoryExists(rawBagSearchDirectory);
fcn_INTERNAL_confirmDirectoryExists(poseOnlyParsedBagRoot);
% fcn_INTERNAL_confirmDirectoryExists(fullParsedBagRootDirectory);
fcn_INTERNAL_confirmDirectoryExists(parsedMATLAB_PoseOnly);
% fcn_INTERNAL_confirmDirectoryExists(parsedMATLAB_PoseOnlyMergedDirectory);
% fcn_INTERNAL_confirmDirectoryExists(mergedTimeCleanedDirectory);
% fcn_INTERNAL_confirmDirectoryExists(mergedDataCleanedDirectory);
% fcn_INTERNAL_confirmDirectoryExists(mergedKalmanFilteredDirectory);


% Below were run on 11/07/2024
testingConditions = {
    % '2024-02-01','4.2'; % NOT parsed - bad data
    '2024-02-06','4.3';             % Done - confirmed on 2024-11-07
    % '2024-04-19','2.3'; % NOT parsed
    '2024-06-24','I376ParkwayPitt'; % Done - confirmed on 2024-11-07
    % '2024-06-28','4.1b'; % NOT parsed
    '2024-07-10','I376ParkwayPitt'; % Done - confirmed on 2024-11-07
    '2024-07-11','I376ParkwayPitt'; % Done - confirmed on 2024-11-07
    '2024-08-05','BaseMap';         % Done - confirmed on 2024-11-07
    '2024-08-12','BaseMap';         % Done - confirmed on 2024-11-07
    '2024-08-13','BaseMap';         % Done - confirmed on 2024-11-07
    '2024-08-14','4.1a';            % Done - confirmed on 2024-11-07
    '2024-08-15','4.1a';            % Done - confirmed on 2024-11-07
    '2024-08-15','4.3';             % Done - confirmed on 2024-11-07
    '2024-08-22','PA653Normalville';% Done - confirmed on 2024-11-07
    '2024-09-04','5.1a';            % Done - confirmed on 2024-11-07
    '2024-09-13','5.2';             % Done - confirmed on 2024-11-07
    '2024-09-17','1.6';             % Done - confirmed on 2024-11-07
    '2024-09-19','PA51Aliquippa';   % Done - confirmed on 2024-11-07
    '2024-09-20','PA51Aliquippa';   % Done - confirmed on 2024-11-07
    '2024-10-16','I376ParkwayPitt'; % Done - confirmed on 2024-11-07
    '2024-10-24','4.1b'; 
    '2024-10-31','6.1'; 
    };

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveImages = 1;
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = 10016;
plotFlags.fig_num_plotAllRawIndividually = 11016;


sizeConditions = size(testingConditions);
allData = cell(sizeConditions(1),1);
for ith_scenarioTest = 18:sizeConditions(1)
    mappingDate = testingConditions{ith_scenarioTest,1};
    scenarioString = testingConditions{ith_scenarioTest,2};

    
    % Grab the identifiers. NOTE: this also sets the reference location for
    % plotting.
    Identifiers = fcn_DataClean_identifyDataByScenarioDate(scenarioString, mappingDate, 1,-1);


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
    rootdirs{1} = fullfile(poseOnlyParsedBagRoot,Identifiers.ProjectStage,fullScenarioString,mappingDate);

    % List what will be saved
    saveFlags.flag_saveMatFile_directory = fullfile(parsedMATLAB_PoseOnly,Identifiers.ProjectStage,fullScenarioString);
    saveFlags.flag_saveImages_directory  = fullfile(parsedMATLAB_PoseOnly,Identifiers.ProjectStage,fullScenarioString);

    % Call the data loading function
    close all;
    allData{ith_scenarioTest}.rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

end

% % For debugging
% allData{ith_scenarioTest}.rawDataCellArray{2}.GPS_SparkFun_RightRear_GGA.GPS_Time(1:10,:) - allData{ith_scenarioTest}.rawDataCellArray{1}.GPS_SparkFun_RightRear_GGA.GPS_Time(1,1)
% allData{ith_scenarioTest}.rawDataCellArray{2}.GPS_SparkFun_LeftRear_GGA.GPS_Time(1:10,:)  - allData{ith_scenarioTest}.rawDataCellArray{1}.GPS_SparkFun_LeftRear_GGA.GPS_Time(1,1)
% allData{ith_scenarioTest}.rawDataCellArray{2}.GPS_SparkFun_Front_GGA.GPS_Time(1:10,:) - allData{ith_scenarioTest}.rawDataCellArray{1}.GPS_SparkFun_Front_GGA.GPS_Time(1,1)

%% Merge all MAT files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  __  __                                _ _   __  __       _______   ______ _ _
% |  \/  |                         /\   | | | |  \/  |   /\|__   __| |  ____(_) |
% | \  / | ___ _ __ __ _  ___     /  \  | | | | \  / |  /  \  | |    | |__   _| | ___  ___
% | |\/| |/ _ \ '__/ _` |/ _ \   / /\ \ | | | | |\/| | / /\ \ | |    |  __| | | |/ _ \/ __|
% | |  | |  __/ | | (_| |  __/  / ____ \| | | | |  | |/ ____ \| |    | |    | | |  __/\__ \
% |_|  |_|\___|_|  \__, |\___| /_/    \_\_|_| |_|  |_/_/    \_\_|    |_|    |_|_|\___||___/
%                   __/ |
%                  |___/
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Merge%20All%20MAT%20Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


poseOnlyParsedMATLABRootMerged_PoseOnly   = 'F:\MappingVanData\ParsedMATLAB_PoseOnly\RawDataMerged';

% Prepare for merging
% Specify the nearby time
thresholdTimeNearby = 10;

% Spedify the fid
fid = 1; % 1 --> print to console
% consoleFname = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario,'MergeProcessingMessages.txt');
% fid = fopen(consoleFname,'w');

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveImages = 1;
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


for ith_scenarioTest = 3:length(allData)
    mappingDate = testingConditions{ith_scenarioTest,1};
    scenarioString = testingConditions{ith_scenarioTest,2};

    
    % Grab the identifiers. NOTE: this also sets the reference location for
    % plotting.
    Identifiers = fcn_DataClean_identifyDataByScenarioDate(scenarioString, mappingDate, 1,-1);

    if ~isnan(str2double(scenarioString(1)))
        fullScenarioString = cat(2,'Scenario ',Identifiers.WorkZoneScenario);
    else
        fullScenarioString = scenarioString;
    end

    saveFlags.flag_saveMatFile_directory = fullfile(poseOnlyParsedMATLABRootMerged_PoseOnly,Identifiers.ProjectStage,fullScenarioString);
    saveFlags.flag_saveImages_directory  = fullfile(poseOnlyParsedMATLABRootMerged_PoseOnly,Identifiers.ProjectStage,fullScenarioString);
    saveFlags.flag_saveImages_name = cat(2,fullScenarioString,'_merged');


    % Call the function
    fcn_DataClean_mergeRawDataStructures(allData{ith_scenarioTest}.rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));
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



%% fcn_INTERNAL_confirmDirectoryExists
function fcn_INTERNAL_confirmDirectoryExists(directoryName)
if 7~=exist(directoryName,'dir')
    warning('on','backtrace');
    warning('Unable to find folder: \n\t%s',directoryName);
    error('Desired directory: %s does not exist!',directoryName);
end
end % Ends fcn_INTERNAL_confirmDirectoryExists
