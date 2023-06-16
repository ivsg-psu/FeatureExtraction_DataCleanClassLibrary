function datatype = fcn_DataClean_determineDataType(topic_name)



topic_name_lower = lower(topic_name);
if any([contains(topic_name_lower,'gps'), contains(topic_name_lower,'bin1')])
    datatype = 'gps';
elseif any([contains(topic_name_lower,'ins'), contains(topic_name_lower,'imu'),contains(topic_name_lower, 'adis')])
    datatype = 'ins';
elseif contains(topic_name_lower,'trigger')
    datatype = 'trigger';
elseif contains(topic_name_lower,'encoder')
    datatype = 'encoder';
elseif contains(topic_name_lower,'sick_lms500/scan')
    datatype = 'lidar2d';
elseif contains(topic_name_lower,'velodyne')
    datatype = 'lidar3d';
else
    datatype = 'other';
end