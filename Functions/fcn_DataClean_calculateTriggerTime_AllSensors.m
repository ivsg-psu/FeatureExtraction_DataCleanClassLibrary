function fixed_dataStructure = fcn_DataClean_calculateTriggerTime_AllSensors(dataStructure,sensors_without_Trigger_Time)

% fcn_DataClean_calculateTriggerTime_AllSensors
% Recalculates the Trigger_Time field for all sensors. This is done by
% using the centiSeconds field and the effective start and end GPS_Times,
% determined by taking the maximum start time and minimum end time over all
% sensors.
%
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_calculateTriggerTime_AllSensors(dataStructure,sensors_without_Trigger_Time,(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      (OPTIONAL INPUTS)
%
%      sensors_without_Trigger_Time: a string to indicate the sensors
%      missing Trigger Time
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
%     See the script: script_test_fcn_DataClean_calculateTriggerTime_AllSensors
%     for a full test suite.
%
% This function was written on 2024_08_29 by X.Cao
% Questions or comments? xfc5113@psu.edu

% Revision history:
%     
% 2024_08_29: xfc5113@psu.edu
% -- wrote the code originally 
% 2024_09_22: xfc5113@psu.edu
% -- fix error for Velodyne LiDAR

% TO DO:
%
% Trigger time for sick lidar need to be recalculated


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
[cell_array_original_Trigger_Time,~]       = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'Trigger_Time','GPS');
[cell_array_Trigger_Time_end,~]     = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'Trigger_Time','GPS','last_row');
%% Find ROS Time
[cell_array_ROS_Time_start,sensor_names_ROS_Time]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS','first_row');
[cell_array_original_ROS_Time,~]       = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS');
[cell_array_ROS_Time_end,~]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS','last_row');
% Confirm that both results are identical
if ~isequal(sensor_names_ROS_Time,sensor_names_Trigger_Time)
    error('Sensors were found that were missing either GPS_Time or ROS_Time. Unable to calculate Trigger_Times.');
end
%% Create common ROS_Time and Trigger_Time (GPS_Time) for GPS units
array_Trigger_Time_start = max(cell2mat(cell_array_Trigger_Time_start));
array_Trigger_Time_end = min(cell2mat(cell_array_Trigger_Time_end));

% Since GPS data have been trimmed, grab the entire range of the ROS_Time
array_ROS_Time_start = min(cell2mat(cell_array_ROS_Time_start));
array_ROS_Time_end = max(cell2mat(cell_array_ROS_Time_end));

Trigger_Time_GPS_common = (array_Trigger_Time_start:max_sample_centiSeconds/100:array_Trigger_Time_end).';
ROS_Time_GPS_common = (array_ROS_Time_start:max_sample_centiSeconds/100:array_ROS_Time_end).';

%% Calculate offset between Trigger_Time (GPS_Time) and ROS_Time for GPS units
array_timeOffset_ROS_Trigger = [];
for idx_GPS_unit = 1:length(sensor_names_Trigger_Time)
   original_Trigger_Time = cell_array_original_Trigger_Time{idx_GPS_unit};
   original_ROS_Time = cell_array_original_ROS_Time{idx_GPS_unit};
   timeOffset_ROS_Trigger = original_ROS_Time - original_Trigger_Time;
   array_timeOffset_ROS_Trigger = [array_timeOffset_ROS_Trigger, timeOffset_ROS_Trigger];
   
end
array_timeOffset_ROS_Trigger_ave = mean(array_timeOffset_ROS_Trigger,2);
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
        disp(text_displaying);

    elseif contains(lower(sensorName),'trigger')
        % Calculate Trigger_Time for trigger box
        modeID = sensorFields.mode;
        Trigger_Time = nan(N_points,1);
        Triggered_indices = find(strcmp(modeID,'L'));
        if isempty(Triggered_indices)
            Triggered_indices = find(strcmp(modeID,'S'));
        end            
            Triggered_modeCount = sensorFields.modeCount;
            ROS_Time = sensorFields.ROS_Time;
            centiSeconds = sensorFields.centiSeconds;
            ROS_Time_triggered  = ROS_Time(Triggered_indices);

            ROS_Time_offsets = pdist2(ROS_Time_triggered,ROS_Time_GPS_common,'euclidean');
            [~,closest_idxs] = min(ROS_Time_offsets,[],2);
            Trigger_start_idx = closest_idxs(1);
            
            Trigger_Time_start = Trigger_Time_GPS_common(Trigger_start_idx);
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
        centiSeconds = sensorFields.centiSeconds;
        Trigger_Time = nan(N_points,1);
        Triggered_indices = find(strcmp(modeID,'T'));
        ROS_Time = sensorFields.ROS_Time;
        ROS_Time_triggered  = ROS_Time(Triggered_indices);
        ROS_Time_offsets = pdist2(ROS_Time_triggered,ROS_Time_GPS_common,'euclidean');
         [~,closest_idxs] = min(ROS_Time_offsets,[],2);
        Trigger_start_idx = closest_idxs(1);
 
        Trigger_Time_start = Trigger_Time_GPS_common(Trigger_start_idx);
     
        Trigger_Time_calculated = Trigger_Time_start+centiSeconds/100*(Triggered_indices-1);
        Trigger_Time(Triggered_indices) = Trigger_Time_calculated;
        sensorFields.Trigger_Time = Trigger_Time;
        if EncoderBox_has_diag_field == 1
            diag_sensorFields = dataStructure.(encoderBox_diag_field_name);
            diag_sensorFields.Trigger_Time = Trigger_Time;
            fixed_dataStructure.(encoderBox_diag_field_name) = diag_sensorFields;
        end

    elseif contains(lower(sensorName),'sick')
        sensorFields.Trigger_Time = sensorFields.ROS_Time;

    elseif contains(lower(sensorName),'velodyne')

        LiDAR_centiSeconds = sensorFields.centiSeconds;
        ROS_Time = sensorFields.ROS_Time;
        ROS_Time_diff = pdist2(ROS_Time,ROS_Time_GPS_common,"euclidean");
        [~, closestIndex] = min(ROS_Time_diff, [], 2);
        GPS_start_idx = closestIndex(1);
        GPS_end_idx = closestIndex(end);
        LiDAR_start_idx = find(closestIndex==GPS_start_idx,1,'last');
        LiDAR_end_idx = find(closestIndex==GPS_end_idx,1,'first');
        N_valid_scans = LiDAR_end_idx - LiDAR_start_idx + 1;
        LiDAR_Trigger_time_start = Trigger_Time_GPS_common(GPS_start_idx);
        LiDAR_centiSeconds_second = LiDAR_centiSeconds/100;
        LiDAR_Trigger_time_end = LiDAR_centiSeconds_second*(N_valid_scans-1)+LiDAR_Trigger_time_start;
        LiDAR_Trigger_time = (LiDAR_Trigger_time_start:LiDAR_centiSeconds_second:LiDAR_Trigger_time_end).';

        sensorFields.Trigger_Time = LiDAR_Trigger_time;

    elseif contains(lower(sensorName),'velocity')
        original_ROS_Time = sensorFields.ROS_Time;
        centiSeconds = sensorFields.centiSeconds;
        start_ROS_Time = original_ROS_Time(1);
        end_ROS_Time = original_ROS_Time(end);
        % if abs(start_ROS_Time-ROS_Time_GPS_common(1)) <= 0.05
        %     ROS_Time_calculated = ROS_Time_GPS_common;
        % else
        ROS_Time_calculated = (start_ROS_Time:centiSeconds/100:end_ROS_Time).';
        % end
        ROS_Time_offsets = pdist2(ROS_Time_calculated,ROS_Time_GPS_common,'euclidean');
        [closest_offsets,closest_idxs] = min(ROS_Time_offsets,[],2);
        % ROS_Time_calculated_valid = ROS_Time_calculated(closest_offsets<=0.05);
        % valid_closest_idxs = closest_idxs(closest_offsets<=0.05);
        Trigger_start_idx = closest_idxs(1); 
        Trigger_Time_start = Trigger_Time_GPS_common(Trigger_start_idx);     
        Triggered_indices = (1:length(ROS_Time_GPS_common)).';
        Trigger_Time_calculated = Trigger_Time_start+centiSeconds/100*(Triggered_indices-1);

        sensorFields.Trigger_Time = Trigger_Time_calculated;
        sensorFields.Npoints = length(Trigger_Time_calculated);
        SpdOverGrndKmph = sensorFields.SpdOverGrndKmph;
        sensorFields.SpdOverGrndKmph = interp1(original_ROS_Time,SpdOverGrndKmph,ROS_Time_GPS_common, "linear","extrap");
        sensorFields.ROS_Time = ROS_Time_GPS_common;
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

