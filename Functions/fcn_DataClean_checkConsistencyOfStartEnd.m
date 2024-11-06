function [flags,offending_sensor, return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(dataStructure, field_name, varargin)
% Checks to see if all data in a field have same start or end values
%
% FORMAT:
%
%      [flags,offending_sensor,return_flag] = fcn_DataClean_checkConsistencyOfStartEnd(dataStructure, field_name, (flags), (sensors_to_check), (flag_name_suffix), (agreement_threshold), (fid), (fig_num))
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
%      into the structure to allow a pass-through of flags structure.
%      Default is empty, e.g. to create a new structure.
%
%      sensors_to_check: a string listing the sensors to check. For
%      example, 'GPS' will check every sensor in the dataStructure whose
%      name contains 'GPS'. Default is empty, which checks all sensors.
%      Default is to check all the sensors.
%
%      flag_name_suffix: a string denoting the suffix of the flag that is
%      created. Default is empty string, e.g. no suffix.
%
%      agreement_threshold: a scalar denoting how "close" end values must
%      be to each other to be in agreement. Default is 0, e.g. require
%      exact agreement.
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (default is FID = 0, e.g. no printing). Set fid to 1
%      for printing to console.
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed. Default is no figure.
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
%      fcn_DataClean_pullDataFromFieldAcrossAllSensors
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_checkConsistencyOfStartEnd
%     for a full test suite.
%
% This function was written on 2023_07_01 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
%
% 2023_07_01: sbrennan@psu.edu
% -- wrote the code originally
% 2024_09_29: sbrennan@psu.edu
% -- updated top comments
% -- added debug flag area
% -- added fig_num input, fixed the plot flag
% -- fixed warning and errors

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==8 && isequal(varargin{end},-1))
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
if (0==flag_max_speed)
    if flag_check_inputs
        % Are there the right number of inputs?
        narginchk(2,8);
    end
end

% Does the user want to specify the flags?
flags = struct;
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        flags = temp;
    end
end

% Does the user want to specify the sensors_to_check?
sensors_to_check = '';
if 4 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        sensors_to_check = temp;
    end
end

% Does the user want to specify the flag_name_suffix?
flag_name_suffix = '';
if 5 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        flag_name_suffix = temp;
    end
end

% Does the user want to specify the agreement_threshold?
agreement_threshold = 0;
if 6 <= nargin
    temp = varargin{4};
    if ~isempty(temp)
        agreement_threshold = temp;
    end
end

% Does the user want to specify the fid?
fid = 0;
if (0==flag_max_speed)
    % Check for user input
    if 7 <= nargin
        temp = varargin{5};
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
end


% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (8<=nargin)
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

% Initialize offending_sensor
offending_sensor = '';

flag_name = sprintf('%s_has_consistent_start_end%s', field_name, flag_name_suffix);

% Produce a list of all the sensors (each is a field in the structure)
[dataArray, sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, field_name, sensors_to_check);

if 0~=fid
    if ~isempty(sensors_to_check)
        fprintf(fid,'Checking consistency of start and end of %s across %s sensors:  --> %s \n', field_name, sensors_to_check, flag_name);
    else
        fprintf(fid,'Checking consistency of start and end of %s:  --> %s \n', field_name, flag_name);
    end
end

Nsensors = length(sensor_names);

startValues = zeros(Nsensors,1);
endValues   = zeros(Nsensors,1);

for ith_sensor = 1:Nsensors
    % Grab the startValues and endValues
    sensor_name = sensor_names{ith_sensor};
    sensor_data = dataArray{ith_sensor};

    if 0~=fid
        fprintf(fid,'\t Checking field %s in sensor %d of %d: %s\n', field_name, ith_sensor,length(sensor_names),sensor_name);
    end

    startValues(ith_sensor,1) = sensor_data(1,1);
    endValues(ith_sensor,1)   = sensor_data(end,1);

end

% Calculate the maximum differences
start_time_differences = max(startValues)-min(startValues);
end_time_differences = max(endValues)-min(endValues);

% Check that they all agree 
flags.(flag_name) = all(start_time_differences<=agreement_threshold)*all(end_time_differences<=agreement_threshold);


if 0==flags.(flag_name)
    % Find offending sensor
    if start_time_differences>agreement_threshold
        [~,min_index] = min(startValues);
        [~,max_index] = max(startValues);
        offending_low_sensor = sensor_names{min_index};
        offending_high_sensor = sensor_names{max_index};
        offending_sensor = cat(2, 'Start values of: ', offending_low_sensor,' ',offending_high_sensor); % Save the names of the sensor
    elseif end_time_differences>agreement_threshold
        [~,min_index] = min(endValues);
        [~,max_index] = max(endValues);
        offending_low_sensor = sensor_names{min_index};
        offending_high_sensor = sensor_names{max_index};
        offending_sensor = cat(2,'End values of: ', offending_low_sensor,' ',offending_high_sensor); % Save the names of the sensor
    else
        error('Should never enter here');
    end
    return_flag = 1; % Indicate that the return was forced

    % Show the results?
    if fid
        % Find the longest name
        longest_Nname_string = 0;
        for ith_name = 1:length(sensor_names)
            if length(sensor_names{ith_name})>longest_Nname_string
                longest_Nname_string = length(sensor_names{ith_name});
            end
        end

        % Print results
        fprintf(fid,'\n\t Inconsistent start or end values detected! \n');

        % Print start time table
        fprintf(fid,'\t \t Summarizing start values: \n');
        sensor_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',longest_Nname_string);
        values_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Values:',25);
        fprintf(fid,'\t \t %s \t %s \n',sensor_title_string,values_title_string);
        for ith_data = 1:length(sensor_names)
            sensor_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sensor_names{ith_data},longest_Nname_string);
            values_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%.6f',startValues(ith_data)),29);
            fprintf(fid,'\t \t %s \t %s \n',sensor_data_string,values_data_string);
        end
        fprintf(fid,'\n');

        % Print end time table
        fprintf(fid,'\t \t Summarizing end values: \n');
        sensor_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',longest_Nname_string);
        values_title_string = fcn_DebugTools_debugPrintStringToNCharacters('Values:',25);
        fprintf(fid,'\t \t %s \t %s \n',sensor_title_string,values_title_string);
        for ith_data = 1:length(sensor_names)
            sensor_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sensor_names{ith_data},longest_Nname_string);
            values_data_string = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%.6f',endValues(ith_data)),29);
            fprintf(fid,'\t \t %s \t %s \n',sensor_data_string,values_data_string);
        end
        fprintf(fid,'\n');

        fprintf(fid,'Offending sensor caused by %s \n\n ',offending_sensor);
    end

else
    return_flag = 0; % Indicate that the return was NOT forced
end


% Tell the user what is happening?
if 0~=fid
    fprintf(fid,'\n\t Flag %s set to: %.0f\n\n',flag_name, flags.(flag_name));
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
if flag_do_plots && isempty(findobj('Number',fig_num))

    % Nothing to plot
end

if  flag_do_debug
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

