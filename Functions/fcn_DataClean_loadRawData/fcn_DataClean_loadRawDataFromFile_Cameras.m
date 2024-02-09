function Camera_structure = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,camera_folder,datatype,fid)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the image data collected from cameras, whose data type is image
% Input Variables:
%      file_path = file path of the Velodyne Lidar data (format txt)
%      datatype  = the datatype should be camera
% Returned Results:
%      Camera_structure

% Author: Xinyu Cao
% Created Date: 2024_02_09
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.

%%


flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end



if strcmp(datatype,'camera')
    opts = detectImportOptions(file_path);
    image_hash_table = readtable(file_path, opts);
    image_hash_table.Properties.VariableNames = {'seq','secs','nsecs','image_hash'};
    % The number of rows in the file, also the number of scans
    N_images = height(image_hash_table);
    image_hash_array = string(image_hash_table.image_hash);
    Camera_structure = fcn_DataClean_initializeDataByType(datatype);
    secs = image_hash_table.secs;
    nsecs = image_hash_table.nsecs;
    % Sick_Lidar_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    Camera_structure.Seq                = image_hash_table.seq;
    Camera_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
    Camera_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    Camera_structure.Npoints            = N_images;  % This is the number of data points in the array
    
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
    Camera_structure.Image_Hash        = image_hash_array;

    for idx_image = 1:N_images
        image_filename = image_hash_array(idx_image);
        image_filename_char = char(image_filename);
        image_filepath = camera_folder+image_filename_char(1:2)+"/"+image_filename_char(3:4)+"/"+image_filename+".jpg";
        image = imread(image_filepath);
        image_cell{idx_image,1} = image;

    end
    Camera_structure.Image = image_cell;
    % Loading completed
 
else
    error('Wrong data type requested: %s',dataType)
end




% Close out the loading process
if flag_do_debug 
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end