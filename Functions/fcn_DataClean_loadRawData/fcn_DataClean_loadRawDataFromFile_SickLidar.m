
function data_structure = fcn_DataClean_loadRawDataFromFile_SickLidar(file_path,datatype,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Hemisphere DGPS(format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
% Returned Results:
%      Hemisphere
% Author: Liming Gao
% Created Date: 2020_11_15
% Modify Date: 2019_11_22
%
% Modified by Aneesh Batchu on 2023_06_13
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 1. check if it is reasonable for the calcualtion of Hemisphere.velMagnitude_Sigma
% 
%%


if strcmp(datatype,'lidar2d')
    opts = detectImportOptions(file_path);
    sick_lidar_data = readmatrix(file_path, opts);
    data_structure = fcn_DataClean_initializeDataByType(datatype);
    secs = sick_lidar_data(:,2);
    nsecs = sick_lidar_data(:,3);
    data_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    data_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
    % data_structure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    data_structure.Npoints            = length(secs);  % This is the number of data points in the array
    data_structure.angle_min          = sick_lidar_data(:,4);  % This is the start angle of scan [rad]
    data_structure.angle_max          = sick_lidar_data(:,5);  % This is the end angle of scan [rad]
    data_structure.angle_increment    = sick_lidar_data(:,6);  % This is the angle increment between each measurements [rad]
    data_structure.time_increment     = sick_lidar_data(:,7);  % This is the time increment between each measurements [s]
    data_structure.scan_time          = sick_lidar_data(:,8);  % This is the time between scans [s]
    data_structure.range_min          = sick_lidar_data(:,9);  % This is the minimum range value [m]
    data_structure.range_max          = sick_lidar_data(:,10);  % This is the maximum range value [m]
    data_structure.ranges             = sick_lidar_data(:,11:1151);  % This is the range data of scans [m]
    data_structure.intensities        = sick_lidar_data(:,1152:2292);  % This is the intensities data of scans (Ranging from 0 to 255)
    
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