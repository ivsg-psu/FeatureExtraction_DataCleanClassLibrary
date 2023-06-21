function dataStructure = fcn_DataClean_fillTestDataStructure(varargin)
% fcn_DataClean_fillTestDataStructure
% Creates five seconds of test data for testing functions
%
% FORMAT:
%
%      dataStructure = fcn_DataClean_fillTestDataStructure((corruption_type)
%
% INPUTS:
%
%      (none)
%
%      (OPTIONAL INPUTS)
%
%      corruption_type: an integer listing the type of noise, errors, faults, etc. to
%      add to the data. The types are as follows:
%
%          0: (default) Perfect data with no noise added. All standard
%          deviations are zero.
%
%          1: Typical data for the mapping van. Standard deviations are
%          representative of the sensors used on the vehicle.
%
%
% OUTPUTS:
%
%      dataStructure: a template data structure containing the fields that
%      are typical for the mapping van.
%
%
% DEPENDENCIES:
%
%      (none)
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_fillTestDataStructure
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_06_19: sbrennan@psu.edu
% -- wrote the code originally 

% TO DO
% 

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

fid = 1; % Print to the console, for any print commands

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


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
    if nargin < 0 || nargin > 1
        error('Incorrect number of input arguments')
    end

end

% Does user want to corrupt the data?
% Set default flags:
flag_add_normal_noise = 0;

if 1 <= nargin
    temp = varargin{end};
    if ~isempty(temp)
        corruption_type = temp;
    end
    if corruption_type>=1
        flag_add_normal_noise = 1;
    end
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
ROS_time_offset = 23.821;

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
if flag_do_debug
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
LLA_full_data  =  gps_object.ENU2WGSLLA(ENU_full_data')';
Latitude_full_data = LLA_full_data(:,1);
Longitude_full_data = LLA_full_data(:,1);
Altitude_full_data = LLA_full_data(:,1);



names = fieldnames(dataStructure); % Grab all the fields that are in rawData structure
for i_data = 1:length(names)
    % Grab the data subfield name
    sensor_name = names{i_data};
    sensor_structure = dataStructure.(sensor_name);  % This is the input (current) data structure

    % Show what we are doing
    if flag_do_debug
        fprintf(fid,'Filling fields on sensor: %s \n',sensor_name);
    end
    
    sensorSubfieldNames = fieldnames(sensor_structure); % Grab all the subfields
    for i_subField = 1:length(sensorSubfieldNames)
        % Grab the name of the ith subfield
        subFieldName = sensorSubfieldNames{i_subField};
        
        if flag_do_debug
            fprintf(fid,'\tFilling field: %s \n',subFieldName);
        end
        % Need to calculate the times
        centiSeconds = sensor_structure.centiSeconds;
        timeSensor = (0:centiSeconds*0.01:numSeconds)';
        onesSensor = ones(length(timeSensor),1);

        % Check to see if this subField is in the time calculationlist
        if any(strcmp(subFieldName,fields_to_calculate_times_for))
            
            timeSimulated = timeSensor;
            
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
                    sensor_structure.velocity = interp1(time_full_data,velocity,timeSensor);
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

if flag_do_debug
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
