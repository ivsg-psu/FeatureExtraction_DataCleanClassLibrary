function matched_GPS_Time_fixed = fcn_DataClean_calculateGPSTimeForMergedData(ROS_Time,GPS_Time,centiSeconds,offset_between_GPSTime_and_ROSTime)

rounded_centiSecond_ROS_Time = round(ROS_Time*100/centiSeconds)*centiSeconds;
rounded_centiSecond_ROS_Time_diff = diff(rounded_centiSecond_ROS_Time);
ROS_Time_strictly_ascends = all(rounded_centiSecond_ROS_Time_diff>0);
rounded_centiSecond_ROS_Time_fixed = rounded_centiSecond_ROS_Time;

if ROS_Time_strictly_ascends == 0
    tf_flat = (rounded_centiSecond_ROS_Time_diff == 0);
    rounded_centiSecond_ROS_Time_fixed(tf_flat) = nan;
    rounded_centiSecond_ROS_Time_fixed = fillmissing(rounded_centiSecond_ROS_Time_fixed,'linear');
end
centiSecond_ROS_Time_fixed = rounded_centiSecond_ROS_Time_fixed/100;
calculated_GPS_Time = centiSecond_ROS_Time_fixed - mean(offset_between_GPSTime_and_ROSTime);
matched_GPS_Time = zeros(size(centiSecond_ROS_Time_fixed));
for idx_time = 1:length(calculated_GPS_Time)
    time_diff = abs(GPS_Time-calculated_GPS_Time(idx_time));
    [~,closest_idx] = min(time_diff);
    matched_GPS_Time(idx_time,:) = GPS_Time(closest_idx);
end

tf_flat_matched_GPS_Time = (diff(matched_GPS_Time) == 0);
matched_GPS_Time_fixed = matched_GPS_Time;
matched_GPS_Time_fixed(tf_flat_matched_GPS_Time) = nan;
matched_GPS_Time_fixed = fillmissing(matched_GPS_Time_fixed,'linear');
