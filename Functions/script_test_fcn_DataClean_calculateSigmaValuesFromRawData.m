%% Define Flags and Identifiers
Flags.flag_do_load_SICK = 0;
Flags.flag_do_load_Velodyne = 1;
Flags.flag_do_load_cameras = 0;
Flags.flag_do_load_all_data = 1;
Flags.flag_select_scan_duration = 0;
Flags.flag_do_load_GST = 0;
Flags.flag_do_load_VTG = 0;
Flags.flag_do_load_PVT = 0;

clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'TestTrack'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

%% Load test data sets
fid = 1;
clear rawDataCellArray
rootdirs{1} = fullfile(cd,'LargeData','2024-11-15','Lane 1');
bagQueryString = 'mapping_van_2024-11-15*';
rawDataCellArrayLaneOne = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);

%% Convert LLA to ENU and filled the XYZ fields

N_cell = length(rawDataCellArrayLaneOne);
rawDataWithENUCellArray = {};
for idx_cell = 1:N_cell
    rawDataStructure = rawDataCellArrayLaneOne{idx_cell};
    rawDataStructureWithENU = fcn_Transform_convertLLA2ENU(rawDataStructure);
    rawDataWithENUCellArray{idx_cell,1} = rawDataStructureWithENU;
  
end
%% Calculate velocities for GPS fields
N_cell = length(rawDataWithENUCellArray);
rawDataWithVelocityCellArray = {};
for idx_cell = 1:N_cell
    rawDataStructureWithENU = rawDataWithENUCellArray{idx_cell};
    rawDataStructureWithVelocity = fcn_DataClean_calculateGPSVelocity(rawDataStructureWithENU);
    rawDataWithVelocityCellArray{idx_cell,1} = rawDataStructureWithVelocity;
end
%% Calculate Sigmas
N_cell = length(rawDataWithVelocityCellArray);
rawDataWithSigmasCellArray = {};
for idx_cell = 1:N_cell
    rawDataStructureWithVelocity = rawDataWithVelocityCellArray{idx_cell};
    rawDataStructureWithSigmas = fcn_DataClean_calculateSigmaValuesFromRawData(rawDataStructureWithVelocity);
    rawDataWithSigmasCellArray{idx_cell,1} = rawDataStructureWithSigmas;
end

