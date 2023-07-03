function [flags,offending_sensor,return_flag] = fcn_DataClean_checkFieldCountMatchesTimeCount(dataStructure, field_name,varargin)

 % fcn_DataClean_checkFieldCountMatchesTimeCount
% Checks a given dataStructure to check, for each sensor, whether all the
% fields have the same vector length as a given time field. If the time
% field is not specified, then the 'Trigger_Time' field is used.
%
% FORMAT:
%
%      [flags,offending_sensor] = fcn_DataClean_checkFieldCountMatchesTimeCount(...
%          dataStructure,field_name,...
%          (flags),(time_field),(sensors_to_check),(fid))
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
%      time_field: a string listing the time field to use as reference. The
%      default is 'Trigger_Time', but other common options are 'GPS_Time'
%      and 'ROS_Time'.
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
%     See the script: script_test_fcn_DataClean_checkFieldCountMatchesTimeCount
%     for a full test suite.
%
% This function was written on 2023_07_02 by S. Brennan, based on
% fcn_DataClean_checkIfFieldHasNaN as a template.
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
    narginchk(2,6);
end

% Does the user want to specify the flags?
flags = struct;
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        flags = temp;
    end
end

% Does the user want to specify the string_any_or_all?
time_field = 'Trigger_Time';
if 4 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        time_field = temp;
    end
end


% Does the user want to specify the sensors_to_check?
sensors_to_check = '';
if 5 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        sensors_to_check = temp;
    end
end


% Does the user want to specify the fid?
fid = 0;
% Check for user input
if 6 <= nargin
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
if flag_check_all_sensors
    flag_name = sprintf('%s_has_same_length_as_%s_in_all_sensors',field_name,time_field);
else
    flag_name =  sprintf('%s_has_same_length_as_%s_in_%s_sensors',field_name,time_field,sensors_to_check);
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
    fprintf(fid,'Checking that %s field has same number of data points as %s:\n',field_name,time_field);
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
            if length(sensor_data.(subFieldName)(:,1))~=length(sensor_data.(time_field)(:,1))
                flags_sensor_field_has_correct_length = 0;
                break;
            end  % Ends if to check if the field is a cell
        end % Ends if to check if field is a "Sigma" field
        
    end % Ends for loop through the subfields
    
    
    
    flags.(flag_name) = flags_sensor_field_has_correct_length;
    if 0==flags.(flag_name)
        offending_sensor = sensor_name; % cat(2,sensor_name, ' ' ,subFieldName); % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end    
   
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


