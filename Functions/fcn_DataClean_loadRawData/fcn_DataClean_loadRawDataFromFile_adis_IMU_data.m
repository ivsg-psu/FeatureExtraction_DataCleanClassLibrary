function adis_IMU_data = fcn_DataClean_loadRawDataFromFile_adis_IMU_data(file_path,datatype,table,flag_do_debug)

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

if contains(file_path,'imu/data')
    
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

else
    error('Please indicate the data source')
end

% clear data_structure %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return