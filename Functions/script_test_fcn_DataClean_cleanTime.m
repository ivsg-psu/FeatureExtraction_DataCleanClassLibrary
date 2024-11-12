% script_test_fcn_DataClean_cleanTime.m
% tests fcn_DataClean_cleanTime.m

% Revision history
% 2024_09_09 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all

%% Test 1: Load and clean a single bag file
fig_num = 1;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


% fullExampleFilePath = fullfile(cd,'Data','ExampleData_cleanData.mat');
% fullExampleFilePath = fullfile(cd,'Data','ExampleData_cleanData2.mat');
fullExampleFilePath = fullfile(cd,'Data','ExampleData_cleanData3.mat');

load(fullExampleFilePath,'dataStructure')

%%%%%
% Run the command
fid = 1;
Flags = [];

% List what will be saved
Identifiers = dataStructure.Identifiers;
clear saveFlags
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

dataStructure_cleanedNames = fcn_DataClean_cleanNaming(dataStructure, (fid), (Flags), (-1));
dataStructure_cleanedTime = fcn_DataClean_cleanTime(dataStructure_cleanedNames, (fid), (Flags), (saveFlags), (plotFlags));

% Check the data
assert(isstruct(dataStructure_cleanedNames))


%% Test 1: Load all bag files from one given directory and all subdirectories
% fig_num = 1;
% if ~isempty(findobj('Number',fig_num))
%     figure(fig_num);
%     clf;
% end

% Grab the identifiers. NOTE: this also sets the reference location for
% plotting.
Identifiers = fcn_DataClean_identifyDataByScenarioDate('I376ParkwayPitt', '2024-07-10', 1,-1);

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


%%

%% Fail conditions
if 1==0
    %% ERROR situation: 
end
















