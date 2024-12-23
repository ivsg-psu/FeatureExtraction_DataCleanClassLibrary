%% Define Flags and Identifiers
Flags.flag_do_load_SICK = 0;
Flags.flag_do_load_Velodyne = 1;
Flags.flag_do_load_cameras = 0;
Flags.flag_do_load_all_data = 1;
Flags.flag_select_scan_duration = 0;
Flags.flag_do_load_GST = 0;
Flags.flag_do_load_VTG = 0;
Flags.flag_do_load_PVT = 0;
Flags.flag_do_load_Ouster = 0;
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
rootdirs{1} = fullfile(cd,'LargeData','Ouster Test');
bagQueryString = 'mapping_van_2024-11-26*';
TruckFollowingPoseOnlyCell = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);

%% Load Ouster LiDAR scan
Flags.flag_do_load_Ouster = 1;
bagQueryString = 'mapping_van_OusterO1_Raw_2024-11-26-16-26*';
TruckFollowingOusterScan = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);
%%
OusterLiDAR_Scructure = TruckFollowingOusterScan{1}.Lidar_Velodyne_Rear;
%%
Ouster_ROS_Time = OusterLiDAR_Scructure.ROS_Time;
Ouster_ROS_Time_Diff = diff(Ouster_ROS_Time);
Ouster_PointCloud_Cell = OusterLiDAR_Scructure.PointCloud;
N_scans = length(Ouster_PointCloud_Cell);


roi = [-10 60 -10 25 -5 5];

figure;
ax = axes;
axis(roi)
set(gcf,'outerposition',get(0,'screensize'));
outputGIF = 'Ouster_Scan_Animation_30s.gif';
for idx_scan = 1:300
    clf
    currentScan = Ouster_PointCloud_Cell{idx_scan};
    XYZ_Ouster_currentScan = currentScan(:,1:3);
    reflectivity_Ouster_currentScan = currentScan(:,4);
    
    ptcloud_obj = pointCloud(XYZ_Ouster_currentScan, 'Intensity',reflectivity_Ouster_currentScan);
   
    roi_indices = findPointsInROI(ptcloud_obj,roi);
    ptcloud_roi = select(ptcloud_obj, roi_indices);
    % scatter3(ptcloud_roi.Location(:,1),ptcloud_roi.Location(:,2),ptcloud_roi.Location(:,3),20,ptcloud_roi.Intensity,'filled')
    pcshow(ptcloud_roi, "MarkerSize",30,'ColorSource','Intensity')
    axis(roi)
    xlabel('X [m]'); 
    ylabel('Y [m]'); 
    zlabel('Z [m]');
    drawnow;
    frame = getframe(gcf);
    img = frame2im(frame);
    [imind, cm] = rgb2ind(img, 256);
    if idx_scan == 1
        imwrite(imind, cm, outputGIF, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        imwrite(imind, cm, outputGIF, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
end


%% Load fields Ouster LiDAR scan
tic;
Flags.flag_do_load_Ouster = 1;
fid = 1;
clear TruckFollowingPoseOnlyCell
rootdirs{1} = fullfile(cd,'LargeData','2024-10-26');
bagQueryString = 'mapping_van_OusterO1_Raw_2024-10-16-15*';
SiteOneInFieldsCell = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);
toc;
%%
OusterLiDAR_Scructure = SiteOneInFieldsCell{1}.Lidar_Ouster_Front;
%%
close all
Ouster_ROS_Time = OusterLiDAR_Scructure.ROS_Time;
Ouster_ROS_Time_Diff = diff(Ouster_ROS_Time);
Ouster_PointCloud_Cell = OusterLiDAR_Scructure.PointCloud;
N_scans = length(Ouster_PointCloud_Cell);

set(gcf,'outerposition',get(0,'screensize'));
outputGIF = 'Ouster_Scan_Animation.gif';
roi = [-30 60 -10 10 -5 5];


ax = axes;
axis(roi)
set(gcf,'outerposition',get(0,'screensize'));
outputGIF = 'Ouster_Scan_Animation.gif';
for idx_scan = 1:100
    clf
    currentScan = Ouster_PointCloud_Cell{idx_scan};
    XYZ_Ouster_currentScan = currentScan(:,1:3);
    reflectivity_Ouster_currentScan = currentScan(:,4);
    
    ptcloud_obj = pointCloud(XYZ_Ouster_currentScan, 'Intensity',reflectivity_Ouster_currentScan);
   
    roi_indices = findPointsInROI(ptcloud_obj,roi);
    ptcloud_roi = select(ptcloud_obj, roi_indices);
    % scatter3(ptcloud_roi.Location(:,1),ptcloud_roi.Location(:,2),ptcloud_roi.Location(:,3),20,ptcloud_roi.Intensity,'filled')
    pcshow(ptcloud_roi, "MarkerSize",30)
    axis(roi)
    xlabel('X [m]'); 
    ylabel('Y [m]'); 
    zlabel('Z [m]');
    drawnow;
    frame = getframe(gcf);
    img = frame2im(frame);
    [imind, cm] = rgb2ind(img, 256);
    if idx_scan == 1
        imwrite(imind, cm, outputGIF, 'gif', 'Loopcount', inf, 'DelayTime', 0.5);
    else
        imwrite(imind, cm, outputGIF, 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
    end
end

%% Load fields Ouster LiDAR scan PCL version
tic
Flags.flag_do_load_Ouster = 1;
fid = 1;
clear TruckFollowingPoseOnlyCell
rootdirs{1} = fullfile(cd,'LargeData','2024-10-26');
bagQueryString = 'mapping_van_OusterO1_Raw_2024-10-16-15-09*';
SiteOneInFieldsCell = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);
toc
%%
%% Load fields Velodyne LiDAR scan PCL version
tic
Flags.flag_do_load_Velodyne = 1;
fid = 1;
clear TruckFollowingPoseOnlyCell
rootdirs{1} = fullfile(cd,'LargeData','2024-10-26');
bagQueryString = 'mapping_van_2024-10-16*';
CellwithVelodyne = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);
toc