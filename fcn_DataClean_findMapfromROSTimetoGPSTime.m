function fcn_DataClean_findMapfromROSTimetoGPSTime(dataStructure)


sensorfields = fieldnames(rawDataStructure);
trimedDataStructure = rawDataStructure;
p_array = [];
for idx_field = 1:length(sensorfields)
    current_field_struct = rawDataStructure.(sensorfields{idx_field});
    trimmed_field_struct = current_field_struct;
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

    if (~isempty(current_field_struct_ROS_Time))&(~isempty(current_field_struct_GPS_Time))
        p = polyfit(current_field_struct_GPS_Time,current_field_struct_ROS_Time);


    end

    p_array = [p_array;p];
    valid_idxs = (current_field_struct_ROS_Time>=min(time_range))&(current_field_struct_ROS_Time<=max(time_range));
    topicfields = fieldnames(current_field_struct);
    N_topics = length(topicfields);
    for idx_topic = 1:N_topics
        current_topic_content = current_field_struct.(topicfields{idx_topic});
        if length(current_topic_content) > 1
           trimmed_field_struct.(topicfields{idx_topic}) = current_topic_content(valid_idxs,:);
        end
        trimmed_field_struct.centiSeconds = current_field_struct.centiSeconds;
        trimmed_field_struct.Npoints = length(trimmed_field_struct.ROS_Time);

    end
    trimedDataStructure.(sensorfields{idx_field}) = trimmed_field_struct;

end