function fixed_dataStructure = fcn_DataClean_sortSensorDataByGPSTime(dataStructure,varargin)
% fcn_DataClean_sortSensorDataByGPSTime
% Finds sensors where the GPS_Time is not sorted in ascending order. It
% then sorts this data, recording the sorting order, and moves all other
% data in that same sensor by the same sorting order.
%
% Also allows the type of sensor, for example 'GPS', to be selected.
%
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_sortSensorDataByGPSTime(...
%         dataStructure,(field_name),(sensors_to_check),(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed 
%
%      (OPTIONAL INPUTS)
%
%      field_name: a string idicating the field to be checked, for example
%      'GPS_Time' (default)
%
%      sensors_to_check: a string idicating the sensors to be checked, for
%      example 'GPS' (default)
%
%      fid: a file ID to print results of analysis. If not entered, the
%      function does not print (FID is 0). Set FID to 1 to print to the
%      console.
%
% OUTPUTS:
%
%      fixed_dataStructure: a data structure with repeated values removed
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_sortSensorDataByGPSTime
%     for a full test suite.
%
% This function was written on 2023_07_01 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
%
% 2023_07_01: sbrennan@psu.edu
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
    narginchk(1,4);

end


% Check for user-defined field_name input
field_name = 'GPS_Time'; % Set the default
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        field_name = temp;
    end
end

% Check for user-defined field_name input
sensors_to_check = 'GPS'; % Set the default
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        sensors_to_check = temp;
    end
end

% Does the user want to specify the fid?
fid = 0; % Default case is to NOT print to the console
if 4 <= nargin
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

if fid~=0
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

% Report what we are doing
if 0~=fid
    fprintf(fid,'Checking for non-increasing ordering of %s data ',field_name);
    fprintf(fid,'in all %s sensors:\n', sensors_to_check);
end

% Initialize the outputs
fixed_dataStructure = dataStructure;

% Produce a list of all the sensors that meet the search criteria, and grab
% their data also
[data,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, field_name,sensors_to_check);

for ith_data = 1:length(sensorNames)
    % Grab the sensor subfield name and the data
    sensor_name = sensorNames{ith_data};
    sensor_data = dataStructure.(sensor_name);
    GPS_Time_data = data{ith_data};

    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',ith_data,length(sensorNames),sensor_name);
    end
    
    % Is this data sorted?
    if ~issorted(GPS_Time_data,'strictascend')
        
        % Find the sorted values, saving indicies where data is going to
        % move to
        [~,indicies_data] = sort(GPS_Time_data,1,'ascend');
        
        % Tell the user what we are doing
        if fid
            fprintf(fid,'\t\t Unsorted time found. Looping through subfields to resort corresponding data.\n');
        end
        
        % Define the reference length - all arrays in the sensor must match
        % this one
        lengthReference = length(GPS_Time_data);
        
        % Loop through subfields
        subfieldNames = fieldnames(sensor_data);
        for i_subField = 1:length(subfieldNames)
            % Grab the name of the ith subfield
            subFieldName = subfieldNames{i_subField};
            
            if fid
                fprintf(fid,'\t\t\t Resorting field: %s.\n',subFieldName);
            end
            
            if ~iscell(dataStructure.(sensor_name).(subFieldName)) % Is it a cell? If yes, skip it
                if length(dataStructure.(sensor_name).(subFieldName)) ~= 1 % Is it a scalar? If yes, skip it
                    % It's an array, make sure it has right length
                    if lengthReference~= length(dataStructure.(sensor_name).(subFieldName))
                        error('Sensor %s contains a datafield %s that is an array, but not equal to the query field. This is usually because data is missing.',sensor_name,subFieldName);
                    end
                    
                    % Replace the values
                    fixed_dataStructure.(sensor_name).(subFieldName) = dataStructure.(sensor_name).(subFieldName)(indicies_data,:);
                end
            end
            
        end % Ends for loop through the subfields
            
        % Fix the Npoints
        fixed_dataStructure.(sensor_name).Npoints = length(indicies_data);

    end % Ends if to see if it is sorted
end % Ends for loop

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

