function [flags,offending_sensor,sensors_without_Trigger_Time] = fcn_DataClean_checkDataTimeConsistency(dataStructure, varargin)

% fcn_DataClean_checkDataTimeConsistency
% Checks a given dataset to verify whether data meets key time consistency
% requirements. 
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
%      [flags,offending_sensor] = fcn_DataClean_checkDataTimeConsistency(dataStructure, (fid), (fig_num))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      (OPTIONAL INPUTS)
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
% # Trigger_Time tests include:
%     ## Trigger_Time_exists_in_all_GPS_sensors
%     ## all_sensors_have_trigger_time
% 
% # ROS_Time tests include:GPS
%     ## ROS_Time_exists_in_all_GPS_sensors
%     ## ROS_Time_scaled_correctly_as_seconds
%     ## ROS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
%     ## ROS_Time_strictly_ascends
%     ## ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors
%     ## ROS_Time_rounds_correctly_to_Trigger_Time_in_GPS_sensors
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
%     See the script: script_test_fcn_DataClean_checkDataTimeConsistency
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_06_12: sbrennan@psu.edu
% -- wrote the code originally 
% 2023_06_24 - sbrennan@psu.edu
% -- added fcn_INTERNAL_checkIfFieldInAnySensor and test case in script
% 2023_06_30 - sbrennan@psu.edu
% -- fixed verbose mode bug
% 2023_07_02 - sbrennan@psu.edu
% -- fixed bug when GPS_Time and ROS_Time are different lengths
% 2023_07_03 - sbrennan@psu.edu
% -- added diff check on time
% 2024_09_27: sbrennan@psu.edu
% -- updated top comments
% -- added debug flag area
% -- fixed fid printing error
% -- added fig_num input, fixed the plot flag
% -- fixed warning and errors
% 2024_09_27: xfc5113@psu.edu
% -- move fcn_DataClean_checkAllSensorsHaveTriggerTime in the function
% -- add sensors_without_Trigger_Time as the output of the function

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
        narginchk(1,3);
    end
end

% Does the user want to specify the fid?
fid = 0;
% Check for user input
if 2 <= nargin
    temp = varargin{1};
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
if (0==flag_max_speed) &&  (3<=nargin)
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

[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency_GPS(dataStructure, flags, fid);

% Do any of these produce an exit condition?
fieldList = fieldnames(flags);
for ith_field = 1:length(fieldList)
    if 0==flags.(fieldList{ith_field})
        return
    end
end




%% Trigger_Time Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   _______   _                                  _______ _                   _______        _       
%  |__   __| (_)                                |__   __(_)                 |__   __|      | |      
%     | |_ __ _  __ _  __ _  ___ _ __              | |   _ _ __ ___   ___      | | ___  ___| |_ ___ 
%     | | '__| |/ _` |/ _` |/ _ \ '__|             | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
%     | | |  | | (_| | (_| |  __/ |                | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
%     |_|_|  |_|\__, |\__, |\___|_|                |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
%                __/ | __/ |            ______                                                      
%               |___/ |___/            |______|                                                     
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Trigger%20_%20Time%20%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if Trigger_Time_exists_in_all_GPS_sensors            
%    ### ISSUES with this:
%    * This field is used to assign data collection timings for all
%    non-GPS-triggered sensors, and to fill in GPS_Time data if there's a
%    short outage
%    * These sensors may be configured wrong
%    * These sensors may be faililng or operating incorrectly
%    ### DETECTION:
%    * Examine if Trigger_Time fields exist
%    ### FIXES:
%    * Recalculate Trigger_Time fields as needed, using centiSeconds

[flags,offending_sensor,~] = fcn_DataClean_checkIfFieldInSensors(dataStructure,'Trigger_Time',flags,'all','GPS',fid);
if 0==flags.Trigger_Time_exists_in_all_GPS_sensors
    warning('on','backtrace');
    warning('Trigger time does not exist in GPS sensors')
    return
end

%% ROS_Time Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   _____   ____   _____            _______ _                   _______        _       
%  |  __ \ / __ \ / ____|          |__   __(_)                 |__   __|      | |      
%  | |__) | |  | | (___               | |   _ _ __ ___   ___      | | ___  ___| |_ ___ 
%  |  _  /| |  | |\___ \              | |  | | '_ ` _ \ / _ \     | |/ _ \/ __| __/ __|
%  | | \ \| |__| |____) |             | |  | | | | | | |  __/     | |  __/\__ \ |_\__ \
%  |_|  \_\\____/|_____/              |_|  |_|_| |_| |_|\___|     |_|\___||___/\__|___/
%                          ______                                                      
%                         |______|                                                     
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=ROS%20_%20Time%20%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if ROS_Time_exists_in_all_GPS_sensors
%    ### ISSUES with this:
%    * If the sensor is recording data, all data is time-stamped to ROS
%    time
%    * The ROS time is aligned with GPS time for sensors that do not have
%    GPS timebase, and if it is missing, then we cannot use the sensor
%    ### DETECTION:
%    * Examine if ROS_Time fields exist on all sensors
%    ### FIXES:
%    * Catastrophic error. Sensor has failed and should be removed.

[flags,offending_sensor,~] = fcn_DataClean_checkIfFieldInSensors(dataStructure,'ROS_Time',flags,'all','GPS',fid);
if 0==flags.ROS_Time_exists_in_all_GPS_sensors
    return
end

%% Check if ROS_Time_scaled_correctly_as_seconds
%    ### ISSUES with this:
%    * ROS records time in posix nanoseconds, whereas GPS units records in
%    posix seconds
%    * If ROS data is saved in nanoseconds, it causes large scaling
%    problems and incorrect calculation of sampling time (see next check)
%    ### DETECTION:
%    * Examine if any ROS_Time data is more than 10^8 larger than the
%    largest GPS_Time data
%    ### FIXES:
%    * Divide ROS_Time on this sensor by 10^9, confirm that this fixes the
%    problem

[flags,offending_sensor,~] = fcn_INTERNAL_checkIfROSTimeMisScaled(fid, dataStructure, flags);
if 0==flags.ROS_Time_scaled_correctly_as_seconds
    return
end

%% Check if ROS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
%    ### ISSUES with this:
%    * The ROS time and GPS time should both have approximately the same
%    sampling rates, and we use this alignment to calibrate ROS time to GPS
%    time absolutely.
%    * If they do not agree, then either the GPS or the ROS master are
%    giving wrong data
%    ### DETECTION:
%    * Examine if centiSeconds calculation of time interval matches ROS
%    time interval for data collection, on average
%    ### FIXES:
%    * Manually fix, or
%    * Remove this sensor

fig_num = 98765432;
[flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(dataStructure,'ROS_Time',flags, 'GPS',fid, fig_num);
if 0==flags.ROS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
    return
end


%% Check if ROS_Time_strictly_ascends
%    ### ISSUES with this:
%    * This field is used to calibrate ROS to GPS time via interpolation, and must
%    be STRICTLY increasing for the interpolation function to work
%    * If data packets arrive out-of-order with this sensor, times may not
%    be in an increasing sequence
%    * If the ROS topic is glitching, its time may be temporarily incorrect
%    ### DETECTION:
%    * Examine if time data from sensor is STRICTLY increasing
%    ### FIXES:
%    * Remove and interpolate time field if not strictkly increasing
%    * Re-order data, if minor ordering error

[flags,offending_sensor,~] = fcn_INTERNAL_checkDataStrictlyIncreasing(fid, dataStructure, flags, 'ROS_Time');
if 0==flags.ROS_Time_strictly_ascends
    return
end

%% Check if ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors
%    ### ISSUES with this:
%    * The Trigger_Time represents, for many sensors, when they were
%    commanded to collect data. If the number of data in the ROS time list
%    does not match the Trigger_Time length, then this indicates that there
%    are sensor failures
%    ### DETECTION:
%    * Count the number of data in Trigger_Time, and compare it with
%    ROS_Time - these should match
%    ### FIXES:
%    * Remove and interpolate time field if not strictly increasing

[flags,offending_sensor,~]  = fcn_DataClean_checkFieldCountMatchesTimeCount(dataStructure,'ROS_Time',flags,'Trigger_Time','GPS',fid);
if 0==flags.ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors
    return
end

%% Check if ROS_Time_rounds_correctly_to_Trigger_Time

% error('NOT FINISHED')
% Check that the ROS Time, when rounded to the nearest sampling interval,
% matches the Trigger time.
%    ### ISSUES with this:
%    * The data on some sensors are triggered, inlcuding the GPS sensors
%    which are self-triggered
%    * If the rounding does not work, this indicates a problem in the ROS
%    master
%    ### DETECTION:
%    * Round the ROS Time and compare to the Trigger_Times
%    ### FIXES:
%    * Remove and interpolate time field if not strictly increasing

[flags,offending_sensor,~] = fcn_DataClean_checkTimeRoundsCorrectly(dataStructure, 'ROS_Time',flags,'Trigger_Time','GPS',fid);
if 0==flags.ROS_Time_rounds_correctly_to_Trigger_Time_in_GPS_sensors
    warning('on','backtrace');
    warning('ROS_Time need to be rounded to Trigger_Time in all GPS sensors')
    return
else
    disp("ROS_Time is rounded correctly")
end

%% Check all_sensors_have_trigger_time
% Do all sensors have Trigger Time, not just GPS sensors
% Check that the ROS Time, when rounded to the nearest sampling interval,
% matches the Trigger time.
%    ### ISSUES with this:
%    * The data on some sensors are triggered, inlcuding the GPS sensors
%    which are self-triggered
%    * If the rounding does not work, this indicates a problem in the ROS
%    master
%    ### DETECTION:
%    * Round the ROS Time and compare to the Trigger_Times
%    ### FIXES:
%    * Remove and interpolate time field if not strictly increasing
% error('stop here');
[flags,sensors_without_Trigger_Time] = fcn_DataClean_checkAllSensorsHaveTriggerTime(dataStructure,flags,fid);
if 0==flags.all_sensors_have_trigger_time
    warning('on','backtrace');
    warning('Not all sensors have Trigger Time')
    return
else
    disp("All sensors have Trigger Time")
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


%% fcn_INTERNAL_checkIfROSTimeMisScaled
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkIfROSTimeMisScaled(fid, dataStructure, flags)
% Checks to see if the ROS_Time fields are wrongly scaled

% Initialize offending_sensor
offending_sensor = '';

% Produce a list of all the sensors (each is a field in the structure)
[~,sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS');

if 0~=fid
    fprintf(fid,'Checking if ROS time is measured in seconds, not nanoseconds, across GPS sensors:\n');
end

flags_data_good = ones(length(sensor_names),1);

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
    
    GPS_Time = sensor_data.GPS_Time;
    ROS_Time = sensor_data.ROS_Time;

    length_to_use = length(GPS_Time(:,1));
    if length(GPS_Time(:,1)) ~= length(ROS_Time(:,1))
        warning('on','backtrace');
        warning('Dissimilar ROS and GPS time lengths detected. This indicates a major sensor error.');
        if length(GPS_Time(:,1))>length(ROS_Time(:,1))
            length_to_use = length(ROS_Time(:,1));
        end        
    end
    mean_ratio = mean(ROS_Time(1:length_to_use,1)./GPS_Time(1:length_to_use,1));
    
    if (0.95*1E9)<mean_ratio && mean_ratio<(1.05*1E9)
        flags_data_good(i_data,1) = 0;
        offending_sensor = sensor_name;
    elseif 0.95 > mean_ratio || mean_ratio>1.05
        warning('on','backtrace');
        warning('Bad ratio detected.')
        error('Strange ratio detected between ROS Time and GPS Time');
    end            
end

if all(flags_data_good==0)
    flags.ROS_Time_scaled_correctly_as_seconds = 0;
elseif any(flags_data_good==0)
    warning('on','backtrace');
    warning('Some GPS sensors appear to be scaled incorrectly where ROS_Time is not in seconds. This indicates a data loading error.');
    flags.ROS_Time_scaled_correctly_as_seconds = 0;
else
    flags.ROS_Time_scaled_correctly_as_seconds = 1;
end
    
if 0==flags.ROS_Time_scaled_correctly_as_seconds
    return_flag = 1; % Indicate that the return was forced
    return
else
    return_flag = 0; % Indicate that the return was NOT forced
end

% If get here, there are NO offending sensors!
offending_sensor = '';


end % Ends fcn_INTERNAL_checkIfROSTimeMisScaled
