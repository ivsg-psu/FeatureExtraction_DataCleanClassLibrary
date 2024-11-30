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

%% Load test data set 
fid = 1;
clear rawDataCellArray
rootdirs{1} = fullfile(cd,'LargeData','TestOnly');
bagQueryString = 'mapping_van_2024-11-25*';
rawDataCellArrayLaneOne = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);
%%
dataStructure = rawDataCellArrayLaneOne{1};
flag_recalculate_ROS_Time = fcn_DataClean_checkDataTimeConsistency_LiDARVelodyne(dataStructure);

%%
flag_recalculate_ROS_Time = 1;
if flag_recalculate_ROS_Time == 1
    recalculated_dataStructure = fcn_DataClean_calculateROSTimeforVelodyneLiDAR(dataStructure);
end