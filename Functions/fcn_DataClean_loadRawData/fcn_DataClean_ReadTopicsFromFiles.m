function [MappingVan_data, rawdata_struct] = fcn_DataClean_ReadTopicsFromFiles(bagname,ref_basestation)


% addpath(bagname+"\")
% folder_path = bagname+
folder_path = bagname + "/"
addpath(folder_path)
file_list = dir(folder_path);
num_files = length(file_list);

rawdata_struct = struct;

topic_content_cell = {};
for file_idx = 3:num_files
    file_name = file_list(file_idx).name;
    file_name_noext = extractBefore(file_name,'.'); 
    file_name_noslash = extractAfter(file_name_noext,'_slash_');
    topic_name = strrep(file_name_noext,'_slash_','/');
    topic_name_noslash = extractAfter(topic_name,'/');
    file_path = folder_path + file_name;
    opts = detectImportOptions(file_path);
    if contains(topic_name,'sick_lms500/scan')
        table = readmatrix(file_path, opts)
    else
        opts = detectImportOptions(file_path);
        opts.PreserveVariableNames = true;
        table = readtable(file_path,opts);
    end
    if contains(topic_name, 'Bin1')
        secs = table.secs;
        nsecs = table.secs;
        Hemisphere_DGPS.Time = secs+nsecs*10^-9;
        Hemisphere_DGPS.Latitude = table.Latitude;
        Hemisphere_DGPS.Longitude = table.Longitude;
        Hemisphere_DGPS.Height = table.Height;
        Hemisphere_DGPS.NavMode = table.NavMode;
        Hemisphere_DGPS.VNorth = table.VNorth;
        Hemisphere_DGPS.VEast = table.VEast;
        Hemisphere_DGPS.VUp = table.VUp;
        Hemisphere_DGPS.NumOfSats = table.NumOfSats;
        Hemisphere_DGPS.xEast = [];
        Hemisphere_DGPS.yNorth = [];
        Hemisphere_DGPS.zUp = [];
        Hemisphere_DGPS.AgeOfDiff = table.AgeOfDiff;
        Hemisphere_DGPS.GPSWeek = table.GPSWeek;
        Hemisphere_DGPS.GPSTimeOfWeek = table.GPSTimeOfWeek;
        Hemisphere_DGPS.StdDevResid = table.StdDevResid;
        Hemisphere_DGPS.ExtendedAgeOfDiff = table.ExtendedAgeOfDiff;
        Hemisphere_DGPS.ROSTime = table.rosbagTimestamp;

    elseif contains(topic_name, 'GPS_Novatel')
        secs = table.secs;
        nsecs = table.secs;
        GPS_Novatel.Latitude = table.Latitude;
        GPS_Novatel.Longitude = table.Longitude;
        GPS_Novatel.Height = table.Height;
        GPS_Novatel.Seconds = table.Seconds;
        GPS_Novatel.Time = secs+nsecs*10^-9;
        GPS_Novatel.NorthVelocity = table.NorthVelocity;
        GPS_Novatel.EastVelocity = table.EastVelocity;
        GPS_Novatel.UpVelocity = table.UpVelocity;
        GPS_Novatel.Roll = table.Roll;
        GPS_Novatel.Pitch = table.Pitch;
        GPS_Novatel.Azimuth = table.Azimuth;
        GPS_Novatel.xEast = table.xEast;
        GPS_Novatel.yNorth = table.yNorth;
        GPS_Novatel.zUp = table.zUp;

    elseif contains(topic_name, 'Garmin_GPS')

        secs = table.secs;
        nsecs = table.secs;
        Garmin_GPS.Latitude = table.Latitude;
        Garmin_GPS.Longitude = table.Longitude;
        Garmin_GPS.Height = table.Height;
        Garmin_GPS.Time = secs+nsecs*10^-9;
        Garmin_GPS.xEast = table.xEast;
        Garmin_GPS.yNorth = table.yNorth;
        Garmin_GPS.zUp = table.zUp;

    elseif contains(topic_name, 'Novatel_IMU')

        secs = table.secs;
        nsecs = table.secs;
        Novatel_IMU.Time = secs+nsecs*10^-9;
        Novatel_IMU.centiSeconds = '';
        Novatel_IMU.XAccel = table.x;
        Novatel_IMU.YAccel = table.y;
        Novatel_IMU.ZAccel = table.z;
        Novatel_IMU.XGyro = table.x_1;
        Novatel_IMU.YGyro = table.y_2;
        Novatel_IMU.ZGyro = table.z_2;
        Novatel_IMU.ROSTime = table.rosbagTimestamp;


    elseif contains(topic_name, '4')
    
        secs = table.secs;
        nsecs = table.secs;
        Raw_encoder.Time = secs+nsecs*10^-9;
        Raw_encoder.CountsL = table.CountsL;
        Raw_encoder.CountsR = table.CountsR;
        Raw_encoder.AngularVelocityL = table.AngularVelocityL;
        Raw_encoder.AngularVelocityR = table.AngularVelocityR;
        Raw_encoder.DeltaCountsL = table.DeltaCountsL;
        Raw_encoder.DeltaCountsR = table.DeltaCountsR;
    
    elseif contains(topic_name, 'tire_radius_rear_left')
    
        secs = table.secs;
        nsecs = table.secs;
        Tire_radius_rear_left_wheel.Time = secs+nsecs*10^-9;
        Tire_radius_rear_left_wheel.Counts = table.Counts;
        Tire_radius_rear_left_wheel.AngularVelocity = table.AngularVelocity;

    elseif contains(topic_name, 'tire_radius_rear_right')
    
        secs = table.secs;
        nsecs = table.secs;
        Tire_radius_rear_right_wheel.Time = secs+nsecs*10^-9;
        Tire_radius_rear_right_wheel.Counts = table.Counts;
        Tire_radius_rear_right_wheel.AngularVelocity = table.AngularVelocity;

    elseif contains(topic_name, 'imu/rpy/filtered')
        secs = table.secs;
        nsecs = table.nsecs;
        adis_IMU_filtered_rpy.Time = secs+nsecs*10^-9;
        adis_IMU_filtered_rpy.VectorX = table.x;
        adis_IMU_filtered_rpy.VectorY = table.y;
        adis_IMU_filtered_rpy.VectorZ = table.z;    


    elseif contains(topic_name, 'imu/data')
        secs = table.secs;
        nsecs = table.nsecs;
        adis_IMU_data.Time = secs + nsecs*10^-9;
        adis_IMU_data.LinearAccelerationX = table.x2;
        adis_IMU_data.LinearAccelerationY = table.y2;
        adis_IMU_data.LinearAccelerationZ = table.linearaccelerationz;    
        adis_IMU_data.AngularVelocityX = table.angularvelocityx;
        adis_IMU_data.AngularVelocityY = table.angularvelocityy;
        adis_IMU_data.AngularVelocityZ = table.angularvelocityz
    elseif contains(topic_name, 'imu/data')
        secs = table.secs;
        nsecs = table.nsecs;
        adis_IMU_data.Time = secs + nsecs*10^-9;
        adis_IMU_dataraw.Time = secs+nsecs*10^-9;
adis_IMU_dataraw.LinearAccelerationX = table.linearaccelerationx;
adis_IMU_dataraw.LinearAccelerationY = table.linearaccelerationy;
adis_IMU_dataraw.LinearAccelerationZ = table.linearaccelerationz;    
adis_IMU_dataraw.AngularVelocityX = table.angularvelocityx;
adis_IMU_dataraw.AngularVelocityY = table.angularvelocityy;
adis_IMU_dataraw.AngularVelocityZ = table.angularvelocityz;
    elseif contains(topic_name,'parseTrigger')
        secs = table.secs;
        nsecs = table.nsecs;
        parseTrigger.Time = secs + nsecs*(10^-9);
        parseTrigger.mode = table.mode;
        parseTrigger.GPS_Time                          = default_value;  % This is the GPS time, UTC, as reported by the unit
        parseTrigger.Trigger_Time                      = default_value;  % This is the Trigger time, UTC, as calculated by sample
        parseTrigger.ROS_Time                          = default_value;  % This is the ROS time that the data arrived into the bag
        parseTrigger.centiSeconds                      = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        parseTrigger.Npoints                           = default_value;  % This is the number of data points in the array
        parseTrigger.mode                              = table.mode;     % This is the mode of the trigger box (I: Startup, X: Freewheeling, S: Syncing, L: Locked)
        parseTrigger.adjone                            = table.adjone;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
        parseTrigger.adjtwo                            = table.adjrwo;   % This is phase adjustment magnitude relative to the calculated period of the output pulse
        parseTrigger.adjthree                          = table.adjthree; % This is phase adjustment magnitude relative to the calculated period of the output pulse
        % Data below are error monitoring messages
        parseTrigger.err_failed_mode_count             = table.err_failed_mode_count;  
        parseTrigger.err_failed_XI_format              = table.err_failed_XI_format; 
        parseTrigger.err_failed_checkInformation       = table.err_failed_checkInformation; 
        parseTrigger.err_trigger_unknown_error_occured = table.err_trigger_unknown_error_occured; 
        parseTrigger.err_bad_uppercase_character       = table.err_bad_uppercase_character; 
        parseTrigger.err_bad_lowercase_character       = table.err_bad_lowercase_character; 
        parseTrigger.err_bad_three_adj_element         = table.err_bad_three_adj_element; 
        parseTrigger.err_bad_first_element             = table.err_bad_first_element; 
        parseTrigger.err_bad_character                 = table.err_bad_character; 
        parseTrigger.err_wrong_element_length          = table.err_wrong_element_length; 
    elseif contains(topic_name, 'sparkfun_gps_rear_left')
        SparkFun_GPS_RearLeft.Time = '';
        SparkFun_GPS_RearLeft.Latitude = table.Latitude;
        SparkFun_GPS_RearLeft.Longitude = table.Longitude;
        SparkFun_GPS_RearLeft.Altitude = table.Altitude;
        SparkFun_GPS_RearLeft.SpdOverGrndKmph = table.SpdOverGrndKmph;
        SparkFun_GPS_RearLeft.NavMode = table.NavMode;
        SparkFun_GPS_RearLeft.LockStatus = table.LockStatus;
        SparkFun_GPS_RearLeft.NumOfSats = table.NumOfSats;
        SparkFun_GPS_RearLeft.AgeOfDiff = table.AgeOfDiff;

        SparkFun_GPS_RearLeft.xEast = [];
        SparkFun_GPS_RearLeft.yNorth = [];
        SparkFun_GPS_RearLeft.zUp = [];
        % SparkFun_GPS_RearLeft.GPSWeek = '';
        SparkFun_GPS_RearLeft.HDOP = table.HDOP;
        SparkFun_GPS_RearLeft.StdLat = table.StdLat;
        SparkFun_GPS_RearLeft.StdLon = table.StdLon;
        SparkFun_GPS_RearLeft.StdAlt = table.StdAlt;

        % SparkFun_GPS_RearLeft.GPSTimeOfWeek = table.GPSTimeOfWeek;
        % SparkFun_GPS_RearLeft.StdDevResid = table.StdDevResid;
        % SparkFun_GPS_RearLeft.ExtendedAgeOfDiff = table.ExtendedAgeOfDiff;
        % SparkFun_GPS_RearLeft.ROSTime = table.rosbagTimestamp;
    elseif contains(topic_name, 'sparkfun_gps_rear_right')
        % SparkFun_GPS_RearRight.Time = '';
        SparkFun_GPS_RearRight.Latitude = table.Latitude;
        SparkFun_GPS_RearRight.Longitude = table.Longitude;
        SparkFun_GPS_RearRight.Altitude = table.Altitude;
        SparkFun_GPS_RearRight.SpdOverGrndKmph = table.SpdOverGrndKmph;
        SparkFun_GPS_RearRight.NavMode = table.NavMode;
        SparkFun_GPS_RearRight.LockStatus = table.LockStatus;
        SparkFun_GPS_RearRight.NumOfSats = table.NumOfSats;
        SparkFun_GPS_RearRight.AgeOfDiff = table.AgeOfDiff;

        SparkFun_GPS_RearRight.xEast = [];
        SparkFun_GPS_RearRight.yNorth = [];
        SparkFun_GPS_RearRight.zUp = [];
        % SparkFun_GPS_RearLeft.GPSWeek = '';
        SparkFun_GPS_RearRight.HDOP = table.HDOP;
        SparkFun_GPS_RearRight.StdLat = table.StdLat;
        SparkFun_GPS_RearRight.StdLon = table.StdLon;
        SparkFun_GPS_RearRight.StdAlt = table.StdAlt;
        
        % SparkFun_GPS_RearLeft.GPSTimeOfWeek = table.GPSTimeOfWeek;
        % SparkFun_GPS_RearLeft.StdDevResid = table.StdDevResid;
        % SparkFun_GPS_RearLeft.ExtendedAgeOfDiff = table.ExtendedAgeOfDiff;
        SparkFun_GPS_RearRight.ROSTime = table.rosbagTimestamp;
    elseif contains(topic_name, 'sick_lms500/scan')

    end

    % table = readtable(file_name,opts);
    rawdata_struct.(file_name_noslash) = table;
    topic_name_list(file_idx,1) = string(topic_name);
    topic_content_cell{file_idx,1} = table;
%         table = readtable(file_name,opts);
%         topic_name_list(topic_idx,1) = string(topic_name);
%         topic_content_cell{topic_idx,1} = table;
%     end

    
%     mappingVan_data{topic_idx,1} = topic_name;
%     mappingVan_data{topic_idx,2} = table;
end
MappingVan_data = dictionary(topic_name_list,topic_content_cell);