function fixed_dataStructure = fcn_DataClean_fillMissingsInGPSUnits(dataStructure,ref_basestation,varargin)

% fcn_DataClean_fillMissingsInGPSUnits
% Interpolate the GPS_Time field for all GPS sensors. This is done by
% using the centiSeconds field and the effective start and end GPS_Times,
% determined by taking the maximum start time and minimum end time over all
% sensors.
%
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_fillMissingsInGPSUnits(dataStructure,ref_basestation,(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      ref_basestation: base station that used for the dataset
%
%      (OPTIONAL INPUTS)
%
%
%      fid: a file ID to print results of analysis. If not entered, the
%      console (FID = 1) is used.
%
% OUTPUTS:
%
%      fixed_dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%      See script_test_fcn_DataClean_fillMissingsInGPSUnits
%
% This function was written on 2024_08_15 by X. Cao
% Questions or comments? xfc5113@psu.edu

% Revision history:
% 2024_10_08 - S. Brennan
% -- added test cases
% -- updated top comments
% -- added debug flag area
% -- fixed fid printing error
% -- added fig_num input, fixed the plot flag
% -- fixed warning and errors

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==3 && isequal(varargin{end},-1))
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS");
    MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG = getenv("MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_fig_num = 999978; %#ok<NASGU>
else
    debug_fig_num = []; %#ok<NASGU>
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

if (0 == flag_max_speed)
    if flag_check_inputs
        % Are there the right number of inputs?
        if nargin < 1 || nargin > 3
            error('Incorrect number of input arguments')
        end
    end
end

% Does the user want to specify the fid?
% Check for user input
fid = 0; %#ok<NASGU> % Default case is to NOT print to the console
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        fid = temp; %#ok<NASGU>
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

% The method this is done is to:
% 1. Find the effective start and end GPS_Times, determined by taking the maximum start time and minimum end time over all
% sensors.
% 2.  Fill and interpolate the missing data in GPS units


%% Step 1: Find the effective start and end GPS and ROS times over all sensors


[cell_array_GPS_Time, sensor_names_GPS_Time] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS');
[cell_array_ROS_Time,sensor_names_ROS_Time]  = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS');

if ~isequal(sensor_names_GPS_Time,sensor_names_ROS_Time)
    error('Sensors were found that were missing either GPS_Time or ROS_Time. Unable to interpolate.');
end

[cell_array_centiSeconds, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds','GPS');
N_GPS_Units = length(cell_array_GPS_Time);

%% Define fields need to be interpolated

fields_need_to_be_interpolated=[
    "ROS_Time",...
    "GPS_Time2",...
    "ROS_Time2",...
    "ROS_Time3"];

GST_Fields = ["GPS_Time2","ROS_Time2","StdLat","StdLon","StdAlt"];


%% Interate over GPS units and interpolate data
fixed_dataStructure = dataStructure;
for idx_gps_unit = 1:N_GPS_Units
    GPSUnitName = sensor_names_GPS_Time{idx_gps_unit};
    GPSdataStructure = fixed_dataStructure.(GPSUnitName);
    centiSeconds = cell_array_centiSeconds{idx_gps_unit};
    sub_fields = fieldnames(GPSdataStructure);
    N_fields = length(sub_fields);

    original_GPS_Time = cell_array_GPS_Time{idx_gps_unit};
    %original_ROS_Time_GGA = cell_array_ROS_Time{idx_gps_unit};

    % Find number of GPS_Time in the subfields to force all to have the same
    % GPS_Time. To do this, we need to know the start and end time. The
    % start time is the maximum GPS_Time among all the first GPS_Times. The
    % end time is the minimum GPS_Time among all the last GPS_Times.

    % URHERE - this code below does not work if more than 2 GPS times
    N_GPSTimeFields = length(find(contains(sub_fields,"GPS_Time")));
    if N_GPSTimeFields ~= 1 % all GPS_Time fields should have the same GPS_Time
        original_GPS_Time_GST = GPSdataStructure.GPS_Time2;
        start_GPSTime = max([original_GPS_Time(1),original_GPS_Time_GST(1)]);
        end_GPSTime = min([original_GPS_Time(end),original_GPS_Time_GST(end)]);
    else
        start_GPSTime = original_GPS_Time(1);
        end_GPSTime = original_GPS_Time(end);
    end

    %URHERE
    Loop through all the fields. If they contain any time fields, interpolate them



    % offset_between_GPSTime_and_ROSTime = original_ROS_Time_GGA - original_GPS_Time_GGA;
    % Make sure we choose a time that all the sensors CAN start at. We round
    % start seconds up, and end seconds down.
    start_GPSTime_centiSeconds = round(100*start_GPSTime/centiSeconds)*centiSeconds;
    end_GPSTime_centiSeconds = round(100*end_GPSTime/centiSeconds)*centiSeconds;
    fixed_GPSTime_centiSeconds = (start_GPSTime_centiSeconds:centiSeconds:end_GPSTime_centiSeconds).';
    fixed_GPSTime = fixed_GPSTime_centiSeconds/100;
    % Calculate and interpolate X, Y and Z of current GPS unit
    GPS_LLA = [GPSdataStructure.Latitude, GPSdataStructure.Longitude, GPSdataStructure.Altitude];
    GPS_ENU = lla2enu(GPS_LLA,ref_basestation,'ellipsoid');
    GPS_ENU_interp = interp1(original_GPS_Time,GPS_ENU,fixed_GPSTime,'linear','extrap');
    GPS_LLA_interp = enu2lla(GPS_ENU_interp,ref_basestation,'ellipsoid');

    
    %% Find number of GPS_Time in the subfields,
    % Interpolate each field except LLA fields and scalar field
    for idx_field = 1:N_fields
        sub_field = sub_fields{idx_field};
        current_field = GPSdataStructure.(sub_field);
        if (length(current_field)>1)&(any(ismember(fields_need_to_be_interpolated,sub_field)))
            interp_method = fcn_DataClean_determineInterpolateMethod(sub_field);
            original_GPS_Time = original_GPS_Time;
            if (N_GPSTimeFields ~= 1)&(any(ismember(GST_Fields,sub_field)))
                original_GPS_Time = original_GPS_Time_GST;
            end
            current_field_interp = interp1(original_GPS_Time,current_field,fixed_GPSTime,interp_method,"extrap");
            % else
            % current_field_interp = current_field_unique;
            % end
            GPSdataStructure.(sub_field) = current_field_interp;
        end
    end
    % Fill the position fields
    GPSdataStructure.GPS_Time = fixed_GPSTime;
    GPSdataStructure.Latitude = GPS_LLA_interp(:,1);
    GPSdataStructure.Longitude = GPS_LLA_interp(:,2);
    GPSdataStructure.Altitude = GPS_LLA_interp(:,3);
    GPSdataStructure.xEast = GPS_ENU_interp(:,1);
    GPSdataStructure.yNorth = GPS_ENU_interp(:,2);
    GPSdataStructure.zUp = GPS_ENU_interp(:,3);
    GPSdataStructure.centiSeconds = centiSeconds;
    GPSdataStructure.Npoints = length(fixed_GPSTime);

    fixed_dataStructure.(GPSUnitName) = GPSdataStructure;
end % Ends for loop


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

