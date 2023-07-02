function [dataArray, sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, field_string, varargin)

% fcn_DataClean_pullDataFromFieldAcrossAllSensors
% Pulls a given field's data from all sensors. If the field does not exist,
% it returns an empty array for that field
%
% FORMAT:
%
%      dataArray = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,field_string,(sensor_identifier_string), (entry_location), (fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed 
%
%      field_string: the field whose data is to be collected
%
%      (OPTIONAL INPUTS)
%
%      sensor_identifier_string: a string that is used to select only some
%      sensor fields, matched using lower-case comparisons. For example, if
%      sensor_identifier_string = 'GPS', then all sensors whose names, when
%      coverted to lower case, contain 'gps' will be queried. If there are
%      only 3 sensors with 'gps' in their name, then the resulting
%      dataArray and sensorNames will only have 3 entries.
% 
%      entry_location: a string specifying which element to keep, if the
%      data is an array:
%      
%            'first_row' - saves the first element of the first column, i.e. (1,1)
%            'last_row'  - saves the last element of the first column, i.e. (end,1)
%            'all'   - (default) saves the entire array
%
%      fid: a file ID to print results of analysis. If not entered, no
%      printing is done. Set fid to 1 to print to the console.
%
% OUTPUTS:
%
%      dataArray: a data structure in cell array form containing the data
%      from every sensor
%
%      sensorNames: a structure containing an array of each sensor's name
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_pullDataFromFieldAcrossAllSensors
%     for a full test suite.
%
% This function was written on 2023_06_29 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_06_29: sbrennan@psu.edu
% -- wrote the code originally 

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
    if nargin < 2 || nargin > 5
        error('Incorrect number of input arguments')
    end
        
end

% Does the user want to specify the sensors_to_search
sensor_identifier_string = '';
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        sensor_identifier_string = temp;
    end
end

% Does the user want to specify the entry_location?
entry_location = 'all';
if 4 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        entry_location = temp;
    end
end


% Does the user want to specify the fid?
fid = 0; % Default is 0 (not printing)
if 5 == nargin
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

st = dbstack; 
if fid~=0
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

% Produce a list of all the sensors (each is a field in the structure)
sensorNames = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

% Initialize dataArray and sensorNames variables
if ~isempty(sensor_identifier_string)
    matched_indicies = contains(lower(sensorNames),lower(sensor_identifier_string));
    Nsensors = sum(matched_indicies);
    
    % If there were no matches, just exit now
    if Nsensors==0
        dataArray{1} = [];
        sensorNames = '';
        return
    end
    
    sensorNames = sensorNames(matched_indicies);
else
    Nsensors = length(sensorNames);    
end

% Initialize the data array
dataArray{Nsensors}        = [];

if 0~=fid
    fprintf(fid,'\nPulling data from field %s across all sensors:\n',field_string);
end

% Loop through the fields, searching for ones that have "GPS" in their name
for ith_sensor = 1:Nsensors

    % Grab the sensor subfield name
    sensor_name = sensorNames{ith_sensor};
    sensor_data = dataStructure.(sensor_name);

    % Tell what we are doing
    if 0~=fid
        fprintf(fid,'\t Loading data from sensor %d of %d: %s\n',ith_sensor,length(sensorNames),sensor_name);
    end

    % Does the field exist?
    if isfield(sensor_data, field_string)
        dataArray{ith_sensor} = sensor_data.(field_string);
    else
        dataArray{ith_sensor} = [];
    end
end

%            'first_row' - saves the first element of the first column, i.e. (1,1)
%            'last_row'  - saves the last element of the first column, i.e. (end,1)
%            'all'   - (default) saves the entire array

switch entry_location
    case 'all'
        % Do nothing, return
    case 'first_row' % saves the first element of the first column, i.e. (1,1)
        for ith_sensor = 1:Nsensors
            if length(dataArray{ith_sensor}(:,1))>=1
                dataArray{ith_sensor} = dataArray{ith_sensor}(1,1);
            end
        end
    case 'last_row' % saves the first element of the first column, i.e. (1,1)
        for ith_sensor = 1:Nsensors
            if length(dataArray{ith_sensor}(:,1))>=1
                dataArray{ith_sensor} = dataArray{ith_sensor}(end,1);
            end
        end
    otherwise
        error('unrecognized position requested for data retrieval');
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

