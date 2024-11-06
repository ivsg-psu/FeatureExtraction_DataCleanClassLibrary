function [flags,offending_sensor,sensors_without_Trigger_Time] = fcn_DataClean_checkDataTimeConsistency_GPS(dataStructure, varargin)

% fcn_DataClean_checkDataTimeConsistency_GPS
% Checks a given dataset to verify whether data meets key time consistency
% requirements, for GPS sensors. 
%
% Time consistency refers to any time fields in data with
% particular focus on sensors that utilize GPS timing, specifically UTC
% time as measured in Posix time, e.g. seconds since 00:00:00 on Jan 1st,
% 1970. The primary purpose of this consistency testing is to ensure the
% time sampling intervals (measured in hundreths of a second, or
% "centiSeconds"), the number of data measured, and the relationship
% between GPS time and ROS time (the time measured on the data recording
% computer) are all logically consistent. 
%
% The input is a structure that has as sub-fields each sensor, which in
% turn is a structure that also has key recordings each saved as
% sub-sub-fields. Many key features are tested in the data, changing
% certain flag values in a structure called "flags". 
% 
% The output is a structure 'flags' with subfield flags which are set so
% that the flag = 1 condition represents data that passes that particular
% consistency test. If any flags fail, the flag for that test is
% immediately set to zero and the offending sensor causing the failure is
% noted as a string output. The function immediately exits without checking
% any further flags.
%
% If no flag errors are detected, e.g. all flags = 1, then the
% 'offending_sensor' output is an empty string.
%
% FORMAT:
%
%      [flags,offending_sensor] = fcn_DataClean_checkDataTimeConsistency_GPS(dataStructure, (flags), (fid), (fig_num))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      (OPTIONAL INPUTS)
%
%      flags: If a structure is entered, it will append the flag result
%      into the structure to allow a pass-through of flags structure
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (FID = 0). Set fid to 1 for printing to console.
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
% Time inconsistencies include situations where the time vectors on data
% are fundamentally flawed, and are checked in order of flaws. 
%
% Many consistency tests later in the sequence depend on a sensor passing
% consistency tests early in the sequence. For example, the consistency
% check for inconsistent time sampling of ROS_Time on a particular sensor
% cannot be performed unless that same sensor has a recorded value for its
% sampling time in the 'centiSeconds' field.
%
% For timing data to be consistent, the following must be true, and
% correspond directly to the names of flags being set. For some tests, if
% they are not true, there are procedures to fix these errors and these are
% typically performed via other functions in the DataClean library.
%
% # GPS_Time tests include:
%     ## GPS_Time_exists_in_at_least_one_GPS_sensor
%     ## GPS_Time_exists_in_all_GPS_sensors
%     ## centiSeconds_exists_in_all_GPS_sensors
%     ## GPS_Time_has_no_repeats_in_GPS_sensors
%     ## GPS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
%     ## start_time_GPS_sensors_agrees_to_within_5_seconds
%     ## consistent_start_and_end_times_across_GPS_sensors
%     ## GPS_Time_strictly_ascends
%
% The above issues are explained in more detail in the following
% sub-sections of code.
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_checkDataTimeConsistency_GPS
%     for a full test suite.
%
% This function was written on 2024_09_30 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2024_09_30: sbrennan@psu.edu
% -- wrote the code originally by pulling out of checkDataTimeConsistency

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==4 && isequal(varargin{end},-1))
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
        narginchk(1,4);
    end
end

% Does the user want to specify the flags?
flags = struct; %#ok<NASGU>
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        flags = temp; %#ok<NASGU>
    end
end

% Does the user want to specify the fid?
fid = 0;
% Check for user input
if 3 <= nargin
    temp = varargin{2};
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

% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (4<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp; %#ok<NASGU>
        flag_do_plots = 1;
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

% Initialize flags
flags = struct;
sensors_without_Trigger_Time = '';
% flags.GPS_Time_exists_in_at_least_one_sensor = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _______ _                   _____                _     _                           _____ _               _        
%  |__   __(_)                 / ____|              (_)   | |                         / ____| |             | |       
%     | |   _ _ __ ___   ___  | |     ___  _ __  ___ _ ___| |_ ___ _ __   ___ _   _  | |    | |__   ___  ___| | _____ 
%     | |  | | '_ ` _ \ / _ \ | |    / _ \| '_ \/ __| / __| __/ _ \ '_ \ / __| | | | | |    | '_ \ / _ \/ __| |/ / __|
%     | |  | | | | | | |  __/ | |___| (_) | | | \__ \ \__ \ ||  __/ | | | (__| |_| | | |____| | | |  __/ (__|   <\__ \
%     |_|  |_|_| |_| |_|\___|  \_____\___/|_| |_|___/_|___/\__\___|_| |_|\___|\__, |  \_____|_| |_|\___|\___|_|\_\___/
%                                                                              __/ |                                  
%                                                                             |___/                                   
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Time%20Consistency%20Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% GPS_Time tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    _____ _____   _____            _______ _                   _______        _       
%   / ____|  __ \ / ____|          |__   __(_)                 |__   __|      | |      
%  | |  __| |__) | (___               | |   _ _ __ ___   ___      | | ___  ___| |_ ___ 
%  | | |_ |  ___/ \___ \              | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
%  | |__| | |     ____) |             | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
%   \_____|_|    |_____/              |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
%                          ______                                                      
%                         |______|                                                     
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=GPS%20_%20Time%20%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if GPS_Time_exists_in_at_least_one_GPS_sensor
%    ### ISSUES with this:
%    * There is no absolute time base to use for the data
%    * The tracking of vehicle data relative to external sources is no
%    longer possible
%    ### DETECTION:
%    * Examine if GPS time fields exist on any GPS sensor
%    ### FIXES:
%    * Catastrophic error. Data collection should end.
%    * One option? Check if ROS_Time recorded, and is locked to UTC via NTP, use ROS
%    Time as stand-in
%    * Otherwise, complete failure of sensor recordings

[flags,offending_sensor] = fcn_DataClean_checkIfFieldInSensors(dataStructure,'GPS_Time',flags,'any','GPS',fid);

if 0==flags.GPS_Time_exists_in_at_least_one_GPS_sensor
    return
end

%% Check if GPS_Time_exists_in_all_GPS_sensors
%    ### ISSUES with this:
%    * There is no absolute time base to use for the sensor
%    * This usually indicates back lock for the GPS
%    ### DETECTION:
%    * Examine if GPS time fields exist on all GPS sensors
%    ### FIXES:
%    * If another GPS is available, use its time alongside the GPS data
%    * Remove this GPS data field


[flags,offending_sensor] = fcn_DataClean_checkIfFieldInSensors(dataStructure,'GPS_Time',flags,'all','GPS',fid);
if 0==flags.GPS_Time_exists_in_all_GPS_sensors
    return
end

%% Check if centiSeconds_exists_in_all_GPS_sensors
%    ### ISSUES with this:
%    * This field defines the expected sample rate for each sensor
%    ### DETECTION:
%    * Examine if centiSeconds fields exist on all sensors
%    ### FIXES:
%    * Manually fix, or
%    * Remove this sensor

[flags,offending_sensor] = fcn_DataClean_checkIfFieldInSensors(dataStructure,'centiSeconds',flags,'all','GPS',fid);
if 0==flags.centiSeconds_exists_in_all_GPS_sensors
    return
end

%% Check if GPS_Time_has_no_repeats_in_GPS_sensors
%    ### ISSUES with this:
%    * If there are many repeated time values, the calculation of sampling
%    time in the next step produces incorrect results
%    ### DETECTION:
%    * Examine if time values are unique
%    ### FIXES:
%    * Remove repeats

[flags,offending_sensor,~] = fcn_INTERNAL_checkIfFieldHasRepeatedValues(fid, dataStructure, flags, 'GPS_Time','GPS');
if 0==flags.GPS_Time_has_no_repeats_in_GPS_sensors
    return
end


%% Check if GPS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
%    ### ISSUES with this:
%    * This field is used to confirm GPS sampling rates for all
%    GPS-triggered sensors
%    * These sensors are used to correct ROS timings, so if any are misisng, the
%    timing and thus positioning of vehicle data may be wrong
%    * The GPS unit may be configured wrong
%    * The GPS unit may be faililng or operating incorrectly
%    ### DETECTION:
%    * Examine if centiSeconds calculation of time interval matches GPS
%    time interval for data collection, on average
%    ### FIXES:
%    * Manually fix, or
%    * Remove this sensor

fig_num = 12345678;
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(dataStructure,'GPS_Time', flags, 'GPS',fid, fig_num);

if 0==flags.GPS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
    return
end

%% Check if start_time_GPS_sensors_agrees_to_within_5_seconds and if consistent_start_and_end_times_across_GPS_sensors
%    ### ISSUES with this:
%    * The start times and end times of all data collection assumes all GPS
%    systems are operating simultaneously
%    * The calculation of Trigger_Time assumes that all start times are the
%    same, and all end times are the same
%    * If they are not the same, the count of data in one sensor may be
%    different than another, especially if each were referencing different
%    GPS sources.
%    ### DETECTION:
%    * Seach through the GPS time fields for all sensors, rounding them to
%    their appropriate centi-second values
%    * Check that they all agree
%    ### FIXES:
%    * Crop all data to same starting centi-second value


% Check start_time_GPS_sensors_agrees_to_within_5_seconds
URHERE - need to add threshold to below
[flags,offending_sensor,~] = fcn_INTERNAL_checkConsistencyOfStartEnd(fid, dataStructure, flags, 'GPS_Time', 'GPS', consistency_name)
if 0==flags.start_time_GPS_sensors_agrees_to_within_5_seconds
    return
end

% Check consistent_start_and_end_times_across_GPS_sensors
[flags,offending_sensor,~] = fcn_INTERNAL_checkConsistencyOfStartEnd(fid, dataStructure, flags, 'GPS_Time', 'GPS', consistency_name)
if 0==flags.consistent_start_and_end_times_across_GPS_sensors
    return
end


%% Check if GPS_Time_strictly_ascends
%    ### ISSUES with this:
%    * This field is used to calibrate ROS time via interpolation, and must
%    be STRICTLY increasing
%    * If data packets arrive out-of-order with this sensor, times may not
%    be in an increasing sequence
%    * If a GPS is glitching, its time may be temporarily incorrect
%    ### DETECTION:
%    * Examine if time data from sensor is STRICTLY increasing
%    ### FIXES:
%    * Remove and interpolate time field if not strictkly increasing
%    * Re-order data, if minor ordering error

[flags,offending_sensor,~] = fcn_INTERNAL_checkDataStrictlyIncreasing(fid, dataStructure, flags, 'GPS_Time','GPS');
if 0==flags.GPS_Time_strictly_ascends
    return
end

%% Check if no_jumps_in_differences_of_GPS_Time_in_any_GPS_sensors
%    ### ISSUES with this:
%    * The GPS_Time may have small jumps which could occur if the sensor
%    pauses for a moment, then restarts
%    * If these jumps are large, the data from the sensor may be corrupted
%    ### DETECTION:
%    * Examine if the differences in GPS_Time are out of ordinary by
%    looking at the standard deviations of the differences relative to the
%    mean differences
%    ### FIXES:
%    * Interpolate time field if only a small segment is missing

threshold_in_standard_deviations = 5;
custom_lower_threshold = 0.0001; % Time steps cannot be smaller than this
[flags,offending_sensor] = fcn_DataClean_checkFieldDifferencesForJumps(dataStructure,'GPS_Time',flags,threshold_in_standard_deviations, custom_lower_threshold,'any','GPS', fid);

if 0==flags.no_jumps_in_differences_of_GPS_Time_in_any_GPS_sensors
    warning('on','backtrace');
    warning('There are jumps in differences of GPS time, GPS time needs to be interpolated')
    return
end

%% Check if no_missings_in_differences_of_GPS_Time_in_any_GPS_sensors
%    ### ISSUES with this:
%    * The GPS_Time may have small missing portions which could occur if
%    the sensor pauses for a moment, then restarts
%    * If these missings are large, the data from the sensor may be corrupted
%    ### DETECTION:
%    * Examine if the differences in GPS_Time are out of ordinary by
%    looking at the standard deviations of the differences relative to the
%    mean differences
%    ### FIXES:
%    * Interpolate time field if only a small segment is missing

warning('on','backtrace');
warning('This code looks wrong - need to check.')

threshold_for_agreement = 0.0001; % Data must agree within this interval
expectedJump = 0.01; 
string_any_or_all = 'any'; 
sensors_to_check = 'GPS'; 
fid = 0; 

% Show an error is detected
[flags,offending_sensor] = fcn_DataClean_checkFieldDifferencesForMissings(dataStructure, 'GPS_Time', (flags), (threshold_for_agreement), (expectedJump), (string_any_or_all), (sensors_to_check), (fid));

% [flags,offending_sensor] = fcn_DataClean_checkFieldDifferencesForMissings(dataStructure, 'GPS_Time',  flags,   threshold_in_standard_deviations, custom_lower_threshold,'any','GPS', fid);

if 0==flags.no_missings_in_differences_of_GPS_Time_in_any_GPS_sensors
    warning('on','backtrace');
    warning('There are missing data in differences of GPS time, GPS time need to be interpolated')
    return
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

%% fcn_INTERNAL_checkIfFieldHasRepeatedValues
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkIfFieldHasRepeatedValues(fid, dataStructure, flags, field_name,sensors_to_check)
% Checks to see if a particular sensor has any repeated values in the
% requested field

if ~exist('sensors_to_check','var')
    flag_check_all_sensors = 1;    
else
    flag_check_all_sensors = 0;
end

if flag_check_all_sensors
    flag_name = cat(2,field_name,'_has_no_repeats_in_all_sensors');
else
    flag_name = cat(2,field_name,sprintf('_has_no_repeats_in_%s_sensors',sensors_to_check));
end

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
if flag_check_all_sensors
    sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
else
    % Produce a list of all the sensors that meet the search criteria, and grab
    % their data also
    [~,sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, field_name,sensors_to_check);
end


if 0~=fid
    fprintf(fid,'Checking for repeats in %s data ',field_name);
    if flag_check_all_sensors
        fprintf(fid,': --> %s\n', flag_name);
    else
        fprintf(fid,'in all %s sensors: --> %s\n', sensors_to_check, flag_name);
    end
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};   
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
    
    unique_values = unique(sensor_data.(field_name),'stable');
    
    if ~isequal(unique_values,sensor_data.(field_name))
        flag_no_repeats_detected = 0;
    else
        flag_no_repeats_detected = 1;
    end
    

    flags.(flag_name) = flag_no_repeats_detected;
    
    if 0==flags.(flag_name)
        offending_sensor = sensor_name; % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end
end % Ends for loop


% Tell the user what is happening?
if 0~=fid
    fprintf(fid,'\n\t Flag %s set to: %.0d\n\n',flag_name, flag_no_repeats_detected);
end

end % Ends fcn_INTERNAL_checkIfFieldHasRepeatedValues


%% fcn_INTERNAL_checkConsistencyOfStartEnd
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkConsistencyOfStartEnd(fid, dataStructure, flags, field_to_check, sensor_type, consistency_name)
% Checks to see if all data in a field have same start or end values

% Initialize offending_sensor
offending_low_sensor = '';
offending_high_sensor = '';
lowest_start_time = inf;
highest_end_time = -inf;

URHERE
flag_name = sprintf('%s_consistent_start_end_%s_to_%s',sensor_type, field_to_check,consistency_name);

% Initialize starting centiSeconds
start_times_centiSeconds = [];
end_times_centiSeconds = [];
all_centiSecond_values = [];

% Produce a list of all the sensors (each is a field in the structure)
[~,sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, field_to_check, sensor_type);

if 0~=fid
    fprintf(fid,'Checking consistency of start and end of %s across %s sensors:  --> %s \n', field_to_check, sensor_type, flag_name);
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
    
    times_centiSeconds = round(100*sensor_data.GPS_Time/sensor_data.centiSeconds)*sensor_data.centiSeconds;
    start_times_centiSeconds = [start_times_centiSeconds; times_centiSeconds(1)]; %#ok<AGROW>
    end_times_centiSeconds = [end_times_centiSeconds; times_centiSeconds(end)]; %#ok<AGROW>
    all_centiSecond_values = [all_centiSecond_values; sensor_data.centiSeconds]; %#ok<AGROW>
    
    if times_centiSeconds(1)< lowest_start_time
        lowest_start_time = times_centiSeconds(1);
        offending_low_sensor = sensor_name;
    end
    
    if times_centiSeconds(end)> highest_end_time
        highest_end_time = times_centiSeconds(end);
        offending_high_sensor = sensor_name;
    end
    
end

URHERE



% Calculate the differences in the times
start_time_differences = diff(start_times_centiSeconds);
end_time_differences = diff(end_times_centiSeconds);

% Check that the start times are all within 5 seconds of each other 
% Note: typical boot-up time for sensors is about 2 seconds
flags.start_time_GPS_sensors_agrees_to_within_5_seconds = max(abs(start_time_differences))<=(5*100);
if 0==flags.start_time_GPS_sensors_agrees_to_within_5_seconds % Is it bad?
    offending_sensor = cat(2,offending_low_sensor,' ',offending_high_sensor); % Save the names of the sensor
    return_flag = 1; % Indicate that the return was forced   
    return
end

% Check that they all agree exactly
largest_time_diff = max(all_centiSecond_values);
abs_start_diffs = abs(start_time_differences);
abs_end_diffs = abs(end_time_differences);
flags.consistent_start_and_end_times_across_GPS_sensors = all(abs_start_diffs<=largest_time_diff)*all(abs_end_diffs<=largest_time_diff);
if 0==flags.consistent_start_and_end_times_across_GPS_sensors
    offending_sensor = cat(2,offending_low_sensor,' ',offending_high_sensor); % Save the names of the sensor
    return_flag = 1; % Indicate that the return was forced
    
    % Show the results?
    if fid
        % Find the longest name
        longest_name_string = 0;
        for ith_name = 1:length(sensor_names)
            if length(sensor_names{ith_name})>longest_name_string
                longest_name_string = length(sensor_names{ith_name});
            end
        end
        
        % Print results
        fprintf(fid,'\n\t Inconsistent start or end time detected! \n');
        
        % Print start time table
        fprintf(fid,'\t \t Summarizing start times: \n');
        sensor_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',longest_name_string);
        posix_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Posix Time (sec since 1970):',29);
        datetime_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Date Time:',25);
        fprintf(fid,'\t \t %s \t %s \t %s \n',sensor_title_string,posix_title_string,datetime_title_string);
        for ith_data = 1:length(sensor_names)
            sensor_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sensor_names{ith_data},longest_name_string);
            posix_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%.6f',start_times_centiSeconds(ith_data)),29);
            time_in_datetime = datetime(start_times_centiSeconds(ith_data),'convertfrom','posixtime','format','yyyy-MM-dd HH:mm:ss.SSS');
            
            time_string = sprintf('%s',time_in_datetime);
            datetime_data_string = fcn_DebugTools_debugPrintStringToNCharacters(time_string,25);
            fprintf(fid,'\t \t %s \t %s \t %s \n',sensor_data_string,posix_data_string,datetime_data_string);
        end
        fprintf(fid,'\n');
        
        % Print end time table
        fprintf(fid,'\t \t Summarizing end times: \n');
        sensor_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',longest_name_string);
        posix_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Posix Time (sec since 1970):',29);
        datetime_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Date Time:',25);
        fprintf(fid,'\t \t %s \t %s \t %s \n',sensor_title_string,posix_title_string,datetime_title_string);
        for ith_data = 1:length(sensor_names)
            sensor_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sensor_names{ith_data},longest_name_string);
            posix_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%.6f',end_times_centiSeconds(ith_data)*0.01),29);
            time_in_datetime = datetime(end_times_centiSeconds(ith_data)*0.01,'convertfrom','posixtime','format','yyyy-MM-dd HH:mm:ss.SSS');
            
            time_string = sprintf('%s',time_in_datetime);
            datetime_data_string = fcn_DebugTools_debugPrintStringToNCharacters(time_string,25);
            fprintf(fid,'\t \t %s \t %s \t %s \n',sensor_data_string,posix_data_string,datetime_data_string);
        end
        fprintf(fid,'\n');
    end

    return
else
    return_flag = 0; % Indicate that the return was NOT forced
end

% If get here, there are NO offending sensors!
offending_sensor = '';


end % Ends fcn_INTERNAL_checkConsistencyOfStartEnd


%% fcn_INTERNAL_checkTimeOrdering
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkDataStrictlyIncreasing(fid, dataStructure, flags, field_name, sensors_to_check)
% Checks that a sensor is strictly ascending, usually used for testing Time
% fields.

if ~exist('sensors_to_check','var')
    flag_check_all_sensors = 1;    
else
    flag_check_all_sensors = 0;
end

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
if flag_check_all_sensors
    sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
else
    % Produce a list of all the sensors that meet the search criteria, and grab
    % their data also
    [~,sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, field_name,sensors_to_check);
end

if 0~=fid
    fprintf(fid,'Checking that %s data is strictly ascending',field_name);
    if flag_check_all_sensors
        fprintf(fid,':\n');
    else
        fprintf(fid,' in all %s sensors:\n', sensors_to_check);
    end
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
    flags_data_strictly_ascends= 1;
    % time_diff = diff(sensor_data.(field_name));
    sensor_value = sensor_data.(field_name);
    sensor_value_noNaN = sensor_value(~isnan(sensor_value));

    if ~issorted(sensor_value_noNaN,1,"strictascend")
        flags_data_strictly_ascends = 0;
    end
    
    flag_name = cat(2,field_name,'_strictly_ascends');
    flags.(flag_name) = flags_data_strictly_ascends;

    if 0==flags.(flag_name)
        offending_sensor = sensor_name; % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end    
   
end

end % Ends fcn_INTERNAL_checkTimeOrdering



