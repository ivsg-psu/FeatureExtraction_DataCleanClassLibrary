function [flags,offending_sensor] = fcn_DataClean_checkDataConsistency(dataStructure,varargin)

% fcn_DataClean_checkDataConsistency
% Checks a given dataset to verify whether data meets key requirements. If
% any flags fail, the flag is set to zero and the offending sensor causing
% the failure is returned.
%
% FORMAT:
%
%      [flags,offending_sensor] = fcn_DataClean_checkDataConsistency(dataStructure,(fid),(fig_num))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      (OPTIONAL INPUTS)
%
%      fid: a file ID to print results of analysis. If not entered, the
%      console (FID = 1) is used.
%
% OUTPUTS:
%
%      flags: a data structure containing subfields that define the results
%      of each verification check. These include:
%
%            flags.GPS_time_exists - this is set to 1 if all the sensors
%            have a field called "GPS_Time", which is the core time
%            assigned to the data from each sensor. If the field is
%            missing, exists but is empty, or exists and filled with only
%            NaN values, the flag is set to zero and the function returns.
%
%            flags.centiSeconds_exists - this is set to 1 if all the sensors
%            have a field called "centiSeconds", which is the core time
%            sampling interval for a sensor, in hundreths of a second. If
%            the field is missing, exists but is empty, or exists and
%            filled with only NaN values, the flag is set to zero and the
%            function returns.
%
%            flags.dataTimeIntervalMatchesIntendedSamplingRate - this is
%            set to 1 if the average of the time difference as measured in
%            the GPS_time, multiplied by 100 and rounded to the nearest
%            integer, matches the centiSeconds value. In other words, it is
%            1 if the commanded sample time interval in centiSeconds matches
%            the average observed time sampling interval in the data. If
%            the values do not match, the flag is set to zero and the
%            function returns.
%
%            flags.Trigger_Time_exist - this is set to 1 if all the sensors
%            have a field called "Trigger_Time", which is the expected time
%            assigned to the data from each sensor. If the field is
%            missing, exists but is empty, or exists and filled with only
%            NaN values, the flag is set to zero and the function returns.
%
%            flags.GPS_Time_strictly_ascends - this is set to 1 if GPS_Time
%            is strictly ascending, e.g. increases with no repeated times.
%            If not, the flag is set to zero and the function returns.
%
%            flags.ROS_time_exists - this is set to 1 if all the sensors
%            have a field called "ROS_time", which is the ROS time
%            assigned to the data from each sensor. If the field is
%            missing, exists but is empty, or exists and filled with only
%            NaN values, the flag is set to zero and the function returns.
%
%     offending_sensor: this is the string corresponding to the sensor
%     field in the data structure that caused a flag to become zero. 
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_checkDataConsistency
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_06_12: sbrennan@psu.edu
% -- wrote the code originally 

% TO DO
% 

% Set default fid (file ID) first:
fid = 1; % Default case is to print to the console
flag_do_debug = 1;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if fid~=0
    st = dbstack; %#ok<*UNRCH>
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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

if flag_check_inputs
    % Are there the right number of inputs?
    if nargin < 1 || nargin > 2
        error('Incorrect number of input arguments')
    end
        
end


% Does the user want to specify the fid?

% Check for user input
if 1 <= nargin
    temp = varargin{1};
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

% Time inconsistencies include situations where the time vectors on data
% are fundamentally flawed
%
% Time inconsistencies include:
% ## There are no data collected that have GPS time (UTC time) recorded
% ## At least one GPS sensor is missing GPS time
% ## The centiSeconds field is missing
% ## Inconsistency between expected and actual time sampling for GPS_Time
% ## The Trigger_Time field is missing on a sensor
% ## GPS_Time data is not strictly ascending on a sensor
% ## ROS_Time data is missing on a sensor
% ## Inconsistent sampling for ROS_Time
% ## ROS_Time data is not strictly ascending
% ## ROS_Time data has incorrect total data count
% ## ROS_Time data does not round to correct centiSeconds
%
% The above issues are explained in more detail in the following
% sub-sections

%% There are no data collected that have GPS time (UTC time) recorded
%    ### ISSUES with this:
%    * There is no absolute time base to use for the data
%    * The tracking of vehicle data relative to external sourses is no
%    longer possible
%    ### DETECTION:
%    * Examine if GPS time fields exist on any GPS sensor
%    ### FIXES:
%    * Check if ROS_Time recorded, and is locked to UTC via NTP, use ROS
%    Time as stand-in
%    * Otherwise, complete failure of sensor recordings

%% Check existence of GPS_Time data in ANY sensor
disp('Need to code this');


%% At least one GPS sensor is missing GPS time
%    ### ISSUES with this:
%    * There is no absolute time base to use for the sensor
%    * This usually indicates back lock for the GPS
%    ### DETECTION:
%    * Examine if GPS time fields exist on all GPS sensors
%    ### FIXES:
%    * If another GPS is available, use its time alongside the GPS data
%    * Remove this GPS data field


%% Check existence of GPS_Time data in each sensor
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkFieldExists(fid, dataStructure, flags, 'GPS_Time');
if return_flag
    return
end

%% The centiSeconds field is missing
%    ### ISSUES with this:
%    * This field defines the expected sample rate for each sensor
%    ### DETECTION:
%    * Examine if centiSeconds fields exist on all sensors
%    ### FIXES:
%    * Manually fix, or
%    * Remove this sensor


%% Check existence of centiSeconds data in each sensor
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkFieldExists(fid, dataStructure, flags, 'centiSeconds');
if return_flag
    return
end

%% Inconsistency between expected and actual time sampling for GPS_Time
%    ### ISSUES with this:
%    * This field is used to confirm GPS sampling rates for all
%    GPS-triggered sensors
%    * These sensors are used to correct ROS timings, so if misisng, the
%    timing and thus positioning of vehicle data may be wrong
%    * The GPS unit may be configured wrong
%    * The GPS unit may be faililng or operating incorrectly
%    ### DETECTION:
%    * Examine if centiSeconds calculation of time interval matches GPS
%    time interval for data collection, on average
%    ### FIXES:
%    * Manually fix, or
%    * Remove this sensor

%% Check consistency of expected and actual time sampling for GPS_Time
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkTimeSamplingConsistency(fid, dataStructure, flags,'GPS_Time');
if return_flag
    return
end

%% The Trigger_Time field is missing on a sensor
%    ### ISSUES with this:
%    * This field is used to assign data collection timings for all
%    non-GPS-triggered sensors
%    * These sensors may be configured wrong
%    * These sensors may be faililng or operating incorrectly
%    ### DETECTION:
%    * Examine if Trigger_Time fields exist
%    ### FIXES:
%    * Recalculate Trigger_Time fields as needed, using centiSeconds

%% Check existence of Trigger_Time data in each sensor
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkFieldExists(fid, dataStructure, flags, 'Trigger_Time');
if return_flag
    return
end

% IF NOT, fill it in
% This is from removeTimeGapsFromRawData
%                % Grab the time vector
%                 t = d.(subFieldName);
%                 centiSeconds = d.centiSeconds;
%                 t_interval = t(end,1)-t(1,1);
% 
%                 % Check if the number of samples make sense
%                 num_expected = round(t_interval/(centiSeconds*0.01)) + 1;

%% GPS_Time data is not strictly ascending on a sensor
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

%% Check that GPS_Time data is strictly ascending
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkDataStrictlyIncreasing(fid, dataStructure, flags, 'GPS_Time');
if return_flag
    return
end

%% TO-DO - need to finish documentation - starting HERE

%% Check existence of ROS_Time data in each sensor
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkFieldExists(fid, dataStructure, flags, 'ROS_Time');
if return_flag
    return
end

%% Check consistency of expected and actual time sampling for ROS_Time
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkTimeSamplingConsistency(fid, dataStructure, flags,'ROS_Time');
if return_flag
    return
end

%% Check that ROS_Time data is strictly ascending
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkDataStrictlyIncreasing(fid, dataStructure, flags, 'ROS_Time');
if return_flag
    return
end

%% Check that ROS_Time data has expected count
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkFieldCountMatchesTriggerTime(fid, dataStructure, flags, 'ROS_Time');
if return_flag
    return
end

%% Check that ROS_Time data would round to correct centiSeconds
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkROSTimeRoundsCorrectly(fid, dataStructure, flags, 'ROS_Time');
if return_flag
    return
end

% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____        _           _____                _     _                           _____ _               _        
%  |  __ \      | |         / ____|              (_)   | |                         / ____| |             | |       
%  | |  | | __ _| |_ __ _  | |     ___  _ __  ___ _ ___| |_ ___ _ __   ___ _   _  | |    | |__   ___  ___| | _____ 
%  | |  | |/ _` | __/ _` | | |    / _ \| '_ \/ __| / __| __/ _ \ '_ \ / __| | | | | |    | '_ \ / _ \/ __| |/ / __|
%  | |__| | (_| | || (_| | | |___| (_) | | | \__ \ \__ \ ||  __/ | | | (__| |_| | | |____| | | |  __/ (__|   <\__ \
%  |_____/ \__,_|\__\__,_|  \_____\___/|_| |_|___/_|___/\__\___|_| |_|\___|\__, |  \_____|_| |_|\___|\___|_|\_\___/
%                                                                           __/ |                                  
%                                                                          |___/                                   
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Data%20Consistency%20Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data consistency include situations where individual data fields have
% issues that can affect data quality, which can be detected by checking
% data from one sensor by itself, or with small interactions between
% sensors. For large-scale interactions, see "Data Events" below.
%
% Example data consistency errors include:
% ## Data is missing either entirely or partially
% ## Core data has not loaded - GPS receivers are missing Latitude for
%  example
% ## GPS increments do not exist in ENU
% ## GPS yaw does not exist
% ## Standard deviations on data are unknown
% ## Data has outliers
% ## Angle data is wrapped from 0 to 360, resulting in jumps from 0 to 360
%
% The above issues are explained in more detail in the following
% sub-sections

%% Data is missing either entirely or partially
%    ### ISSUES with this:
%    * This causes readings to be missing, fundamentally corrupting the
%    data
%    * Means of data cannot be calculated correctly if some are missing,
%    resulting in incorrect operations (outlier detection, for example).
%    ### DETECTION:
%    * Examine if all or some of the data has NaN values
%    * Examine if all or some of the data is within expected range
%    ### FIXES:
%    * If only small sets of data are missing, then remove
%    * Once remaining data has been cleaned of outliers, resample
% 

%% Check whether any fields contain NaN
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkDataHasNoNaN(fid, dataStructure, flags);
if return_flag
    return
end


% ## Core data has not loaded - GPS receivers are missing Latitude for
%  example
%    ### ISSUES with this:
%    * The sensors are not usable if missing key data
%    * Sensors may be faulting
%    ### DETECTION:
%    * Examine if key fields exist for all sensors
%    * Examine if data in key fields is within pre-test range
%    ### FIXES:
%    * If a redundant sensor exists, use this, otherwise data collection is
%    failed for this sensor mode
%
% ## GPS increments do not exist in ENU
%  See fcn_DataClean_fillPositionIncrementsFromGPSPosition
%    ### ISSUES with this:
%    * GPS increments are used to detect GPS jumps due to multi-path
%    * Increments are used to calculate orientations of vehicle
%    ### DETECTION:
%    * Examine if key fields exist for increments
%    * Examine if data in key fields is within pre-test range
%    ### FIXES:
%    * Convert data to ENU, recalculate
%
% ## GPS yaw does not exist
% - fcn_DataClean_fillRawYawEstimatesFromGPSPosition
%    ### ISSUES with this:
%    * GPS yaw used to calculate orientations of vehicle
%    ### DETECTION:
%    * Examine if key fields exist for increments
%    * Examine if data in key fields is within pre-test range
%    ### FIXES:
%    * Use increments fields to calculate
%
%% Standard deviations on data are unknown
%    ### ISSUES with this:
%    * Cannot detect outliers without standard deviations
%    * Cannot merge data via Kalman Filters without standard deviations
%    ### DETECTION:
%    * Examine if all or some of the Sigma fields have NaN values
%    ### FIXES:
%    * Assign default sigma values for known sensors
%    * Calculate sigma values if enough data is available for sensor
%

%% Check whether Sigma fields contain NaN
[flags,offending_sensor,return_flag] = fcn_INTERNAL_checkSigmasHaveNoNaN(fid, dataStructure, flags);
if return_flag
    return
end


%% Data has outliers
%    ### ISSUES with this:
%    * This data is incorrect
%    * If outliers are left in the data, they corrupt surrounding data once
%    data is filtered either in time or space (smoothing data with outliers
%    makes data worse)
%    wrong answers
%    ### DETECTION:
%    * Examine whether any data falls well outside mean plus/minus wide
%    standard deviations (for example 5 or more standard deviations)
%    ### FIXES:
%    * Find outliers, and only in locations with outliers, apply median
%    filter outputs to fill in data.



%% Check that no outliers
disp('Need to code this!');
% From loadSigmaValuesFromRawData
% %% fcn_INTERNAL_calcSigmaNoOutliers
% function real_sigma = fcn_INTERNAL_calcSigmaNoOutliers(data)
% % Some of the data may contain NaN values, hence the use of nanmean and
% % nanstd below.
% 
% differences = diff(data);
% deviations = differences - mean(differences,'omitnan');
% outlier_sigma = std(deviations,'omitnan');
% 
% % Reject outliers
% deviations_with_no_outliers = deviations(abs(deviations)<(3*outlier_sigma));
% real_sigma = std(deviations_with_no_outliers,'omitnan');
% 
% %real_sigma_vector = real_sigma*
% end % Ends fcn_INTERNAL_calcSigmaNoOutliers

%% Angle data is wrapped from 0 to 360, resulting in jumps from 0 to 360
%    ### ISSUES with this:
%    * This causes discontinuities in orientation velocities
%    * If left in, and data is smoothed, data may be interpolated between
%    angles slightly above zero and slightly below 360 (which are close to
%    each other in angle domain), and interpolation will give "averaged"
%    results of both, for example data around 180 degrees.
%    wrong answers
%    ### DETECTION:
%    * Examine orientation data to find any that have large jumps (larger
%    than 180 degrees) at any time step
%    ### FIXES:
%    * Calculate change in angles, keeping the initial angle
%    * For changes in angles larger in magnitude than 360, keep remainder
%    after mod operation with 360
%    * Add up all changes, and add back to initial angle
%

%% Check if unwrapped
disp('Need to code this!');
% See cleanGPSData
% function unwrapped_angle = fcn_DataClean_unwrapAngles(wrapped)
% % Sometimes this function is called with NaN values, which will give bad
% % results, so we need to fill these in
% do_debug = 0;
% if 1== do_debug % For debugging
%     figure(3737);
%     clf;
%     hold on;
%     grid minor;
%     plot(wrapped);
% end
% wrapped = fillmissing(wrapped,'previous');
% 
% if 1== do_debug % For debugging
%     figure(3737);
%     plot(wrapped,'r');
% end
% 
% 
% 
% initial_angle = wrapped(1,1); % Grab the first angle
% change_in_angle = [0; diff(wrapped)]; % Use diff to find jumps
% index_jumps = find(change_in_angle>180); % Tag jumps greater than 180
% change_in_angle(index_jumps) = change_in_angle(index_jumps)-360; % Shift these down
% index_jumps = find(change_in_angle<-180); % Tag jumps less than -180
% change_in_angle(index_jumps) = change_in_angle(index_jumps)+360; % Shift these up
% unwrapped_angle = cumsum(change_in_angle) + initial_angle; % Re-add jumps
% 
% % After above process, data may be shifted up or down by multiples of 360,
% % so shift all data back so mean is between zero and 360
% mean_angle = mean(unwrapped_angle);
% good_mean = mod(mean_angle,360);
% shift = mean_angle - good_mean;
% unwrapped_angle = unwrapped_angle - shift;
% return

% Check if data needs to be unwrapped
% see medianFilterFromRawAndSigmaData
%             % Check if the data needs to be unwrapped first
%             if any(strcmp(subFieldName,fields_to_unwrap_angles))
%                 data = fcn_DataClean_unwrapAngles(data);
%             end  
%    

% in cleanGPSData
% CheckKinematicLimits
% 





% 
%                 % Check to see if there are time jumps out of the ordinary
%                 diff_t = diff(t);
%                 mean_dt = mean(diff_t);
%                 std_dt = std(diff_t);
%                 max_dt = mean_dt+5*std_dt;
%                 min_dt = max(0.00001,mean_dt-5*std_dt);
%                 flag_jump_error_detected = 0;
%                 if any(diff_t>max_dt) || any(diff_t<min_dt)
%                     flag_jump_error_detected = 1;
%                 end
%
% AND (retiming data)
%
%                             tolerance = centiSeconds*0.5;
%                             t_diff = (t(i_time)-t(i_time-1))*100;
%                             if t_diff>(centiSeconds+tolerance) || t_diff<(centiSeconds-tolerance)
%                                 flag_delta_errors_detected = 1;
%                                 if flag_detecting_bad_now==0
%                                     i_bad_start = i_time;
%                                     flag_detecting_bad_now = 1;
%                                 end
%                             else



     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   _____        _          ______               _      _____ _               _        
%  |  __ \      | |        |  ____|             | |    / ____| |             | |       
%  | |  | | __ _| |_ __ _  | |____   _____ _ __ | |_  | |    | |__   ___  ___| | _____ 
%  | |  | |/ _` | __/ _` | |  __\ \ / / _ \ '_ \| __| | |    | '_ \ / _ \/ __| |/ / __|
%  | |__| | (_| | || (_| | | |___\ V /  __/ | | | |_  | |____| | | |  __/ (__|   <\__ \
%  |_____/ \__,_|\__\__,_| |______\_/ \___|_| |_|\__|  \_____|_| |_|\___|\___|_|\_\___/
%                                                                                      
%                                                                                      
% http://patorjk.com/software/taag/#p=display&f=Big&t=Data%20Event%20Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data events include situations where combinations of data can detect
% special operational situations that can affect data quality, which can be
% detected by checking data from one sensor to another. 
%
% Example data events include:
% ## Vehicle speed determination
% ## Wheel radius estimation
% ## Stopping the vehicle
% ## Reversing the vehicle
%
% Speeds filled fcn_DataClean_loadRawData_Hemisphere.m
% Check encoder wheel radius calculations - fcn_DataClean_loadRawData_Encoder_RearWheels.m
%
% ## Stopping the vehicle
%    ### ISSUES with this:
%    * This causes divide by zero in slip-based vehicle dynamic models
%    * This causes GPS-based yaw to give wrong answers
%    ### DETECTION:
%    * Examine velocity magnitude calculated from GPS
%    * Examine velocity magnitude calculated from Encoders
%    * If either are below a threshold, the vehicle is considered stop
%    ### FIXES:
%    * Use encoder velocities up to point where encoder noise dominates
%    * Assign velocity to zero, and position unchanging from moment that
%    velocity entered zero. (e.g, use hysteresis)
%
% ## Reversing the vehicle
%    ### ISSUES with this:
%    * This causes yaw angle to point opposite the direction of veh
%    orientation
%    * This causes transform-based calculations of sensor pose to give
%    wrong answers
%    ### DETECTION:
%    * Examine velocity magnitude and direction calculated from GPS
%    * Examine velocity magnitude and calculated from Encoders
%    * If encoders are negative in velocity, the vehicle is reversing
%    ### FIXES:
%    * Change sign on yaw orientations from GPS if in reverse


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____             _         ______               _      _____ _               _        
%  |  __ \           | |       |  ____|             | |    / ____| |             | |       
%  | |__) |___  _   _| |_ ___  | |____   _____ _ __ | |_  | |    | |__   ___  ___| | _____ 
%  |  _  // _ \| | | | __/ _ \ |  __\ \ / / _ \ '_ \| __| | |    | '_ \ / _ \/ __| |/ / __|
%  | | \ \ (_) | |_| | ||  __/ | |___\ V /  __/ | | | |_  | |____| | | |  __/ (__|   <\__ \
%  |_|  \_\___/ \__,_|\__\___| |______\_/ \___|_| |_|\__|  \_____|_| |_|\___|\___|_|\_\___/
%                                                                                          
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Route%20Event%20Checks                                                                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Route events include situations where the route information provides
% clues to data flaws. These can include driver mistakes, geo-located
% areas, etc
%
% Example route events include:
% ## Stop sign areas and intersections
% ## Tunnels and metal bridges
% ## Overpasses
% ## Urban canyons
% ## Leaving the planned data collection route
% ## Highway off-ramps and on-ramps
% ## Starting or ending segments
% ## Workzones


%% Check if vehicle is stopped
% see medianFilter
%             % Check if the data has absolutely zero change
%             if any(strcmp(subFieldName,fields_to_check_diff_not_zero))
%                 good_indices = find(abs(data)>0.000000001); % Set a very low tolerance...
%                 data = fcn_DataClean_replaceBadIndicesWithNearestGood(data,good_indices);
%                 
%             end

%% Check if vehicle is backing up






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
    fprintf(fid,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
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

%% fcn_INTERNAL_checkFieldExists
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkFieldExists(fid, dataStructure, flags, field_name)

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

if 0~=fid
    fprintf(fid,'Checking existence of %s data:\n',field_name);
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end

   
    flag_field_exists= 1;
    if ~isfield(sensor_data,field_name)
        flag_field_exists = 0;
    elseif isempty(sensor_data.(field_name))
        flag_field_exists = 0;
    elseif all(isnan(sensor_data.(field_name)))
        flag_field_exists = 0;
    end

    flag_name = cat(2,field_name,'_exists');
    flags.(flag_name) = flag_field_exists;

    if 0==flags.(flag_name)
        offending_sensor = sensor_name; % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end
end

end % Ends fcn_INTERNAL_checkFieldExists


%% fcn_INTERNAL_checkTimeSamplingConsistency
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkTimeSamplingConsistency(fid, dataStructure, flags, time_field)

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

if 0~=fid
    fprintf(fid,'Checking consistency of expected and actual time sampling rates:\n');
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end

    flags_dataTimeIntervalMatchesIntendedSamplingRate = 1;
    centiSeconds = sensor_data.centiSeconds;
    try
        if centiSeconds ~= round(100*mean(diff(sensor_data.(time_field))))
            flags_dataTimeIntervalMatchesIntendedSamplingRate = 0;
        end
    catch
        disp('stop here');
    end
    
    flag_name = cat(2,time_field,'_has_same_sample_rate_as_centiSeconds');
    flags.(flag_name) = flags_dataTimeIntervalMatchesIntendedSamplingRate;
    
    if 0==flags.(flag_name)
        offending_sensor = sensor_name; % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end
   
end

end % Ends fcn_INTERNAL_checkTimeSamplingConsistency


%% fcn_INTERNAL_checkTimeOrdering
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkDataStrictlyIncreasing(fid, dataStructure, flags, field_name)

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

if 0~=fid
    fprintf(fid,'Checking that %s data is strictly ascending:\n',field_name);
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
    flags_data_strictly_ascends= 1;
    if ~issorted(sensor_data.(field_name),1,"strictascend")
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

%% fcn_INTERNAL_checkROSTimeRoundsCorrectly
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkROSTimeRoundsCorrectly(fid, dataStructure, flags, field_name)

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

if 0~=fid
    fprintf(fid,'Checking that ROS time would round correctly:\n',field_name);
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
    flags_data_rounds_correctly = 1;
    
    % Round ROS_Time    
    ROS_Time_samples = round(sensor_data.ROS_Time*100/sensor_data.centiSeconds);
    
    % Shift it to 1, 2, etc.
    ROS_Time_samples_shifted = ROS_Time_samples - ROS_Time_samples(1) + 1;
    
    % Shift the Trigger time similarly
    Trigger_Time_samples = round(sensor_data.Trigger_Time*100/sensor_data.centiSeconds);
    
    % Shift it to 1, 2, etc.
    Trigger_Time_samples_shifted = Trigger_Time_samples - Trigger_Time_samples(1) + 1;
    
    % Make sure it counts strictly up
    if ~isequal(ROS_Time_samples_shifted,Trigger_Time_samples_shifted)
        flags_data_rounds_correctly = 0;
    end
        
    %flag_name = cat(2,field_name,'_strictly_ascends');
    flag_name = 'ROS_Time_correct_length';
    flags.(flag_name) = flags_data_rounds_correctly;

    if 0==flags.(flag_name)
        offending_sensor = sensor_name; % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end    
   
end

end % Ends fcn_INTERNAL_checkROSTimeRoundsCorrectly


% 
%                 % Check to see if there are time jumps out of the ordinary
%                 diff_t = diff(t);
%                 mean_dt = mean(diff_t);
%                 std_dt = std(diff_t);
%                 max_dt = mean_dt+5*std_dt;
%                 min_dt = max(0.00001,mean_dt-5*std_dt);
%                 flag_jump_error_detected = 0;
%                 if any(diff_t>max_dt) || any(diff_t<min_dt)
%                     flag_jump_error_detected = 1;
%                 end
%
% AND (retiming data)
%
%                             tolerance = centiSeconds*0.5;
%                             t_diff = (t(i_time)-t(i_time-1))*100;
%                             if t_diff>(centiSeconds+tolerance) || t_diff<(centiSeconds-tolerance)
%                                 flag_delta_errors_detected = 1;
%                                 if flag_detecting_bad_now==0
%                                     i_bad_start = i_time;
%                                     flag_detecting_bad_now = 1;
%                                 end
%                             else



%% fcn_INTERNAL_checkFieldCountMatchesGPSTime
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkFieldCountMatchesTriggerTime(fid, dataStructure, flags, field_name)


% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

if 0~=fid
    fprintf(fid,'Checking that %s field has same number of data points as Trigger_Time:\n',field_name);
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
        
    flags_sensor_field_has_correct_length = 1;
    
    % Grab all the subfields
    subfieldNames = fieldnames(sensor_data);
    
    % Loop through subfields
    for i_subField = 1:length(subfieldNames)
        % Grab the name of the ith subfield
        subFieldName = subfieldNames{i_subField};
        if strcmp(subFieldName,field_name)
            
            if 0~=fid
                fprintf(fid,'\t\t Checking subfield: %s\n ',subFieldName);
            end
            
            % Check to see if this subField has column length equal to the
            % Target_Time vector
            if length(sensor_data.(subFieldName)(:,1))~=length(sensor_data.Trigger_Time(:,1))
                flags_sensor_field_has_correct_length = 0;
                break;
            end  % Ends if to check if the field is a cell
        end % Ends if to check if field is a "Sigma" field
        
    end % Ends for loop through the subfields
    
    
    
    % flag_name = cat(2,field_name,'_strictly_ascends');
    flag_name = cat(2,field_name,'_has_correct_length');
    flags.(flag_name) = flags_sensor_field_has_correct_length;

    if 0==flags.(flag_name)
        offending_sensor = sensor_name; % cat(2,sensor_name, ' ' ,subFieldName); % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end    
   
end

end % Ends fcn_INTERNAL_checkFieldCountMatchesGPSTime



%% fcn_INTERNAL_checkSigmasHaveNoNaN
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkSigmasHaveNoNaN(fid, dataStructure, flags)

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

if 0~=fid
    fprintf(fid,'Checking that sigma fields have no NaN values:\n');
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
        
    flags_sensor_fields_have_no_NaN = 1;
    
    % Grab all the subfields
    subfieldNames = fieldnames(sensor_data);
    
    % Loop through subfields
    for i_subField = 1:length(subfieldNames)
        % Grab the name of the ith subfield
        subFieldName = subfieldNames{i_subField};
        if contains(subFieldName,'Sigma')
            
            if 0~=fid
                fprintf(fid,'\t\t Checking subfield: %s\n ',subFieldName);
            end
            
            % Check to see if this subField has any NaN
            if ~iscell(sensor_data.(subFieldName))
                if any(isnan(sensor_data.(subFieldName)))
                    flags_sensor_fields_have_no_NaN = 0;
                    break;
                end % Ends the if statement to check if subfield is on list
            end  % Ends if to check if the field is a cell
        end % Ends if to check if field is a "Sigma" field
        
    end % Ends for loop through the subfields
    
    
    
    % flag_name = cat(2,field_name,'_strictly_ascends');
    flag_name = 'sensor_fields_have_no_NaN';
    flags.(flag_name) = flags_sensor_fields_have_no_NaN;

    if 0==flags.(flag_name)
        offending_sensor = cat(2,sensor_name, ' ' ,subFieldName); % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end    
   
end

end % Ends fcn_INTERNAL_checkSigmasHaveNoNaN


%% fcn_INTERNAL_checkDataHasNoNaN
function [flags,offending_sensor,return_flag] = fcn_INTERNAL_checkDataHasNoNaN(fid, dataStructure, flags)

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

if 0~=fid
    fprintf(fid,'Checking that data has no NaN within fields:\n');
end

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
        
    flags_sensor_fields_have_no_NaN = 1;
    
    % Grab all the subfields
    subfieldNames = fieldnames(sensor_data);
    
    % Loop through subfields
    for i_subField = 1:length(subfieldNames)
        % Grab the name of the ith subfield
        subFieldName = subfieldNames{i_subField};
        
        if 0~=fid
            fprintf(fid,'\t\t Checking subfield: %s\n ',subFieldName);
        end
        
        % Check to see if this subField has any NaN
        if ~iscell(sensor_data.(subFieldName))
            if any(isnan(sensor_data.(subFieldName)))
                flags_sensor_fields_have_no_NaN = 0; 
                break;
            end % Ends the if statement to check if subfield is on list
        end  % Ends if to check if the fiel is a call
    end % Ends for loop through the subfields
    
    
    
    % flag_name = cat(2,field_name,'_strictly_ascends');
    flag_name = 'sensor_fields_have_no_NaN';
    flags.(flag_name) = flags_sensor_fields_have_no_NaN;

    if 0==flags.(flag_name)
        offending_sensor = cat(2,sensor_name, ' ' ,subFieldName); % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end    
   
end

end % Ends fcn_INTERNAL_checkDataHasNoNaN


