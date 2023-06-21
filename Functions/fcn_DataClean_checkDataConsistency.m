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
flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
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

% Initialize offending_sensor
offending_sensor = '';

%% Loop thorough all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if flag_do_debug
        fprintf(fid,'\n Sensor %d of %d: ',i_data,length(sensor_names));
    end

    %% Check existence of time data in each sensor
    if flag_do_debug
        fprintf(fid,'Checking existence of time data:\n');
    end
    flags_GPS_Time_exists= 1;
    if ~isfield(sensor_data,'GPS_Time')
        flags_GPS_Time_exists = 0;
    elseif isempty(sensor_data.GPS_Time)
        flags_GPS_Time_exists = 0;
    elseif all(isnan(sensor_data.GPS_Time))
        flags_GPS_Time_exists = 0;        
    end
    flags.GPS_Time_exists = flags_GPS_Time_exists;
    if 0==flags.GPS_Time_exists
        offending_sensor = sensor_name; % Save the name of the sensor
        return; % Exit the function immediately to avoid more processing
    end

    %% Check existence of core data elements: centiSeconds
    if flag_do_debug
        fprintf(fid,'Checking existence of time data:\n');
    end
    flags_core_data_fields_exist = 1;
    if ~isfield(sensor_data,'GPS_Time')
        flags_core_data_fields_exist = 0;
    elseif isempty(sensor_data.GPS_Time)
        flags_core_data_fields_exist = 0;
    elseif all(isnan(sensor_data.GPS_Time))
        flags_core_data_fields_exist = 0;        
    end
    flags.GPS_Time_exists = flags_core_data_fields_exist;
    if 0==flags.GPS_Time_exists
        offending_sensor = sensor_name; % Save the name of the sensor
        return; % Exit the function immediately to avoid more processing
    end

    %% Check consistency of time data
    if flag_do_debug
        fprintf(fid,'Checking existence of time data:\n');
    end
    centiSeconds = sensor_data.centiSeconds;

    if isfield(d,'GPS_Time')
        if centiSeconds ~= round(100*mean(diff(d.GPS_Time)))
            error('For sensor: %s, the centiSeconds does not match the calculated time difference in GPS_Time',sensor_name);
        end
    end
    %
    %
    %     if flag_do_debug
    %         fprintf(fid,'Searching NaN within fields for sensor: %s\n',sensor_name);
    %     end
    %     subfieldNames = fieldnames(d); % Grab all the subfields
    %     for i_subField = 1:length(subfieldNames)
    %         % Grab the name of the ith subfield
    %         subFieldName = subfieldNames{i_subField};
    %
    %         if flag_do_debug
    %             fprintf(fid,'\tProcessing subfield: %s ',subFieldName);
    %         end
    %
    %         % Check to see if this subField has any NaN
    %         if ~iscell(d.(subFieldName))
    %             if any(isnan(d.(subFieldName)))
    %                 if flag_do_debug
    %                     fprintf(fid,' <-- contains an NaN value\n');
    %                 end
    %             else % No NaNs found
    %                 if flag_do_debug
    %                     fprintf(fid,'\n');
    %                 end
    %
    %             end % Ends the if statement to check if subfield is on list
    %         end  % Ends if to check if the fiel is a call
    %     end % Ends for loop through the subfields
    
end  % Ends for loop through all sensor names in dataStructure


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
