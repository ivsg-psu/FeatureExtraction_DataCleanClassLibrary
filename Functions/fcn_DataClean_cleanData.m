function [cleanDataStruct, subPathStrings]  = fcn_DataClean_cleanData(rawDataStruct, varargin)
% fcn_DataClean_cleanData
% given a raw data structure, cleans time jumps and outliers from the data
%
% FORMAT:
%
%      cleanDataStruct = fcn_DataClean_cleanData(rawDataStruct, (ref_baseStationLLA), (fid), (Flags), (fig_num))
%
% INPUTS:
%
%      rawDataStruct: a  data structure containing data fields filled for each
%      ROS topic. If multiple bag files are specified, a cell array of data
%      structures is returned.
%
%      (OPTIONAL INPUTS)
%
%      ref_baseStationLLA: the [Latitude Longitude Altitude] of the
%      reference base station to use. If empty, then the test track origin
%      is used: ref_baseStationLLA = [40.86368573 -77.83592832 344.189]
%
%      fid: the fileID where to print. Default is 1, to print results to
%      the console.
%
%      Flags: a structure containing key flags to set the process. The
%      defaults, and explanation of each, are below:
%
%           Flags.flag_do_load_sick = 0; % Loads the SICK LIDAR data
%           Flags.flag_do_load_velodyne = 0; % Loads the Velodyne LIDAR
%           Flags.flag_do_load_cameras = 0; % Loads camera images
%           Flags.flag_select_scan_duration = 0; % Lets user specify scans from Velodyne
%           Flags.flag_do_load_GST = 0; % Loads the GST field from Sparkfun GPS Units          
%           Flags.flag_do_load_VTG = 0; % Loads the VTG field from Sparkfun GPS Units
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      cleanDataStruct: a  data structure containing data fields filled for
%      each ROS topic, in cleaned form.
%
%     subPathStrings: a string for each rawData load indicating the subpath
%     where the data was obtained
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%      fcn_DataClean_mergeSensorsByMethod
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_cleanData
%     for a full test suite.
%
% This function was written on 2024_09_09 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history
% 2024_09_09 by S. Brennan
% -- wrote the code originally pulling it out of the main script
% 2024_09_23 by X. Cao
% -- add fcn_DataClean_trimDataToCommonStartEndTriggerTimes to the while
% loop
% 2024_09_23 - S. Brennan
% -- removed environment variable setting within function (not good
% practice)
% 2024_09_27 - X. Cao
% -- move fcn_DataClean_checkAllSensorsHaveTriggerTime into fcn_DataClean_checkDataTimeConsistency
% -- add a step to temporary remove Identifiers from rawDataStruct before
% the while loop and fill it back later
% 2024_11_05 - S. Brennan
% -- removed name cleaning code and moved to a different function
% 2024_11_30 - X. Cao
% -- added a ROS_Time checking section for Velodyne LiDAR after time
% checked for GPS units, recalculate ROS_Time for Velodyne LiDAR if needed.


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==5 && isequal(varargin{end},-1))
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

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(1,5);

    end
end

% Does user want to specify ref_baseStationLLA?
ref_baseStationLLA = [40.86368573 -77.83592832 344.189]; %#ok<NASGU>
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        ref_baseStationLLA = temp; %#ok<NASGU>
    end
end

% Does user want to specify fid?
fid = 1;
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        fid = temp;
    end
end


% Does user specify Flags?
% Set defaults
Flags.flag_do_load_SICK = 0;
Flags.flag_do_load_Velodyne = 0;
Flags.flag_do_load_cameras = 0;
Flags.flag_select_scan_duration = 0;
Flags.flag_do_load_GST = 0;
Flags.flag_do_load_VTG = 0;

if 4 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        Flags = temp; %#ok<NASGU>
        
    end
end


% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (5<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp;
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


%% Define the stitching points based on the site's start and end locations
% This section takes a user-given start and end location for a site, and
% identifies which data sets 

%% Fill in test cases?
% Fill in the initial data - we use this for testing
% dataStructure = fcn_DataClean_fillTestDataStructure;

%% Start the looping process to iteratively clean data
% The method used below is as follows:
% -- The data is initialized before the loop by loading (see above)
% -- The loop is started, and for each version of the loop, the data is
%    checked to see if there are any errors measured in the data.
% -- For each error type, a flag is set that is used to initiate a process
%    that seeks to remove that type of error.
% 
% For example: say the data has wrap-around error on yaw angle due to angle
% roll-over. This is checked and reported, and a function is called if this
% is detected to fix that error.

flag_stay_in_main_loop = 1;
N_max_loops = 30;

% Preallocate the data array
debugging_data_structure_sequence{N_max_loops} = struct;

main_data_clean_loop_iteration_number = 0; % The first iteration corresponds to the raw data loading
currentDataStructure = rawDataStruct;
% Grab the Indentifiers field from the rawDataStructure
Identifiers_Hold = rawDataStruct.Identifiers;

%%
while 1==flag_stay_in_main_loop   
    %% Keep data thus far
    main_data_clean_loop_iteration_number = main_data_clean_loop_iteration_number+1;
    debugging_data_structure_sequence{main_data_clean_loop_iteration_number} = currentDataStructure;

    fprintf(1,'\n\nTime Cleaning Iteration #%.0d\n',main_data_clean_loop_iteration_number);

    %% Remove Identifiers, temporarily
    if isfield(currentDataStructure, 'Identifiers')
        nextDataStructure = rmfield(currentDataStructure,'Identifiers');
    else
        nextDataStructure = currentDataStructure;
    end
    
    
    %% Data cleaning processes to fix the latest error start here
    flag_keep_checking = 1; % Flag to keep checking (1), or to indicate a data correction is done and checking should stop (0)
    
  
    %% GPS_Time tests - all of these steps can be found in fcn_DataClean_checkDataTimeConsistency, the following sections need to be deleted later
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
   
    
    %% Check data for errors in Time data related to GPS-enabled sensors -- Done
    % Fills in the following
    %                   GPS_Time_exists_in_at_least_one_GPS_sensor: 1
    %                           GPS_Time_exists_in_all_GPS_sensors: 1
    %                       centiSeconds_exists_in_all_GPS_sensors: 1
    %                       GPS_Time_has_no_repeats_in_GPS_sensors: 1
    %      GPS_Time_sample_modes_match_centiSeconds_in_GPS_sensors: 1
    %           GPS_Time_has_consistent_start_end_within_5_seconds: 1
    %         GPS_Time_has_consistent_start_end_across_GPS_sensors: 1
    %                     GPS_Time_strictly_ascends_in_GPS_sensors: 1
    %            GPS_Time_has_no_sampling_jumps_in_any_GPS_sensors: 1

    % Used to create test data
    if 1==0
        fullExampleFilePath = fullfile(cd,'Data','ExampleData_checkDataTimeConsistency.mat');
        dataStructure = nextDataStructure;
        save(fullExampleFilePath,'dataStructure');
    end

    if (1==flag_keep_checking)
        [time_flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(nextDataStructure,fid);
    end
    
    fcn_INTERNAL_reportFlagStatus(time_flags,'TIMING FLAGS');

    %% Check if GPS_Time_exists_in_at_least_one_GPS_sensor
    %    ### ISSUES with this:
    %    * There is no absolute time base to use for the data
    %    * The tracking of vehicle data relative to external sourses is no
    %    longer possible
    %    ### DETECTION:
    %    * Examine if GPS time fields exist on any GPS sensor
    %    ### FIXES:
    %    * Catastrophic error. Data collection should end.
    %    * One option? Check if ROS_Time recorded, and is locked to UTC via NTP, use ROS
    %    Time as stand-in
    %    * Otherwise, complete failure of sensor recordings
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_exists_in_at_least_one_GPS_sensor)
        warning('on','backtrace');
        warning('Fundamental error on GPS_time: no sensors detected that have GPS time!?');
        error('Catastrophic data error detected: no GPS_Time data detected in any sensor.');
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
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_exists_in_all_GPS_sensors)
        warning('on','backtrace');
        warning('Fundamental error on GPS_time: a GPS sensor is missing GPS time!?');
        error('Catastrophic data error detected: the following GPS sensor is missing GPS_Time data: %s.',offending_sensor);        
    end
    
    %% Check if centiSeconds_exists_in_all_GPS_sensors
    %    ### ISSUES with this:
    %    * This field defines the expected sample rate for each sensor
    %    ### DETECTION:
    %    * Examine if centiSeconds fields exist on all sensors
    %    ### FIXES:
    %    * Manually fix, or
    %    * Remove this sensor
    
    if (1==flag_keep_checking) && (0==time_flags.centiSeconds_exists_in_all_GPS_sensors)
        disp(nextDataStructure.(offending_sensor))
        warning('on','backtrace');
        warning('Fundamental error on GPS_time: a GPS sensor is missing centiSeconds!?');
        error('Catastrophic data error detected: the following GPS sensor is missing centiSeconds: %s.',offending_sensor);                
    end
    


    %% Check if GPS_Time_has_no_repeats_in_GPS_sensors
    %    ### ISSUES with this:
    %    * If there are many repeated time values, the calculation of sampling
    %    time in the future steps produces incorrect results
    %    ### DETECTION:
    %    * Examine if time values are unique
    %    ### FIXES:
    %    * Remove repeats

    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_has_no_repeats_in_GPS_sensors)
        % Fix the data
        field_name = 'GPS_Time';
        sensors_to_check = 'GPS';
        nextDataStructure = fcn_DataClean_trimRepeatsFromField(nextDataStructure,fid, field_name,sensors_to_check);
        flag_keep_checking = 0;
    end



    %% Check if GPS_Time_sample_modes_match_centiSeconds_in_GPS_sensors
    %    ### ISSUES with this:
    %    * This field is used to confirm GPS sampling rates for all
    %    GPS-triggered sensors
    %    * These sensors are used to correct ROS timings, so if misisng, the
    %    timing and thus positioning of vehicle data may be wrong
    %    * The GPS unit may be configured wrong
    %    * The GPS unit may be faililng or operating incorrectly
    %    ### DETECTION:
    %    * Make sure centiSeconds exists in all GPS sensors
    %    * Examine if centiSeconds calculation of time interval matches GPS
    %    time interval for data collection, on average
    %    ### FIXES:
    %    * Manually fix, or
    %    * Remove this sensor
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_sample_modes_match_centiSeconds_in_GPS_sensors)
        warning('on','backtrace');
        warning('A GPS sensor has a sampling rate different than expected by centiSeconds!?');
        error('Inconsistent data detected: the following GPS sensor has an average sampling rate different than predicted from centiSeconds: %s.',offending_sensor);                
    end
    
    
    %% Check if GPS_Time_has_consistent_start_end_within_5_seconds
    %    ### ISSUES with this:
    %    * The start times of all sensors in general should be the same,
    %    within a few seconds, as this is the boot-up time for sensors
    %    * If the times are severely wrong, this can indicate that the
    %    sensors are giving bad data
    %    * As an example, on 2023_06_22, a new GPS antenna installed on the
    %    mapping van produced time that was not UTC, but EST, resulting in
    %    a 4-hour difference in start times
    %    ### DETECTION:
    %    * Seach through the GPS time fields for all sensors, rounding them to
    %    their appropriate centi-second values
    %    * Check that they all agree within 5 seconds
    %    ### FIXES:
    %    * Use GPS sensors to "vote" on actual start time. For outliers,
    %    try different time shifts to minimize error. If error is reduced
    %    to less than 5 seconds, then the fix worked. Otherwise, throw an
    %    error.
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_has_consistent_start_end_within_5_seconds)
        nextDataStructure = fcn_DataClean_correctTimeZoneErrorsInGPSTime(nextDataStructure,fid);
        flag_keep_checking = 0;
    end
    
    %% Check if GPS_Time_has_consistent_start_end_across_GPS_sensors
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

    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_has_consistent_start_end_across_GPS_sensors)
        field_name = 'GPS_Time';
        sensors_to_check = 'GPS';
        fill_type = 1;
        nextDataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(nextDataStructure, (field_name), (sensors_to_check), (fill_type), (fid));
        flag_keep_checking = 0;
    end

    %% Check if GPS_Time_strictly_ascends_in_GPS_sensors
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
    
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_strictly_ascends_in_GPS_sensors)
        field_name = 'GPS_Time';
        sensors_to_check = 'GPS';
        fid = 1;
        nextDataStructure = fcn_DataClean_sortSensorDataByGPSTime(nextDataStructure, field_name,sensors_to_check,fid);               
        flag_keep_checking = 0;
    end


    %% Check if GPS_Time_has_no_sampling_jumps_in_any_GPS_sensors
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

    % Used to create test data
    if 1==0
        fullExampleFilePath = fullfile(cd,'Data','ExampleData_fillMissingsInGPSUnits.mat');
        dataStructure = nextDataStructure;
        save(fullExampleFilePath,'dataStructure');
    end

    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_has_no_sampling_jumps_in_any_GPS_sensors)
        nextDataStructure = fcn_DataClean_fillMissingsInGPSUnits(nextDataStructure, fid);
        flag_keep_checking = 0;
    end
    
    % %% Check if GPS_Time_has_no_missing_sample_differences_in_any_GPS_sensors
    % %    ### ISSUES with this:
    % %    * The GPS_Time may have small jumps which could occur if the sensor
    % %    pauses for a moment, then restarts
    % %    * If these jumps are large, the data from the sensor may be corrupted
    % %    ### DETECTION:
    % %    * Examine if the differences in GPS_Time are out of ordinary by
    % %    looking at the standard deviations of the differences relative to the
    % %    mean differences
    % %    ### FIXES:
    % %    * Interpolate time field if only a small segment is missing        
    % 
    if (1==flag_keep_checking) && (0==time_flags.GPS_Time_has_no_missing_sample_differences_in_any_GPS_sensors)
        nextDataStructure = fcn_DataClean_fillMissingsInGPSUnits(nextDataStructure, fid);
        flag_keep_checking = 0;    
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

    warning('on','backtrace');
    warning('time_flags.Trigger_Time_exists_in_all_GPS_sensors is not working --- skipping');

    if (1==flag_keep_checking) && (0==time_flags.Trigger_Time_exists_in_all_GPS_sensors)
        nextDataStructure = fcn_DataClean_recalculateTriggerTimes(nextDataStructure,'gps',fid);
        flag_keep_checking = 0;
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
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_exists_in_all_GPS_sensors)
        warning('on','backtrace');
        warning('Fundamental error on ROS_time: a GPS sensor was found that has no ROS time!?');
        error('Catastrophic failure in one of the sensors in that it is missing ROS time. Stopping.');
    end
    
    %% Check if ROS_Time_scaled_correctly_as_seconds
    %    ### ISSUES with this:
    %    * ROS records time in posix nanoseconds, whereas GPS units records in
    %    posix seconds
    %    * If ROS data is saved in nanoseconds, it causes large scaling
    %    problems.
    %    ### DETECTION:
    %    * Examine if any ROS_Time data is more than 10^8 larger than the
    %    largest GPS_Time data
    %    ### FIXES:
    %    * Divide ROS_Time on this sensor by 10^9, confirm that this fixes the
    %    problem
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_scaled_correctly_as_seconds)
        nextDataStructure = fcn_DataClean_convertROSTimeToSeconds(nextDataStructure,'',fid);              
        flag_keep_checking = 0;
    end
    
    %% Check if ROS_Time_sample_modes_match_centiSeconds_in_GPS_sensors
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
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_sample_modes_match_centiSeconds_in_GPS_sensors)
        warning('on','backtrace');
        warning('Fundamental error on ROS_time: a GPS sensor was found that has a ROS time sample rate different than the GPS sample rate!?');
        error('ROS time is mis-sampled.\');            
        flag_keep_checking = 0;
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
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_strictly_ascends)
        warning('on','backtrace');
        warning('Fundamental error on ROS_time: it is not counting up!?');
        error('ROS time is not strictly ascending.');
        flag_keep_checking = 0;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    _____      _ _ _               _           _____   ____   _____            _______ _                     _             _____ _____   _____            _______ _
    %   / ____|    | (_) |             | |         |  __ \ / __ \ / ____|          |__   __(_)                   | |           / ____|  __ \ / ____|          |__   __(_)
    %  | |     __ _| |_| |__  _ __ __ _| |_ ___    | |__) | |  | | (___               | |   _ _ __ ___   ___     | |_ ___     | |  __| |__) | (___               | |   _ _ __ ___   ___
    %  | |    / _` | | | '_ \| '__/ _` | __/ _ \   |  _  /| |  | |\___ \              | |  | | '_ ` _ \ / _ \    | __/ _ \    | | |_ |  ___/ \___ \              | |  | | '_ ` _ \ / _ \
    %  | |___| (_| | | | |_) | | | (_| | ||  __/   | | \ \| |__| |____) |             | |  | | | | | | |  __/    | || (_) |   | |__| | |     ____) |             | |  | | | | | | |  __/
    %   \_____\__,_|_|_|_.__/|_|  \__,_|\__\___|   |_|  \_\\____/|_____/              |_|  |_|_| |_| |_|\___|     \__\___/     \_____|_|    |_____/              |_|  |_|_| |_| |_|\___|
    %                                                                      ______                                                                     ______
    %                                                                     |______|                                                                   |______|
    % See http://patorjk.com/software/taag/#p=display&f=Big&t=Calibrate%20%20%20ROS%20_%20Time%20%20%20%20to%20%20%20GPS%20_%20Time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
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
    
    %% Check that ROS_Time data has expected count
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_has_same_length_as_Trigger_Time_in_GPS_sensors)
        warning('on','backtrace');
        warning('Fundamental error on ROS_time: unexpected count');
        error('ROS time does not have expected count.\');
        flag_keep_checking = 0;
    end


    
    %% Check ROS_Time_rounds_correctly_to_Trigger_Time
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

    
    %% Check that ROS_Time_rounds_correctly_to_Trigger_Time 
    if (1==flag_keep_checking) && (0==time_flags.ROS_Time_rounds_correctly_to_Trigger_Time_in_GPS_sensors)
        warning('on','backtrace');
        warning('ROS time does not round correctly to Trigger_Time on sensor %s and perhaps other sensors. There is no code yet to fix this.',offending_sensor);
        % figure(123)
        % plot(nextDataStructure.GPS_SparkFun_RightRear.ROS_Time,'r','LineWidth',2)
        % hold on
        % plot(nextDataStructure.GPS_SparkFun_LeftRear.ROS_Time,'g','LineWidth',2)
        % plot(nextDataStructure.GPS_SparkFun_Front.ROS_Time,'b','LineWidth',2)
        nextDataStructure = fcn_DataClean_roundROSTimeForGPSUnits(nextDataStructure,fid);
        flag_keep_checking = 0;
        % clf
        % plot(nextDataStructure.GPS_SparkFun_RightRear.ROS_Time,'r','LineWidth',2)
        % hold on
        % plot(nextDataStructure.GPS_SparkFun_LeftRear.ROS_Time,'g','LineWidth',2)
        % plot(nextDataStructure.GPS_SparkFun_Front.Trigger_Time,'k','LineWidth',2)
    end
    
    %% Check that whether Velodyne LiDAR has correct ROS_Time
    if (1==flag_keep_checking) 
        flag_recalculate_ROS_Time = fcn_DataClean_checkDataTimeConsistency_LiDARVelodyne(nextDataStructure,fid);
    end

    %% Recalculate the ROS_Time for Velodyne LiDAR according to ros bag timestamps
    if (1==flag_keep_checking)&&(1==flag_recalculate_ROS_Time)
        nextDataStructure = fcn_DataClean_calculateROSTimeforVelodyneLiDAR(nextDataStructure, fid);
        flag_keep_checking = 0;
    end
    %% Entering this section indicates all time in GPS units have been checked and fixed
    
    
    %% First, check whether all sensors have Trigger_Time 
    % Moved into fcn_DataClean_checkDataTimeConsistency
%     if (1==flag_keep_checking)         
% %         error('stop here');
%         [time_flags,sensors_without_Trigger_Time] = fcn_DataClean_checkAllSensorsHaveTriggerTime(nextDataStructure,fid,time_flags);
%     end

    %% If not, calculate Trigger_Time to rest of sensors
    if (1==flag_keep_checking) && (0==time_flags.Trigger_Time_exists_in_all_sensors)
        warning('on','backtrace');
        warning('Some sensors do not have Trigger_Time, start to calculate Trigger_Time for those sensors');
        nextDataStructure = fcn_DataClean_calculateTriggerTime_AllSensors(nextDataStructure,sensors_without_Trigger_Time);
        flag_all_trigger_time_calculated = 1;
        flag_keep_checking = 0;
    end
    %%
  
    %% Start to work on other sensors, start with Velodyne LiDAR
    if (1==flag_keep_checking) && (flag_all_trigger_time_calculated==1)
        % figure(123)
        % plot(nextDataStructure.GPS_SparkFun_Front.Trigger_Time)
        % hold on
        % plot(nextDataStructure.LiDAR_Velodyne_Rear.Trigger_Time)
        % plot(nextDataStructure.TRIGGER_TrigBox_RearTop.Trigger_Time)
        nextDataStructure = fcn_DataClean_trimDataToCommonStartEndTriggerTimes(nextDataStructure,fid);
        flag_keep_checking = 0;
        % figure(124)
        % plot(nextDataStructure.GPS_SparkFun_Front.Trigger_Time)
        % hold on
        % plot(nextDataStructure.LiDAR_Velodyne_Rear.Trigger_Time)
        % 
    end

    %% TO-DO - Create a time analysis function - and add it here
    % Fix the x-axes to match the time duration, e.g. index*centiSeconds*0.01

    % Examine the offset deviations between the different time sources
    % [cell_array_centiSeconds,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds','GPS');
    % [cell_array_GPS_Time,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS');
    % [cell_array_Trigger_Time,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'Trigger_Time','GPS');
    % [cell_array_ROS_Time,sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS');
    % 
    % % Calculate ROS_Time - Trigger_time, plot this versus duration
    % figure(1818);
    % clf;
    % hold on;
    % grid on;
    % xlabel('Duration of Data Collection (seconds)');
    % ylabel('Deviations in Time (seconds)');
    % title('Differences, ROS Time - Trigger Time');
    % 
    % for ith_sensor = 1:length(sensor_names)
    % 
    %     xdata = (1:length(cell_array_Trigger_Time{ith_sensor}))'*0.01*cell_array_centiSeconds{ith_sensor};
    %     deviations_in_time = (cell_array_ROS_Time{ith_sensor} - cell_array_Trigger_Time{ith_sensor});
    %     plot(xdata,deviations_in_time);
    % end
    % legend(sensor_names,'Interpreter','none')
    % 
    % % Calculate GPS_Time - Trigger_time, plot this versus duration
    % figure(1819);
    % clf;
    % hold on;
    % grid on;
    % xlabel('Duration of Data Collection (seconds)');
    % ylabel('Deviations in Time (seconds)');
    % title('Differences, GPS Time - Trigger Time');
    % 
    % for ith_sensor = 1:length(sensor_names)
    %     xdata = (1:length(cell_array_Trigger_Time{ith_sensor}))'*0.01*cell_array_centiSeconds{ith_sensor};
    %     deviations_in_time = (cell_array_GPS_Time{ith_sensor} - cell_array_Trigger_Time{ith_sensor});
    %     plot(xdata,deviations_in_time);
    % end
    % legend(sensor_names,'Interpreter','none')
    % 
    % 


    %% Done!
    % Only way to get here is if everything above worked - can exit!
    if (1==flag_keep_checking)
        flag_stay_in_main_loop = 0; %#ok<NASGU>
    end
    
    %% Exiting conditions
    % if length(dataset)==1
    %     temp = dataset;
    %     clear dataset
    %     dataset{1} = temp;
    % end
    currentDataStructure = nextDataStructure;
    currentDataStructure.Identifiers = Identifiers_Hold;
      
    % Check if all the name_flags work, so we can exit!
    name_flag_stay_in_main_loop = fcn_INTERNAL_checkFlagsForExit(name_flags);
 
    if 0 == name_flag_stay_in_main_loop
        % Check if all the time_flags work, so we can exit!
        flag_stay_in_main_loop = fcn_INTERNAL_checkFlagsForExit(time_flags);
    else
        flag_stay_in_main_loop = 1;
    end
    
    % Have we done too many loops?
    if main_data_clean_loop_iteration_number>N_max_loops
        flag_stay_in_main_loop = 0;
    end
          
end

main_data_clean_loop_iteration_number = main_data_clean_loop_iteration_number+1;
debugging_data_structure_sequence{main_data_clean_loop_iteration_number} = currentDataStructure; %#ok<NASGU>
cleanDataStruct = currentDataStructure;
subPathStrings = '';


%% Save cleanData


% %% ======================= Raw Data Clean and Merge =========================
% % Step 1: we check if the time is incrementing uniformly. If it does not,
% % the data around this is set to NaN. In later steps, this is interpolated.
% rawDataTimeFixed = fcn_DataClean_removeTimeGapsFromRawData(rawData);
% %fcn_DataClean_searchAllFieldsForNaN(rawDataTimeFixed)
% 
% % Step 2: assign to each data a measured or calculated variance.
% % Fill in the sigma values for key fields. This just calculates the sigma
% % values for key fields (velocities, accelerations, angular rates in
% % particular), useful for doing outlier detection, etc. in steps that
% % follow.
% rawDataWithSigmas = fcn_DataClean_loadSigmaValuesFromRawData(rawDataTimeFixed);
% 
% % NOTE: the following function changes the yaw angles to wind (correctly)
% % up or down)
% 
% % Step 3: Remove outliers on key fields via median filtering
% % This removes outliers by median filtering key values.
% rawDataWithSigmasAndMedianFiltered = fcn_DataClean_medianFilterFromRawAndSigmaData(rawDataWithSigmas);
% 
% % PLOTS to show winding up or down:
% % figure(2); plot(mod(rawDataWithSigmas.GPS_Novatel.Yaw_deg,360),'b')
% % figure(3); plot(mod(rawDataWithSigmasAndMedianFiltered.GPS_Novatel.Yaw_deg,360),'k')
% % figure(4); plot(rawDataWithSigmasAndMedianFiltered.GPS_Novatel.Yaw_deg,'r')
% 
% % Step 4: Remove additional data artifacts such as yaw angle wrapping. This
% % is the cleanData structure. This has to be done before filtering to avoid
% % smoothing these artificial discontinuities. Clean the raw data
% cleanData = fcn_DataClean_cleanRawDataBeforeTimeAlignment(rawDataWithSigmasAndMedianFiltered);
% 
% % Step 5: Time align the data to GPS time. and make time a "sensor" field This step aligns
% % all the time vectors to GPS time, and ensures that the data has an even time sampling.
% cleanAndTimeAlignedData = fcn_DataClean_alignToGPSTimeAllData(cleanData);
% 
% % Step 6: Time filter the signals
% timeFilteredData = fcn_DataClean_timeFilterData(cleanAndTimeAlignedData);
% 
% % Step 7: Merge each signal by those that are common along the same state.
% % This is in the structure mergedData. Calculate merged data via Baysian
% % averaging across same state
% mergedData = fcn_DataClean_mergeTimeAlignedData(timeFilteredData);
% 
% % Step 8: Remove jumps from merged data caused by DGPS outages
% mergedDataNoJumps = fcn_DataClean_removeDGPSJumpsFromMergedData(mergedData,rawData,base_station);
% 
% 
% % Step 9: Calculate the KF fusion of single signals
% mergedByKFData = mergedDataNoJumps;  % Initialize the structure with prior data
% 
% % KF the yawrate and yaw together
% t_x1 = mergedByKFData.MergedGPS.GPS_Time;
% x1 = mergedByKFData.MergedGPS.Yaw_deg;
% x1_Sigma = mergedByKFData.MergedGPS.Yaw_deg_Sigma;
% t_x1dot = mergedByKFData.MergedIMU.GPS_Time;
% x1dot = mergedByKFData.MergedIMU.ZGyro*180/pi;
% x1dot_Sigma = mergedByKFData.MergedIMU.ZGyro_Sigma*180/pi;
% nameString = 'Yaw_deg';
% [x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
% x_kf_resampled = interp1(t_x1dot,x_kf,t_x1,'linear','extrap');
% sigma_x_resampled = interp1(t_x1dot,sigma_x,t_x1,'linear','extrap');
% mergedByKFData.MergedGPS.Yaw_deg = x_kf_resampled;
% mergedByKFData.MergedGPS.Yaw_deg_Sigma = sigma_x_resampled;
% 
% % KF the xEast_increments and xEast together
% t_x1 = mergedByKFData.MergedGPS.GPS_Time;
% x1 = mergedByKFData.MergedGPS.xEast;
% x1_Sigma = mergedByKFData.MergedGPS.xEast_Sigma;
% t_x1dot = mergedByKFData.MergedGPS.GPS_Time;
% x1dot = mergedByKFData.MergedGPS.xEast_increments/0.05;  % The increments are raw changes, not velocities. Have to divide by time step.
% x1dot_Sigma = mergedByKFData.MergedGPS.xEast_increments_Sigma/0.05;
% nameString = 'xEast';
% [x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
% mergedByKFData.MergedGPS.xEast = x_kf;
% mergedByKFData.MergedGPS.xEast_Sigma = sigma_x;
% 
% % KF the yNorth_increments and yNorth together
% t_x1 = mergedByKFData.MergedGPS.GPS_Time;
% x1 = mergedByKFData.MergedGPS.yNorth;
% x1_Sigma = mergedByKFData.MergedGPS.yNorth_Sigma;
% t_x1dot = mergedByKFData.MergedGPS.GPS_Time;
% x1dot = mergedByKFData.MergedGPS.yNorth_increments/0.05;  % The increments are raw changes, not velocities. Have to divide by time step.
% x1dot_Sigma = mergedByKFData.MergedGPS.yNorth_increments_Sigma/0.05;
% nameString = 'yNorth';
% [x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
% mergedByKFData.MergedGPS.yNorth = x_kf;
% mergedByKFData.MergedGPS.yNorth_Sigma = sigma_x;
% 
% % convert ENU to LLA (used for geoplot)
% [mergedByKFData.MergedGPS.latitude,mergedByKFData.MergedGPS.longitude,mergedByKFData.MergedGPS.altitude] ...
%     = enu2geodetic(mergedByKFData.MergedGPS.xEast,mergedByKFData.MergedGPS.yNorth,mergedByKFData.MergedGPS.zUp,...
%     base_station.latitude,base_station.longitude, base_station.altitude,wgs84Ellipsoid);
% 
% %% Step 10: Add interpolation to Lidar data to create field in Lidar that has GPS position in ENU
% % NOTE: as of 2023-06-11
% % The following does NOT work yet, and needs to be corrected via transforms
% % [mergedDataNoJumps,mergedByKFData] = fcn_DataClean_AddLocationToLidar(mergedDataNoJumps,mergedByKFData,base_station);
% 
% % Note: mergedDataNoJumps may have better GPS location data than
% % mergedByKFData if the Kalman filter fusion does not work well, for
% % example, the data at test track with trip_id =2.
% 
% % add Hemisphere_gps_week to mergedDataNoJumps and mergedByKFData
% if length(Hemisphere_gps_week) >1
%     error('More than one week data was collected in the trip!')
% end
% mergedDataNoJumps.MergedGPS.GPS_week = Hemisphere_gps_week;
% mergedDataNoJumps.Lidar.GPS_week = Hemisphere_gps_week;
% mergedByKFData.MergedGPS.GPS_week = Hemisphere_gps_week;
% mergedByKFData.Lidar.GPS_week = Hemisphere_gps_week;
% 
% % Probably can delete the following if statement (VERY old)
% if 1==0
%     % The following shows that we should NOT use yaw angles to calculate yaw rate
%     fcn_plotArtificialYawRateFromYaw(MergedData,timeFilteredData);
% 
%     % Now to check to see if raw integration of YawRate can recover the yaw
%     % angle
%     fcn_plotArtificialYawFromYawRate(MergedData,timeFilteredData);
% 
% 
%     %fcn_plotArtificialVelocityFromXAccel(MergedData,timeFilteredData);
%     fcn_plotArtificialPositionFromIncrementsAndVelocity(MergedData,cleanAndTimeAlignedData)
% end
% 
% 
% %% Update plotting flags to allow merged data to now appear hereafter
% 
% clear plottingFlags
% plottingFlags.fields_to_plot = [...
%     %     {'All_AllSensors_velMagnitude'}...
%     %     {'All_AllSensors_ZGyro'},...
%     %     {'All_AllSensors_yNorth_increments'}...
%     %     {'All_AllSensors_xEast_increments'}...
%     %     {'All_AllSensors_xEast'}...
%     %     {'All_AllSensors_yNorth'}...
%     %     {'xEast'}...
%     %     {'yNorth'}...
%     %     {'xEast_increments'}...
%     %     {'yNorth_increments'}...
%     %     {'All_AllSensors_Yaw_deg'},...
%     %     {'Yaw_deg'},...
%     %     {'ZGyro_merged'},...
%     %     {'All_AllSensors_ZGyro_merged'},...
%     {'XYplot'},...
%     %     {'All_AllSensors_XYplot'},...
%     ];
% % Define what is plotted
% plottingFlags.flag_plot_Garmin = 0;
% 
% %
% % % THE TEMPLATE FOR ALL PLOTTING
% % fieldOrdering = [...
% %     {'Yaw_deg'},...                 % Yaw variables
% %     {'Yaw_deg_from_position'},...
% %     {'Yaw_deg_from_velocity'},...
% %     {'All_SingleSensor_Yaw_deg'},...
% %     {'All_AllSensors_Yaw_deg'},...
% %     {'Yaw_deg_merged'},...
% %     {'All_AllSensors_Yaw_deg_merged'},...
% %     {'ZGyro'},...                   % Yawrate (ZGyro) variables
% %     {'All_AllSensors_ZGyro'},...
% %     {'velMagnitude'},...            % velMagnitude variables
% %     {'All_AllSensors_velMagnitude'},...
% %     {'XAccel'},...                  % XAccel variables
% %     {'All_AllSensors_XAccel'},...
% %     {'xEast_increments'},...        % Position increment variables
% %     {'All_AllSensors_xEast_increments'},...
% %     {'yNorth_increments'},...
% %     {'All_AllSensors_yNorth_increments'},...
% %     {'zUp_increments'},...
% %     {'All_AllSensors_zUp_increments'},...
% %     {'XYplot'},...                  % XY plots
% %     {'All_AllSensors_XYplot'},...
% %     {'xEast'},...                   % xEast and yNorth plots
% %     {'All_AllSensors_xEast'},...
% %     {'yNorth'},...
% %     {'All_AllSensors_yNorth'},...
% %     {'zUp'},...
% %     {'All_AllSensors_zUp'},...
% %     {'DGPS_is_active'},...
% %     {'All_AllSensors_DGPS_is_active'},...
% %     %     {'velNorth'},...                % Remaining are not yet plotted - just kept here for now as  placeholders
% %     %     {'velEast'},...
% %     %     {'velUp'},...
% %     %     {'Roll_deg'},...
% %     %     {'Pitch_deg'},...
% %     %     {'xy_increments'}... % Confirmed
% %     %     {'YAccel'},...
% %     %     {'ZAccel'},...
% %     %     {'XGyro'},...
% %     %     {'YGyro'},...
% %     %     {'VelocityR},...
% %     ];
% 
% % Define which sensors to plot individually
% plottingFlags.SensorsToPlotIndividually = [...
%     {'GPS_Hemisphere'}...
%     {'GPS_Novatel'}...
%     {'MergedGPS'}...
%     %    {'VelocityProjectedByYaw'}...
%     %     {'GPS_Garmin'}...
%     %     {'IMU_Novatel'}...
%     %     {'IMU_ADIS'}...
%     %     {'Input_Steering'}...
%     %     {'Encoder_RearWheels'}...
%     %     {'MergedIMU'}...
%     ];
% 
% % Define zoom points for plotting
% % plottingFlags.XYZoomPoint = [-4426.14413504648 -4215.78947791467 1601.69022519862 1709.39208889317]; % This is the corner after Toftrees, where the DGPS lock is nearly always bad
% % plottingFlags.TimeZoomPoint = [297.977909295872          418.685505549775];
% % plottingFlags.TimeZoomPoint = [1434.33632953011          1441.17612419014];
% % plottingFlags.TimeZoomPoint = [1380   1600];
% % plottingFlags.TimeZoomPoint = [760 840];
% % plottingFlags.TimeZoomPoint = [596 603];  % Shows a glitch in the Yaw_deg_all_sensors plot
% % plottingFlags.TimeZoomPoint = [1360   1430];  % Shows lots of noise in the individual Yaw signals
% % plottingFlags.TimeZoomPoint = [1226 1233]; % This is the point of time discontinuity in the raw dat for Hemisphere
% % plottingFlags.TimeZoomPoint = [580 615];  % Shows a glitch in xEast_increments plot
% % plottingFlags.TimeZoomPoint = [2110 2160]; % This is the point of discontinuity in xEast
% % plottingFlags.TimeZoomPoint = [2119 2129]; % This is the location of a discontinuity produced by a variance change
% % plottingFlags.TimeZoomPoint = [120 150]; % Strange jump in xEast data
% plottingFlags.TimeZoomPoint = [185 185+30]; % Strange jump in xEast data
% 
% 
% % if isfield(plottingFlags,'TimeZoomPoint')
% %     plottingFlags = rmfield(plottingFlags,'TimeZoomPoint');
% % end
% 
% 
% % These set common y limits on values
% % plottingFlags.ylim.('xEast') = [-4500 500];
% plottingFlags.ylim.('yNorth') = [500 2500];
% 
% plottingFlags.ylim.('xEast_increments') = [-1.5 1.5];
% plottingFlags.ylim.('All_AllSensors_xEast_increments') = [-1.5 1.5];
% plottingFlags.ylim.('yNorth_increments') = [-1.5 1.5];
% plottingFlags.ylim.('All_AllSensors_yNorth_increments') = [-1.5 1.5];
% 
% plottingFlags.ylim.('velMagnitude') = [-5 35];
% plottingFlags.ylim.('All_AllSensors_velMagnitude') = [-5 35];
% 
% 
% plottingFlags.PlotDataDots = 0; % If set to 1, then the data is plotted as dots as well as lines. Useful to see data drops.
% 
% %% Plot the results
% fcn_DataClean_plotStructureData(rawData,plottingFlags);
% %fcn_DataClean_plotStructureData(rawDataTimeFixed,plottingFlags);
% %fcn_DataClean_plotStructureData(rawDataWithSigmas,plottingFlags);
% %fcn_DataClean_plotStructureData(rawDataWithSigmasAndMedianFiltered,plottingFlags);
% %fcn_DataClean_plotStructureData(cleanData,plottingFlags);
% %fcn_DataClean_plotStructureData(cleanAndTimeAlignedData,plottingFlags);
% %fcn_DataClean_plotStructureData(timeFilteredData,plottingFlags);
% %fcn_DataClean_plotStructureData(mergedData,plottingFlags);
% fcn_DataClean_plotStructureData(mergedDataNoJumps,plottingFlags);
% fcn_DataClean_plotStructureData(mergedByKFData,plottingFlags);
% 
% % The following function allows similar plots, made when there are repeated
% % uncommented versions above, to all scroll/zoom in unison.
% %fcn_plotAxesLinkedTogetherByField;
% 
% 
% %% geoplot
% figure(123)
% clf
% geoplot(mergedByKFData.GPS_Hemisphere.Latitude,mergedByKFData.GPS_Hemisphere.Longitude,'b', ...
%     mergedByKFData.MergedGPS.latitude,mergedByKFData.MergedGPS.longitude,'r',...
%     mergedDataNoJumps.MergedGPS.latitude,mergedDataNoJumps.MergedGPS.longitude,'g', 'LineWidth',2)
% 
% % geolimits([45 62],[-149 -123])
% legend('mergedByKFData.GPS\_Hemisphere','mergedByKFData.MergedGPS','mergedDataNoJumps.MergedGPS')
% geobasemap satellite
% %geobasemap street
% %% OLD STUFF
% 
% % %% Export results to Google Earth?
% % %fcn_exportXYZ_to_GoogleKML(rawData.GPS_Hemisphere,'rawData_GPS_Hemisphere.kml');
% % %fcn_exportXYZ_to_GoogleKML(mergedData.MergedGPS,'mergedData_MergedGPS.kml');
% % fcn_exportXYZ_to_GoogleKML(mergedDataNoJumps.MergedGPS,[dir.datafiles 'mergedDataNoJumps_MergedGPS.kml']);
% %
% %
% % %% Save cleaned data to .mat file
% % % The following is not used
% % newStr = regexprep(trip_name{1},'\s','_'); % replace whitespace with underscore
% % newStr = strrep(newStr,'-','_');
% % cleaned_fileName = [newStr,'_cleaned'];
% % eval([cleaned_fileName,'=mergedByKFData'])
% % save(strcat(dir.datafiles,cleaned_fileName,'.mat'),cleaned_fileName)
% 
% %
% % fields = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% % I99_Altoona33_to_StateCollege73 = rmfield(mergedByKFData.MergedGPS,fields);
% % save('I99_Altoona33_to_StateCollege73_20210123.mat','I99_Altoona33_to_StateCollege73')
% % if trip_id_cleaned == 7
% %     fields_rm = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% %     I99_StateCollege73_to_Altoona33 = rmfield(mergedByKFData.MergedGPS,fields_rm);
% %     save('I99_StateCollege73_to_Altoona33_20210123.mat','I99_StateCollege73_to_Altoona33')
% % 
% %     fields_rm = {'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% %     I99_StateCollege73_to_Altoona33_mergedDataNoJumps = rmfield(mergedDataNoJumps.MergedGPS,fields_rm);
% %     I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station = [0; cumsum(sqrt(diff(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.xEast).^2+diff(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.yNorth).^2))];
% %     save('I99_StateCollege73_to_Altoona33_mergedDataNoJumps_20210123.mat','I99_StateCollege73_to_Altoona33_mergedDataNoJumps')
% % end
% 
% % extract TestTrack data
% % fields = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% % TestTrack_all = rmfield(mergedByKFData.MergedGPS,fields);
% % TestTrack_all_table = struct2table(TestTrack_all);
% % TestTrack_table = TestTrack_all_table(6000:9398,:);
% % TestTrack = table2struct(TestTrack_table,'ToScalar',true);
% % save('TestTrack.mat','TestTrack')
% %
% % figure(1234)
% % clf
% % geoplot(TestTrack.latitude,TestTrack.longitude,'b', ...
% % TestTrack.latitude(1),TestTrack.longitude(1),'r.',...
% % TestTrack.latitude(end),TestTrack.longitude(end),'g.','LineWidth',2)
% % % geolimits([45 62],[-149 -123])
% % legend('Merged')
% % geobasemap satellite
% 
% %%  Yaw Rate and Curvature Comparision
% if 1 ==0
%     [~, ~, ~, ~,R_spiral,UnitNormalV,concavity]=fnc_parallel_curve(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.xEast, I99_StateCollege73_to_Altoona33_mergedDataNoJumps.yNorth, 1, 0,1,100);
% 
%     yaw_rate = [0; diff(mergedDataNoJumps.MergedGPS.Yaw_deg)./diff(mergedDataNoJumps.MergedGPS.GPS_Time)];
% 
%     figure(23)
%     clf
%     hold on
%     % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,I99_StateCollege73_to_Altoona33_mergedDataNoJumps.altitude)
%     plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,mergedDataNoJumps.MergedGPS.Yaw_deg,'b','LineWidth',1)
%     plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,yaw_rate,'r','LineWidth',1)
% 
%     grid on
%     box on
%     xlabel('station (m)')
%     ylabel('yaw and yaw rate (deg)')
%     % ylim([0 0.01])
% 
% 
%     figure(24)
%     clf
%     hold on
%     Ux = mergedDataNoJumps.GPS_Hemisphere.velEast.*cosd(mergedDataNoJumps.MergedGPS.Yaw_deg) + ...
%         mergedDataNoJumps.GPS_Hemisphere.velNorth.*sind(mergedDataNoJumps.MergedGPS.Yaw_deg);
%     plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,Ux,'b','LineWidth',1)
%     plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,mergedDataNoJumps.GPS_Hemisphere.velNorth,'g')
%     plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,mergedDataNoJumps.GPS_Hemisphere.velEast,'r','LineWidth',1)
% 
%     % plot(mergedDataNoJumps.IMU_Novatel.GPS_Time,mergedDataNoJumps.IMU_Novatel.ZAccel,'b')
%     grid on
%     box on
%     xlabel('time (s)')
%     ylabel('velocity (m/s)')
%     % ylim([0 0.01])
% 
%     curvature_ss  = (yaw_rate*pi/180)./Ux;
% 
%     figure(22)
%     clf
%     % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,I99_StateCollege73_to_Altoona33_mergedDataNoJumps.altitude)
%     hold on
%     % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,curvature_ss,'g','LineWidth',1)
%     plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,abs(concavity).*1./R_spiral,'r','LineWidth',1)
%     grid on
%     box on
%     xlabel('Station (m)')
%     ylabel('Curvature')
%     ylim([-0.01 0.04])
% 
% 
% end
% %% ======================= Insert Cleaned Data to 'mapping_van_cleaned' database =========================
% % Input trips information
% %
% % tripsInfo.id = trip_id_cleaned;
% % tripsInfo.vehicle_id = 1;
% % tripsInfo.base_stations_id = base_station.id;
% % tripsInfo.name = trip_name;
% % if trip_id_cleaned == 2
% %
% %     tripsInfo.description = {'Test Track MappingVan night middle speed'};
% %     tripsInfo.date = {'2019-10-18 20:39:30'};
% %     tripsInfo.driver = {'Liming Gao'};
% %     tripsInfo.passengers = {'N/A'};
% %     tripsInfo.notes = {'without traffic light, at night. DGPS mode was activated. middle speed. 7 traversals'};
% %     cleanedData  = mergedDataNoJumps;
% %
% %     start_point.start_longitude=-77.833842140800000;  %deg
% %     start_point.start_latitude =40.862636161300000;   %deg
% %     start_point.start_xEast=1345.204537286125; % meters
% %     start_point.start_yNorth=6190.884280063217; % meters
% %
% %     start_point.end_longitude=-77.833842140800000;  %deg
% %     start_point.end_latitude =40.862636161300000;   %deg
% %     start_point.end_xEast=1345.204537286125; % meters
% %     start_point.end_yNorth=6190.884280063217; % meters
% %
% %     start_point.start_yaw_angle = 37.38; %deg
% %     start_point.expectedRouteLength = 1555.5; % meters
% %     start_point.direction = 'CCW'; %
% %     cleanedData.start_point = start_point;
% % elseif trip_id_cleaned == 7
% %
% %     tripsInfo.description = {'Map I99 from State College(exit 73) to Altoona (exit 33)'};
% %     tripsInfo.date = {'2021-01-23 15:00:00'};
% %     tripsInfo.driver = {'Wushuang Bai'};
% %     tripsInfo.passengers = {'Liming Gao'};
% %     tripsInfo.notes = {'Mapping from State College(exit 73) to Altoona (exit 33) through I-99. Lost DGPS mode when approaching Altoona. Drving on the right lane.'};
% %     cleanedData  = mergedByKFData;
% % elseif trip_id_cleaned == 8
% %     tripsInfo.description = {'Map I99 from Altoona (exit 33) to State College(exit 73)'};
% %     tripsInfo.date = {'2021-01-23 16:00:00'};
% %     tripsInfo.driver = {'Wushuang Bai'};
% %     tripsInfo.passengers = {'Liming Gao'};
% %     tripsInfo.notes = {'Mapping from Altoona (exit 33) to State College(exit 73) through I-99. Nexver lost DGPS mode except for passing below bridge or traffic sign. Drving on the right lane.'};
% %     cleanedData  = mergedByKFData;
% % else
% %     error("Wrong Trip ID");
% % end
% % % insert cleaned data
% % fcn_DataClean_insertCleanedData(cleanedData,rawData,tripsInfo,flag);
% % % save('cleanedData.mat','cleanedData')
% %

%%
fprintf(fid,'Cleaning completed\n');

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
if (1==flag_do_plots) 
    figure(fig_num);

    % % Plot some test data
    % LLdata = [rawData.GPS_SparkFun_Front_GGA.Latitude rawData.GPS_SparkFun_Front_GGA.Longitude];
    % 
    % clear plotFormat
    % plotFormat.Color = [0 0.7 0];
    % plotFormat.Marker = '.';
    % plotFormat.MarkerSize = 20;
    % plotFormat.LineStyle = '-';
    % plotFormat.LineWidth = 3;
    % 
    % 
    % % Fill in large colormap data using turbo
    % colorMapMatrix = colormap('turbo');
    % colorMapMatrix = colorMapMatrix(100:end,:); % Keep the scale from green to red
    % 
    % % Reduce the colormap
    % Ncolors = 20;
    % reducedColorMap = fcn_plotRoad_reduceColorMap(colorMapMatrix, Ncolors, -1);
    % 
    % if 1==0
    %     h_animatedPlot = fcn_plotRoad_animatePlot('plotLL',0,[],LLdata, plotFormat,reducedColorMap,fig_num);
    % 
    %     for ith_time = 1:10:length(LLdata(:,1))
    %         fcn_plotRoad_animatePlot('plotLL', ith_time, h_animatedPlot, LLdata, (plotFormat), (reducedColorMap), (fig_num));
    %         set(gca,'ZoomLevel',20,'MapCenter',LLdata(ith_time,1:2));
    %         pause(0.02);
    %     end
    % else
    %     Npoints = length(LLdata(:,1));
    %     Idata = ((1:Npoints)-1)'/(Npoints-1);
    %     fcn_plotRoad_plotLLI([LLdata Idata], (plotFormat), (reducedColorMap), (fig_num));
    %     set(gca,'MapCenterMode','auto','ZoomLevelMode','auto');
    % end
    % title(sprintf('%s',bagName_clean),'Interpreter','none');

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


%% fcn_INTERNAL_checkFlagsForExit
function flag_stay_in_main_loop = fcn_INTERNAL_checkFlagsForExit(flags)
flag_fields = fieldnames(flags); % Grab all the flags
flag_array = zeros(length(flag_fields),1);
for ith_field = 1:length(flag_fields)
    flag_array(ith_field,1) = flags.(flag_fields{ith_field});
end

flag_stay_in_main_loop = 1;
if all(flag_array==1)
    flag_stay_in_main_loop = 0;
end
end % Ends fcn_INTERNAL_checkFlagsForExit


%% fcn_INTERNAL_reportFlagStatus
function fcn_INTERNAL_reportFlagStatus(flagStructure,printTitle)
fprintf(1,'\n%s\n',printTitle);
fieldsToprint = fieldnames(flagStructure);
NcharactersField = 50;
for ith_field = 1:length(fieldsToprint)
    thisField = fieldsToprint{ith_field};
    formattedHeaderString  = fcn_DebugTools_debugPrintStringToNCharacters(thisField,NcharactersField);
    fprintf(1,'%s\t',formattedHeaderString);
    fieldValue = flagStructure.(thisField);
    if 1==fieldValue
        fieldString = 'yes';
    else
        fieldString = 'no';
    end
    fprintf(1,'%s\n',fieldString);    
end
fprintf(1,'\n');
end % Ends fcn_INTERNAL_reportFlagStatus
