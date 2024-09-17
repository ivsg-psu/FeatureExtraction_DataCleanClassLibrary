function locked_dataStructure = fcn_DataClean_extractRTKLockedData(dataStructure)

% fcn_DataPreprocessing_RemoveUnlockedData removes unlocked GPS data from
% the single GPS_data_struct
%
% FORMAT:
%
% GPS_Locked = fcn_DataPreprocessing_RemoveUnlockedData(GPS_rawdata_struct)
%
% INPUTS:
%
%      GPS_rawdata_struct: a structure array containing raw GPS data
%
%
% OUTPUTS:
%
%      GPS_Locked_data_struct: a structure array containing locked GPS data
%
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%      fcn_geometry_plotCircle
%
% EXAMPLES:
%      
%      % BASIC example
%      points = [0 0; 1 4; 0.5 -1];
%      [centers,radii] = fcn_geometry_circleCenterFrom3Points(points,1)
% 
% See the script: script_test_fcn_Transform_CalculateAngleBetweenVectors
% for a full test suite.
%
% This function was written on 2023_10_20 by X.Cao
% Questions or comments? xfc5113@psu.edu

% Revision history:
% 2023_10_20 - wrote the code
% 2024_01_28 - added more comments, particularly to explain inputs more
% clearly

%% Debugging and Input checks
flag_do_debug = 0;
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
flag_check_inputs = 1; % Flag to perform input checking

if flag_check_inputs == 1
    if ~isstruct(dataStructure)
        error('The input of the function should be a structure array')
    end

end

%% Solve for the angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a new structure array has the same fields with GPS_rawdata_struct


%%
%% Find centiSeconds 
[cell_array_DGPS_mode,sensors_names_DGPS_mode]       = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'DGPS_mode','GPS');
[cell_array_Trigger_Time_GPS,sensor_names_Trigger_Time_GPS]       = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'Trigger_Time','GPS','all');

if ~isequal(sensors_names_DGPS_mode,sensor_names_Trigger_Time_GPS)
    error('Sensors were found that were missing either Trigger_Time or DGPS_mode');
end
%
start_Trigger_Times = [];
end_Trigger_Times = [];
for idx_GPS_unit = 1:length(sensors_names_DGPS_mode)
    LockStatus = cell_array_DGPS_mode{idx_GPS_unit};
    idxs_locked = (LockStatus>5);
    Trigger_Time_GPS = cell_array_Trigger_Time_GPS{idx_GPS_unit};

    Trigger_Time_GPS_locked = Trigger_Time_GPS(idxs_locked,:);
    start_Trigger_Times = [start_Trigger_Times;min(Trigger_Time_GPS_locked)];
    end_Trigger_Times = [end_Trigger_Times; max(Trigger_Time_GPS_locked)];

end

start_Trigger_Time_all_sensors = max(start_Trigger_Times);
end_Trigger_Time_all_sensors = min(end_Trigger_Times);
time_range = [start_Trigger_Time_all_sensors, end_Trigger_Time_all_sensors];
sensorfields = fieldnames(dataStructure);
locked_dataStructure = dataStructure;
time_type = "Trigger_Time";
for idx_field = 1:length(sensorfields)
    sensor_field = sensorfields{idx_field};
    current_field_struct = dataStructure.(sensor_field);
    trimmed_field_struct = current_field_struct;
    if isfield(current_field_struct,time_type)
        current_field_struct_Time = current_field_struct.(time_type);
    else
        current_field_struct_Time = [];
    end
 
    start_idx = find(current_field_struct_Time>min(time_range),1,'first');
    end_idx = find((current_field_struct_Time<max(time_range)),1,'last');
    valid_idxs = (start_idx:end_idx).';
    topicfields = fieldnames(current_field_struct);
    N_topics = length(topicfields);


    % figure(13)
    % clf
    % plot(current_field_struct_Time)
    % hold on
    % plot(start_Trigger_Time_all_sensors:end_Trigger_Time_all_sensors)
    for idx_topic = 1:N_topics
        current_topic_content = current_field_struct.(topicfields{idx_topic});
        if length(current_topic_content) > 1
           trimmed_field_struct.(topicfields{idx_topic}) = current_topic_content(valid_idxs,:);
        end
        trimmed_field_struct.Npoints = length(trimmed_field_struct.ROS_Time);

    end
    locked_dataStructure.(sensorfields{idx_field}) = trimmed_field_struct;

end
end