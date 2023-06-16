function IMU_Novatel = fcn_DataClean_loadRawDataFromFile_IMU_Novatel(data_structure,data_source,flag_do_debug)

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
%
% Updates:
%
% To do lists:
% 1.
%
%

%%

if strcmp(data_source,'mat_file')
    
    IMU_Novatel.GPS_Time           = data_structure.GPS_Time;  % This is the GPS time, UTC, as reported by the unit
    IMU_Novatel.Trigger_Time       = data_structure.Trigger_Time;  % This is the Trigger time, UTC, as calculated by sample
    IMU_Novatel.ROS_Time           = data_structure.ROS_Time;  % This is the ROS time that the data arrived into the bag
    IMU_Novatel.centiSeconds       = data_structure.centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    IMU_Novatel.Npoints            = data_structure.Npoints;  % This is the number of data points in the array
    IMU_Novatel.IMUStatus          = data_structure.IMUStatus;  
    IMU_Novatel.XAccel             = data_structure.XAccel; 
    IMU_Novatel.XAccel_Sigma       = data_structure.XAccel_Sigma; 
    IMU_Novatel.YAccel             = data_structure.YAccel; 
    IMU_Novatel.YAccel_Sigma       = data_structure.YAccel_Sigma; 
    IMU_Novatel.ZAccel             = data_structure.ZAccel; 
    IMU_Novatel.ZAccel_Sigma       = data_structure.ZAccel_Sigma; 
    IMU_Novatel.XGyro              = data_structure.XGyro; 
    IMU_Novatel.XGyro_Sigma        = data_structure.XGyro_Sigma; 
    IMU_Novatel.YGyro              = data_structure.YGyro; 
    IMU_Novatel.YGyro_Sigma        = data_structure.YGyro_Sigma; 
    IMU_Novatel.ZGyro              = data_structure.ZGyro; 
    IMU_Novatel.ZGyro_Sigma        = data_structure.ZGyro_Sigma; 
    % Event functions
    IMU_Novatel.EventFunctions = {}; % These are the functions to determine if something went wrong

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
