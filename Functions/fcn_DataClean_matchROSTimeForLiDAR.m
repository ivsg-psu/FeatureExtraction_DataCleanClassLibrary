function matched_dataStructure = fcn_DataClean_matchROSTimeForLiDAR(dataStructure,fid)
% fcn_DataClean_roundROSTimeForGPSUnits(dataStructure,fid)
% fcn_DataClean_roundROSTimeForGPSUnits
% Given a data structure, round ROS time of GPS units to the centiSecond
% value
%
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_roundROSTimeForGPSUnits(dataStructure, (sensot_type), (fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed
%
%      (OPTIONAL INPUTS)
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (FID = 0). Set fid to 1 for printing to console.
%
% OUTPUTS:
%
%      fixed_dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES: # to be done
%
%     See the script: script_test_fcn_DataClean_roundROSTimeForGPSUnits
%     for a full test suite.
%
% This function was written on 2024_08_09 by X. Cao
% Questions or comments? xfc5113@psu.edu 

% Revision history:
%     
% 2024_08_09: xfc5113@psu.edu
% -- wrote the code originally 


flag_do_debug = 1;  %#ok<NASGU> % Flag to show the results for debugging
flag_do_plots = 0;  % Flag to plot the final results
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
% sensor_type = '';
% if 2 <= nargin
%     temp = varargin{1};
%     if ~isempty(temp)
%         sensor_type = temp;
%     end
% end
% 

% Does the user want to specify the fid?
% Check for user input
fid = 0; % Default case is to NOT print to the console

% if 3 == nargin
%     temp = varargin{end};
%     if ~isempty(temp)
%         % Check that the FID works
%         try
%             temp_msg = ferror(temp); %#ok<NASGU>
%             % Set the fid value, if the above ferror didn't fail
%             fid = temp;
%         catch ME
%             warning('User-specified FID does not correspond to a file. Unable to continue.');
%             throwAsCaller(ME);
%         end
%     end
% end

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
% 1. Find the effective start and end ROS_Times, determined by taking the maximum start time and minimum end time over all
% sensors.
% 2.  Recalculates the common ROS_Time field for all sensors. This is done by
% using the centiSeconds field.


%% Step 1: Find centiSeconds, ROS_Time and Trigger Time for GPS units
[centiSeconds_GPS_cell,sensor_GPS_names_centiSeconds] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'centiSeconds','GPS');
% Convert centiSeconds to a column matrix
array_centiSeconds_GPS = cell2mat(centiSeconds_GPS_cell);
% To synchronize sensors, take maximum sampling rate so all sensors have
% data from the start
max_sampling_period_centiSeconds = max(array_centiSeconds_GPS);

centiSeconds_GPS = round(mean(array_centiSeconds_GPS));


%% Find start time
% Confirm that both results are identical
[cell_array_GPS_ROS_Time_start,sensor_GPS_names_ROS_Time]  = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS','first_row');
if ~isequal(sensor_GPS_names_ROS_Time,sensor_GPS_names_centiSeconds)
    error('Sensors were found that were missing either GPS_Time or centiSeconds. Unable to calculate Trigger_Times.');
end

% Convert GPS_Time_start to a column matrix
array_ROS_Time_start = cell2mat(cell_array_GPS_ROS_Time_start).';

% Find when each sensor's start time lands on this centiSecond value, rounding up
all_start_times_centiSeconds = ceil(100*array_ROS_Time_start/max_sampling_period_centiSeconds)*max_sampling_period_centiSeconds;

if (max(all_start_times_centiSeconds)-min(all_start_times_centiSeconds))>100
    error('The start times on different GPS sensors appear to be untrimmed to same value. The Trigger_Time calculations will give incorrect results if the data are not trimmed first.');
end
centitime_all_GPS_have_started_ROS_Time = max(all_start_times_centiSeconds);


%% Find end time

[cell_array_GPS_ROS_Time_end,sensor_GPS_names_ROS_Time]  = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS','last_row');

% Confirm that both results are identical
if ~isequal(sensor_GPS_names_ROS_Time,sensor_GPS_names_centiSeconds)
    error('Sensors were found that were missing either GPS_Time or centiSeconds. Unable to calculate Trigger_Times.');
end

% Convert GPS_Time_start to a column matrix 
array_ROS_Time_end = cell2mat(cell_array_GPS_ROS_Time_end).';

% Find when each sensor's end time lands on this centiSecond value,
% rounding down
all_end_times_centiSeconds = floor(100*array_ROS_Time_end/max_sampling_period_centiSeconds)*max_sampling_period_centiSeconds;

if (max(all_end_times_centiSeconds)-min(all_end_times_centiSeconds))>100
    error('The end times on different GPS sensors appear to be untrimmed to same value. The Trigger_Time calculations will give incorrect results if the data are not trimmed first.');
end

centitime_all_GPS_have_ended_ROS_Time = min(all_end_times_centiSeconds);

%% Step 2: Create the common ROS_Time for all GPS units

ROS_Time_GPS_common_centiSeconds = (centitime_all_GPS_have_started_ROS_Time:centiSeconds_GPS:centitime_all_GPS_have_ended_ROS_Time).';

%% Step 3: Grab the centiSeconds and ROS_Time from velodyne LiDAR and round ROS_Time to centiSeconds
[cell_array_ROS_Time_Lidar,LiDAR_Names_ROS_Time] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'ROS_Time','Lidar');
[cell_array_centiSeconds_Lidar, LiDAR_Names_centiSeconds] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'centiSeconds','Lidar');
[cell_array_PointCloud,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'PointCloud','Lidar');
if ~isequal(LiDAR_Names_ROS_Time,LiDAR_Names_centiSeconds)
    error('Sensors were found that were missing either ROS_Time or centiSeconds');
end
N_LiDAR_units = length(LiDAR_Names_ROS_Time);
for idx_LiDAR = 1:N_LiDAR_units
    LiDARName = LiDAR_Names_ROS_Time{idx_LiDAR};
    if strcmp(LiDARName, 'LiDAR_Velodyne_Rear')
        ROS_Time_LiDARVelodyne = cell_array_ROS_Time_Lidar{idx_LiDAR};
        centiSeconds_LiDARVelodyne = cell_array_centiSeconds_Lidar{idx_LiDAR};
        PointCloud_LiDARVelodyne = cell_array_PointCloud{idx_LiDAR};
    end
end
ROSTime_LiDARVelodyne_centiSeconds = round(100*ROS_Time_LiDARVelodyne/centiSeconds_LiDARVelodyne)*centiSeconds_LiDARVelodyne;
%%
centitime_all_sensors_have_started_ROS_Time = max([min(ROSTime_LiDARVelodyne_centiSeconds),centitime_all_GPS_have_started_ROS_Time]);
centitime_all_sensors_have_ended_ROS_Time = min([max(ROSTime_LiDARVelodyne_centiSeconds),centitime_all_GPS_have_ended_ROS_Time]);    
%% Use the find the start and end indices of the ROS Time for GPS units
[~,start_index_GPS] = min(abs(ROS_Time_GPS_common_centiSeconds - centitime_all_sensors_have_started_ROS_Time));
[~,end_index_GPS] = min(abs(ROS_Time_GPS_common_centiSeconds - centitime_all_sensors_have_ended_ROS_Time));
start_index_LiDAR = find(ROSTime_LiDARVelodyne_centiSeconds==centitime_all_sensors_have_started_ROS_Time,1,'first');
end_index_LiDAR = find(ROSTime_LiDARVelodyne_centiSeconds==centitime_all_sensors_have_ended_ROS_Time,1,'last');
ROSTime_common_centiSeconds_rounded_valid = ROS_Time_GPS_common_centiSeconds(start_index_GPS:end_index_GPS,:);
ROSTime_LiDARVelodyne_centiSeconds_valid = ROSTime_LiDARVelodyne_centiSeconds(start_index_LiDAR:end_index_LiDAR,:);
%% Use GPS common ROS time as a reference to match LiDAR, fill the element with nan if there is missing data
matchedROSTime_Velodyne_centiSeconds = nan(size(ROSTime_common_centiSeconds_rounded_valid));
matchedPointCloud_LiDARVelodyne = cell(size(ROSTime_common_centiSeconds_rounded_valid));
for idx_time = 1:length(ROSTime_LiDARVelodyne_centiSeconds_valid)
        time_diff = abs(ROSTime_common_centiSeconds_rounded_valid-ROSTime_LiDARVelodyne_centiSeconds_valid(idx_time));
        [~,closest_idx] = min(time_diff);
        matchedROSTime_Velodyne_centiSeconds(closest_idx,:) = ROSTime_LiDARVelodyne_centiSeconds_valid(idx_time);
        matchedPointCloud_LiDARVelodyne(closest_idx,:) = PointCloud_LiDARVelodyne(idx_time);
end
matchedSeq = (1:length(matchedROSTime_Velodyne_centiSeconds)).';
%% Fill the matched_dataStructure (GPS units and Velodyne LiDAR)
matched_dataStructure = dataStructure;
sensorNames = [sensor_GPS_names_ROS_Time;{'LiDAR_Velodyne_Rear'}];

for idx_field = 1:length(sensor_GPS_names_ROS_Time)
    current_field_struct = dataStructure.(sensorNames{idx_field});
    matched_field_struct = current_field_struct;
    topicfields = fieldnames(current_field_struct);
    N_topics = length(topicfields);
    if contains(sensorNames{idx_field},'GPS')
        valid_idxs = start_index_GPS:end_index_GPS;
    else
        valid_idxs = start_index_LiDAR:end_index_LiDAR;
    end
    for idx_topic = 1:N_topics
        current_topic_content = current_field_struct.(topicfields{idx_topic});
        if (length(current_topic_content) > 1)&(~any(regexp(topicfields{idx_topic} ,'[0-9]')))
           matched_field_struct.(topicfields{idx_topic}) = current_topic_content(valid_idxs,:);
        end
        matched_field_struct.centiSeconds = current_field_struct.centiSeconds;
        matched_field_struct.Npoints = length(matched_field_struct.ROS_Time);

    end
    matched_dataStructure.(sensorNames{idx_field}) = matched_field_struct;

end 
matched_dataStructure.LiDAR_Velodyne_Rear.Seq = matchedSeq;
matched_dataStructure.LiDAR_Velodyne_Rear.ROS_Time = matchedROSTime_Velodyne_centiSeconds/100;
matched_dataStructure.LiDAR_Velodyne_Rear.PointCloud = matchedPointCloud_LiDARVelodyne;
matched_dataStructure.LiDAR_Velodyne_Rear.Npoints = length(matchedSeq);

    %%
  
    