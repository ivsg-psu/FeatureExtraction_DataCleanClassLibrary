function SickLiDAR = fcn_DataClean_loadRawDataFromFile_sickLIDAR(table,rawdata,flag_do_debug)

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

if strcmp(data_source,'mat_file')

    % sickLIDAR.GPS_Time           = data_structure.GPS_Time;  % This is the GPS time, UTC, as reported by the unit
    % sickLIDAR.Trigger_Time       = data_structure.Trigger_Time;  % This is the Trigger time, UTC, as calculated by sample
    % sickLIDAR.ROS_Time           = data_structure.ROS_Time;  % This is the ROS time that the data arrived into the bag
    % sickLIDAR.centiSeconds       = data_structure.centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    % sickLIDAR.Npoints            = data_structure.Npoints;  % This is the number of data points in the array
    % sickLIDAR.angle_min          = data_structure.angle_min;  % This is the start angle of scan [rad]
    % sickLIDAR.angle_max          = data_structure.angle_max;  % This is the end angle of scan [rad]
    % sickLIDAR.angle_increment    = data_structure.angle_increment;  % This is the angle increment between each measurements [rad]
    % sickLIDAR.time_increment     = data_structure.time_increment;  % This is the time increment between each measurements [s]
    % sickLIDAR.scan_time          = data_structure.scan_time;  % This is the time between scans [s]
    % sickLIDAR.range_min          = data_structure.range_min;  % This is the minimum range value [m]
    % sickLIDAR.range_max          = data_structure.range_max;  % This is the maximum range value [m]
    % sickLIDAR.ranges             = data_structure.ranges;  % This is the range data of scans [m]
    % sickLIDAR.intensities        = data_structure.intensities;  % This is the intensities data of scans (Ranging from 0 to 255)
    % % Event functions
    % sickLIDAR.EventFunctions = {}; % These are the functions to determine if something went wrong


    sick_lidar_data = readmatrix(file_path, opts);
    SickLiDAR = fcn_DataClean_initializeDataByType(datatype);
    secs = sick_lidar_data(:,2);
    nsecs = sick_lidar_data(:,3);
    SickLiDAR.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % SickLiDAR.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    SickLiDAR.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
    % SickLiDAR.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    SickLiDAR.Npoints            = length(secs);  % This is the number of data points in the array
    SickLiDAR.angle_min          = sick_lidar_data(:,4);  % This is the start angle of scan [rad]
    SickLiDAR.angle_max          = sick_lidar_data(:,5);  % This is the end angle of scan [rad]
    SickLiDAR.angle_increment    = sick_lidar_data(:,6);  % This is the angle increment between each measurements [rad]
    SickLiDAR.time_increment     = sick_lidar_data(:,7);  % This is the time increment between each measurements [s]
    SickLiDAR.scan_time          = sick_lidar_data(:,8);  % This is the time between scans [s]
    SickLiDAR.range_min          = sick_lidar_data(:,9);  % This is the minimum range value [m]
    SickLiDAR.range_max          = sick_lidar_data(:,10);  % This is the maximum range value [m]
    SickLiDAR.ranges             = sick_lidar_data(:,11:1151);  % This is the range data of scans [m]
    SickLiDAR.intensities        = sick_lidar_data(:,1152:2292);  % This is the intensities data of scans (Ranging from 0 to 255)

    % SickLiDAR = fcn_DataClean_loadRawDataFromFile_sickLIDAR(file_path,datatype,flag_do_debug);

    rawdata.SickLiDAR = SickLiDAR;
else
    error('Please indicate the data source')
end



clear data_structure %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return