% script_test_fcn_DataClean_loadRawDataFromDirectories.m
% tests fcn_DataClean_loadRawDataFromDirectories.m

% Revision history
% 2024_09_13 - sbrennan@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter

%% Set up the workspace
close all

%% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.


%% Test 1: Load all bag files from one given directory and all subdirectories
% fig_num = 1;
% figure(fig_num);
% clf;

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
fid = 1; % 1 --> print to console

% Specify the Flags
Flags = []; 

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'LargeData','2024-07-10');
% rootdirs{2} = fullfile(cd,'LargeData','2024-07-11');

% List what will be saved
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawData',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllRawTogether = []; %1111;
plotFlags.fig_num_plotAllRawIndividually = []; %2222;

% Call the function
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

% Check the results
assert(iscell(rawDataCellArray));


%% Test 2: Load all bag files from several given directories and all subdirectories
% fig_num = 2;
% figure(fig_num);
% clf;
if 1==0  % Change to 1==1 to see it work (slow)

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
    fid = 1; % 1 --> print to console

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
    saveFlags.flag_forceDirectoryCreation = 1;
    saveFlags.flag_forceImageOverwrite = 1;
    saveFlags.flag_forceMATfileOverwrite = 1;

    % List what will be plotted, and the figure numbers
    plotFlags.fig_num_plotAllRawTogether = []; %1111;
    plotFlags.fig_num_plotAllRawIndividually = []; %2222;

    % Call the function
    rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

    % Check the results
    assert(iscell(rawDataCellArray));
end

%% Test 3: Load all bag files from several given directories and all subdirectories, no plotting
% fig_num = 3;
% figure(fig_num);
% clf;

if 1==0  % Change to 1==1 to see it work (slow)
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
    plotFlags.fig_num_plotAllRawTogether = []; %[];
    plotFlags.fig_num_plotAllRawIndividually = []; %[];

    % Call the function
    rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags));

    % Check the results
    assert(iscell(rawDataCellArray));
end

%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagName, bagName);
end
