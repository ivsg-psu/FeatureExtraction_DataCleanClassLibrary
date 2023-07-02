function fixed_dataStructure = fcn_DataClean_recalculateTriggerTimes(dataStructure,varargin)

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
centitime_all_sensors_have_ended_GPS_Time = max(all_end_times_centiSeconds);

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

