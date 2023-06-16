function IMU_data_structure = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(file_path,datatype,flag_do_debug,topic_name)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the parse Encoder data, whose data type is imu
% Input Variables:
%      file_path = file path of the IMU data
%      datatype  = the datatype should be imu
% Returned Results:
%      IMU_data_structure

% Author: Liming Gao
% Created Date: 2020_11_15
% Modify Date: 2023_06_16
%
% Modified by Xinyu Cao, Aneesh Batchu and Mariam Abdellatief on 2023_06_16
% 
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 
% Reference:
% 
%%
if strcmp(datatype, 'ins')
    IMU_data_structure = fcn_DataClean_initializeDataByType(datatype);
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    switch topic_name
        case '/imu/data_raw'
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            IMU_data_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % IMU_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            IMU_data_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % IMU_data_structure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            IMU_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
            % IMU_data_structure.IMUStatus          = default_value;  
            IMU_data_structure.XAccel             = datatable.x_2; 
            % IMU_data_structure.XAccel_Sigma       = default_value; 
            IMU_data_structure.YAccel             = datatable.y_2; 
            % IMU_data_structure.YAccel_Sigma       = default_value; 
            IMU_data_structure.ZAccel             = datatable.z_2; 
            % IMU_data_structure.ZAccel_Sigma       = default_value; 
            IMU_data_structure.XGyro              = datatable.x_1; 
            % IMU_data_structure.XGyro_Sigma        = default_value; 
            IMU_data_structure.YGyro              = datatable.y_1; 
            % IMU_data_structure.YGyro_Sigma        = default_value; 
            IMU_data_structure.ZGyro              = datatable.z_1; 
            % IMU_data_structure.ZGyro_Sigma        = default_value; 
       
        case '/imu/data'
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            IMU_data_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % IMU_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            IMU_data_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % IMU_data_structure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            IMU_data_structure.Npoints            = height(datatable);;  % This is the number of data points in the array
            % IMU_data_structure.IMUStatus          = default_value;  
            IMU_data_structure.XAccel             = datatable.x_2; 
            % IMU_data_structure.XAccel_Sigma       = default_value; 
            IMU_data_structure.YAccel             = datatable.y_2; 
            % IMU_data_structure.YAccel_Sigma       = default_value; 
            IMU_data_structure.ZAccel             = datatable.z_2; 
            % IMU_data_structure.ZAccel_Sigma       = default_value; 
            IMU_data_structure.XGyro              = datatable.x_1; 
            % IMU_data_structure.XGyro_Sigma        = default_value; 
            IMU_data_structure.YGyro              = datatable.y_1; 
            % IMU_data_structure.YGyro_Sigma        = default_value; 
            IMU_data_structure.ZGyro              = datatable.z_1; 
            % IMU_data_structure.ZGyro_Sigma        = default_value; 


        case '/imu/rpy/filtered'
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            
            IMU_data_structure.GPS_Time           = secs+nsecs*10^-9;;  % This is the GPS time, UTC, as reported by the unit
            % IMU_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            IMU_data_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % IMU_data_structure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            IMU_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
            % IMU_data_structure.IMUStatus          = default_value;  
            IMU_data_structure.XAccel             = datatable.x; 
            % adis_IMU_filtered_rpy.XAccel_Sigma       = default_value; 
            IMU_data_structure.YAccel             = datatable.y; 
            % adis_IMU_filtered_rpy.YAccel_Sigma       = default_value; 
            IMU_data_structure.ZAccel             = datatable.z; 
            % IMU_data_structure.ZAccel_Sigma       = default_value; 
            % IMU_data_structure.XGyro              = default_value; 
            % IMU_data_structure.XGyro_Sigma        = default_value; 
            % IMU_data_structure.YGyro              = default_value; 
            % IMU_data_structure.YGyro_Sigma        = default_value; 
            % IMU_data_structure.ZGyro              = default_value; 
            % IMU_data_structure.ZGyro_Sigma        = default_value; 

        otherwise
            error('Unrecognized topic requested: %s',topic_name)
    end

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
