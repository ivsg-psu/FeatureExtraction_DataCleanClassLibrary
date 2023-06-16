function IMU_Novatel_structure = fcn_DataClean_loadRawDataFromFile_IMU_Novatel(file_path,datatype,flag_do_debug)

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

if strcmp(datatype,'ins')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    IMU_Novatel_structure = fcn_DataClean_initializeDataByType(datatype);
    
    IMU_Novatel_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % IMU_Novatel_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    IMU_Novatel_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
    % IMU_Novatel_structure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    IMU_Novatel_structure.Npoints            = height(datatable);  % This is the number of data points in the array
    % IMU_Novatel_structure.IMUStatus          = default_value;
    IMU_Novatel_structure.XAccel             = datatable.x_2;
    % IMU_Novatel_structure.XAccel_Sigma       = default_value;
    IMU_Novatel_structure.YAccel             = datatable.y_2;
    % IMU_Novatel_structure.YAccel_Sigma       = default_value;
    IMU_Novatel_structure.ZAccel             = datatable.z_2;
    % IMU_Novatel_structure.ZAccel_Sigma       = default_value;
    IMU_Novatel_structure.XGyro              = datatable.x_1;
    % IMU_Novatel_structure.XGyro_Sigma        = default_value;
    IMU_Novatel_structure.YGyro              = datatable.y_1;
    % IMU_Novatel_structure.YGyro_Sigma        = default_value;
    IMU_Novatel_structure.ZGyro              = datatable.z_1;
    % IMU_data_structure.ZGyro_Sigma        = default_value;
    % Event functions
    IMU_Novatel_structure.EventFunctions = {}; % These are the functions to determine if something went wrong

else
    error('Wrong data type requested: %s',dataType)
end

clear datatable %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
