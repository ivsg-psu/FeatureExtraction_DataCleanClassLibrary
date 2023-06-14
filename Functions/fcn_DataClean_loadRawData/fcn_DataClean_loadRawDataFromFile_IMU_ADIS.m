function IMU_ADIS = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(d,data_source,flag_do_debug)

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
%
% Updates:
%
% To do lists:
% 1.
%
%

%%

if strcmp(data_source,'mat_file')
    IMU_ADIS.ROS_Time      = d.Time';
    IMU_ADIS.centiSeconds  = 1; % This is sampled every 1 ms
    IMU_ADIS.Npoints       = length(IMU_ADIS.ROS_Time(:,1));
    IMU_ADIS.EmptyVector   = fcn_DataClean_fillEmptyStructureVector(IMU_ADIS); % Fill in empty vector (this is useful later)
    %IMU_ADIS.GPS_Time      = IMU_ADIS.EmptyVector;
    IMU_ADIS.deltaT_ROS    = mean(diff(IMU_ADIS.ROS_Time));
    %IMU_ADIS.deltaT_GPS    = mean(diff(IMU_ADIS.GPS_Time));
    %IMU_ADIS.IMUStatus     = IMU_ADIS.EmptyVector;
    IMU_ADIS.XAccel        = -d.LinearAccelerationY';
    IMU_ADIS.YAccel        = d.LinearAccelerationX';
    IMU_ADIS.ZAccel        = d.LinearAccelerationZ';
    IMU_ADIS.XGyro         = d.AngularVelocityY';  % note - these seem to be swapped!?! (if enter them swapped, they seem to agree)
    IMU_ADIS.YGyro         = d.AngularVelocityX';
    IMU_ADIS.ZGyro         = d.AngularVelocityZ';

else
    error('Please indicate the data source')
end

clear d %clear temp variable

% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
