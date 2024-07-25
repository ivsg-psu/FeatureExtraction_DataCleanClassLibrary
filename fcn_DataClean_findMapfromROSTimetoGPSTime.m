function time_offset_stats = fcn_DataClean_findMapfromROSTimetoGPSTime(dataStructure)

flag_do_plot = 1;
sensorfields = fieldnames(dataStructure);

time_offset_stats = [];
for idx_field = 1:length(sensorfields)

    current_field_struct = dataStructure.(sensorfields{idx_field});
    if isfield(current_field_struct,'ROS_Time')
        current_field_struct_ROS_Time = current_field_struct.ROS_Time;
    else
        current_field_struct_ROS_Time = [];
    end

    if isfield(current_field_struct,'GPS_Time')
        current_field_struct_GPS_Time = current_field_struct.GPS_Time;
    else
        current_field_struct_GPS_Time = [];
    end

    if (~isempty(current_field_struct_ROS_Time))&(~isnan(current_field_struct_GPS_Time))
        time_offset = current_field_struct_GPS_Time - current_field_struct_ROS_Time;
        
        
        
        time_offset_ave = mean(time_offset);
        time_offset_std = std(time_offset);
        time_offset_stat = [time_offset_ave, time_offset_std];
        time_offset_stats = [time_offset_stats;time_offset_stat];
        if flag_do_plot == 1
            plot(time_offset)
            hold on

        end
    end

   

end