function fixed_dataStructure = fcn_DataClean_fillMissingsInGPSUnits(dataStructure,ref_basestation,varargin)

% fcn_DataClean_interpolateGPSTime
% Interpolate the GPS_Time field for all GPS sensors. This is done by
% using the centiSeconds field and the effective start and end GPS_Times,
% determined by taking the maximum start time and minimum end time over all
% sensors.
%
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_recalculateTriggerTimes(dataStructure,(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      (OPTIONAL INPUTS)
%
%      sensor_type: a string to indicate the type of sensor to query, for
%      example 'gps' will query all sensors whose name contains 'gps'
%      somewhere in the name
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
%     See the script: script_test_fcn_DataClean_recalculateTriggerTimes
%     for a full test suite.
%
% This function was written on 2023_06_29 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_06_29: sbrennan@psu.edu
% -- wrote the code originally 
% 2023_06_30: sbrennan@psu.edu
% -- added the sensor_type field

% TO DO

% Set default fid (file ID) first:
flag_do_debug = 1;  %#ok<NASGU> % Flag to show the results for debugging
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
    if nargin < 1 || nargin > 3
        error('Incorrect number of input arguments')
    end
        
end

% Does the user want to specify the sensor_type?
sensor_type = '';
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        sensor_type = temp;
    end
end
        

% Does the user want to specify the fid?
% Check for user input
fid = 0; % Default case is to NOT print to the console

if 3 == nargin
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
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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
% 2.  Recalculates the Trigger_Time field for all sensors. This is done by
% using the centiSeconds field.


%% Step 1: Find the effective start and end GPS and ROS times over all sensors


linear_fields = ["ROS_Time","ROS_Time1","ROS_Time2","SpdOverGrndKmph"];
nearest_fields = ["GeoSep","numSatellites","DGPS_mode","HDOP","AgeOfDiff"];

[GPSTimeArray, sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS');
[centiSecondsArray, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds','GPS');
N_GPS_Units = length(GPSTimeArray);
timeOffset_array = [];
start_GPSTimes = [];
end_GPSTimes = [];
start_ROSTimes = [];
end_ROSTimes = [];

fixed_dataStructure = dataStructure;

for idx_gps_unit = 1:N_GPS_Units
    GPSUnitName = sensorNames{idx_gps_unit};
    GPSdataStructure = fixed_dataStructure.(GPSUnitName);
    sub_fields = fieldnames(GPSdataStructure);
    N_fields = length(sub_fields);
    GPSTime = GPSTimeArray{idx_gps_unit};
    start_GPSTime = GPSTime(1);
    end_GPSTime = GPSTime(end);
    centiSeconds = centiSecondsArray{idx_gps_unit};
    start_GPSTime_centiSeconds = 100*start_GPSTime/centiSeconds*centiSeconds;
    end_GPSTime_centiSeconds = 100*end_GPSTime/centiSeconds*centiSeconds;
    newGPSTime_centiSeconds = (start_GPSTime_centiSeconds:centiSeconds:end_GPSTime_centiSeconds).';
    newGPSTime = newGPSTime_centiSeconds/100;
    GPS_LLA = [GPSdataStructure.Latitude, GPSdataStructure.Longitude, GPSdataStructure.Altitude];
    GPS_ENU = lla2enu(GPS_LLA,ref_basestation,'ellipsoid');
    GPS_ENU_interp = interp1(GPSTime,GPS_ENU,newGPSTime,'linear','extrap');
    GPS_LLA_interp = enu2lla(GPS_ENU_interp,ref_basestation,'ellipsoid');
    
    % Interpolate each field except LLA fields and scalar field
    for idx_field = 1:N_fields
        sub_field = sub_fields{idx_field};
        current_field = GPSdataStructure.(sub_field);
        if ~isscalar(current_field)
            
            if any(strcmp(linear_fields,sub_field))
                current_field_interp = interp1(GPSTime,current_field,newGPSTime,"linear","extrap");
                GPSdataStructure.(sub_field) = current_field_interp;
            elseif any(strcmp(nearest_fields,sub_field))
                current_field_interp = interp1(GPSTime,current_field,newGPSTime,"nearest","extrap");
                GPSdataStructure.(sub_field) = current_field_interp;
            end  
        end
        
    end
    % Fill the position fields
    GPSdataStructure.GPS_Time = newGPSTime;
    GPSdataStructure.Latitude = GPS_LLA_interp(:,1);
    GPSdataStructure.Longitude = GPS_LLA_interp(:,2);
    GPSdataStructure.Altitude = GPS_LLA_interp(:,3);
    GPSdataStructure.xEast = GPS_ENU_interp(:,1);
    GPSdataStructure.yNorth = GPS_ENU_interp(:,2);
    GPSdataStructure.zUp = GPS_ENU_interp(:,3);
    GPSdataStructure.centiSeconds = centiSeconds;
    GPSdataStructure.Npoints = length(newGPSTime);
    
    fixed_dataStructure.(GPSUnitName) = GPSdataStructure;

end

