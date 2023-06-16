function adis_IMU_data = fcn_DataClean_loadRawDataFromFile_adis_IMU_data(table,rawdata,flag_do_debug)

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
% Modified by Aneesh Batchu on 2023_06_15
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 1.
%
%

%%

if strcmp(data_source,'mat_file')
    
    % IMU_Novatel.GPS_Time           = data_structure.GPS_Time;  % This is the GPS time, UTC, as reported by the unit
    % IMU_Novatel.Trigger_Time       = data_structure.Trigger_Time;  % This is the Trigger time, UTC, as calculated by sample
    % IMU_Novatel.ROS_Time           = data_structure.ROS_Time;  % This is the ROS time that the data arrived into the bag
    % IMU_Novatel.centiSeconds       = data_structure.centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    % IMU_Novatel.Npoints            = data_structure.Npoints;  % This is the number of data points in the array
    % IMU_Novatel.IMUStatus          = data_structure.IMUStatus;  
    % IMU_Novatel.XAccel             = data_structure.XAccel; 
    % IMU_Novatel.XAccel_Sigma       = data_structure.XAccel_Sigma; 
    % IMU_Novatel.YAccel             = data_structure.YAccel; 
    % IMU_Novatel.YAccel_Sigma       = data_structure.YAccel_Sigma; 
    % IMU_Novatel.ZAccel             = data_structure.ZAccel; 
    % IMU_Novatel.ZAccel_Sigma       = data_structure.ZAccel_Sigma; 
    % IMU_Novatel.XGyro              = data_structure.XGyro; 
    % IMU_Novatel.XGyro_Sigma        = data_structure.XGyro_Sigma; 
    % IMU_Novatel.YGyro              = data_structure.YGyro; 
    % IMU_Novatel.YGyro_Sigma        = data_structure.YGyro_Sigma; 
    % IMU_Novatel.ZGyro              = data_structure.ZGyro; 
    % IMU_Novatel.ZGyro_Sigma        = data_structure.ZGyro_Sigma; 
    % % Event functions
    % IMU_Novatel.EventFunctions = {}; % These are the functions to determine if something went wrong

    adis_IMU_data = fcn_DataClean_initializeDataByType(datatype);
    
    secs = table.secs;
    nsecs = table.nsecs;
    adis_IMU_data.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % adis_IMU_data.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    adis_IMU_data.ROS_Time           = table.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
    % adis_IMU_data.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    % adis_IMU_data.Npoints            = default_value;  % This is the number of data points in the array
    % adis_IMU_data.IMUStatus          = default_value;  
    adis_IMU_data.XAccel             = table.x_2; 
    % adis_IMU_data.XAccel_Sigma       = default_value; 
    adis_IMU_data.YAccel             = table.y_2; 
    % adis_IMU_data.YAccel_Sigma       = default_value; 
    adis_IMU_data.ZAccel             = table.z_2; 
    % adis_IMU_data.ZAccel_Sigma       = default_value; 
    adis_IMU_data.XGyro              = table.x_1; 
    % adis_IMU_data.XGyro_Sigma        = default_value; 
    adis_IMU_data.YGyro              = table.y_1; 
    % adis_IMU_data.YGyro_Sigma        = default_value; 
    adis_IMU_data.ZGyro              = table.z_1; 
    % adis_IMU_data.ZGyro_Sigma        = default_value; 
    rawdata.adis_IMU_data = adis_IMU_data;


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
