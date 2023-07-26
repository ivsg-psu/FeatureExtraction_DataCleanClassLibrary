function Velodyne_Lidar_structure = fcn_DataClean_loadRawDataFromFile_velodyneLIDAR(file_path,datatype,fid)

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
    velodyne_lidar_table.Properties.VariableNames = {'seq','secs','nsecs','Height','Width',...
        'is_bigendian','point_step','row_step','point_cloud','is_dense'};
    % The number of rows in the file, also the number of scans
    Nrows = height(velodyne_lidar_table);

    Velodyne_Lidar_structure = fcn_DataClean_initializeDataByType(datatype);
    secs = velodyne_lidar_table.secs;
    nsecs = velodyne_lidar_table.nsecs;
    % Sick_Lidar_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    Velodyne_Lidar_structure.Seq                = velodyne_lidar_table.seq;
    Velodyne_Lidar_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
    Velodyne_Lidar_structure.centiSeconds       = 100;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    Velodyne_Lidar_structure.Npoints            = length(secs);  % This is the number of data points in the array
    
    % Save the data structure and layout information first, these data will
    % be used to process the actual point cloud data later
    % 2D structure of the point cloud. If the cloud is unordered, 
    % height is 1 and width is the length of the point cloud.
    Velodyne_Lidar_structure.Height             = velodyne_lidar_table.Height; 
    Velodyne_Lidar_structure.Width          = velodyne_lidar_table.Width;  
    Velodyne_Lidar_structure.is_bigendian   = velodyne_lidar_table.is_bigendian;  % Is this data bigendian?
    Velodyne_Lidar_structure.point_step    = velodyne_lidar_table.point_step;  % This is the length of a point in bytes
    Velodyne_Lidar_structure.row_step        = velodyne_lidar_table.row_step;  % This is the length of a row in bytes
    Velodyne_Lidar_structure.is_dense         = velodyne_lidar_table.is_dense;  %  True if there are no invalid points
    
    
    x_cell = {};
    y_cell = {};
    z_cell = {};
    intensity_cell = {};
    ring_cell = {};
    time_cell = {};
    
    % The point data is stored as a binary blob, its layout described by the
    % contents of the "fields" array.
    % The point_cloud field contains the raw point cloud data whose size is 
    % size is row_step*height. The length of a point in bytes is point_step
    % Each point contains x, y, z, intensity, ring and time.
    % Start to process the point cloud data, since all point cloud data are
    % saved in bytes, 
    for i_scan = 1:Nrows
        % Initialize the array for each scan
        x_array = [];
        y_array = [];
        z_array = [];
        intensity_array = [];
        ring_array = [];
        time_array = [];
        N_point_cloud = velodyne_lidar_table.Width(i_scan); % Num of points in each scan
        point_step = velodyne_lidar_table.point_step(i_scan); % Length of a point in bytes (uint8)
        % Load the point cloud data, which is a character array
        point_cloud_char = velodyne_lidar_table.point_cloud{i_scan};
        % Convert the char array to uint8        
        point_cloud_array = uint8(str2double(strsplit(point_cloud_char,',')));
        % Reshape the array to a matrix of N_point_cloud by point_step
        point_cloud_array_reshape = reshape(point_cloud_array, [point_step, N_point_cloud]).';
        % Process the point one by one
        for i_point = 1:N_point_cloud
            x_uint8_vec = point_cloud_array_reshape(i_point,1:4);
            y_uint8_vec = point_cloud_array_reshape(i_point,5:8);
            z_uint8_vec = point_cloud_array_reshape(i_point,9:12);
            intensity_uint8_vec = point_cloud_array_reshape(i_point,13:16);
            ring_uint8_vec = point_cloud_array_reshape(i_point,17:18);
            time_uint8_vec = point_cloud_array_reshape(i_point,19:22);
            % Save the processed data into the corresponding array
            x_array(i_point) = typecast(x_uint8_vec,'single');
            y_array(i_point) = typecast(y_uint8_vec,'single');
            z_array(i_point) = typecast(z_uint8_vec,'single');
            intensity_array(i_point) = typecast(intensity_uint8_vec,'single');
            ring_array(i_point) = typecast(ring_uint8_vec,'uint16');
            time_array(i_point) = typecast(time_uint8_vec,'single');
        end
        % Save the data to the corresponding cell
        x_cell{i_scan,1} = x_array;
        y_cell{i_scan,1} = y_array;
        z_cell{i_scan,1} = z_array;
        intensity_cell{i_scan,1} = intensity_array;
        ring_cell{i_scan,1} = ring_array;
        time_cell{i_scan,1} = time_array;   
    end
    Velodyne_Lidar_structure.X        = x_cell;  % This is the x coordinate of each point [m]
    Velodyne_Lidar_structure.Y        = y_cell;  % This is the y coordinate of each point [m]
    Velodyne_Lidar_structure.Z        = z_cell;  % This is the z coordinate of each point [m]
    Velodyne_Lidar_structure.Intensity = intensity_cell; % This is the intensity of each point
    Velodyne_Lidar_structure.Ring     = ring_cell; % This the ring sequence for device laser numbers, range from 0 to 15.
    % Ring zero is the lower-most laser, ring one is next. Ring 15 is the upper-most.  

    Velodyne_Lidar_structure.Time_Offset = time_cell; % This are hard coded time offsets from the message timestamps
    % Loading completed
 
else
    error('Wrong data type requested: %s',dataType)
end




% Close out the loading process
if flag_do_debug 
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end