function Sick_Lidar_structure = fcn_DataClean_loadRawDataFromFile_sickLIDAR(file_path,datatype,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Sick Lidar data, whose data type is lidar2d
% Input Variables:
%      file_path = file path of the Sick Lidar data (format txt)
%      datatype  = the datatype should be lidar2d
% Returned Results:
%      Sick_Lidar_structure

% Author: Liming Gao
% Created Date: 2020_11_15
% Modify Date: 2023_06_16
%
% Modified by Xinyu Cao and Aneesh Batchu on 2023_06_16
% 
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 
% Reference:
% Document/Sick LiDAR Message Info.txt
%%


if strcmp(datatype,'lidar2d')
    opts = detectImportOptions(file_path);
    sick_lidar_data = readmatrix(file_path, opts);
    Npoints = size(sick_lidar_data,1);
    Sick_Lidar_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    
    secs = sick_lidar_data(:,2);
    nsecs = sick_lidar_data(:,3);
    % Sick_Lidar_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    Sick_Lidar_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
    Sick_Lidar_structure.centiSeconds       = 100;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    Sick_Lidar_structure.Npoints            = length(secs);  % This is the number of data points in the array
    Sick_Lidar_structure.angle_min          = sick_lidar_data(:,4);  % This is the start angle of scan [rad]
    Sick_Lidar_structure.angle_max          = sick_lidar_data(:,5);  % This is the end angle of scan [rad]
    Sick_Lidar_structure.angle_increment    = sick_lidar_data(:,6);  % This is the angle increment between each measurements [rad]
    Sick_Lidar_structure.time_increment     = sick_lidar_data(:,7);  % This is the time increment between each measurements [s]
    Sick_Lidar_structure.scan_time          = sick_lidar_data(:,8);  % This is the time between scans [s]
    Sick_Lidar_structure.range_min          = sick_lidar_data(:,9);  % This is the minimum range value [m]
    Sick_Lidar_structure.range_max          = sick_lidar_data(:,10);  % This is the maximum range value [m]
    Sick_Lidar_structure.ranges             = sick_lidar_data(:,11:1151);  % This is the range data of scans [m]
    Sick_Lidar_structure.intensities        = sick_lidar_data(:,1152:2292);  % This is the intensities data of scans (Ranging from 0 to 255)
    

    % Process Sick Time topics
    dataFolder = fileparts(file_path);
    sick_time_file_name = '_slash_sick_lms500_slash_sicktime.csv';
    sick_time_file_path = fullfile(dataFolder,sick_time_file_name);
    sick_time_opts = detectImportOptions(sick_time_file_path);
    sick_time_opts.PreserveVariableNames = true;
    sick_time_table = readtable(sick_time_file_path,sick_time_opts);

    sick_time_secs = sick_time_table.secs_1;
    sick_time_nsecs = sick_time_table.nsecs_1;
    Sick_Lidar_structure.Sick_Time = sick_time_secs + sick_time_nsecs*10^-9;
    

else
    error('Wrong data type requested: %s',dataType)
end




% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return