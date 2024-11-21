function IMU_Novatel_structure = fcn_DataClean_loadRawDataFromFile_IMU_Ouster(file_path,datatype,fid)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the GPS_Novatel data
% Input Variables:
%      d = raw data from GPS_Novatel(format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
%
% Returned Results:
%      IMU_Novatel
% Author: Liming Gao
% Created Date: 2020_12_07
%
% Modified by Aneesh Batchu and Mariam Abdellatief on 2023_06_13
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.

% UPDATES:
% 2023_07_04 sbrennan@psu.edu
% -- fixed return at end of function to be 'end', keeping in function
% format
% -- added fid to fprint to allow printing to file
% -- added entry and exit debugging prints
% -- removed variable clearing at end of function because this is automatic
% 2024-10-28 by X. Cao
% -- rewrite the function to fcn_DataClean_loadRawDataFromFile_IMU_Ouster
% 2024-11-20 by X. Cao
% -- add feature that load sigmas from the datatable
% 2024-11-21 by X. Cao
% -- replace for loop with cellfun() to improve speed

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

if strcmp(datatype,'imu')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    IMU_Novatel_structure = fcn_DataClean_initializeDataByType(datatype);
    
    % IMU_Novatel_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % IMU_Novatel_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    IMU_Novatel_structure.ROS_Time           = datatable.rosbagTimestamp*10^-9;  % This is the ROS time that the data arrived into the bag
    IMU_Novatel_structure.centiSeconds       = 1;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    IMU_Novatel_structure.Npoints            = height(datatable);  % This is the number of data points in the array
    % IMU_Novatel_structure.IMUStatus          = default_value;
   
    IMU_Novatel_structure.XAccel             = datatable.x_2;
    IMU_Novatel_structure.YAccel             = datatable.y_2;
    IMU_Novatel_structure.ZAccel             = datatable.z_2;
    IMU_Novatel_structure.XGyro              = datatable.x_1;
    IMU_Novatel_structure.YGyro              = datatable.y_1;
    IMU_Novatel_structure.ZGyro              = datatable.z_1;

    % Grab linear acceleration convariance and angular acceleration
    % convariance from the datatable, and calculate the sigma with
    % std = sqrt(conv)
    Linear_Acceleration_Covariance_CellArray = datatable.linear_acceleration_covariance;
    Angular_Velocity_Covariance_CellArray = datatable.angular_velocity_covariance;
    Linear_Acceleration_Covariance_Matrices = cellfun(@(x) reshape(str2num(x), [3, 3]), Linear_Acceleration_Covariance_CellArray,'UniformOutput',false); 
    Angular_Velocity_Covariance_Matrices = cellfun(@(x) reshape(str2num(x), [3, 3]), Angular_Velocity_Covariance_CellArray,'UniformOutput',false); 
    

    XAccel_Sigma  = cellfun(@(m) sqrt(m(1,1)), Linear_Acceleration_Covariance_Matrices);
    YAccel_Sigma = cellfun(@(m) sqrt(m(2,2)), Linear_Acceleration_Covariance_Matrices);
    ZAccel_Sigma = cellfun(@(m) sqrt(m(3,3)), Linear_Acceleration_Covariance_Matrices);
    XGyro_Sigma = cellfun(@(m) sqrt(m(1,1)), Angular_Velocity_Covariance_Matrices);
    YGyro_Sigma = cellfun(@(m) sqrt(m(2,2)), Angular_Velocity_Covariance_Matrices);
    ZGyro_Sigma = cellfun(@(m) sqrt(m(3,3)), Angular_Velocity_Covariance_Matrices);

    % for idx_data_point = 1:IMU_Novatel_structure.Npoints     
    %     Linear_Acceleration_Covariance = str2num(Linear_Acceleration_Covariance_CellArray{idx_data_point});
    %     Linear_Acceleration_Covariance_Matrix = reshape(Linear_Acceleration_Covariance,[3 3]);   
    %     Angular_Velocity_Covariance = str2num(Angular_Velocity_Covariance_CellArray{idx_data_point});
    %     Angular_Velocity_Covariance_Matrix = reshape(Angular_Velocity_Covariance,[3 3]);   
    %     XAccel_Sigma(idx_data_point,1) = sqrt(Linear_Acceleration_Covariance_Matrix(1,1));
    %     YAccel_Sigma(idx_data_point,1) = sqrt(Linear_Acceleration_Covariance_Matrix(2,2));
    %     ZAccel_Sigma(idx_data_point,1) = sqrt(Linear_Acceleration_Covariance_Matrix(3,3));
    %     XGyro_Sigma(idx_data_point,1) = sqrt(Angular_Velocity_Covariance_Matrix(1,1));
    %     YGyro_Sigma(idx_data_point,1) = sqrt(Angular_Velocity_Covariance_Matrix(3,3));
    %     ZGyro_Sigma(idx_data_point,1) = sqrt(Angular_Velocity_Covariance_Matrix(3,3));
    % end
    % Fill the sigmas field
    IMU_Novatel_structure.XAccel_Sigma       = XAccel_Sigma;
    IMU_Novatel_structure.YAccel_Sigma       = YAccel_Sigma;
    IMU_Novatel_structure.ZAccel_Sigma       = ZAccel_Sigma;
    IMU_Novatel_structure.XGyro_Sigma        = XGyro_Sigma;
    IMU_Novatel_structure.YGyro_Sigma       = YGyro_Sigma;
    IMU_Novatel_structure.ZGyro_Sigma       = ZGyro_Sigma;
    % Event functions
    IMU_Novatel_structure.EventFunctions = {}; % These are the functions to determine if something went wrong

else
    error('Wrong data type requested: %s',dataType)
end


% Close out the loading process
if flag_do_debug
    fprintf(fid,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end
