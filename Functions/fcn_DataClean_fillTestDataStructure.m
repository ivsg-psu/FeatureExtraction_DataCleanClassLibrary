function [dataStructure, time_corruption_type_string] = fcn_DataClean_fillTestDataStructure(varargin)
% fcn_DataClean_fillTestDataStructure
% Creates five seconds of test data for testing functions
%
% FORMAT:
%
%      dataStructure =
%      fcn_DataClean_fillTestDataStructure((time_time_corruption_type),(fid))
%
% INPUTS:
%
%      (none)
%
%      (OPTIONAL INPUTS)
%
%      time_time_corruption_type: an integer listing the type of noise,
%      errors, faults, etc. to add to the time data. The types can be
%      entered as a decimal integer, where the bits represent what
%      noise/corruption are added. Note: bit flags can easily be turned
%      into decimal using the "bi2de" (binary to decimal) command. The bits
%      are defined as follows:
%
%          2^0 bit = 0: (default) Perfect data with no noise added. All standard
%          deviations are zero.
%
%          2^0 bit = 1: Typical data for the mapping van. Standard deviations are
%          representative of the sensors used on the vehicle.
%
%          2^1 bit (2) = 1: The GPS_Time field is missing on one of the GPS sensors. This
%          is a catastrophic failure as these sensors align true UTC time
%          (measured from GPS) to the CPU time as noted in ROS.
%
%          2^2 bit (4) = 1: The GPS_Time field is empty on one of the GPS sensors. This
%          is a catastrophic failure as these sensors align true UTC time
%          (measured from GPS) to the CPU time as noted in ROS.
%    
%          2^3 bit (8) = 1: The GPS_Time field is empty on one of the GPS sensors. This
%          is a catastrophic failure as these sensors align true UTC time
%          (measured from GPS) to the CPU time as noted in ROS.
%    
%          2^4 bit (16) = 1:: The centiSeconds field is missing on one of the sensors. This
%          is a major failure as this field defines the sampling rate.
%    
%          2^5 bit (32) = 1: The centiSeconds field is empty on one of the sensors. This
%          is a major failure as this field defines the sampling rate.
%    
%          2^6 bit (64) = 1: The centiSeconds field is NaN on one of the sensors. This
%          is a major failure as this field defines the sampling rate.
%    
%          2^7 bit (128) = 1: The centiSeconds field is inconsistent with
%          GPS_Time data. This occurs if the sampling rate is set wrong, if
%          the GPS mode changes unexpectedly, or if there is a failure
%          during operation of the GPS sensor.
%    
%          2^8 bit (256) = 1: The centiSeconds field is inconsistent with
%          ROS_Time data. This occurs if the sampling rate is set wrong, if
%          the GPS mode changes unexpectedly, or if there is a failure
%          during operation of the GPS sensor. (NOTE: Trigger_Time is
%          calculated from centiSeconds, so there is no check if this is
%          missing, as this is redundant to checking if centiSeconds
%          exists.)
%    
%          2^9 bit (512) = 1: The Trigger_Time field is missing. This
%          indicates that this field must be calculated or recalculated.
%
%          2^10 bit (1024) = 1: The Trigger_Time field is empty. This
%          indicates that this field must be calculated or recalculated.
%
%          2^11 bit (2048) = 1: The Trigger_Time field has a NaN value.
%          This indicates that this field must be calculated or
%          recalculated.
%
%          2^12 bit (4092) = 1: The GPS_Time field is not increasing. This
%          occurs when packets arrive from the GPS out-of-order. In most
%          cases, this can be fixed with reprocessing.
%
%          2^13 bit (8192) = 1: The GPS_Time field has a repeating time. This
%          occurs when a packet is resent due to a sensor fault. In most
%          cases, this can be fixed with reprocessing.
%
%          2^14 bit (16384) = 1: The ROS_Time field is missing.
%          This occurs if there is a major fault in the ROS bag file. This
%          is recoverable if the sensor has GPS_Time recorded or if the
%          trigger time is known.
%
%          2^15 bit (32768) = 1: The ROS_Time field is empty.
%          This occurs if there is a major fault in the ROS bag file. This
%          is recoverable if the sensor has GPS_Time recorded or if the
%          trigger time is known.
%
%          2^16 bit (65536) = 1: The ROS_Time field contains NaN.
%          This occurs if there is a minor fault in the ROS bag file. This
%          is recoverable if the sensor has GPS_Time recorded or if the
%          trigger time is known.
%
%          2^17 bit = 1: The ROS_Time is not increasing
%          This occurs if there is a minor fault in the ROS bag file. This
%          is recoverable if the sensor has GPS_Time recorded or if the
%          trigger time is known.
%
%          2^18 bit = 1: ROS_Time has a repeat.
%          This occurs if there is a minor fault in the ROS bag file. This
%          is recoverable if the sensor has GPS_Time recorded.
%
%          2^19 bit = 1: The ROS_Time field has wrong length.
%          This occurs if the ROS time does not align in count to the
%          expected number of data from the Trigger_Time. This is
%          recoverable by matching the ROS_Time values to Trigger_Times to
%          find the missing data, then resampling over the gap.
%
%          2^20 bit = 1: The GPS_Time field in a GPS sensor has repeated
%          but ordered entries.
%
%          2^21 bit = 1: The ROS_Time field in a GPS sensor has repeated
%          but ordered entries.
%
%          2^22 bit = 1: The GPS_Time field in a GPS sensor has a
%          discontinuity.
%
%      fid: a file ID to print results of analysis. If not entered, no
%      printing is done. Set fid to 1 to print to the console.%
%
% OUTPUTS:
%
%      dataStructure: a template data structure containing the fields that
%      are typical for the mapping van.
% 
%      time_corruption_type_string: a string indicating the sequence of
%      corruptions added into the time data
%
%
% DEPENDENCIES:
%
%      (none)
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_fillTestDataStructure
%     for a basic test suite. See the script:
%     script_test_fcn_DataClean_checkDataTimeConsistency for additional
%     examples.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_06_19: sbrennan@psu.edu
% -- wrote the code originally 

% TO DO
% 

flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking





%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag_check_inputs
    % Are there the right number of inputs?
    if nargin < 0 || nargin > 2
        error('Incorrect number of input arguments')
    end

end

% Does user want to corrupt the data?
% Set default flags:
flag_add_normal_noise = 0;
time_corruption_type = 0;
if 1 <= nargin
    temp = varargin{end};
    if ~isempty(temp)
        time_corruption_type = temp;
    end
    if time_corruption_type>=1
        flag_add_normal_noise = 1;
    end
end


% Does the user want to specify the fid?
fid = 0; % Do not print by default
if 2 == nargin
    temp = varargin{end};
    if ~isempty(temp)
        % Check that the FID works
        try
            temp_msg = ferror(temp); %#ok<NASGU>
            % Set the fid value, if the above ferror didn't fail
            fid = temp;
        catch ME
            warning('User-specified FID does not correspond to a file. Unable to continue.');
            throwAsCaller(ME);
        end
    end
end

if fid
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize structure
dataStructure = struct;

% Initialize corruption type
if time_corruption_type == 0
    time_corruption_type_string = 'Perfect data, no noise, no errors';
elseif time_corruption_type ==1
    time_corruption_type_string = 'Typical data, typical noise, no errors';
else
    time_corruption_type_string = '';
end


% Initialize all the sensors
dataStructure.TRIGGER = fcn_DataClean_initializeDataByType('trigger');
dataStructure.GPS_Sparkfun_RearRight = fcn_DataClean_initializeDataByType('gps');
dataStructure.GPS_Sparkfun_RearLeft = fcn_DataClean_initializeDataByType('gps');
dataStructure.GPS_Hemisphere = fcn_DataClean_initializeDataByType('gps');
dataStructure.ENCODER_RearLeft = fcn_DataClean_initializeDataByType('encoder');
dataStructure.ENCODER_RearRight = fcn_DataClean_initializeDataByType('encoder');
dataStructure.IMU_ADIS = fcn_DataClean_initializeDataByType('imu');
dataStructure.LIDAR2D_Sick = fcn_DataClean_initializeDataByType('lidar2d');
% dataStructure.DIAGNOSTIC = fcn_DataClean_initializeDataByType('diagnostic');

% Set the sampling intervals
dataStructure.TRIGGER.centiSeconds                   = 100; % 1 Hz
dataStructure.GPS_Sparkfun_RearRight.centiSeconds    = 5; % 20 Hz
dataStructure.GPS_Sparkfun_RearLeft.centiSeconds     = 5; % 20 Hz
dataStructure.GPS_Hemisphere.centiSeconds            = 5; % 20 Hz
dataStructure.ENCODER_RearLeft.centiSeconds          = 1; % 100 Hz
dataStructure.ENCODER_RearRight.centiSeconds         = 1; % 100 Hz
dataStructure.IMU_ADIS.centiSeconds                  = 1; % 100 Hz
dataStructure.LIDAR2D_Sick.centiSeconds              = 10; % 10 Hz


numSeconds = 5; % Simulate 5 seconds of data
ROS_time_offset = 0.00123; % It will be just a very small bit off

% Fill in time data
fields_to_calculate_times_for = [...
    {'GPS_Time'}...
    {'Trigger_Time'}...
    {'ROS_Time'},...    
    ];

% Add noise?
velMagnitude_Sigma = 0;
velNorth_Sigma = 0;
velEast_Sigma = 0;
velUp_Sigma = 0;

if flag_add_normal_noise
    velMagnitude_Sigma = 0.01; % Roughly 1 cm/sec
    velNorth_Sigma = velMagnitude_Sigma*2^1/3;
    velEast_Sigma  = velMagnitude_Sigma*2^1/3;
    velUp_Sigma    = velMagnitude_Sigma*2^1/3;
end


% Fill in trajectory data
OneSigmaPos = 0.01; % One centimeter

deltaT = 0.01;
time_full_data = (0:deltaT:numSeconds)';
ones_full_data = ones(length(time_full_data(:,1)),1);
yaw_angles = 357*pi/180 + 15*pi/180 * sin(2*pi/numSeconds*time_full_data); % A swerving maneuver
yaw_angles = mod(yaw_angles,360*pi/180); % Round it just like the sensor does, to 0 to 360 degrees
base_velocity = 20; % Meters per second

velocity = base_velocity*ones_full_data + velMagnitude_Sigma*randn(length(ones_full_data(:,1)),1);
velNorth = velocity.*cos(yaw_angles); % NOTE: this is probably wrong!
velEast  = velocity.*sin(yaw_angles);
velUp    = 0*velocity;

% Use cumulative sum to find positions
X_data = cumsum(velEast)*deltaT + OneSigmaPos*randn(length(ones_full_data(:,1)),1);
Y_data = cumsum(velNorth)*deltaT + OneSigmaPos*randn(length(ones_full_data(:,1)),1);
Z_data = cumsum(velUp)*deltaT + OneSigmaPos*randn(length(ones_full_data(:,1)),1);





% For debugging, to see what the ENU trajactory looks like
if fid
    figure(5874);
    clf;
    hold on;
    % plot(X_data,Y_data,'.','MarkerSize',20,'Linewidth',3);
    temp_h = scatter(X_data,Y_data,'.','SizeData',200); %#ok<NASGU>
    plot(X_data(1,1),Y_data(1,1),'go','MarkerSize',20);
    axis equal;
    title('Full bandwidth (100Hz) XY data');
end



% Convert ENU data to LLA
% Define reference location at test track
reference_latitude = 40.8623031194444;
reference_longitude = -77.8362636138889;
reference_altitude = 333.817;

gps_object = GPS(reference_latitude,reference_longitude,reference_altitude); % Initiate the class object for GPS
% ENU_full_data = gps_object.WGSLLA2ENU(LLA_full_data(:,1), LLA_full_data(:,2), LLA_full_data(:,3));
ENU_full_data = [X_data, Y_data, Z_data];
LLA_full_data  =  gps_object.ENU2WGSLLA(ENU_full_data);
Latitude_full_data = LLA_full_data(:,1);
Longitude_full_data = LLA_full_data(:,1);
Altitude_full_data = LLA_full_data(:,1);



names = fieldnames(dataStructure); % Grab all the fields that are in rawData structure
for i_data = 1:length(names)
    % Grab the data subfield name
    sensor_name = names{i_data};
    sensor_structure = dataStructure.(sensor_name);  % This is the input (current) data structure

    % Show what we are doing
    if fid
        fprintf(fid,'Filling fields on sensor: %s \n',sensor_name);
    end
    
    sensorSubfieldNames = fieldnames(sensor_structure); % Grab all the subfields
    for i_subField = 1:length(sensorSubfieldNames)
        % Grab the name of the ith subfield
        subFieldName = sensorSubfieldNames{i_subField};
        
        if fid
            fprintf(fid,'\tFilling field: %s \n',subFieldName);
        end
        % Need to calculate the times
        centiSeconds = sensor_structure.centiSeconds;
        timeSensor = (0:centiSeconds*0.01:numSeconds)';
        onesSensor = ones(length(timeSensor),1);

        % Check to see if this subField is in the time calculationlist
        if any(strcmp(subFieldName,fields_to_calculate_times_for))
            
            timeSimulated = timeSensor  + posixtime(datetime('now'));
            
            if strcmp(subFieldName,'ROS_Time')
                timeSimulated = timeSimulated+ROS_time_offset;
            end
            sensor_structure.(subFieldName) = timeSimulated;
        elseif strcmp(subFieldName,'centiSeconds')
            if isempty(sensor_structure.centiSeconds)
                error('One of the sensor substructure centiSeconds fields was not correctly initialized!');
            end
        elseif strcmp(subFieldName,'Npoints')
            sensor_structure.Npoints = length(sensor_structure.GPS_Time(:,1));
        else
            
            % Fill in other fields using interpolation
            % Vq = interp1(X,V,Xq)
            switch subFieldName
                % TRIGGER fields
                case {'mode'}
                    sensor_structure.mode = onesSensor;
                case {'adjone'}
                    sensor_structure.adjone = onesSensor;
                case {'adjtwo'}
                    sensor_structure.adjtwo = onesSensor;
                case {'adjthree'}
                    sensor_structure.adjthree = onesSensor;
                case {'err_failed_mode_count'}
                    sensor_structure.err_failed_mode_count = onesSensor;
                case {'err_failed_checkInformation'}
                    sensor_structure.err_failed_checkInformation = onesSensor;
                case {'err_failed_XI_format'}
                    sensor_structure.err_failed_XI_format = onesSensor;
                case {'err_trigger_unknown_error_occured'}
                    sensor_structure.err_trigger_unknown_error_occured = onesSensor;
                case {'err_bad_uppercase_character'}
                    sensor_structure.err_bad_uppercase_character = onesSensor;
                case {'err_bad_lowercase_character'}
                    sensor_structure.err_bad_lowercase_character = onesSensor;
                case {'err_bad_three_adj_element'}
                    sensor_structure.err_bad_three_adj_element = onesSensor;
                case {'err_bad_first_element'}
                    sensor_structure.err_bad_first_element = onesSensor;
                case {'err_bad_character'}
                    sensor_structure.err_bad_character = onesSensor;
                case {'err_wrong_element_length'}
                    sensor_structure.err_wrong_element_length = onesSensor;
                case {'TRIGGER_EventFunctions'}
                    sensor_structure.TRIGGER_EventFunctions = {};
                    
                    % GPS fields
                case {'Latitude'}
                    sensor_structure.Latitude = interp1(time_full_data,Latitude_full_data,timeSensor);
                case {'Longitude'}
                    sensor_structure.Longitude = interp1(time_full_data,Longitude_full_data,timeSensor);
                case {'Altitude'}
                    sensor_structure.Altitude = interp1(time_full_data,Altitude_full_data,timeSensor);
                case {'xEast'}
                    sensor_structure.xEast = interp1(time_full_data,X_data,timeSensor);
                case {'yNorth'}
                    sensor_structure.yNorth = interp1(time_full_data,Y_data,timeSensor);
                case {'zUp'}
                    sensor_structure.zUp = interp1(time_full_data,Z_data,timeSensor);
                case {'velNorth'}
                    sensor_structure.velNorth = interp1(time_full_data,velNorth,timeSensor);
                case {'velEast'}
                    sensor_structure.velEast = interp1(time_full_data,velEast,timeSensor);
                case {'velUp'}
                    sensor_structure.velUp = interp1(time_full_data,velUp,timeSensor);
                case {'velMagnitude'}
                    sensor_structure.velMagnitude = interp1(time_full_data,abs(velocity),timeSensor);
                case {'velNorth_Sigma'}
                    sensor_structure.velNorth_Sigma = onesSensor*velNorth_Sigma;
                case {'velEast_Sigma'}
                    sensor_structure.velEast_Sigma = onesSensor*velEast_Sigma;
                case {'velUp_Sigma'}
                    sensor_structure.velUp_Sigma = onesSensor*velUp_Sigma;
                case {'velMagnitude_Sigma'}
                    sensor_structure.velMagnitude_Sigma = onesSensor*velMagnitude_Sigma;
                case {'DGPS_is_active'}
                    sensor_structure.DGPS_is_active = onesSensor;
                case {'OneSigmaPos'}
                    sensor_structure.OneSigmaPos = OneSigmaPos*onesSensor;
                case {'xEast_Sigma'}
                    sensor_structure.xEast_Sigma = onesSensor;
                case {'yNorth_Sigma'}
                    sensor_structure.yNorth_Sigma = onesSensor;
                case {'zUp_Sigma'}
                    sensor_structure.zUp_Sigma = onesSensor;
                case {'xEast_increments'}
                    sensor_structure.xEast_increments = onesSensor;
                case {'yNorth_increments'}
                    sensor_structure.yNorth_increments = onesSensor;
                case {'zUp_increments'}
                    sensor_structure.zUp_increments = onesSensor;
                case {'xEast_increments_Sigma'}
                    sensor_structure.xEast_increments_Sigma = onesSensor;
                case {'yNorth_increments_Sigma'}
                    sensor_structure.yNorth_increments_Sigma = onesSensor;
                case {'zUp_increments_Sigma'}
                    sensor_structure.zUp_increments_Sigma = onesSensor;
                case {'xy_increments'}
                    sensor_structure.xy_increments = onesSensor;
                case {'xy_increments_Sigma'}
                    sensor_structure.xy_increments_Sigma = onesSensor;
                case {'Yaw_deg_from_position'}
                    sensor_structure.Yaw_deg_from_position = onesSensor;
                case {'Yaw_deg_from_position_Sigma'}
                    sensor_structure.Yaw_deg_from_position_Sigma = onesSensor;
                case {'Yaw_deg_from_velocity'}
                    sensor_structure.Yaw_deg_from_velocity = onesSensor;
                case {'Yaw_deg_from_velocity_Sigma'}
                    sensor_structure.Yaw_deg_from_velocity_Sigma = onesSensor;
                case {'numSatellites'}
                    sensor_structure.numSatellites = onesSensor;
                case {'DGPS_mode'}
                    sensor_structure.DGPS_mode = onesSensor;
                case {'Roll_deg'}
                    sensor_structure.Roll_deg = onesSensor;
                case {'Roll_deg_Sigma'}
                    sensor_structure.Roll_deg_Sigma = onesSensor;
                case {'Pitch_deg'}
                    sensor_structure.Pitch_deg = onesSensor;
                case {'Pitch_deg_Sigma'}
                    sensor_structure.Pitch_deg_Sigma = onesSensor;
                case {'Yaw_deg'}
                    sensor_structure.Yaw_deg = onesSensor;
                case {'Yaw_deg_Sigma'}
                    sensor_structure.Yaw_deg_Sigma = onesSensor;
                case {'HDOP'}
                    sensor_structure.HDOP = onesSensor;
                case {'AgeOfDiff'}
                    sensor_structure.AgeOfDiff = onesSensor;
                case {'GPS_EventFunctions'}
                    sensor_structure.GPS_EventFunctions = {};
                case {'StdDevResid'}
                    sensor_structure.StdDevResid = onesSensor;
                case{'MessageID'}
                    sensor_structure.MessageID = onesSensor;
                case{'StdLat'}
                    sensor_structure.StdLat = onesSensor;
                case{'StdLon'}
                    sensor_structure.StdLon = onesSensor;
                case{'StdAlt'}
                    sensor_structure.StdAlt = onesSensor;
                case{'GeoSep'}
                    sensor_structure.GeoSep = onesSensor;
                case{'SpdOverGrndKmph'}
                    sensor_structure.SpdOverGrndKmph = onesSensor;
                case{'TrueTrack'}
                    sensor_structure.SpdOverGrndKmph = onesSensor;
                                                          
                    
                    % ENCODER fields
                case {'CountsPerRev'}
                    sensor_structure.CountsPerRev = onesSensor;
                case {'Counts'}
                    sensor_structure.Counts = onesSensor;
                case {'DeltaCounts'}
                    sensor_structure.DeltaCounts = onesSensor;
                case {'LastIndexCount'}
                    sensor_structure.LastIndexCount = onesSensor;
                case {'AngularVelocity'}
                    sensor_structure.AngularVelocity = onesSensor;
                case {'AngularVelocity_Sigma'}
                    sensor_structure.AngularVelocity_Sigma = onesSensor;
                case {'ENCODER_EventFunctions'}
                    sensor_structure.ENCODER_EventFunctions = {};
                    
                    % IMU fields
                case {'IMUStatus'}
                    sensor_structure.IMUStatus = onesSensor;
                case {'XAccel'}
                    sensor_structure.XAccel = onesSensor;
                case {'XAccel_Sigma'}
                    sensor_structure.XAccel_Sigma = onesSensor;
                case {'YAccel'}
                    sensor_structure.YAccel = onesSensor;
                case {'YAccel_Sigma'}
                    sensor_structure.YAccel_Sigma = onesSensor;
                case {'ZAccel'}
                    sensor_structure.ZAccel = onesSensor;
                case {'ZAccel_Sigma'}
                    sensor_structure.ZAccel_Sigma = onesSensor;
                case {'Accel_Sigma'}
                    sensor_structure.Accel_Sigma = onesSensor;


                case {'XGyro'}
                    sensor_structure.XGyro = onesSensor;
                case {'XGyro_Sigma'}
                    sensor_structure.XGyro_Sigma = onesSensor;
                case {'YGyro'}
                    sensor_structure.YGyro = onesSensor;
                case {'YGyro_Sigma'}
                    sensor_structure.YGyro_Sigma = onesSensor;
                case {'ZGyro'}
                    sensor_structure.ZGyro = onesSensor;
                case {'ZGyro_Sigma'}
                    sensor_structure.ZGyro_Sigma = onesSensor;
                case {'Gyro_Sigma'}
                    sensor_structure.Gyro_Sigma = onesSensor;
                    

                case {'XOrientation'}
                    sensor_structure.XOrientation = onesSensor;
                case {'YOrientation'}
                    sensor_structure.YOrientation = onesSensor;
                case {'ZOrientation'}
                    sensor_structure.ZOrientation = onesSensor;
                case {'XOrientation_Sigma'}
                    sensor_structure.XOrientation_Sigma = onesSensor;
                case {'YOrientation_Sigma'}
                    sensor_structure.YOrientation_Sigma = onesSensor;
                case {'ZOrientation_Sigma'}
                    sensor_structure.ZOrientation_Sigma = onesSensor;
                case {'WOrientation'}
                    sensor_structure.WOrientation = onesSensor;
                case {'WOrientation_Sigma'}
                    sensor_structure.WOrientation_Sigma = onesSensor;
                case {'Orientation_Sigma'}
                    sensor_structure.Orientation_Sigma = onesSensor;

                case {'XMagnetic'}
                    sensor_structure.XMagnetic = onesSensor;
                case {'XMagnetic_Sigma'}
                    sensor_structure.XMagnetic_Sigma = onesSensor;
                case {'YMagnetic'}
                    sensor_structure.YMagnetic = onesSensor;
                case {'YMagnetic_Sigma'}
                    sensor_structure.YMagnetic_Sigma = onesSensor;
                case {'ZMagnetic'}
                    sensor_structure.ZMagnetic = onesSensor;
                case {'ZMagnetic_Sigma'}
                    sensor_structure.ZMagnetic_Sigma = onesSensor;
                case {'Magnetic_Sigma'}
                    sensor_structure.Magnetic_Sigma = onesSensor;

                case {'Pressure'}
                    sensor_structure.Pressure = onesSensor;
                case {'Pressure_Sigma'}
                    sensor_structure.Pressure_Sigma = onesSensor;
                case {'Temperature'}
                    sensor_structure.Temperature = onesSensor;
                case {'Temperature_Sigma'}
                    sensor_structure.Temperature_Sigma = onesSensor;
                    
                case {'IMU_EventFunctions'}
                    sensor_structure.IMU_EventFunctions = {};
                    
                    % LIDAR2D fields
                case {'Sick_Time'}
                    sensor_structure.Sick_Time = onesSensor;                    
                case {'angle_min'}
                    sensor_structure.angle_min = onesSensor;
                case {'angle_max'}
                    sensor_structure.angle_max = onesSensor;
                case {'angle_increment'}
                    sensor_structure.angle_increment = onesSensor;
                case {'time_increment'}
                    sensor_structure.time_increment = onesSensor;
                case {'scan_time'}
                    sensor_structure.scan_time = onesSensor;
                case {'range_min'}
                    sensor_structure.range_min = onesSensor;
                case {'range_max'}
                    sensor_structure.range_max = onesSensor;
                case {'ranges'}
                    sensor_structure.ranges = onesSensor;
                case {'intensities'}
                    sensor_structure.intensities = onesSensor;
                    
                case {'LIDAR2D_EventFunctions'}
                    sensor_structure.LIDAR2D_EventFunctions = {};
                    
                otherwise
                    try
                        callStack = dbstack('-completenames');
                        errorStruct.message = sprintf('Error in file: %s \n\t Line: %d \n\t Unknown field found! \n\t Sensor: %s \n\t Subfield: %s\n',callStack(1).file, callStack(1).line, sensor_name, subFieldName);
                        errorStruct.identifier = 'DataClean:fillTestDataStructure:BadSensorField';
                        errorStruct.stack = callStack(1);
                        error(errorStruct);
                    catch ME
                        throw(ME);
                    end

            end % Ends switch statement
        end % Ends check whether to fill time or other subfields
        
    end
    
    % Save results back to data structure
    dataStructure.(sensor_name) = sensor_structure;
    
end % Ends looping through structure

%% Create bad data?

if time_corruption_type>1
    BadDataStructure = dataStructure;
    
    % Use decimal to binary to convert the input flags into binary, and pad
    % the bits that were not specified with zeros
    binary_time_corruption = de2bi(time_corruption_type);       
    num_bits = 23;
    if length(binary_time_corruption)<num_bits
        binary_time_corruption(end+1:num_bits) = 0;
    end

    % Missing GPS_Time field test - the GPS_Time field is completely missing
    if binary_time_corruption(2)
        time_corruption_type_string = cat(2,time_corruption_type_string,'GPS_Time field missing, ');
        BadGPSSensor = rmfield(BadDataStructure.GPS_Hemisphere, 'GPS_Time');
        BadDataStructure.GPS_Hemisphere = BadGPSSensor;
    end
    
    % Missing GPS_Time field test - the GPS_Time field is empty
    if binary_time_corruption(3)
        time_corruption_type_string = cat(2,time_corruption_type_string,'GPS_Time field is empty, ');
        BadDataStructure.GPS_Sparkfun_RearLeft.GPS_Time = [];
    end
    
    % Missing GPS_Time field test - the GPS_Time field is only NaNs
    if binary_time_corruption(4)
        time_corruption_type_string = cat(2,time_corruption_type_string,'GPS_Time field has only NaNs, ');
        BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time*NaN;
    end    

    % Missing centiSeconds field test - the centiSeconds field is completely missing
    if binary_time_corruption(5)
        time_corruption_type_string = cat(2,time_corruption_type_string,'centiSeconds field is completely missing, ');
        BadGPSSensor = rmfield(BadDataStructure.IMU_ADIS, 'centiSeconds');
        BadDataStructure.GPS_Hemisphere = BadGPSSensor;
    end

    % Missing centiSeconds field test - the centiSeconds field is empty
    if binary_time_corruption(6)
        time_corruption_type_string = cat(2,time_corruption_type_string,'centiSeconds field is empty, ');
        BadDataStructure.GPS_Hemisphere.centiSeconds = [];
    end

    % Missing centiSeconds field test - the centiSeconds field is only NaNs
    if binary_time_corruption(7)
        time_corruption_type_string = cat(2,time_corruption_type_string,'centiSeconds field is NaN, ');
        BadDataStructure.GPS_Sparkfun_RearRight.centiSeconds = BadDataStructure.GPS_Hemisphere.centiSeconds*NaN;
    end

    % Bad time interval test - the centiSeconds field is inconsistent with GPS_Time data
    if binary_time_corruption(8)
        time_corruption_type_string = cat(2,time_corruption_type_string,'centiSeconds field is inconsistent with GPS_Time data, ');
        % Copy time structure from encoder (100 Hz) to Trigger (1 Hz) to create bad
        % time sample interval.
        BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.ENCODER_RearLeft.GPS_Time;
    end
    
    % Bad time interval test - the centiSeconds field is inconsistent with ROS_Time data
    if binary_time_corruption(9)
        time_corruption_type_string = cat(2,time_corruption_type_string,'centiSeconds field is inconsistent with ROS_Time data, ');
        % Copy time structure from encoder (100 Hz) to Trigger (1 Hz) to create bad
        % time sample interval.
        BadDataStructure.TRIGGER.ROS_Time = BadDataStructure.ENCODER_RearLeft.ROS_Time;
    end

    % Missing Trigger_Time field test - the Trigger_Time field is completely missing
    if binary_time_corruption(10)
        time_corruption_type_string = cat(2,time_corruption_type_string,'Trigger_Time field missing, ');
        BadGPSSensor = rmfield(BadDataStructure.GPS_Hemisphere, 'Trigger_Time');
        BadDataStructure.GPS_Hemisphere = BadGPSSensor;
    end

    % Missing Trigger_Time field test - the Trigger_Time field is empty
    if binary_time_corruption(11)
        time_corruption_type_string = cat(2,time_corruption_type_string,'Trigger_Time field is empty, ');
        BadDataStructure.GPS_Hemisphere.Trigger_Time = [];
    end

    % Missing Trigger_Time field test - the Trigger_Time field is only NaNs
    if binary_time_corruption(12)
        time_corruption_type_string = cat(2,time_corruption_type_string,'Trigger_Time field has NaN, ');
        BadDataStructure.GPS_Hemisphere.Trigger_Time = BadDataStructure.GPS_Hemisphere.Trigger_Time*NaN;
    end
    
    % Bad time ordering test - the GPS_Time is not increasing
    if binary_time_corruption(13)
        time_corruption_type_string = cat(2,time_corruption_type_string,'GPS_Time not increasing in GPS_Hemisphere, ');

        % Make the first element slightly larger than the 2nd element
        temp = BadDataStructure.GPS_Hemisphere.GPS_Time(2,:);
        BadDataStructure.GPS_Hemisphere.GPS_Time(2,:) = dataStructure.GPS_Hemisphere.GPS_Time(3,:)+0.001; % nudge to avoid repeats
        BadDataStructure.GPS_Hemisphere.GPS_Time(3,:) = temp;
    end

    % Bad ROS units - using nanoseconds instead of seconds
    if binary_time_corruption(14)
        time_corruption_type_string = cat(2,time_corruption_type_string,'ROS_Time has incorrect units of nanoseconds, ');
        
        % Define a dataset with corrupted ROS_Time where the ROS_Time has a
        % nanosecond scaling
        BadDataStructure.GPS_Hemisphere.ROS_Time = dataStructure.GPS_Hemisphere.ROS_Time*1E9;
    end

    % Missing ROS_Time field test - the ROS_Time field is completely missing
    if binary_time_corruption(15)
        time_corruption_type_string = cat(2,time_corruption_type_string,'ROS_Time field missing, ');        
        BadGPSSensor = rmfield(BadDataStructure.GPS_Sparkfun_RearLeft, 'ROS_Time');
        BadDataStructure.GPS_Sparkfun_RearLeft = BadGPSSensor;
    end

    % Missing ROS_Time field test - the ROS_Time field is empty
    if binary_time_corruption(16)
        time_corruption_type_string = cat(2,time_corruption_type_string,'ROS_Time field empty, ');
        BadDataStructure.GPS_Hemisphere.ROS_Time = [];
    end

    % Missing ROS_Time field test - the ROS_Time field is only NaNs
    if binary_time_corruption(17)
        time_corruption_type_string = cat(2,time_corruption_type_string,'ROS_Time field has NaNs, ');
        BadDataStructure.GPS_Hemisphere.ROS_Time = BadDataStructure.GPS_Hemisphere.ROS_Time*NaN;
    end

    % Bad time ordering test - the ROS_Time is not increasing
    if binary_time_corruption(18)
        time_corruption_type_string = cat(2,time_corruption_type_string,'ROS_Time is not increasing, ');
 
        % Swap order of first two time elements
        BadDataStructure.GPS_Hemisphere.ROS_Time(1,:) = dataStructure.GPS_Hemisphere.ROS_Time(2,:);
        BadDataStructure.GPS_Hemisphere.ROS_Time(2,:) = dataStructure.GPS_Hemisphere.ROS_Time(1,:);
    end

    % Bad time ordering test - the ROS_Time has a repeat
    if binary_time_corruption(19)
        time_corruption_type_string = cat(2,time_corruption_type_string,'ROS_Time has a repeat, ');
 
        % Swap order of first two time elements
        BadDataStructure.GPS_Hemisphere.ROS_Time(2,:) = dataStructure.GPS_Hemisphere.ROS_Time(1,:);
    end

    % Bad time length test - the ROS_Time has wrong length
    if binary_time_corruption(20)
        time_corruption_type_string = cat(2,time_corruption_type_string,'ROS_Time has wrong length, ');
 
        % Add one more tiny data point to end
        BadDataStructure.GPS_Hemisphere.ROS_Time(end+1,:) = dataStructure.GPS_Hemisphere.ROS_Time(end,:)+0.001;
    end
    
    %% 2^20 bit = 1: The GPS_Time field in a GPS sensor has repeated but ordered entries.
    if binary_time_corruption(21)
        time_corruption_type_string = cat(2,time_corruption_type_string,'GPS_Time has repeated entries, ');
        
        dataStructureToCorrupt = dataStructure.GPS_Hemisphere;
        
        lengthReference = length(dataStructureToCorrupt.GPS_Time);
        badIndicies = [ones(7,1);(1:lengthReference)']; % Throw in some repeats
        goodIndicies = (1:length(badIndicies))';
        dataStructureToCorrupt.Npoints = length(goodIndicies);
        
        % Grab all the subfields
        subfieldNames = fieldnames(dataStructureToCorrupt);
        
        % Loop through subfields
        for i_subField = 1:length(subfieldNames)
            % Grab the name of the ith subfield
            subFieldName = subfieldNames{i_subField};
            
            if ~iscell(dataStructureToCorrupt.(subFieldName)) % Is it a cell? If yes, skip it
                if length(dataStructureToCorrupt.(subFieldName)) ~= 1 % Is it a scalar? If yes, skip it
                    % It's an array, make sure it has right length
                    if lengthReference== length(dataStructureToCorrupt.(subFieldName))
                        dataStructureToCorrupt.(subFieldName)(goodIndicies,:) = dataStructureToCorrupt.(subFieldName)(badIndicies,:);
                    end
                end
            end
            
        end % Ends for loop through the subfields
        
        % Put data into the BadDataStructure
        BadDataStructure.GPS_Hemisphere = dataStructureToCorrupt;
    end
    
    %% 2^21 bit = 1: The ROS_Time field in a GPS sensor does not align with the others
    if binary_time_corruption(22)
        time_corruption_type_string = cat(2,time_corruption_type_string,'ROS_Time has bad entries and will not round to Trigger_Time, on GPS_Hemisphere, ');
        
        dataStructureToCorrupt = dataStructure.GPS_Hemisphere;
        
        % Nudge one point so that it rounds to the same point
        dataStructureToCorrupt.ROS_Time(2,1) = dataStructureToCorrupt.ROS_Time(3,1)+0.000001;
        dataStructureToCorrupt.ROS_Time(3,1) = dataStructureToCorrupt.ROS_Time(3,1)+0.000002;
        
        % FOR DEBUGGING:
        % disp((dataStructureToCorrupt.ROS_Time(1:10)-dataStructureToCorrupt.ROS_Time(1,1)));
        
        % Put data into the BadDataStructure
        BadDataStructure.GPS_Hemisphere = dataStructureToCorrupt;
    end
    
    %% 2^22 bit = 1: The GPS_Time field in a GPS sensor has a discontinuity.
    if binary_time_corruption(23)
        time_corruption_type_string = cat(2,time_corruption_type_string,'GPS_Time has a discontinuity in GPS_Hemisphere, ');
        
        dataStructureToCorrupt = dataStructure.GPS_Hemisphere;
        
        % Add a jump discontinuity
        jump = 0.4;
        dataStructureToCorrupt.GPS_Time(5:end,1) = dataStructureToCorrupt.GPS_Time(5:end,1) + jump;

        % Add random time noise - about 5 milliseconds standard deviation
        timing_error = 0.005*randn(length(dataStructureToCorrupt.GPS_Time(:,1)),1);
        dataStructureToCorrupt.GPS_Time = dataStructureToCorrupt.GPS_Time + timing_error;
        
        % Cut off the end data
        cut_point = find(dataStructureToCorrupt.GPS_Time>=dataStructure.GPS_Sparkfun_RearLeft.GPS_Time(end),1,'first');
        dataStructureToCorrupt.GPS_Time = dataStructureToCorrupt.GPS_Time(1:cut_point,:);
        
        % FOR DEBUGGING:
        % disp(dataStructureToCorrupt.GPS_Time(1:10,1)-dataStructureToCorrupt.GPS_Time(1,1));
        % disp(dataStructureToCorrupt.GPS_Time(end-3:end,1)-dataStructureToCorrupt.GPS_Time(1,1));
        % disp(dataStructure.GPS_Sparkfun_RearLeft.GPS_Time(end-3:end,1)-dataStructure.GPS_Sparkfun_RearLeft.GPS_Time(1,1));
        
        % Put data into the BadDataStructure
        BadDataStructure.GPS_Hemisphere = dataStructureToCorrupt;
    end

    dataStructure = BadDataStructure;
end % Ends if statement on time_corruption


%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots
    
    % Nothing to plot        
    
end

if fid
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function




%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§
