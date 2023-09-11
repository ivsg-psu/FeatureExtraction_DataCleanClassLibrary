function IMU_data_structure = fcn_DataClean_loadRawDataFromDB_IMU_ADIS(field_data_struct,datatype,fid)

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


% Updates:
% 2023_06_22 sbrennan@psu.edu
% -- fixed type error for imu (it was listed as ins, which is deprecated)
% -- fixed error in datatype (typo in variable name)
% 2023_07_04 sbrennan@psu.edu
% -- fixed return at end of function to be 'end', keeping in function
% format
% -- added fid to fprint to allow printing to file

% To do lists:
% -- Need test script to catch errors
% -- Need to functionalize code into standard form

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  %#ok<NASGU> % % Flag to plot the final results
flag_check_inputs = 1; %#ok<NASGU> % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


%%
if strcmp(datatype, 'imu')
    Npoints = length(field_data_struct.id);
    IMU_data_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    if isempty(field_data_struct.id)
        warning('IMU Adis Table is Empty!')
    else
        secs = field_data_struct.seconds;
        nsecs = field_data_struct.nanoseconds;
        IMU_data_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
        % IMU_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        IMU_data_structure.ROS_Time           = field_data_struct.time;  % This is the ROS time that the data arrived into the bag
        % IMU_data_structure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        IMU_data_structure.Npoints            = Npoints;  % This is the number of data points in the array
        % IMU_data_structure.IMUStatus          = default_value;
        IMU_data_structure.XOrientation       = field_data_struct.x_orientation;
        % IMU_data_structure.XOrientation_Sigma = default_value;
        IMU_data_structure.YOrientation       = field_data_struct.y_orientation;
        % IMU_data_structure.YOrientation_Sigma = default_value;
        IMU_data_structure.ZOrientation       = field_data_struct.z_orientation;
        % IMU_data_structure.ZOrientation_Sigma = default_value;
        IMU_data_structure.WOrientation       = field_data_struct.w_orientation;
        % IMU_data_structure.WOrientation_Sigma = default_value;
        %             IMU_data_structure.Orientation_Sigma  = field_data_struct.orientation_covariance;

        IMU_data_structure.XAccel             = field_data_struct.x_acceleration;
        % IMU_data_structure.XAccel_Sigma       = default_value;
        IMU_data_structure.YAccel             = field_data_struct.y_acceleration;
        % IMU_data_structure.YAccel_Sigma       = default_value;
        IMU_data_structure.ZAccel             = field_data_struct.z_acceleration;
        % IMU_data_structure.ZAccel_Sigma       = default_value;
        %             IMU_data_structure.Accel_Sigma        = field_data_struct.linear_acceleration_covariance;
        IMU_data_structure.XGyro              = field_data_struct.x_angular_velocity;
        % IMU_data_structure.XGyro_Sigma        = default_value;
        IMU_data_structure.YGyro              = field_data_struct.y_angular_velocity;
        % IMU_data_structure.YGyro_Sigma        = default_value;
        IMU_data_structure.ZGyro              = field_data_struct.z_angular_velocity;
        % IMU_data_structure.ZGyro_Sigma        = default_value;
        %             IMU_data_structure.Gyro_Sigma         = field_data_struct.angular_velocity_covariance;
        % Message below are not exist
        IMU_data_structure.XMagnetic          = field_data_struct.magnetic_x;
        % IMU_data_structure.XMagnetic_Sigma    = default_value;
        IMU_data_structure.YMagnetic          = field_data_struct.magnetic_y;
        % IMU_data_structure.YMagnetic_Sigma    = default_value;
        IMU_data_structure.ZMagnetic          = field_data_struct.magnetic_z;
        % IMU_data_structure.ZMagnetic_Sigma    = default_value;
        % IMU_data_structure.Magnetic_Sigma     = default_value;
        IMU_data_structure.Pressure           = field_data_struct.pressure;
        % IMU_data_structure.Pressure_Sigma     = default_value;
        IMU_data_structure.Temperature        = field_data_struct.temperature;
        % IMU_data_structure.Temperature_Sigma  = default_value;
    end

else
    error('Wrong data type requested: %s',datatype)

end


% Close out the loading process
if flag_do_debug
    fprintf(fid,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end
