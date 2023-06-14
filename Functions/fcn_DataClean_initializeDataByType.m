function dataStructure = fcn_DataClean_initializeDataByType(dataType)
% fcn_DataClean_initializeDataByType
% Creates an empty data structure that corresponds to a particular type of
% sensor. 
%
% FORMAT:
%
%      dataStructure = fcn_DataClean_initializeDataByType(dataType)
%
% INPUTS:
%
%      dataType: a string denoting the type of dataStructure to be filled.
%      The fillowing data types are expected:
%      'Trigger' - This is the data type for the trigger box data
%      'GPS' - This is the data type for GPS data
%      'INS' - This is the data type for INS data
%      'Encoder' - This is the data type for Encoder data
%      'LIDAR2D' - This is the data type for 2D Lidar data
%      'LIDAR3D' - This is the data type for 3D Lidar data
%
%      (OPTIONAL INPUTS)
%
%      (none)
%
% OUTPUTS:
%
%      dataStructure: a template data structure containing the fields that
%      are expected to be filled for a particular sensor type.%
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_initializeDataByType
%     for a full test suite.
%
% This function was written on 2023_06_12 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_06_12: sbrennan@psu.edu
% -- wrote the code originally 

% TO DO
% 

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

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
    if nargin < 1 || nargin > 1
        error('Incorrect number of input arguments')
    end
        
    % NOTE: zone types are checked below

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

default_value = NaN;

switch lower(dataType)
    case 'trigger'
        % Xinyu - fill this in
        dataStructure.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
        dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        dataStructure.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
        dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        dataStructure.Npoints            = default_value;  % This is the number of data points in the array

    case 'gps'
        dataStructure.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
        dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        dataStructure.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
        dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        dataStructure.Npoints            = default_value;  % This is the number of data points in the array
        dataStructure.Latitude           = default_value;  % The latitude [deg]
        dataStructure.Longitude          = default_value;  % The longitude [deg]
        dataStructure.Altitude           = default_value;  % The altitude above sea level [m]
        dataStructure.xEast              = default_value;  % The xEast value (ENU) [m]
        dataStructure.xEast_Sigma        = default_value;  % Sigma in xEast [m]
        dataStructure.yNorth             = default_value;  % The yNorth value (ENU) [m]
        dataStructure.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
        dataStructure.zUp                = default_value;  % The zUp value (ENU) [m]
        dataStructure.zUp_Sigma          = default_value;  % Sigma in zUp [m]
        dataStructure.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
        dataStructure.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
        dataStructure.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
        dataStructure.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
        dataStructure.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
        dataStructure.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
        dataStructure.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s] 
        dataStructure.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
        dataStructure.numSatellites      = default_value;  % Number of satelites visible 
        dataStructure.DGPS_mode          = default_value;  % Mode indicating DGPS status (for example, navmode 6;
        dataStructure.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
        dataStructure.Roll_deg_Sigma     = default_value;  % Sigma in Roll
        dataStructure.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
        dataStructure.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
        dataStructure.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
        dataStructure.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
        dataStructure.OneSigmaPos        = default_value;  % Sigma in position 
        dataStructure.DOP                = default_value;  % DOP in position (ratio, usually close to 1)
        
    case 'ins'
        dataStructure.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
        dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        dataStructure.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
        dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        dataStructure.Npoints            = default_value;  % This is the number of data points in the array
        dataStructure.IMUStatus          = default_value;  
        dataStructure.XAccel             = default_value; 
        dataStructure.XAccel_Sigma       = default_value; 
        dataStructure.YAccel             = default_value; 
        dataStructure.YAccel_Sigma       = default_value; 
        dataStructure.ZAccel             = default_value; 
        dataStructure.ZAccel_Sigma       = default_value; 
        dataStructure.XGyro              = default_value; 
        dataStructure.XGyro_Sigma        = default_value; 
        dataStructure.YGyro              = default_value; 
        dataStructure.YGyro_Sigma        = default_value; 
        dataStructure.ZGyro              = default_value; 
        dataStructure.ZGyro_Sigma        = default_value; 

    case 'encoder'
        dataStructure.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
        dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        dataStructure.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
        dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        dataStructure.Npoints            = default_value;  % This is the number of data points in the array

        dataStructure.CountsPerRev       = default_value;  % How many counts are in each revolution of the encoder (with quadrature)
        dataStructure.Counts             = default_value;  % A vector of the counts measured by the encoder, Npoints long
        dataStructure.DeltaCounts        = default_value;  % A vector of the change in counts measured by the encoder, with first value of zero, Npoints long
        dataStructure.LastIndexCount     = default_value;  % Count at which last index pulse was detected, Npoints long
        dataStructure.AngularVelocity    = default_value;  % Angular velocity of the encoder
        dataStructure.AngularVelocity_Sigma    = default_value; 
   
    case 'lidar2d'
        % Xinyu - fill this in
        dataStructure.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
        dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        dataStructure.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
        dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        dataStructure.Npoints            = default_value;  % This is the number of data points in the array

    case 'lidar3d'
        % Xinyu - fill this in
        dataStructure.GPS_Time           = default_value;  % This is the GPS time, UTC, as reported by the unit
        dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        dataStructure.ROS_Time           = default_value;  % This is the ROS time that the data arrived into the bag
        dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        dataStructure.Npoints            = default_value;  % This is the number of data points in the array

    otherwise
        error('Unrecognized data type requested: %s',dataType)
end


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
