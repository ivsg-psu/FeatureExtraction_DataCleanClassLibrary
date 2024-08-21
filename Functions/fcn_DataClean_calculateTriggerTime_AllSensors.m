function fixed_dataStructure = fcn_DataClean_calculateTriggerTime_AllSensors(dataStructure,sensors_without_Trigger_Time)

% fcn_DataClean_recalculateTriggerTimes
% Recalculates the Trigger_Time field for all sensors. This is done by
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
    if nargin < 1 || nargin > 2
        error('Incorrect number of input arguments')
    end
        
end

% Does the user want to specify the sensor_type?

        

% Does the user want to specify the fid?
% Check for user input
fid = 0; % Default case is to NOT print to the console


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


%%
trigBox_has_diag_field = 0;
EncoderBox_has_diag_field = 0;
%% Step 1: Find corresponding ROS_Time and Trigger_Time from GPS units
%% Find centiSeconds 
[cell_array_centiSeconds,~]       = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds','GPS');
array_centiSeconds = cell2mat(cell_array_centiSeconds);
max_sample_centiSeconds = max(array_centiSeconds);
%% Find Trigger Time
[cell_array_Trigger_Time_start,sensor_names_Trigger_Time]       = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'Trigger_Time','GPS','first_row');
[cell_array_Trigger_Time_end,~]       = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'Trigger_Time','GPS','last_row');
%% Find ROS Time
[cell_array_ROS_Time_start,sensor_names_ROS_Time]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS','first_row');
[cell_array_ROS_Time_end,~]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS','last_row');
% Confirm that both results are identical
if ~isequal(sensor_names_ROS_Time,sensor_names_Trigger_Time)
    error('Sensors were found that were missing either GPS_Time or ROS_Time. Unable to calculate Trigger_Times.');
end
%%
% Convert Trigger_Time_start to a column matrix
array_Trigger_Time_start = max(cell2mat(cell_array_Trigger_Time_start));
array_Trigger_Time_end = min(cell2mat(cell_array_Trigger_Time_end));

array_ROS_Time_start = max(cell2mat(cell_array_ROS_Time_start));
array_ROS_Time_end = min(cell2mat(cell_array_ROS_Time_end));

%% Create common ROS_Time and GPS_Time for GPS units
Trigger_Time_GPS_common = (array_Trigger_Time_start:max_sample_centiSeconds/100:array_Trigger_Time_end).';
ROS_Time_GPS_common = (array_ROS_Time_start:max_sample_centiSeconds/100:array_ROS_Time_end).';

%% Step 2: Calculate Trigger_Time for other sensors
N_sensors = size(sensors_without_Trigger_Time,1);
fixed_dataStructure = dataStructure;
for idx_sensor = 1:N_sensors
    sensorName = sensors_without_Trigger_Time(idx_sensor,:);
    sensorFields = dataStructure.(sensorName);
    N_points = sensorFields.Npoints;
    if contains(lower(sensorName),'diagnostic')
        if contains(lower(sensorName),'trigbox')
            trigBox_has_diag_field = 1;
            trigBox_diag_field_name = sensorName;
        elseif contains(lower(sensorName),'usdigital')
            EncoderBox_has_diag_field = 1;
            encoderBox_diag_field_name = sensorName;
        end
        text_displaying = sprintf('Trigger_time of %s will be calculated later',sensorName);
        disp(text_displaying)

    elseif contains(lower(sensorName),'trigger')
        % Calculate Trigger_Time for trigger box
        modeID = sensorFields.mode;
        Trigger_Time = nan(N_points,1);
        Triggered_indices = find(strcmp(modeID,'L'));
        if isempty(Triggered_indices)
            Triggered_indices = find(strcmp(modeID,'S'));
        end
        %     % Use -1 to fill trigger time
        %     sensorFields.Trigger_Time = -1*ones(size(modeID));
        %     % if trigBox_has_diag_field == 1
        %     %     diag_sensorFields = dataStructure.(trigBox_diag_field_name);
        %     %     diag_sensorFields.Trigger_Time = -1*ones(size(modeID));
        %     %     fixed_dataStructure.(trigBox_diag_field_name) = diag_sensorFields;
        %     % end
        % 
        % 
        % else
            
            Triggered_modeCount = sensorFields.modeCount;
            ROS_Time = sensorFields.ROS_Time;
            ROS_Time_triggered  = ROS_Time(Triggered_indices);

            ROS_Time_triggered_start = ROS_Time_triggered(1);
            time_diff = abs(ROS_Time_GPS_common-ROS_Time_triggered_start);
            [~, idx_closest] = min(time_diff);
            Trigger_Time_start = Trigger_Time_GPS_common(idx_closest);
            Trigger_Time_calculated = Trigger_Time_start + Triggered_modeCount(Triggered_indices) - 1;
            Trigger_Time(Triggered_indices) = Trigger_Time_calculated;
            sensorFields.Trigger_Time = Trigger_Time;
            if trigBox_has_diag_field == 1
                diag_sensorFields = dataStructure.(trigBox_diag_field_name);
                diag_sensorFields.Trigger_Time = Trigger_Time;
                fixed_dataStructure.(trigBox_diag_field_name) = diag_sensorFields;
            end
        % end
    elseif contains(lower(sensorName),'encoder')
        % Calculate Trigger_Time for encoder box
        modeID = sensorFields.Mode;
        Trigger_Time = nan(N_points,1);
        Triggered_indices = find(strcmp(modeID,'T'));
        ROS_Time = sensorFields.ROS_Time;
        Trigger_Time(Triggered_indices) = ROS_Time(Triggered_indices);
        sensorFields.Trigger_Time = Trigger_Time;
        if EncoderBox_has_diag_field == 1
            diag_sensorFields = dataStructure.(encoderBox_diag_field_name);
            diag_sensorFields.Trigger_Time = Trigger_Time;
            fixed_dataStructure.(encoderBox_diag_field_name) = diag_sensorFields;
        end

    elseif contains(lower(sensorName),'sick')
        sensorFields.Trigger_Time = sensorFields.ROS_Time;

    elseif contains(lower(sensorName),'velodyne')
        pointCloud_cell = sensorFields.PointCloud;
        N_scans = N_points;
        ROS_Time = sensorFields.ROS_Time;
        Tigger_Time = nan(N_scans,1);
        for idx_scan = 1:N_scans
            pointCloud = pointCloud_cell{idx_scan};
            % this is results stucture from old decoder
            
            if size(pointCloud,2) == 6
                time_offsets = pointCloud(:,6);
                
            % this is results stucture from new decoder
            elseif size(pointCloud,2) == 8
                time_offsets = pointCloud(:,5);
            end
            LiDARPoints_Time = ROS_Time(idx_scan,:) + time_offsets;
            Trigger_time(idx_scan,1) = min(LiDARPoints_Time);
            sensorFields.Trigger_Time = Trigger_time;
        end

    end

    fixed_dataStructure.(sensorName) = sensorFields;

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

if  fid~=0
    fprintf(fid,'\nENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
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

