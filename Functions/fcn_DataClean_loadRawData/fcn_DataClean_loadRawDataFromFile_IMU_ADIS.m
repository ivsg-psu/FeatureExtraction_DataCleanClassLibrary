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

 
    % IMU_ADIS.ROS_Time      = d.Time';
    % IMU_ADIS.centiSeconds  = 1; % This is sampled every 1 ms
    % IMU_ADIS.Npoints       = length(IMU_ADIS.ROS_Time(:,1));
    % IMU_ADIS.EmptyVector   = fcn_DataClean_fillEmptyStructureVector(IMU_ADIS); % Fill in empty vector (this is useful later)
    % %IMU_ADIS.GPS_Time      = IMU_ADIS.EmptyVector;
    % IMU_ADIS.deltaT_ROS    = mean(diff(IMU_ADIS.ROS_Time));
    % %IMU_ADIS.deltaT_GPS    = mean(diff(IMU_ADIS.GPS_Time));
    % %IMU_ADIS.IMUStatus     = IMU_ADIS.EmptyVector;
    % IMU_ADIS.XAccel        = d.LinearAccelerationY';
    % IMU_ADIS.YAccel        = d.LinearAccelerationX';
    % IMU_ADIS.ZAccel        = d.LinearAccelerationZ';
    % IMU_ADIS.XGyro         = d.AngularVelocityY';  % note - these seem to be swapped!?! (if enter them swapped, they seem to agree)
    % IMU_ADIS.YGyro         = d.AngularVelocityX';
    % IMU_ADIS.ZGyro         = d.AngularVelocityZ';
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
