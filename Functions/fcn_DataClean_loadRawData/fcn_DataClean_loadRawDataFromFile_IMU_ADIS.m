function IMU_ADIS = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(data_structure,data_source,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the IMU_ADIS data
% Input Variables:
%      d = raw data from IMU_ADIS(format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
%
% Returned Results:
%      IMU_ADIS
% Author: Liming Gao
% Created Date: 2020_12_07
%
% Modified by Aneesh Batchu and Mariam Abdellatief on 2023_06_13
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
%
% Updates:
%
% To do lists:
% 1.
%
%

%%

if strcmp(data_source,'mat_file')


    IMU_ADIS.GPS_Time           = data_structure.GPS_Time;  % This is the GPS time, UTC, as reported by the unit
    IMU_ADIS.Trigger_Time       = data_structure.Trigger_Time;  % This is the Trigger time, UTC, as calculated by sample
    IMU_ADIS.ROS_Time           = data_structure.ROS_Time;  % This is the ROS time that the data arrived into the bag
    IMU_ADIS.centiSeconds       = data_structure.centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    IMU_ADIS.Npoints            = data_structure.Npoints;  % This is the number of data points in the array
    IMU_ADIS.IMUStatus          = data_structure.IMUStatus;  
    IMU_ADIS.XAccel             = data_structure.XAccel; 
    IMU_ADIS.XAccel_Sigma       = data_structure.XAccel_Sigma; 
    IMU_ADIS.YAccel             = data_structure.YAccel; 
    IMU_ADIS.YAccel_Sigma       = data_structure.YAccel_Sigma; 
    IMU_ADIS.ZAccel             = data_structure.ZAccel; 
    IMU_ADIS.ZAccel_Sigma       = data_structure.ZAccel_Sigma; 
    IMU_ADIS.XGyro              = data_structure.XGyro; 
    IMU_ADIS.XGyro_Sigma        = data_structure.XGyro_Sigma; 
    IMU_ADIS.YGyro              = data_structure.YGyro; 
    IMU_ADIS.YGyro_Sigma        = data_structure.YGyro_Sigma; 
    IMU_ADIS.ZGyro              = data_structure.ZGyro; 
    IMU_ADIS.ZGyro_Sigma        = data_structure.ZGyro_Sigma; 
    % Event functions
    IMU_ADIS.EventFunctions = {}; % These are the functions to determine if something went wrong

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
