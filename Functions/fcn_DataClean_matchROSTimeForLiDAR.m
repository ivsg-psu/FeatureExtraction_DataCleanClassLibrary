function matched_dataStructure = fcn_DataClean_matchROSTimeForLiDAR(dataStructure,fid)

[cell_array_ROS_Time_start,sensor_names_ROS_Time]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS','first_row');
    [cell_array_ROS_Time_end,~]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS','last_row');
    [centiSeconds_GPS_cell,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'centiSeconds','GPS');
    centiSeconds_GPS = cell2mat(centiSeconds_GPS_cell);
    max_sampling_period_centiSeconds = max(centiSeconds_GPS);
    array_ROS_Time_start = cell2mat(cell_array_ROS_Time_start).';
    all_start_times_centiSeconds = ceil(100*array_ROS_Time_start/max_sampling_period_centiSeconds)*max_sampling_period_centiSeconds;
    % centitime_all_sensors_have_started_ROS_Time = max(all_start_times_centiSeconds);

    array_ROS_Time_end = cell2mat(cell_array_ROS_Time_end).';
    all_end_times_centiSeconds = floor(100*array_ROS_Time_end/max_sampling_period_centiSeconds)*max_sampling_period_centiSeconds;
    % 
    % Grab LiDARs Ros time
    [ROSTimeLidar,LiDARNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'ROS_Time','Lidar');
    [centiSecondsLiDARs, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'centiSeconds','Lidar');
    N_LiDAR_units = length(LiDARNames);
    for idx_LiDAR = 1:N_LiDAR_units
        LiDARName = LiDARNames{idx_LiDAR};
        if strcmp(LiDARName, 'LiDAR_Velodyne_Rear')
            ROSTime_LiDARVelodyne = ROSTimeLidar{idx_LiDAR};
            centiSeconds_LiDARVelodyne = centiSecondsLiDARs{idx_LiDAR};
        end
    end
    ROSTime_LiDARVelodyne_centiSeconds = round(100*ROSTime_LiDARVelodyne/centiSeconds_LiDARVelodyne)*centiSeconds_LiDARVelodyne;
    %
    all_start_times_centiSeconds = [all_start_times_centiSeconds; ROSTime_LiDARVelodyne_centiSeconds(1)];
    centitime_all_sensors_have_started_ROS_Time = max(all_start_times_centiSeconds);
    
    all_end_times_centiSeconds = [all_end_times_centiSeconds; ROSTime_LiDARVelodyne_centiSeconds(end)];
    centitime_all_sensors_have_ended_ROS_Time = min(all_end_times_centiSeconds);
   
    %% GPS units times are calibrated, the next step is to match time from other sensors to GPS time
    %% Use the average ROS time from GPS units as the common ROS time
    [ROSTime_GPS,GPSUnitsName] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'ROS_Time','GPS');
    [TriggerTime_GPS,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'Trigger_Time','GPS');
    [centiSeconds_GPS,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'centiSeconds','GPS');
    N_GPS_Units = length(GPSUnitsName);
    ROS_Time_all_GPS = [];
    for idx_gps_unit = 1:N_GPS_Units
        ROSTime = ROSTime_GPS{idx_gps_unit};
        ROS_Time_all_GPS = [ROS_Time_all_GPS, ROSTime];
    end
    ROSTime_common = mean(ROS_Time_all_GPS,2);
    centiSeconds_GPS_common = centiSeconds_GPS{1};

    ROSTime_common_centiSeconds_rounded = round(100*ROSTime_common/centiSeconds_GPS_common)*centiSeconds_GPS_common;
    [~,closest_idx_start] = min(abs(ROSTime_common_centiSeconds_rounded - centitime_all_sensors_have_started_ROS_Time));
    [~,closest_idx_end] = min(abs(ROSTime_common_centiSeconds_rounded - centitime_all_sensors_have_ended_ROS_Time));
    
    %%
    ROSTime_common_centiSeconds_rounded_valid = ROSTime_common_centiSeconds_rounded(closest_idx_start:closest_idx_end,:);
    ROSTime_LiDARVelodyne_centiSeconds_valid = ROSTime_LiDARVelodyne_centiSeconds(closest_idx_start_LiDAR:closest_idx_end_LiDAR,:);
    %% Use GPS common ROS time as a reference to match LiDAR, fill the element with nan if there is missing data
    matchedROSTime_Velodyne_centiSeconds = nan(size(ROSTime_common_centiSeconds_rounded_valid));
    for idx_time = 1:length(ROSTime_LiDARVelodyne_centiSeconds_valid)
        time_diff = abs(ROSTime_common_centiSeconds_rounded_valid-ROSTime_LiDARVelodyne_centiSeconds_valid(idx_time));
        [~,closest_idx] = min(time_diff);
        matchedROSTime_Velodyne_centiSeconds(closest_idx,:) = ROSTime_LiDARVelodyne_centiSeconds_valid(idx_time);

    end
   
    %%
  
    

    figure(142)
    clf
    plot(matchedROSTime_Velodyne_centiSeconds,'r-','linewidth',2)
    hold on
    plot(ROSTime_common_centiSeconds_rounded,'b-.','LineWidth',2)
    plot(ROSTime_common_centiSeconds_rounded_fixed,'g--','LineWidth',2)