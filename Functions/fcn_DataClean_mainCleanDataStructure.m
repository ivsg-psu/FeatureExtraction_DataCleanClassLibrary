function dataset = fcn_DataClean_mainCleanDataStructure(dataset,ref_basestation)


%% Start the looping process to iteratively clean data
% The method used below is as follows:
% -- The data is initialized before the loop by loading (see above)
% -- The loop is started, and for each version of the loop, the data is
%    checked to see if there are any errors measured in the data.
% -- For each error type, a flag is set that is used to initiate a process
%    that seeks to remove that type of error.
% 
% For example: say the data has wrap-around error on yaw angle due to angle
% roll-over. This is checked and reported, and a function is called if this
% is detected to fix that error.

flag_stay_in_main_loop = 1;
N_max_loops = 30;

% Preallocate the data array

main_data_clean_loop_iteration_number = 1; % The first iteration corresponds to the raw data loading
flag_trim_with_ROSTime = 1;
fid = 1;
%%
while 1==flag_stay_in_main_loop
    dataStructure = dataset{end};    
    main_data_clean_loop_iteration_number = main_data_clean_loop_iteration_number+1;
    %% Data cleaning processes to fix the latest error start here
    flag_keep_checking = 1; % Flag to keep checking (1), or to indicate a data correction is done and checking should stop (0)
    
    %% Trim data with ROS time
    if flag_trim_with_ROSTime == 1
        dataStructure = fcn_DataClean_trimDataToCommonStartEndROSTimes(dataStructure);
        flag_trim_with_ROSTime = 0;
    end
    %% Name consistency checks start here
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   _   _                         _____                _     _                           _____ _               _
    %  | \ | |                       / ____|              (_)   | |                         / ____| |             | |
    %  |  \| | __ _ _ __ ___   ___  | |     ___  _ __  ___ _ ___| |_ ___ _ __   ___ _   _  | |    | |__   ___  ___| | _____
    %  | . ` |/ _` | '_ ` _ \ / _ \ | |    / _ \| '_ \/ __| / __| __/ _ \ '_ \ / __| | | | | |    | '_ \ / _ \/ __| |/ / __|
    %  | |\  | (_| | | | | | |  __/ | |___| (_) | | | \__ \ \__ \ ||  __/ | | | (__| |_| | | |____| | | |  __/ (__|   <\__ \
    %  |_| \_|\__,_|_| |_| |_|\___|  \_____\___/|_| |_|___/_|___/\__\___|_| |_|\___|\__, |  \_____|_| |_|\___|\___|_|\_\___/
    %                                                                                __/ |
    %                                                                               |___/
    % See: http://patorjk.com/software/taag/#p=display&f=Big&t=Name%20Consistency%20Checks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% Check name flags -- Done
    
    [name_flags, ~] = fcn_DataClean_checkDataNameConsistency(dataStructure,fid);
    

    
    %% Check if sensor outputs are merged -- Done
    %    ### ISSUES with this:
    %    * The Sparkfun GPS unit requires several different datagrams to fully
    %    capture its output
    %    * The data grams are spread across different sensor datasets
    %    corresponding to each topic, but are actually one
    %    * If they are kept separate, the data are not correlated correctly
    %    ### DETECTION:
    %    * Examine if the Sparkfun sensors are fields within the current
    %    datastructure
    %    ### FIXES:
    %    * Merge the data from the fields together

    % Check GPS_SparkFun_RightRear_sensors_are_merged
    if (1==flag_keep_checking) && (0==name_flags.GPS_SparkFun_RightRear_sensors_are_merged)
        sensors_to_merge = 'GPS_SparkFun_RightRear';
        merged_sensor_name = 'GPS_SparkFun_RightRear';
        method_name = 'keep_unique';
        fid = 1;
        dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);
        flag_keep_checking = 1;
    end
    % Check GPS_SparkFun_LeftRear_sensors_are_merged
    if (1==flag_keep_checking) && (0==name_flags.GPS_SparkFun_LeftRear_sensors_are_merged)
        sensors_to_merge = 'GPS_SparkFun_LeftRear';
        merged_sensor_name = 'GPS_SparkFun_LeftRear';
        method_name = 'keep_unique';
        fid = 1;
        dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);
        flag_keep_checking = 1;
    end

    % Check GPS_SparkFun_Front_sensors_are_merged
    if (1==flag_keep_checking) && (0==name_flags.GPS_SparkFun_Front_sensors_are_merged)
        sensors_to_merge = 'GPS_SparkFun_Front';
        merged_sensor_name = 'GPS_SparkFun_Front';
        method_name = 'keep_unique';
        fid = 1;
        dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);
        flag_keep_checking = 1;
    end
    
    % Check ADIS_sensors_are_merged 
    if (1==flag_keep_checking) && (0==name_flags.ADIS_sensors_are_merged)
        sensors_to_merge = 'ADIS';
        merged_sensor_name = 'IMU_Adis_TopCenter';
        method_name = 'keep_unique';
        fid = 1;
        dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure,sensors_to_merge,merged_sensor_name,method_name,fid);
        flag_keep_checking = 0;
    end

    %% Check if sensor_naming_standards_are_used
    %    ### ISSUES with this:
    %    * The sensors used on the mapping van follow a standard naming
    %    convention, such as:
    %    ### DETECTION:
    %    * Examine if the sensor core names appear outside of the standard
    %    convention
    %    ### FIXES:
    %    * Rename the fields
    
    % Check if sensor_naming_standards_are_used
    if (1==flag_keep_checking) && (0==name_flags.sensor_naming_standards_are_used)
        dataStructure = fcn_DataClean_renameSensorsToStandardNames(dataStructure,fid);
        flag_keep_checking = 1;
        name_flags.sensor_naming_standards_are_used = 1;
    end

    
    %% Check data for errors in Time data related to GPS-enabled sensors -- Done
    if (1==flag_keep_checking)
        [time_flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(dataStructure,fid);
    end

    %%
   
    %%
    %% GPS_Time tests - all of these steps can be found in fcn_DataClean_checkDataTimeConsistency, the following sections need to be deleted later
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    _____ _____   _____            _______ _                   _______        _
    %   / ____|  __ \ / ____|          |__   __(_)                 |__   __|      | |
    %  | |  __| |__) | (___               | |   _ _ __ ___   ___      | | ___  ___| |_ ___
    %  | | |_ |  ___/ \___ \              | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
    %  | |__| | |     ____) |             | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
    %   \_____|_|    |_____/              |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
    %                          ______
    %                         |______|
    %
    % See: http://patorjk.com/software/taag/#p=display&f=Big&t=GPS%20_%20Time%20%20Tests
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Check if GPS_Time_exists_in_at_least_one_GPS_sensor
    %    ### ISSUES with this:
    %    * There is no absolute time base to use for the data
    %    * The tracking of vehicle data relative to external sourses is no
    %    longer possible
    %    ### DETECTION:
    %    * Examine if GPS time fields exist on any GPS sensor
    %    ### FIXES:
    %    * Catastrophic error. Data collection should end.
    %    * One option? Check if ROS_Time recorded, and is locked to UTC via NTP, use ROS
    %    Time as stand-in
    %    * Otherwise, complete failure of sensor recordings
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_exists_in_at_least_one_GPS_sensor)
        error('Catastrophic data error detected: no GPS_Time data detected in any sensor.');
    end
    
    
    %% Check if GPS_Time_exists_in_all_GPS_sensors
    %    ### ISSUES with this:
    %    * There is no absolute time base to use for the sensor
    %    * This usually indicates back lock for the GPS
    %    ### DETECTION:
    %    * Examine if GPS time fields exist on all GPS sensors
    %    ### FIXES:
    %    * If another GPS is available, use its time alongside the GPS data
    %    * Remove this GPS data field
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_exists_in_all_GPS_sensors)
        error('Catastrophic data error detected: the following GPS sensor is missing GPS_Time data: %s.',offending_sensor);        
    end
    
    %% Check if centiSeconds_exists_in_all_GPS_sensors
    %    ### ISSUES with this:
    %    * This field defines the expected sample rate for each sensor
    %    ### DETECTION:
    %    * Examine if centiSeconds fields exist on all sensors
    %    ### FIXES:
    %    * Manually fix, or
    %    * Remove this sensor
    
    if (1==flag_keep_checking) && (0==time_flags.centiSeconds_exists_in_all_GPS_sensors)
        disp(dataStructure.(offending_sensor))
        error('Catastrophic data error detected: the following GPS sensor is missing centiSeconds: %s.',offending_sensor);                
    end
    

    %% Check if GPS_Time_has_no_repeats_in_GPS_sensors
    %    ### ISSUES with this:
    %    * If there are many repeated time values, the calculation of sampling
    %    time in the future steps produces incorrect results
    %    ### DETECTION:
    %    * Examine if time values are unique
    %    ### FIXES:
    %    * Remove repeats

    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_has_no_repeats_in_GPS_sensors)
        % Fix the data
        field_name = 'GPS_Time';
        sensors_to_check = 'GPS';
        dataStructure = fcn_DataClean_trimRepeatsFromField(dataStructure,fid, field_name,sensors_to_check);
        flag_keep_checking = 0;
    end



    %% Check if GPS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
    %    ### ISSUES with this:
    %    * This field is used to confirm GPS sampling rates for all
    %    GPS-triggered sensors
    %    * These sensors are used to correct ROS timings, so if misisng, the
    %    timing and thus positioning of vehicle data may be wrong
    %    * The GPS unit may be configured wrong
    %    * The GPS unit may be faililng or operating incorrectly
    %    ### DETECTION:
    %    * Make sure centiSeconds exists in all GPS sensors
    %    * Examine if centiSeconds calculation of time interval matches GPS
    %    time interval for data collection, on average
    %    ### FIXES:
    %    * Manually fix, or
    %    * Remove this sensor
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors)
        error('Inconsistent data detected: the following GPS sensor has an average sampling rate different than predicted from centiSeconds: %s.',offending_sensor);                
    end
    
    
    %% Check if start_time_GPS_sensors_agrees_to_within_5_seconds
    %    ### ISSUES with this:
    %    * The start times of all sensors in general should be the same,
    %    within a few seconds, as this is the boot-up time for sensors
    %    * If the times are severely wrong, this can indicate that the
    %    sensors are giving bad data
    %    * As an example, on 2023_06_22, a new GPS antenna installed on the
    %    mapping van produced time that was not UTC, but EST, resulting in
    %    a 4-hour difference in start times
    %    ### DETECTION:
    %    * Seach through the GPS time fields for all sensors, rounding them to
    %    their appropriate centi-second values
    %    * Check that they all agree within 5 seconds
    %    ### FIXES:
    %    * Use GPS sensors to "vote" on actual start time. For outliers,
    %    try different time shifts to minimize error. If error is reduced
    %    to less than 5 seconds, then the fix worked. Otherwise, throw an
    %    error.
    
    if (1==flag_keep_checking) && (0==time_flags.start_time_GPS_sensors_agrees_to_within_5_seconds)
        dataStructure = fcn_DataClean_correctTimeZoneErrorsInGPSTime(dataStructure,fid);
        flag_keep_checking = 0;
    end
    
    %% Check if consistent_start_and_end_times_across_GPS_sensors
    %    ### ISSUES with this:
    %    * The start times and end times of all data collection assumes all GPS
    %    systems are operating simultaneously
    %    * The calculation of Trigger_Time assumes that all start times are the
    %    same, and all end times are the same
    %    * If they are not the same, the count of data in one sensor may be
    %    different than another, especially if each were referencing different
    %    GPS sources.
    %    ### DETECTION:
    %    * Seach through the GPS time fields for all sensors, rounding them to
    %    their appropriate centi-second values
    %    * Check that they all agree
    %    ### FIXES:
    %    * Crop all data to same starting centi-second value

    if (1==flag_keep_checking) && (0==time_flags.consistent_start_and_end_times_across_GPS_sensors)
        dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure,fid);
        flag_keep_checking = 0;
    end

    %% Check if GPS_Time_strictly_ascends
    %    ### ISSUES with this:
    %    * This field is used to calibrate ROS time via interpolation, and must
    %    be STRICTLY increasing
    %    * If data packets arrive out-of-order with this sensor, times may not
    %    be in an increasing sequence
    %    * If a GPS is glitching, its time may be temporarily incorrect
    %    ### DETECTION:
    %    * Examine if time data from sensor is STRICTLY increasing
    %    ### FIXES:
    %    * Remove and interpolate time field if not strictkly increasing
    %    * Re-order data, if minor ordering error
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_strictly_ascends)
        field_name = 'GPS_Time';
        sensors_to_check = 'GPS';
        fid = 1;
        dataStructure = fcn_DataClean_sortSensorDataByGPSTime(dataStructure, field_name,sensors_to_check,fid);               
        flag_keep_checking = 0;
    end
    
    %% Check if no_jumps_in_differences_of_GPS_Time_in_any_GPS_sensors
    %    ### ISSUES with this:
    %    * The GPS_Time may have small jumps which could occur if the sensor
    %    pauses for a moment, then restarts
    %    * If these jumps are large, the data from the sensor may be corrupted
    %    ### DETECTION:
    %    * Examine if the differences in GPS_Time are out of ordinary by
    %    looking at the standard deviations of the differences relative to the
    %    mean differences
    %    ### FIXES:
    %    * Interpolate time field if only a small segment is missing        
    if (1==flag_keep_checking) && (0==time_flags.no_jumps_in_differences_of_GPS_Time_in_any_GPS_sensors)
        dataStructure = fcn_DataClean_fillMissingsInGPSUnits(dataStructure,ref_basestation,fid);
        flag_keep_checking = 0;

    end

    %% Check if no_missings_in_differences_of_GPS_Time_in_any_GPS_sensors
    %    ### ISSUES with this:
    %    * The GPS_Time may have small jumps which could occur if the sensor
    %    pauses for a moment, then restarts
    %    * If these jumps are large, the data from the sensor may be corrupted
    %    ### DETECTION:
    %    * Examine if the differences in GPS_Time are out of ordinary by
    %    looking at the standard deviations of the differences relative to the
    %    mean differences
    %    ### FIXES:
    %    * Interpolate time field if only a small segment is missing        
    
    if (1==flag_keep_checking) && (0==time_flags.no_missings_in_differences_of_GPS_Time_in_any_GPS_sensors)
        dataStructure = fcn_DataClean_fillMissingsInGPSUnits(dataStructure,ref_basestation,fid);
        flag_keep_checking = 0;  

         % figure(146)
         % plot(dataStructure.GPS_SparkFun_RightRear.GPS_Time,dataStructure.GPS_SparkFun_RightRear.ROS_Time)
         % hold on
         % plot(dataStructure.GPS_SparkFun_LeftRear.GPS_Time,dataStructure.GPS_SparkFun_LeftRear.ROS_Time)
         % plot(dataStructure.GPS_SparkFun_RightRear.GPS_Time,dataStructure.GPS_SparkFun_RightRear.ROS_Time)
         % 1;
    end
    %%
   
     %% Trigger_Time Tests
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   _______   _                                  _______ _                   _______        _
    %  |__   __| (_)                                |__   __(_)                 |__   __|      | |
    %     | |_ __ _  __ _  __ _  ___ _ __              | |   _ _ __ ___   ___      | | ___  ___| |_ ___
    %     | | '__| |/ _` |/ _` |/ _ \ '__|             | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
    %     | | |  | | (_| | (_| |  __/ |                | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
    %     |_|_|  |_|\__, |\__, |\___|_|                |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
    %                __/ | __/ |            ______
    %               |___/ |___/            |______|
    %
    % See: http://patorjk.com/software/taag/#p=display&f=Big&t=Trigger%20_%20Time%20%20Tests
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Check if Trigger_Time_exists_in_all_GPS_sensors
    %    ### ISSUES with this:
    %    * This field is used to assign data collection timings for all
    %    non-GPS-triggered sensors, and to fill in GPS_Time data if there's a
    %    short outage
    %    * These sensors may be configured wrong
    %    * These sensors may be faililng or operating incorrectly
    %    ### DETECTION:
    %    * Examine if Trigger_Time fields exist
    %    ### FIXES:
    %    * Recalculate Trigger_Time fields as needed, using centiSeconds
    if (1==flag_keep_checking) && (0==time_flags.Trigger_Time_exists_in_all_GPS_sensors)
        dataStructure = fcn_DataClean_recalculateTriggerTimes(dataStructure,'gps',fid);
        flag_keep_checking = 0;
    end
    
    



    %% ROS_Time Tests
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   _____   ____   _____            _______ _                   _______        _
    %  |  __ \ / __ \ / ____|          |__   __(_)                 |__   __|      | |
    %  | |__) | |  | | (___               | |   _ _ __ ___   ___      | | ___  ___| |_ ___
    %  |  _  /| |  | |\___ \              | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
    %  | | \ \| |__| |____) |             | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
    %  |_|  \_\\____/|_____/              |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
    %                          ______
    %                         |______|
    %
    % See: http://patorjk.com/software/taag/#p=display&f=Big&t=ROS%20_%20Time%20%20Tests
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Check if ROS_Time_exists_in_all_GPS_sensors
    %    ### ISSUES with this:
    %    * If the sensor is recording data, all data is time-stamped to ROS
    %    time
    %    * The ROS time is aligned with GPS time for sensors that do not have
    %    GPS timebase, and if it is missing, then we cannot use the sensor
    %    ### DETECTION:
    %    * Examine if ROS_Time fields exist on all sensors
    %    ### FIXES:
    %    * Catastrophic error. Sensor has failed and should be removed.
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_exists_in_all_GPS_sensors)
        error('Catastrophic failure in one of the sensors in that it is missing ROS time. Stopping.');
    end
    
    %% Check if ROS_Time_scaled_correctly_as_seconds
    %    ### ISSUES with this:
    %    * ROS records time in posix nanoseconds, whereas GPS units records in
    %    posix seconds
    %    * If ROS data is saved in nanoseconds, it causes large scaling
    %    problems.
    %    ### DETECTION:
    %    * Examine if any ROS_Time data is more than 10^8 larger than the
    %    largest GPS_Time data
    %    ### FIXES:
    %    * Divide ROS_Time on this sensor by 10^9, confirm that this fixes the
    %    problem
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_scaled_correctly_as_seconds)
        dataStructure = fcn_DataClean_convertROSTimeToSeconds(dataStructure,'',fid);              
        flag_keep_checking = 0;
    end
    
    %% Check if ROS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
    %    ### ISSUES with this:
    %    * The ROS time and GPS time should both have approximately the same
    %    sampling rates, and we use this alignment to calibrate ROS time to GPS
    %    time absolutely.
    %    * If they do not agree, then either the GPS or the ROS master are
    %    giving wrong data
    %    ### DETECTION:
    %    * Examine if centiSeconds calculation of time interval matches ROS
    %    time interval for data collection, on average
    %    ### FIXES:
    %    * Manually fix, or
    %    * Remove this sensor
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors)
        error('ROS time is mis-sampled.');            
        flag_keep_checking = 0;
    end
    
    

    %% Check if ROS_Time_strictly_ascends
    %    ### ISSUES with this:
    %    * This field is used to calibrate ROS to GPS time via interpolation, and must
    %    be STRICTLY increasing for the interpolation function to work
    %    * If data packets arrive out-of-order with this sensor, times may not
    %    be in an increasing sequence
    %    * If the ROS topic is glitching, its time may be temporarily incorrect
    %    ### DETECTION:
    %    * Examine if time data from sensor is STRICTLY increasing
    %    ### FIXES:
    %    * Remove and interpolate time field if not strictkly increasing
    %    * Re-order data, if minor ordering error
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_strictly_ascends)
        error('ROS time is not strictly ascending.');
        flag_keep_checking = 0;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    _____      _ _ _               _           _____   ____   _____            _______ _                     _             _____ _____   _____            _______ _
    %   / ____|    | (_) |             | |         |  __ \ / __ \ / ____|          |__   __(_)                   | |           / ____|  __ \ / ____|          |__   __(_)
    %  | |     __ _| |_| |__  _ __ __ _| |_ ___    | |__) | |  | | (___               | |   _ _ __ ___   ___     | |_ ___     | |  __| |__) | (___               | |   _ _ __ ___   ___
    %  | |    / _` | | | '_ \| '__/ _` | __/ _ \   |  _  /| |  | |\___ \              | |  | | '_ ` _ \ / _ \    | __/ _ \    | | |_ |  ___/ \___ \              | |  | | '_ ` _ \ / _ \
    %  | |___| (_| | | | |_) | | | (_| | ||  __/   | | \ \| |__| |____) |             | |  | | | | | | |  __/    | || (_) |   | |__| | |     ____) |             | |  | | | | | | |  __/
    %   \_____\__,_|_|_|_.__/|_|  \__,_|\__\___|   |_|  \_\\____/|_____/              |_|  |_|_| |_| |_|\___|     \__\___/     \_____|_|    |_____/              |_|  |_|_| |_| |_|\___|
    %                                                                      ______                                                                     ______
    %                                                                     |______|                                                                   |______|
    % See http://patorjk.com/software/taag/#p=display&f=Big&t=Calibrate%20%20%20ROS%20_%20Time%20%20%20%20to%20%20%20GPS%20_%20Time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% Check if ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors
    %    ### ISSUES with this:
    %    * The Trigger_Time represents, for many sensors, when they were
    %    commanded to collect data. If the number of data in the ROS time list
    %    does not match the Trigger_Time length, then this indicates that there
    %    are sensor failures
    %    ### DETECTION:
    %    * Count the number of data in Trigger_Time, and compare it with
    %    ROS_Time - these should match
    %    ### FIXES:
    %    * Remove and interpolate time field if not strictly increasing
    
    %% Check that ROS_Time data has expected count
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors)
        error('ROS time does not have expected count.\');
        flag_keep_checking = 0;
    end


    
    %% Check ROS_Time_rounds_correctly_to_Trigger_Time
    % Check that the ROS Time, when rounded to the nearest sampling interval,
    % matches the Trigger time.
    %    ### ISSUES with this:
    %    * The data on some sensors are triggered, inlcuding the GPS sensors
    %    which are self-triggered
    %    * If the rounding does not work, this indicates a problem in the ROS
    %    master
    %    ### DETECTION:
    %    * Round the ROS Time and compare to the Trigger_Times
    %    ### FIXES:
    %    * Remove and interpolate time field if not strictly increasing

    
    %% Check that ROS_Time_rounds_correctly_to_Trigger_Time 
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_rounds_correctly_to_Trigger_Time_in_GPS_sensors)
        warning('ROS time does not round correctly to Trigger_Time on sensor %s and perhaps other sensors. There is no code yet to fix this.',offending_sensor);
        dataStructure = fcn_DataClean_roundROSTimeForGPSUnits(dataStructure,'GPS',fid);
        flag_keep_checking = 0;
    end
    

    %% Entering this section indicates all time in GPS units have been checked and fixed
    %% First, check whether all sensors have Trigger_Time
    if (1==flag_keep_checking)         
        [time_flags,sensors_without_Trigger_Time] = fcn_DataClean_checkAllSensorsHaveTriggerTime(dataStructure,fid,time_flags);
    end

    %% If not, calculate Trigger_Time to rest of sensors
    if (1==flag_keep_checking) && (0==time_flags.all_sensors_have_trigger_time)
        warning('Some sensors do not have Trigger_Time, start to calculate Trigger_Time for those sensors');
        dataStructure = fcn_DataClean_calculateTriggerTime_AllSensors(dataStructure,sensors_without_Trigger_Time);
        flag_keep_checking = 0;
    end
    %%
  
    %% Start to work on other sensors, start with Velodyne LiDAR
    if (1==flag_keep_checking)
        dataStructure = fcn_DataClean_matchOtherSensorsToGPSUnits(dataStructure,fid);
        flag_keep_checking = 0;
    end

    %% TO-DO - Create a time analysis function - and add it here
    % Fix the x-axes to match the time duration, e.g. index*centiSeconds*0.01

    % Examine the offset deviations between the different time sources
    % [cell_array_centiSeconds,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds','GPS');
    % [cell_array_GPS_Time,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS');
    % [cell_array_Trigger_Time,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'Trigger_Time','GPS');
    % [cell_array_ROS_Time,sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS');
    % 
    % % Calculate ROS_Time - Trigger_time, plot this versus duration
    % figure(1818);
    % clf;
    % hold on;
    % grid on;
    % xlabel('Duration of Data Collection (seconds)');
    % ylabel('Deviations in Time (seconds)');
    % title('Differences, ROS Time - Trigger Time');
    % 
    % for ith_sensor = 1:length(sensor_names)
    % 
    %     xdata = (1:length(cell_array_Trigger_Time{ith_sensor}))'*0.01*cell_array_centiSeconds{ith_sensor};
    %     deviations_in_time = (cell_array_ROS_Time{ith_sensor} - cell_array_Trigger_Time{ith_sensor});
    %     plot(xdata,deviations_in_time);
    % end
    % legend(sensor_names,'Interpreter','none')
    % 
    % % Calculate GPS_Time - Trigger_time, plot this versus duration
    % figure(1819);
    % clf;
    % hold on;
    % grid on;
    % xlabel('Duration of Data Collection (seconds)');
    % ylabel('Deviations in Time (seconds)');
    % title('Differences, GPS Time - Trigger Time');
    % 
    % for ith_sensor = 1:length(sensor_names)
    %     xdata = (1:length(cell_array_Trigger_Time{ith_sensor}))'*0.01*cell_array_centiSeconds{ith_sensor};
    %     deviations_in_time = (cell_array_GPS_Time{ith_sensor} - cell_array_Trigger_Time{ith_sensor});
    %     plot(xdata,deviations_in_time);
    % end
    % legend(sensor_names,'Interpreter','none')
    % 
    % 


    %% Done!
    % Only way to get here is if everything above worked - can exit!
    if (1==flag_keep_checking)
        flag_stay_in_main_loop = 0;
    end
    
    %% Exiting conditions
    % if length(dataset)==1
    %     temp = dataset;
    %     clear dataset
    %     dataset{1} = temp;
    % end
    dataset{end+1} = dataStructure; %#ok<SAGROW>
    
       
    % Check if all the name_flags work, so we can exit!
    name_flag_stay_in_main_loop = fcn_INTERNAL_checkFlagsForExit(name_flags);
    
    if 0 == name_flag_stay_in_main_loop
        % Check if all the time_flags work, so we can exit!
        flag_stay_in_main_loop = fcn_INTERNAL_checkFlagsForExit(time_flags);
        
    else
        flag_stay_in_main_loop = 1;
    end
    
    % Have we done too many loops?
    if main_data_clean_loop_iteration_number>N_max_loops
        flag_stay_in_main_loop = 0;
    end
          
end
disp("Data clean completed")
end

%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

%% function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
% Clear out the variables
clear global flag* FLAG*
clear flag*
clear path

% Clear out any path directories under Utilities
path_dirs = regexp(path,'[;]','split');
utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir});
    end
end

% Delete the Utilities folder, to be extra clean!
if  exist(utilities_dir,'dir')
    [status,message,message_ID] = rmdir(utilities_dir,'s');
    if 0==status
        error('Unable remove directory: %s \nReason message: %s \nand message_ID: %s\n',utilities_dir, message,message_ID);
    end
end

end % Ends fcn_INTERNAL_clearUtilitiesFromPathAndFolders

%% fcn_INTERNAL_initializeUtilities
function  fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders)
% Reset all flags for installs to empty
clear global FLAG*

fprintf(1,'Installing utilities necessary for code ...\n');

% Dependencies and Setup of the Code
% This code depends on several other libraries of codes that contain
% commonly used functions. We check to see if these libraries are installed
% into our "Utilities" folder, and if not, we install them and then set a
% flag to not install them again.

% Set up libraries
for ith_library = 1:length(library_name)
    dependency_name = library_name{ith_library};
    dependency_subfolders = library_folders{ith_library};
    dependency_url = library_url{ith_library};

    fprintf(1,'\tAdding library: %s ...',dependency_name);
    fcn_INTERNAL_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url);
    clear dependency_name dependency_subfolders dependency_url
    fprintf(1,'Done.\n');
end

% Set dependencies for this project specifically
fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders);

disp('Done setting up libraries, adding each to MATLAB path, and adding current repo folders to path.');
end % Ends fcn_INTERNAL_initializeUtilities


function fcn_INTERNAL_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url, varargin)
%% FCN_DEBUGTOOLS_INSTALLDEPENDENCIES - MATLAB package installer from URL
%
% FCN_DEBUGTOOLS_INSTALLDEPENDENCIES installs code packages that are
% specified by a URL pointing to a zip file into a default local subfolder,
% "Utilities", under the root folder. It also adds either the package
% subfoder or any specified sub-subfolders to the MATLAB path.
%
% If the Utilities folder does not exist, it is created.
%
% If the specified code package folder and all subfolders already exist,
% the package is not installed. Otherwise, the folders are created as
% needed, and the package is installed.
%
% If one does not wish to put these codes in different directories, the
% function can be easily modified with strings specifying the
% desired install location.
%
% For path creation, if the "DebugTools" package is being installed, the
% code installs the package, then shifts temporarily into the package to
% complete the path definitions for MATLAB. If the DebugTools is not
% already installed, an error is thrown as these tools are needed for the
% path creation.
%
% Finally, the code sets a global flag to indicate that the folders are
% initialized so that, in this session, if the code is called again the
% folders will not be installed. This global flag can be overwritten by an
% optional flag input.
%
% FORMAT:
%
%      fcn_DebugTools_installDependencies(...
%           dependency_name, ...
%           dependency_subfolders, ...
%           dependency_url)
%
% INPUTS:
%
%      dependency_name: the name given to the subfolder in the Utilities
%      directory for the package install
%
%      dependency_subfolders: in addition to the package subfoder, a list
%      of any specified sub-subfolders to the MATLAB path. Leave blank to
%      add only the package subfolder to the path. See the example below.
%
%      dependency_url: the URL pointing to the code package.
%
%      (OPTIONAL INPUTS)
%      flag_force_creation: if any value other than zero, forces the
%      install to occur even if the global flag is set.
%
% OUTPUTS:
%
%      (none)
%
% DEPENDENCIES:
%
%      This code will automatically get dependent files from the internet,
%      but of course this requires an internet connection. If the
%      DebugTools are being installed, it does not require any other
%      functions. But for other packages, it uses the following from the
%      DebugTools library: fcn_DebugTools_addSubdirectoriesToPath
%
% EXAMPLES:
%
% % Define the name of subfolder to be created in "Utilities" subfolder
% dependency_name = 'DebugTools_v2023_01_18';
%
% % Define sub-subfolders that are in the code package that also need to be
% % added to the MATLAB path after install; the package install subfolder
% % is NOT added to path. OR: Leave empty ({}) to only add
% % the subfolder path without any sub-subfolder path additions.
% dependency_subfolders = {'Functions','Data'};
%
% % Define a universal resource locator (URL) pointing to the zip file to
% % install. For example, here is the zip file location to the Debugtools
% % package on GitHub:
% dependency_url = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/blob/main/Releases/DebugTools_v2023_01_18.zip?raw=true';
%
% % Call the function to do the install
% fcn_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url)
%
% This function was written on 2023_01_23 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
% 2023_01_23:
% -- wrote the code originally
% 2023_04_20:
% -- improved error handling
% -- fixes nested installs automatically

% TO DO
% -- Add input argument checking

flag_do_debug = 0; % Flag to show the results for debugging
flag_do_plots = 0; % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(3,4);
end

%% Set the global variable - need this for input checking
% Create a variable name for our flag. Stylistically, global variables are
% usually all caps.
flag_varname = upper(cat(2,'flag_',dependency_name,'_Folders_Initialized'));

% Make the variable global
eval(sprintf('global %s',flag_varname));

if nargin==4
    if varargin{1}
        eval(sprintf('clear global %s',flag_varname));
    end
end

%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if ~exist(flag_varname,'var') || isempty(eval(flag_varname))
    % Save the root directory, so we can get back to it after some of the
    % operations below. We use the Print Working Directory command (pwd) to
    % do this. Note: this command is from Unix/Linux world, but is so
    % useful that MATLAB made their own!
    root_directory_name = pwd;

    % Does the directory "Utilities" exist?
    utilities_folder_name = fullfile(root_directory_name,'Utilities');
    if ~exist(utilities_folder_name,'dir')
        % If we are in here, the directory does not exist. So create it
        % using mkdir
        [success_flag,error_message,message_ID] = mkdir(root_directory_name,'Utilities');

        % Did it work?
        if ~success_flag
            error('Unable to make the Utilities directory. Reason: %s with message ID: %s\n',error_message,message_ID);
        elseif ~isempty(error_message)
            warning('The Utilities directory was created, but with a warning: %s\n and message ID: %s\n(continuing)\n',error_message, message_ID);
        end

    end

    % Does the directory for the dependency folder exist?
    dependency_folder_name = fullfile(root_directory_name,'Utilities',dependency_name);
    if ~exist(dependency_folder_name,'dir')
        % If we are in here, the directory does not exist. So create it
        % using mkdir
        [success_flag,error_message,message_ID] = mkdir(utilities_folder_name,dependency_name);

        % Did it work?
        if ~success_flag
            error('Unable to make the dependency directory: %s. Reason: %s with message ID: %s\n',dependency_name, error_message,message_ID);
        elseif ~isempty(error_message)
            warning('The %s directory was created, but with a warning: %s\n and message ID: %s\n(continuing)\n',dependency_name, error_message, message_ID);
        end

    end

    % Do the subfolders exist?
    flag_allFoldersThere = 1;
    if isempty(dependency_subfolders{1})
        flag_allFoldersThere = 0;
    else
        for ith_folder = 1:length(dependency_subfolders)
            subfolder_name = dependency_subfolders{ith_folder};

            % Create the entire path
            subfunction_folder = fullfile(root_directory_name, 'Utilities', dependency_name,subfolder_name);

            % Check if the folder and file exists that is typically created when
            % unzipping.
            if ~exist(subfunction_folder,'dir')
                flag_allFoldersThere = 0;
            end
        end
    end

    % Do we need to unzip the files?
    if flag_allFoldersThere==0
        % Files do not exist yet - try unzipping them.
        save_file_name = tempname(root_directory_name);
        zip_file_name = websave(save_file_name,dependency_url);
        % CANT GET THIS TO WORK --> unzip(zip_file_url, debugTools_folder_name);

        % Is the file there?
        if ~exist(zip_file_name,'file')
            error(['The zip file: %s for dependency: %s did not download correctly.\n' ...
                'This is usually because permissions are restricted on ' ...
                'the current directory. Check the code install ' ...
                '(see README.md) and try again.\n'],zip_file_name, dependency_name);
        end

        % Try unzipping
        unzip(zip_file_name, dependency_folder_name);

        % Did this work? If so, directory should not be empty
        directory_contents = dir(dependency_folder_name);
        if isempty(directory_contents)
            error(['The necessary dependency: %s has an error in install ' ...
                'where the zip file downloaded correctly, ' ...
                'but the unzip operation did not put any content ' ...
                'into the correct folder. ' ...
                'This suggests a bad zip file or permissions error ' ...
                'on the local computer.\n'],dependency_name);
        end

        % Check if is a nested install (for example, installing a folder
        % "Toolsets" under a folder called "Toolsets"). This can be found
        % if there's a folder whose name contains the dependency_name
        flag_is_nested_install = 0;
        for ith_entry = 1:length(directory_contents)
            if contains(directory_contents(ith_entry).name,dependency_name)
                if directory_contents(ith_entry).isdir
                    flag_is_nested_install = 1;
                    install_directory_from = fullfile(directory_contents(ith_entry).folder,directory_contents(ith_entry).name);
                    install_files_from = fullfile(directory_contents(ith_entry).folder,directory_contents(ith_entry).name,'*'); % BUG FIX - For Macs, must be *, not *.*
                    install_location_to = fullfile(directory_contents(ith_entry).folder);
                end
            end
        end

        if flag_is_nested_install
            [status,message,message_ID] = movefile(install_files_from,install_location_to);
            if 0==status
                error(['Unable to move files from directory: %s\n ' ...
                    'To: %s \n' ...
                    'Reason message: %s\n' ...
                    'And message_ID: %s\n'],install_files_from,install_location_to, message,message_ID);
            end
            [status,message,message_ID] = rmdir(install_directory_from);
            if 0==status
                error(['Unable remove directory: %s \n' ...
                    'Reason message: %s \n' ...
                    'And message_ID: %s\n'],install_directory_from,message,message_ID);
            end
        end

        % Make sure the subfolders were created
        flag_allFoldersThere = 1;
        if ~isempty(dependency_subfolders{1})
            for ith_folder = 1:length(dependency_subfolders)
                subfolder_name = dependency_subfolders{ith_folder};

                % Create the entire path
                subfunction_folder = fullfile(root_directory_name, 'Utilities', dependency_name,subfolder_name);

                % Check if the folder and file exists that is typically created when
                % unzipping.
                if ~exist(subfunction_folder,'dir')
                    flag_allFoldersThere = 0;
                end
            end
        end
        % If any are not there, then throw an error
        if flag_allFoldersThere==0
            error(['The necessary dependency: %s has an error in install, ' ...
                'or error performing an unzip operation. The subfolders ' ...
                'requested by the code were not found after the unzip ' ...
                'operation. This suggests a bad zip file, or a permissions ' ...
                'error on the local computer, or that folders are ' ...
                'specified that are not present on the remote code ' ...
                'repository.\n'],dependency_name);
        else
            % Clean up the zip file
            delete(zip_file_name);
        end

    end


    % For path creation, if the "DebugTools" package is being installed, the
    % code installs the package, then shifts temporarily into the package to
    % complete the path definitions for MATLAB. If the DebugTools is not
    % already installed, an error is thrown as these tools are needed for the
    % path creation.
    %
    % In other words: DebugTools is a special case because folders not
    % added yet, and we use DebugTools for adding the other directories
    if strcmp(dependency_name(1:10),'DebugTools')
        debugTools_function_folder = fullfile(root_directory_name, 'Utilities', dependency_name,'Functions');

        % Move into the folder, run the function, and move back
        cd(debugTools_function_folder);
        fcn_DebugTools_addSubdirectoriesToPath(dependency_folder_name,dependency_subfolders);
        cd(root_directory_name);
    else
        try
            fcn_DebugTools_addSubdirectoriesToPath(dependency_folder_name,dependency_subfolders);
        catch
            error(['Package installer requires DebugTools package to be ' ...
                'installed first. Please install that before ' ...
                'installing this package']);
        end
    end


    % Finally, the code sets a global flag to indicate that the folders are
    % initialized.  Check this using a command "exist", which takes a
    % character string (the name inside the '' marks, and a type string -
    % in this case 'var') and checks if a variable ('var') exists in matlab
    % that has the same name as the string. The ~ in front of exist says to
    % do the opposite. So the following command basically means: if the
    % variable named 'flag_CodeX_Folders_Initialized' does NOT exist in the
    % workspace, run the code in the if statement. If we look at the bottom
    % of the if statement, we fill in that variable. That way, the next
    % time the code is run - assuming the if statement ran to the end -
    % this section of code will NOT be run twice.

    eval(sprintf('%s = 1;',flag_varname));
end


%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots

    % Nothing to do!



end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends function fcn_DebugTools_installDependencies

%% fcn_INTERNAL_checkFlagsForExit
function flag_stay_in_main_loop = fcn_INTERNAL_checkFlagsForExit(flags)
flag_fields = fieldnames(flags); % Grab all the flags
flag_array = zeros(length(flag_fields),1);
for ith_field = 1:length(flag_fields)
    flag_array(ith_field,1) = flags.(flag_fields{ith_field});
end

flag_stay_in_main_loop = 1;
if all(flag_array==1)
    flag_stay_in_main_loop = 0;
    flag_trim_with_ROSTime = 1;
end
end % Ends fcn_INTERNAL_checkFlagsForExit
    