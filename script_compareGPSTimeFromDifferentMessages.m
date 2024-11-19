%% Define Flags and Identifiers
Flags.flag_do_load_SICK = 0;
Flags.flag_do_load_Velodyne = 1;
Flags.flag_do_load_cameras = 0;
Flags.flag_do_load_all_data = 1;
Flags.flag_select_scan_duration = 0;
Flags.flag_do_load_GST = 0;
Flags.flag_do_load_VTG = 0;

clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'TestTrack'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

%% Load static LiDAR scan
fid = 1;
clear rawDataCellArray
rootdirs{1} = fullfile(cd,'LargeData','2024-11-15','Lane 3');
bagQueryString = 'mapping_van_2024-11-15*';
rawDataCellArrayLaneOne = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);
%%
N_cells = length(rawDataCellArrayLaneOne);
flag_trigger_box_data_loss_array = [];
ROS_Time_Trigger_Box_CellArray = {};
Trigger_Mode_CellArray = {};
plot_colors_CellArray = {};

for idx_cell = 1:N_cells
    dataStructure = rawDataCellArrayLaneOne{idx_cell};
    [ROS_Time_Trigger_Box,ROS_Time_diff ,flag_trigger_box_data_loss]= fcn_DataClean_checkDataTimeConsistency_TriggerBox(dataStructure);
    flag_trigger_box_data_loss_array = [flag_trigger_box_data_loss_array; flag_trigger_box_data_loss];
    ROS_Time_Trigger_Box_CellArray{idx_cell,1} = ROS_Time_Trigger_Box;
    [Trigger_Mode_cell, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'mode','Trigger_Raw');
    Trigger_Mode = Trigger_Mode_cell{1};
    Trigger_Mode_CellArray{idx_cell,1} = Trigger_Mode;
    plot_colors = zeros(length(Trigger_Mode),3);

    plot_colors(Trigger_Mode == 'L',3) = 1;
    plot_colors(Trigger_Mode ~= 'L',1) = 1;
    plot_colors_CellArray{idx_cell,1} = plot_colors;
end
%%
cell_index_to_plot = 7;

ROS_Time_Trigger_Box = ROS_Time_Trigger_Box_CellArray{cell_index_to_plot};
Trigger_Mode = Trigger_Mode_CellArray{cell_index_to_plot};
Triggered_indices = find((Trigger_Mode=='L'));
UnTriggered_indices = find(~(Trigger_Mode=='L'));
N_times = length(ROS_Time_Trigger_Box);
% plot_colors = plot_colors_CellArray{cell_index_to_plot};
ROS_Time_Trigger_Box_ZeroStart = ROS_Time_Trigger_Box - ROS_Time_Trigger_Box(1);
figure(870)
clf
scatter(Triggered_indices, ROS_Time_Trigger_Box_ZeroStart(Triggered_indices,:), 10, 'blue','filled')
hold on
scatter(UnTriggered_indices, ROS_Time_Trigger_Box_ZeroStart(UnTriggered_indices,:), 10, 'red','filled')
% plot(1:N_times, ROS_Time_Trigger_Box - ROS_Time_Trigger_Box(1),'k-','LineWidth',2)
legend('Triggered Data', 'Untriggered Data')
xlabel('Time Index')
ylabel('ROS Time [s]')

ROS_Time_ave_triggered = mean(diff(ROS_Time_Trigger_Box(Triggered_indices,:)));
ROS_Time_ave_untriggered = mean(diff(ROS_Time_Trigger_Box(UnTriggered_indices,:)));
%%
OneMinute_rawData = rawDataCellArray{3};
[cell_array_GPS_Time, cell_array_GPS_Topics] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(OneMinute_rawData,'GPS_Time','gps');
[cell_array_ROS_Time, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(OneMinute_rawData,'ROS_Time','gps');
%% Use ROS_Time to find matched GPS_Time for two messages
format short
array_ROS_Time_GGA_Front = cell_array_ROS_Time{1};
array_ROS_Time_VTG_Front = cell_array_ROS_Time{2};
% GGA has longer length
ROS_Time_Dist = pdist2(array_ROS_Time_VTG_Front,array_ROS_Time_GGA_Front,'euclidean');
[~,closest_idx] = min(ROS_Time_Dist,[],2);
array_GPS_Time_GGA_Front = cell_array_GPS_Time{1};
array_GPS_Time_PVT_Front = cell_array_GPS_Time{2};
array_GPS_Time_GGA_Front_match = array_GPS_Time_GGA_Front(closest_idx,:);
GPS_Time_diff_GGA_to_PVT = array_GPS_Time_GGA_Front_match - array_GPS_Time_PVT_Front;
GPS_Time_diff_GGA_to_PVT_ms = GPS_Time_diff_GGA_to_PVT*1E6;
min(GPS_Time_diff_GGA_to_PVT_ms)
max(GPS_Time_diff_GGA_to_PVT_ms)
mean(GPS_Time_diff_GGA_to_PVT_ms)
std(GPS_Time_diff_GGA_to_PVT_ms)
%%
N_GPS_topics = length(cell_array_GPS_Topics);
figure(123)
clf
for idx_gps_topic = 1:2
    array_GPS_Time = cell_array_GPS_Time{idx_gps_topic} - array_ROS_Time_GGA_Front(1);
    array_ROS_Time = cell_array_ROS_Time{idx_gps_topic};
    plot(array_GPS_Time,'LineWidth',2)
    hold on
    % plot(array_ROS_Time,'LineWidth',2)

end
legend(cell_array_GPS_Topics{1:2})
xlabel('Index')
ylabel('GPS Time [s]')
%% Use ROS_Time to find matched GPS_Time for two messages
array_ROS_Time_GGA_Front = cell_array_ROS_Time{1};
array_ROS_Time_VTG_Front = cell_array_ROS_Time{2};
% GGA has longer length
ROS_Time_Dist = pdist2(array_ROS_Time_VTG_Front,array_ROS_Time_GGA_Front,'euclidean');
[~,closest_idx] = min(ROS_Time_Dist,[],2);
array_GPS_Time_GGA_Front = cell_array_GPS_Time{1};
array_GPS_Time_PVT_Front = cell_array_GPS_Time{2};
array_GPS_Time_GGA_Front_match = array_GPS_Time_GGA_Front(closest_idx,:);
GPS_Time_diff_GGA_to_PVT = array_GPS_Time_GGA_Front_match - array_GPS_Time_PVT_Front;
GPS_Time_diff_GGA_to_PVT_ms = GPS_Time_diff_GGA_to_PVT*1E6;

