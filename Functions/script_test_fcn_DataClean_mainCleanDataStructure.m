script_test_fcn_DataClean_mainCleanDataStructure
% script_test_fcn_DataClean_mainCleanDataStructure.m
% tests fcn_DataClean_mainCleanDataStructure.m

% Revision history
% 2024_09_23 - xfc5113@psu.edu
% -- wrote the code originally
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

ref_basestation_TestTrack = [40.86368573, -77.83592832, 344.189];

% 
output_dataset = fcn_DataClean_mainCleanDataStructure(rawData,ref_basestation_TestTrack);
% Check the data
assert(iscell(output_dataset))

%%
