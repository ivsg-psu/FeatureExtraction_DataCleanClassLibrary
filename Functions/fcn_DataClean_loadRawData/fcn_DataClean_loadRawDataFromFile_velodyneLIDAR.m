function Velodyne_Lidar_structure = fcn_DataClean_loadRawDataFromFile_velodyneLIDAR(file_path,bagFolderName,datatype,fid)

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
    opts = detectImportOptions(file_path);
    velodyne_lidar_table = readtable(file_path, opts);
    velodyne_lidar_table.Properties.VariableNames = {'seq','secs','nsecs','MD5Hash'};
    % The number of rows in the file, also the number of scans
    Nscans = height(velodyne_lidar_table);
    MD5Hash_array = string(velodyne_lidar_table.MD5Hash);
    Velodyne_Lidar_structure = fcn_DataClean_initializeDataByType(datatype);
    secs = velodyne_lidar_table.secs;
    nsecs = velodyne_lidar_table.nsecs;
    % Sick_Lidar_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    Velodyne_Lidar_structure.Seq                = velodyne_lidar_table.seq;
    Velodyne_Lidar_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
    Velodyne_Lidar_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    Velodyne_Lidar_structure.Npoints            = Nscans;  % This is the number of data points in the array
    
    % Save the data structure and layout information first, these data will
    % be used to process the actual point cloud data later
    % 2D structure of the point cloud. If the cloud is unordered, 
    % height is 1 and width is the length of the point cloud.
    % Velodyne_Lidar_structure.Height             = velodyne_lidar_table.Height; 
    % Velodyne_Lidar_structure.Width          = velodyne_lidar_table.Width;  
    % Velodyne_Lidar_structure.is_bigendian   = velodyne_lidar_table.is_bigendian;  % Is this data bigendian?
    % Velodyne_Lidar_structure.point_step    = velodyne_lidar_table.point_step;  % This is the length of a point in bytes
    % Velodyne_Lidar_structure.row_step        = velodyne_lidar_table.row_step;  % This is the length of a row in bytes
    % Velodyne_Lidar_structure.is_dense         = velodyne_lidar_table.is_dense;  %  True if there are no invalid points
    Velodyne_Lidar_structure.MD5Hash        = MD5Hash_array;
    points_cell = {};
    pointcloud_folder = "velodyne_pointcloud";
    
    for idx_scan = 1:Nscans
        pointsMD5Hash = MD5Hash_array(idx_scan);
        points_file = bagFolderName+"/"+pointcloud_folder+"/"+pointsMD5Hash + ".txt";
        opts_scan = detectImportOptions(points_file);
        points = readmatrix(points_file,opts_scan);
        points_cell{idx_scan,1} = points;
        clear points

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