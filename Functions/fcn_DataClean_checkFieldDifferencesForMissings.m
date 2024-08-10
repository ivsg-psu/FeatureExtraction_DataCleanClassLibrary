function [flags,offending_sensor,return_flag] = fcn_DataClean_checkFieldDifferencesForMissings(dataStructure, field_name, varargin)
% fcn_DataClean_checkFieldDifferencesForJumps
% Checks if the differences in data in a sub-field are larger than some
% threshold. The purpose of this is to detect outliers and data drops.
%
% To detect jumps, the method is to calculate the difference in the field,
% take the mean and standard deviation of the differences, then use a
% threshold on standard deviations (default is 5). If any of the data fall
% outside of this threshold, a jump error flag is set.
%
% The input is a dataStructure with sensors as fields, and for
% each sensor there are subfields. For a given sub-field, for example
% position, this function takes differences in the position data (using
% diff) and checks whether the differences are unexpected, which could
% occur if there was a data drop. 
%
% If no jumps exist, it sets a flag = 1 whose name is customized
% by the input settings. If not, it sets the flag = 0 and immediately
% exits.
%
% FORMAT:
%
%      [flags,offending_sensor] = fcn_DataClean_checkFieldDifferencesForJumps(...
%          dataStructure, field_name, ...
%          (flags),...
%          (threshold_in_standard_deviations),...
%          (custom_lower_threshold),...
%          (string_any_or_all),(sensors_to_check),(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed
%
%      field_name: the field to be checked
%
%      (OPTIONAL INPUTS)
%
%      flags: If a structure is entered, it will append the flag result
%      into the structure to allow a pass-through of flags structure
% 
%      threshold_in_standard_deviations: the threshold for jump detection
%      in standard deviations. Data would be flagged as having jumps if any
%      data falls outside a range of +/- threshold_in_standard_deviations *
%      standard deviations of the mean difference in data. Default is 5, to
%      check for 5 standard deviations.
%
%      custom_lower_threshold: a custom lower threshold to use instead of
%      standard deviation calculations. If set to a number, differences
%      must be larger than this number for the field to pass the checking
%      of jumps. For example, changes in time will never be less than 0, so
%      if the mean time change is 0.1 seconds and the standard deviation is
%      0.05 seconds, the typical calculations would check that a time
%      change is within 5 standard deviations, meaning checking time
%      differences between +0.35 seconds and -.15 seconds. But the lower
%      value will never occur. With flag = 0.0001, it will check time
%      differences between +0.35 seconds and 0.0001 seconds. Default is
%      empty ([]) which is to use the calculated threshold calculated from
%      standard deviations and threshold_in_standard_deviations.
%
%      string_any_or_all: a string consisting of 'any' or 'all' indicating
%      whether the data should be flagged if any sensor has jumps
%      ('any'), or if all sensors have jumps
%      ('all'). Default is 'any' if not specified or left empty ('');
%
%      sensors_to_check: a string listing the sensors to check. For
%      example, 'GPS' will check every sensor in the dataStructure whose
%      name contains 'GPS'. Default is empty, which checks all sensors.
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (FID = 0). Set fid to 1 for printing to console.
%
% OUTPUTS:
%
%      flags: a data structure containing subfields that define the results
%      of the verification check. The name of the flag is formatted by the
%      argument inputs. 
%
%      offending_sensor: this is the string corresponding to the sensor
%      field in the data structure that caused a flag to become zero. 
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_checkFieldDifferencesForJumps
%     for a full test suite.
%
% This function was written on 2023_07_02 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_07_02: sbrennan@psu.edu
% -- wrote the code originally 


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
    narginchk(2,8);
end

% Does the user want to specify the flags?
flags = struct;
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        flags = temp;
    end
end

% Does the user want to specify the threshold_in_standard_deviations?
threshold_in_standard_deviations = 5;
if 4 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        threshold_in_standard_deviations = temp;
    end
end

% Does the user want to specify the custom_lower_threshold?
custom_lower_threshold = []; % Default
if 5 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        custom_lower_threshold = temp;
    end
end


% Does the user want to specify the string_any_or_all?
string_any_or_all = 'any';
if 6 <= nargin
    temp = varargin{4};
    if ~isempty(temp)
        string_any_or_all = temp;
    end
end


% Does the user want to specify the sensors_to_check?
sensors_to_check = '';
if 7 <= nargin
    temp = varargin{5};
    if ~isempty(temp)
        sensors_to_check = temp;
    end
end


% Does the user want to specify the fid?
fid = 0;
% Check for user input
if 8 <= nargin
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


% Set up flags based on input conditions
if isempty(sensors_to_check)
    flag_check_all_sensors = 1;    
else
    flag_check_all_sensors = 0;
end

% Set up output flag name string
switch lower(string_any_or_all)
    case {'any'}
        if flag_check_all_sensors
            flag_name = sprintf('no_missings_in_differences_of_%s_in_any_sensors',field_name);
        else
            flag_name = sprintf('no_missings_in_differences_of_%s_in_any_%s_sensors',field_name,sensors_to_check);
        end
    case {'all'}
        if flag_check_all_sensors
            flag_name = sprintf('no_missings_in_differences_of_%s_in_all_sensors',field_name);
        else
            flag_name = sprintf('no_missings_in_differences_of_%s__in_all_%s_sensors',field_name, sensors_to_check);
        end
    otherwise
        error('Unrecognized setting on string_any_or_all when checking if fields are in sensors.');
end


% Initialize outputs of the function: offending_sensor and return flag
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

% Tell the user what is happening?
if 0~=fid
    fprintf(fid,'Checking existence of %s data ',field_name);
    if flag_check_all_sensors
        fprintf(fid,':\n');
    else
        fprintf(fid,'in %s %s sensors:\n', string_any_or_all, sensors_to_check);
    end
end

% Loop through the sensor name list, checking each, and stopping
% immediately if we hit a bad case.

% Initialize all flags to 1 (default is that they are good)
sensors_pass_test_flags = ones(length(sensor_names),1);
for ith_sensor = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{ith_sensor};
    sensor_data = dataStructure.(sensor_name);
    
    % Tell the user what is happening?
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',ith_sensor,length(sensor_names),sensor_name);
    end
    
    % To detect jumps, the method is to calculate the difference in the field,
    % take the mean and standard deviation of the differences, then use a
    % threshold on standard deviations (default is 5). If any of the data fall
    % outside of this threshold, a jump error flag is set.
    
    
    flag_this_sensor_passes_test = 1;
    if ~isfield(sensor_data,field_name)
        flag_this_sensor_passes_test = 0;
    else
        differences_in_field_data = diff(sensor_data.(field_name));
        mean_differences = mean(differences_in_field_data);
        std_differences = std(differences_in_field_data);
        max_difference_threshold = mean_differences + threshold_in_standard_deviations*std_differences;
        
        if ~isempty(custom_lower_threshold)
            min_differences_threshold = custom_lower_threshold;
        else
            min_differences_threshold = mean_differences - threshold_in_standard_deviations*std_differences;
        end
        
        if any(differences_in_field_data>max_difference_threshold) || any(differences_in_field_data<min_differences_threshold)
            flag_this_sensor_passes_test = 0;
        end
    end
    sensors_pass_test_flags(ith_sensor,1) = flag_this_sensor_passes_test;

end

flag_field_passes_test = 1;
% Check the all case
if strcmp(string_any_or_all,'all') && all(sensors_pass_test_flags==0)
    % If any sensors have to have the field, then if all are nan, this
    % flag fails
    flag_field_passes_test = 0;
    first_failure = 1;
    offending_sensor = sensor_names{first_failure};
end

% Check the any case
if strcmp(string_any_or_all,'any') && any(sensors_pass_test_flags==0)
    % If any sensors have to have the field, then if all are nan, this
    % flag fails
    flag_field_passes_test = 0;
    first_failure = find(sensors_pass_test_flags==0,1,'first');
    offending_sensor = sensor_names{first_failure};
end

% Set the flag array and return accordingly
flags.(flag_name) = flag_field_passes_test;
if 0==flags.(flag_name)
    return_flag = 1; % Indicate that the return was forced
    return; % Exit the function immediately to avoid more processing
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



