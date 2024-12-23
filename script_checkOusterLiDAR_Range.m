%% Define Flags and Identifiers
Flags.flag_do_load_SICK = 0;
Flags.flag_do_load_Velodyne = 0;
Flags.flag_do_load_cameras = 0;
Flags.flag_do_load_all_data = 1;
Flags.flag_select_scan_duration = 0;
Flags.flag_do_load_GST = 0;
Flags.flag_do_load_VTG = 0;
Flags.flag_do_load_PVT = 0;
Flags.flag_do_load_Ouster = 1;
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'TestTrack'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

%% Load vehicle pose data
fid = 1;
clear TruckFollowingPoseOnlyCell
rootdirs{1} = fullfile(cd,'LargeData','2024-12-18');
bagQueryString = 'mapping_van_*';
RangeTestCell = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);

%%
OusterLiDARCell = RangeTestCell{2,1};
%%
if length(OusterLiDARCell)>1
    OusterLiDARMerged = fcn_DataClean_stitchStructures(OusterLiDARCell);
else
    OusterLiDARMerged = OusterLiDARCell;
end
%%
mainDataStructure = RangeTestCell{1};
mainDataStructureWithOuster = mainDataStructure;
mainDataStructureWithOuster.LiDAR_Ouster_Front = OusterLiDARMerged.Lidar_Ouster_Front;
%% Apply Data Clean -- time clean
cleanedDataStructure = fcn_DataClean_cleanData(mainDataStructure);
%%
OusterLiDAR_Scructure = mainDataStructureWithOuster.LiDAR_Ouster_Front;
Ouster_ROS_Time = OusterLiDAR_Scructure.ROS_Time;
Ouster_ROS_Time_Diff = diff(Ouster_ROS_Time);
Ouster_PointCloud_Cell = OusterLiDAR_Scructure.PointCloud;
N_scans = length(Ouster_PointCloud_Cell);


roi = [-5 10 -6 6 -3 1];

figure;
ax = axes;
axis(roi)
set(gcf,'outerposition',get(0,'screensize'));
% outputGIF = 'Ouster_Scan_Animation_30s.gif';
for idx_scan = 1:N_scans
    clf
    currentScan = Ouster_PointCloud_Cell{idx_scan};
    XYZ_Ouster_currentScan = currentScan(:,1:3);
    reflectivity_Ouster_currentScan = currentScan(:,4);
    ring_id_currentScan = currentScan(:,5);
    ptcloud_obj = pointCloud(XYZ_Ouster_currentScan, 'Intensity',reflectivity_Ouster_currentScan);
    valid_ring_indices = find(((ring_id_currentScan == 118)|(ring_id_currentScan==127)));
    roi_indices = findPointsInROI(ptcloud_obj,roi);
    % roi_indices = findPointsInROI(ptcloud_obj,roi);
    ptcloud_roi = select(ptcloud_obj, valid_ring_indices);
    % scatter3(ptcloud_roi.Location(:,1),ptcloud_roi.Location(:,2),ptcloud_roi.Location(:,3),20,ptcloud_roi.Intensity,'filled')
    pcshow(ptcloud_roi, "MarkerSize",30,'ColorSource','Intensity')
    axis(roi)
    xlabel('X [m]'); 
    ylabel('Y [m]'); 
    zlabel('Z [m]');
    drawnow;
    % frame = getframe(gcf);
    % img = frame2im(frame);
    % [imind, cm] = rgb2ind(img, 256);
    % if idx_scan == 1
    %     imwrite(imind, cm, outputGIF, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    % else
    %     imwrite(imind, cm, outputGIF, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    % end
end
%%
Relative_Distance_From_Ouster_to_RearRightGPSAntenna = [2.39, 0.76, 0.51]; % meter

%% Load ROI hand measurements
fid = 1;
rootdirs{1} = fullfile(cd,'LargeData','2024-12-06');
bagQueryString = 'HandMeasurements_2024-12-06*';
HandMeasurementsCell = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);