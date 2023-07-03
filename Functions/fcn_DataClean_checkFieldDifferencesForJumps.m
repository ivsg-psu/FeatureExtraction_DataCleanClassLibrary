function [flags,offending_sensor,return_flag] = fcn_DataClean_checkFieldDifferencesForJumps(dataStructure, field_name,varargin)
% fcn_DataClean_checkFieldDifferencesForJumps
% Checks if the differences in data in a sub-field are larger than some
% threshold. The input is a dataStructure with sensors as fields, and for
% each sensor there are subfields. For a given sub-field, for example
% position, this function takes differences in the position data (using
% diff) and checks whether the differences are unexpected, which would
% occur if there was a data drop. 

% If no jumps (data is good), it sets a flag = 1 whose name is customized
% by the input settings. If not, it sets the flag = 0 and immediately
% exits.
%
% FORMAT:
%
%      [flags,offending_sensor] = fcn_DataClean_checkFieldDifferencesForJumps(...
%          dataStructure, field_name, threshold,...
%          (flags),(string_any_or_all),(sensors_to_check),(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed
%
%      field_name: the field to be checked
%
%      threshold: the threshold for discontinuity
%
%      (OPTIONAL INPUTS)
%
%      flags: If a structure is entered, it will append the flag result
%      into the structure to allow a pass-through of flags structure
%
%      string_any_or_all: a string consisting of 'any' or 'all' indicating
%      whether the flag should be set if any sensor has no jumps
%      ('any'), or to check that all sensors have no jumps
%      ('all'). Default is 'all' if not specified or left empty ('');
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
    narginchk(2,7);
end

% Does the user want to specify the flags?
flags = struct;
if 4 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        flags = temp;
    end
end

% Does the user want to specify the string_any_or_all?
string_any_or_all = 'all';
if 5 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        string_any_or_all = temp;
    end
end


% Does the user want to specify the sensors_to_check?
sensors_to_check = '';
if 6 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        sensors_to_check = temp;
    end
end


% Does the user want to specify the fid?
fid = 0;
% Check for user input
if 7 <= nargin
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
            flag_name = sprintf('all_jumps_in_differences_of_%s_are_expected_in_all_sensors',field_name);
        else
            flag_name = sprintf('all_jumps_in_differences_of_%s_are_expected_in_%s_sensors',field_name,sensors_to_check);
        end
    case {'all'}
        if flag_check_all_sensors
            flag_name = sprintf('no_jumps_in_differences_exist_in_%s_in_all_sensors',field_name);
        else
            flag_name = sprintf('%s_exists_in_all_%s_sensors',field_name, sensors_to_check);
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



% Loop through the sensor name list, checking each, and stopping
% immediately if we hit a bad case.

% Initialize all flags to 1 (default is that they are good)
any_sensor_exists_results = ones(length(sensor_names),1);
for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    % Tell the user what is happening?
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
    end
    
    % Check the field to see if it exists, saving result in an array that
    % represents the results for each sensor
    flag_field_exists= 1;
    if ~isfield(sensor_data,field_name)
        % If the field is not there, then fails
        any_sensor_exists_results(i_data) = 0;
    elseif isempty(sensor_data.(field_name))
        % if field is empty, then fails
        any_sensor_exists_results(i_data) = 0;
    elseif any(isnan(sensor_data.(field_name)))        
        % if field only filled with nan, it fails
        any_sensor_exists_results(i_data) = 0;
    end   

end

% Check the all case
if strcmp(string_any_or_all,'all') && any(any_sensor_exists_results==0)
    % If any sensors have to have the field, then if all are nan, this
    % flag fails
    flag_field_exists = 0;
    first_failure = find(any_sensor_exists_results==0,1,'first');
    offending_sensor = sensor_names{first_failure};
end

% Check the any case
if strcmp(string_any_or_all,'any') && all(any_sensor_exists_results==0)
    % If any sensors have to have the field, then if all are nan, this
    % flag fails
    flag_field_exists = 0;
    offending_sensor = sensor_names{1};
end

% Set the flag array and return accordingly
flags.(flag_name) = flag_field_exists;
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



