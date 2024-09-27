function fixed_dataStructure = fcn_DataClean_fillTriggerTimes(dataStructure,varargin)

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
            warning('on','backtrace');
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

%% Step 1: Find the effective start and end times over all sensors
%% Find centiSeconds
Trigger_Raw =dataStructure.Trigger_Raw;
Trigger_time_filled = Trigger_Raw;
Trigger_Raw_mode = Trigger_Raw.mode;
Trigger_Raw_modeCount = Trigger_Raw.modeCount;
Trigger_Raw_Trigger_Time = Trigger_Raw.Trigger_Time;

N_trigger = size(Trigger_Raw_mode,1);
for idx_trigger = 1:N_trigger
    current_trigger_mode = Trigger_Raw_mode(idx_trigger,:);
    if strcmp(current_trigger_mode,"L")
        Trigger_Raw_Trigger_Time(idx_trigger,:) = Trigger_Raw_modeCount(idx_trigger,:);
    end
end

Trigger_time_filled.Trigger_Time = Trigger_Raw_Trigger_Time;

[cell_array_centiSeconds,sensor_names_centiSeconds] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds',sensor_type,'first_row');

% Convert centiSeconds to a column matrix
array_centiSeconds = cell2mat(cell_array_centiSeconds)';

% To synchronize sensors, take maximum sampling rate so all sensors have
% data from the start
max_sampling_period_centiSeconds = max(array_centiSeconds);

if 0~=fid
    fprintf(fid,'\nCalculating Trigger_Time by checking start and end times across GPS sensors:\n');
end



%% Find start time
[cell_array_GPS_Time_start,sensor_names_GPS_Time]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time',sensor_type,'first_row');

% Confirm that both results are identical
if ~isequal(sensor_names_GPS_Time,sensor_names_centiSeconds)
    error('Sensors were found that were missing either GPS_Time or centiSeconds. Unable to calculate Trigger_Times.');
end

% Convert GPS_Time_start to a column matrix
array_GPS_Time_start = cell2mat(cell_array_GPS_Time_start)';

% Find when each sensor's start time lands on this centiSecond value, rounding up
all_start_times_centiSeconds = ceil(100*array_GPS_Time_start/max_sampling_period_centiSeconds)*max_sampling_period_centiSeconds;

% Warn if max/min are WAY off (like more than 1 second)
if (max(all_start_times_centiSeconds)-min(all_start_times_centiSeconds))>100
    error('The start times on different GPS sensors appear to be untrimmed to same value. The Trigger_Time calculations will give incorrect results if the data are not trimmed first.');
end
centitime_all_sensors_have_started_GPS_Time = max(all_start_times_centiSeconds);

% Show the results?
if fid
    longest_name_string = 0;
    for ith_name = 1:length(sensor_names_GPS_Time)
        if length(sensor_names_GPS_Time{ith_name})>longest_name_string
            longest_name_string = length(sensor_names_GPS_Time{ith_name});
        end
    end
    fprintf(fid,'\t \t Summarizing start times: \n');
    sensor_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',longest_name_string);
    posix_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Posix Time (sec since 1970):',29);
    datetime_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Date Time:',25);
    fprintf(fid,'\t \t %s \t %s \t %s \n',sensor_title_string,posix_title_string,datetime_title_string);
    for ith_data = 1:length(sensor_names_GPS_Time)
        sensor_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sensor_names_GPS_Time{ith_data},longest_name_string);
        posix_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%.6f',array_GPS_Time_start(ith_data)),29);
        time_in_datetime = datetime(array_GPS_Time_start(ith_data),'convertfrom','posixtime','format','yyyy-MM-dd HH:mm:ss.SSS');
        
        time_string = sprintf('%s',time_in_datetime);
        datetime_data_string = fcn_DebugTools_debugPrintStringToNCharacters(time_string,25);
        fprintf(fid,'\t \t %s \t %s \t %s \n',sensor_data_string,posix_data_string,datetime_data_string);
    end
    fprintf(fid,'\n');
end

%% Find end time
[cell_array_GPS_Time_end,sensor_names_GPS_Time]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time',sensor_type,'last_row');

% Confirm that both results are identical
if ~isequal(sensor_names_GPS_Time,sensor_names_centiSeconds)
    error('Sensors were found that were missing either GPS_Time or centiSeconds. Unable to calculate Trigger_Times.');
end

% Convert GPS_Time_start to a column matrix
array_GPS_Time_end = cell2mat(cell_array_GPS_Time_end)';

% Find when each sensor's end time lands on this centiSecond value,
% rounding down
all_end_times_centiSeconds = floor(100*array_GPS_Time_end/max_sampling_period_centiSeconds)*max_sampling_period_centiSeconds;

% Warn if max/min are WAY off (like more than 1 second)
if (max(all_end_times_centiSeconds)-min(all_end_times_centiSeconds))>100
    error('The end times on different GPS sensors appear to be untrimmed to same value. The Trigger_Time calculations will give incorrect results if the data are not trimmed first.');
end
centitime_all_sensors_have_ended_GPS_Time = min(all_end_times_centiSeconds);

% Show the results?
if fid
    fprintf(fid,'\t \t Summarizing end times: \n');    
    sensor_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',longest_name_string);
    posix_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Posix Time (sec since 1970):',29);
    datetime_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Date Time:',25);
    fprintf(fid,'\t \t %s \t %s \t %s \n',sensor_title_string,posix_title_string,datetime_title_string);
    for ith_data = 1:length(sensor_names_GPS_Time)
        sensor_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sensor_names_GPS_Time{ith_data},longest_name_string);
        posix_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%.6f',array_GPS_Time_end(ith_data)),29);
        time_in_datetime = datetime(array_GPS_Time_end(ith_data),'convertfrom','posixtime','format','yyyy-MM-dd HH:mm:ss.SSS');
        
        time_string = sprintf('%s',time_in_datetime);
        datetime_data_string = fcn_DebugTools_debugPrintStringToNCharacters(time_string,25);
        fprintf(fid,'\t \t %s \t %s \t %s \n',sensor_data_string,posix_data_string,datetime_data_string);
    end
    fprintf(fid,'\n');
end
if fid
    fprintf(fid,'\t The Trigger_Time is using the following GPS_Time range: \n');
    fprintf(fid,'\t\t Start Time (UTC seconds): %.3f\n',centitime_all_sensors_have_started_GPS_Time/100);
    fprintf(fid,'\t\t End Time   (UTC seconds): %.3f\n',centitime_all_sensors_have_ended_GPS_Time/100);
    fprintf(fid,'\n');
end


%% Step 2: Fill all Trigger_Time data to common start/end times
% and fix GPS_Time

[cell_array_GPS_Time,sensor_names_GPS_Time]         = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time',sensor_type);

% Initialize the result:
fixed_dataStructure = dataStructure;

% Loop through the fields, searching for ones that have "GPS" in their name
for ith_sensor = 1:length(sensor_names_GPS_Time)
    % Grab the sensor subfield name
    sensor_name = sensor_names_GPS_Time{ith_sensor};
    
    if 0~=fid
        fprintf(fid,'\t Filling Trigger_Time in sensor %d of %d to have correct start and end GPS_Time values: %s\n',ith_sensor,length(sensor_names_GPS_Time),sensor_name);
    end
    
    % Calculate new Trigger_Time
    centiSeconds = array_centiSeconds(ith_sensor,1);
    new_Trigger_Time = (centitime_all_sensors_have_started_GPS_Time:centiSeconds:centitime_all_sensors_have_ended_GPS_Time)'/100;
    fixed_dataStructure.(sensor_name).Trigger_Time = new_Trigger_Time;

    % Calculate new GPS_Time
    GPS_Time_original = cell_array_GPS_Time{ith_sensor};
    original_vector_size = size(GPS_Time_original);

    % Find the start index
    rounded_centiSecond_GPS_Time = round(100*GPS_Time_original/centiSeconds)*centiSeconds;
    start_index = find(rounded_centiSecond_GPS_Time==centitime_all_sensors_have_started_GPS_Time,1,'first');
    if isempty(start_index)
        warning('on','backtrace');
        warning('GPS time does not match trigger time.');
        error('Unable to match GPS_Time to Trigger_Time for start time calculation');
    end

    % Find the end index
    end_index = find(rounded_centiSecond_GPS_Time==centitime_all_sensors_have_ended_GPS_Time,1,'first');
    if isempty(end_index)
        warning('on','backtrace');
        warning('GPS time does not match trigger time.');
        error('Unable to match GPS_Time to Trigger_Time for end time calculation');
    end
    GPS_Time_in_Trigger = GPS_Time_original(start_index:end_index,:);
    fixed_dataStructure.(sensor_name).GPS_Time = GPS_Time_in_Trigger;

    if length(GPS_Time_in_Trigger)~=length(new_Trigger_Time)
        warning('on','backtrace');
        warning('GPS time does not match trigger time.');
        error('The GPS time calculated to match the Trigger_Time duration does not have same length. This is typically caused by GPS rounding errors, but it must be resolved to continue.\n');
    end

    % Loop through subfields
    sensor_data = fixed_dataStructure.(sensor_name);
    subfieldNames = fieldnames(sensor_data);
    for i_subField = 1:length(subfieldNames)
        % Grab the name of the ith subfield
        subFieldName = subfieldNames{i_subField};
        
        if ~iscell(sensor_data.(subFieldName)) % Is it a cell? If yes, skip it
            if length(sensor_data.(subFieldName)) ~= 1 % Is it a scalar? If yes, skip it
                % It's an array, make sure it has right length
                if isequal(size(sensor_data.(subFieldName)),original_vector_size)
                    if strcmp(sensor_name,'LIDAR_Sick_Rear') 
                        warning('on','backtrace');
                        warning('SICK lidar data processing not yet tested.');
                    else
                        % Resize the data to exact same indicies as trimmed
                        % GPS_Time field, to align with the Trigger_Time
                        fixed_dataStructure.(sensor_name).(subFieldName) = sensor_data.(subFieldName)(start_index:end_index,:);
                    end
                end
            end
        end
       
    end % Ends for loop through the subfields
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
    fprintf(1,'\nENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
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

