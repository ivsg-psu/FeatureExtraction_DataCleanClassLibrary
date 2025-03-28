function Sick_Lidar_structure = fcn_DataClean_loadRawDataFromFile_sickLIDAR(file_path,datatype,fid)

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
% Reference:
% Document/Sick LiDAR Message Info.txt
%%

% Updates:
% 2023_07_04 sbrennan@psu.edu
% -- fixed return at end of function to be 'end', keeping in function
% format
% -- added fid to fprint to allow printing to file
% -- added entry and exit debugging prints
% -- removed variable clearing at end of function because this is automatic

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end



if strcmp(datatype,'lidar2d')
    opts = detectImportOptions(file_path);
    sick_lidar_data = readmatrix(file_path, opts);
    Npoints = size(sick_lidar_data,1);
    data_length = size(sick_lidar_data,2);
    lidar_spec_length = 10;
    single_scan_length = (data_length-lidar_spec_length)/2;
    range_data_start = lidar_spec_length + 1;
    range_data_end = lidar_spec_length + single_scan_length;
    intensity_data_start = range_data_end + 1;
    intensity_data_end = range_data_end + single_scan_length;
    Sick_Lidar_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    % if iscell(sick_lidar_data)
    % 
    %     sick_lidar_data = cell2mat(sick_lidar_data);
    % end
    secs = sick_lidar_data(:,2);
    nsecs = sick_lidar_data(:,3);
    % Sick_Lidar_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    Sick_Lidar_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
    Sick_Lidar_structure.centiSeconds       = 2;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    % Sick_Lidar_structure.Npoints            = length(secs);  % This is the number of data points in the array
    Sick_Lidar_structure.angle_min          = sick_lidar_data(:,4);  % This is the start angle of scan [rad]
    Sick_Lidar_structure.angle_max          = sick_lidar_data(:,5);  % This is the end angle of scan [rad]
    Sick_Lidar_structure.angle_increment    = sick_lidar_data(:,6);  % This is the angle increment between each measurements [rad]
    Sick_Lidar_structure.time_increment     = sick_lidar_data(:,7);  % This is the time increment between each measurements [s]
    Sick_Lidar_structure.scan_time          = sick_lidar_data(:,8);  % This is the time between scans [s]
    Sick_Lidar_structure.range_min          = sick_lidar_data(:,9);  % This is the minimum range value [m]
    Sick_Lidar_structure.range_max          = sick_lidar_data(:,10);  % This is the maximum range value [m]
    Sick_Lidar_structure.ranges             = sick_lidar_data(:,range_data_start:range_data_end);  % This is the range data of scans [m]
    Sick_Lidar_structure.intensities        = sick_lidar_data(:,intensity_data_start:intensity_data_end);  % This is the intensities data of scans (Ranging from 0 to 255)
    

    % Process Sick Time topics
    dataFolder = fileparts(file_path);
    sick_time_file_name = '_slash_sick_lms500_slash_sicktime.csv';
    sick_time_file_path = fullfile(dataFolder,sick_time_file_name);
    if isfile(sick_time_file_path)
        sick_time_opts = detectImportOptions(sick_time_file_path);
        sick_time_opts.PreserveVariableNames = true;
        sick_time_table = readtable(sick_time_file_path,sick_time_opts);

        sick_time_secs = sick_time_table.secs_1;
        sick_time_nsecs = sick_time_table.nsecs_1;
        Sick_Lidar_structure.Sick_Time = sick_time_secs + sick_time_nsecs*10^-9;
    end

else
    error('Wrong data type requested: %s',dataType)
end




% Close out the loading process
if flag_do_debug 
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end