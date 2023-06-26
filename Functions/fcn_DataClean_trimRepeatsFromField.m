function trimmed_dataStructure = fcn_DataClean_trimRepeatsFromField(dataStructure,varargin)
% fcn_DataClean_trimRepeatsFromField
% Removes repeated data from a selected field within a sensor structure.
% For all repeated values, also deletes the corresponding data entries.
%
% Also allows the type of sensor, for example 'GPS', to be selected.
%
% FORMAT:
%
%      trimmed_dataStructure = fcn_INTERNAL_trimRepeatsFromField(...
%         dataStructure,(fid), (field_name),(sensors_to_check))
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
%      field_name: a string idicating the field to be checked, for example
%      'GPS_Time' (default)
%
%      sensors_to_check: a string idicating the sensors to be checked, for
%      example 'GPS' (default)
%
% OUTPUTS:
%
%      trimmed_dataStructure: a data structure with repeated values removed
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_trimRepeatsFromField
%     for a full test suite.
%
% This function was written on 2023_06_26 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
%
% 2023_06_26: sbrennan@psu.edu
% -- wrote the code originally

% TO DO


% Set default fid (file ID) first:
fid = 1; % Default case is to print to the console
flag_do_debug = 1;  %#ok<NASGU> % Flag to show the results for debugging
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
    narginchk(1,4);

end


% Does the user want to specify the fid?

% Check for user-defined fid input
if 2 <= nargin
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


% Check for user-defined field_name input
field_name = 'GPS_Time'; % Set the default
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        field_name = temp;
    end
end

% Check for user-defined field_name input
sensors_to_check = 'GPS'; % Set the default
if 3 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        sensors_to_check = temp;
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

% Report what we are doing
if 0~=fid
    fprintf(fid,'Checking for repeats in %s data ',field_name);
    fprintf(fid,'in all %s sensors:\n', sensors_to_check);
end

% Initialize the outputs
trimmed_dataStructure = dataStructure;

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

for i_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};

    if contains(sensor_name,sensors_to_check)
        sensor_data = dataStructure.(sensor_name);

        if 0~=fid
            fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),sensor_name);
        end

        % Find the unique values, indicies_data (indicies of what data to
        % keep), and indicies_unique (indicies indicating which data was
        % repeated)
        [~,indicies_data,indicies_unique] = unique(sensor_data.(field_name),'rows','stable');

        Nrepeats = length(indicies_unique)-length(indicies_data);
        if 0==Nrepeats
            fprintf(fid,'\t\t No repeats found\n');
        else
            fprintf(fid,'\t\t A total of %.0d repeats discovered.\n',Nrepeats);

            if Nrepeats/length(indicies_unique)>0.1
                if fid==1
                    fcn_DebugTools_cprintf('-Red','\t\t WARNING: More than 10%% of data is repeated - this indicates a faulty sensor!\n');
                else
                    warning('More than 10%% of data is repeated in a sensor field - this indicates a faulty sensor!');
                    fprintf(fid,'More than 10%% of data is repeated - this indicates a faulty sensor!\n');
                end
            end % Ends special warning for really bad data

            fprintf(fid,'\t\t Looping through subfields to remove repeats on all data.\n');
            lengthReference = length(sensor_data.(field_name)(:,1));

            % Loop through subfields
            subfieldNames = fieldnames(sensor_data);
            for i_subField = 1:length(subfieldNames)
                % Grab the name of the ith subfield
                subFieldName = subfieldNames{i_subField};

                fprintf(fid,'\t\t\t Checking field: %s.\n',subFieldName);

                if ~iscell(dataStructure.(sensor_name).(subFieldName)) % Is it a cell? If yes, skip it
                    if length(dataStructure.(sensor_name).(subFieldName)) ~= 1 % Is it a scalar? If yes, skip it
                        % It's an array, make sure it has right length
                        if lengthReference~= length(dataStructure.(sensor_name).(subFieldName))
                            error('Sensor %s contains a datafield %s that has an amount of data not equal to the query field. This is usually because data is missing.',sensor_name,subFieldName);
                        end

                        % Replace the values
                        trimmed_dataStructure.(sensor_name).(subFieldName) = dataStructure.(sensor_name).(subFieldName)(indicies_data,:);
                    end
                end

            end % Ends for loop through the subfields

            % Fix the Npoints
            trimmed_dataStructure.(sensor_name).Npoints = length(indicies_data);
        end % Ends if
    end % Ends check if this field should be checked
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

