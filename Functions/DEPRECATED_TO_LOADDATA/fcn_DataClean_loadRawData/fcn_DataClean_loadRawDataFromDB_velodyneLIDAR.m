function Velodyne_Lidar_structure = fcn_DataClean_loadRawDataFromDB_velodyneLIDAR(field_data_struct,datatype,fid)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Sick Lidar data, whose data type is lidar2d
% Input Variables:
%      file_path = file path of the Velodyne Lidar data (format txt)
%      datatype  = the datatype should be lidar3d
% Returned Results:
%      Sick_Lidar_structure

% Author: Xinyu Cao
% Created Date: 2023_07_18
% To do: 
% - Merge X, Y, Z and Intensity into a matrix
% 
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
% Reference:
% Document/Velodyne LiDAR Point Cloud Message Info.txt
%%


flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end



if strcmp(datatype,'lidar3d')
    Velodyne_Lidar_structure = fcn_DataClean_initializeDataByType(datatype);
    if isempty(field_data_struct.id)
        warning('Velodyne Lidar Table is Empty!')
    else
        secs = field_data_struct.seconds;
        nsecs = field_data_struct.nanoseconds;
        % Sick_Lidar_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
        % data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        Velodyne_Lidar_structure.Seq                = field_data_struct.id;
        Velodyne_Lidar_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
        Velodyne_Lidar_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        Velodyne_Lidar_structure.Npoints            = length(field_data_struct.id);  % This is the number of data points in the array

        % Save the data structure and layout information first, these data will
        % be used to process the actual point cloud data later
        % 2D structure of the point cloud. If the cloud is unordered,
        % height is 1 and width is the length of the point cloud.

        Velodyne_Lidar_structure.MD5Hash        = field_data_struct.file_name;
        points_cell = {};
%         pointcloud_folder = "velodyne_pointcloud";
    
%     for idx_scan = 1:Nscans
%         pointsMD5Hash = MD5Hash_array(idx_scan);
%         points_file = bagFolderName+"/"+pointcloud_folder+"/"+pointsMD5Hash + ".txt";
%         opts_scan = detectImportOptions(points_file);
%         points = readmatrix(points_file,opts_scan);
%         points_cell{idx_scan,1} = points;
%         clear points
    end
    Velodyne_Lidar_structure.PointCloud = points_cell;
    % Loading completed
 
else
    error('Wrong data type requested: %s',dataType)
end




% Close out the loading process
if flag_do_debug 
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end