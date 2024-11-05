function updated_dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure, sensors_to_merge, merged_sensor_name, method_name, varargin)

% fcn_DataClean_mergeSensorsByMethod
% Merges two sensors together by a selected method
%
% FORMAT:
%
%      updated_dataStructure = fcn_DataClean_mergeSensorsByMethod(dataStructure, sensors_to_merge, merged_sensor_name, method_name, (fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be corrected
%
%      sensors_to_merge: a string specifying a search term to match for all
%      sensors to merge, for example 'ADIS'. The search is case
%      insensitive.
%
%      merged_sensor_name: a string to name the resulting merged sensor.
%      The merged sensors will be deleted.
%
%      method_name: a string specifying how the merger should take place.
%      The following strings are allowed:
%
%            'keep_all': the fields from all sensors are kept. If a field
%            is repeated from one sensor to another, the repeated name is
%            appended with "2", then "3", etc.
%
%            'keep_unique': the fields from all sensors are kept only if
%            their contents are different. If a field contains new data and
%            is repeated from one sensor to another, the repeated name is
%            appended with "2", then "3", etc.
%
%      (OPTIONAL INPUTS)
%
%      fid: a file ID to print results of analysis. If not entered, the
%      console (FID = 1) is used.
%
% OUTPUTS:
%
%      updated_dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
% DEPENDENCIES:
%
%      fcn_DataClean_findMatchingSensors
%      fcn_DebugTools_debugPrintStringToNCharacters
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_mergeSensorsByMethod
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
%
% 2023_07_04: sbrennan@psu.edu
% -- wrote the code originally
% 2024_09_26: sbrennan@psu.edu
% -- updated to comments
% -- added debug flag area
% -- fixed fid printing error

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
    if flag_check_inputs
        % Are there the right number of inputs?
        narginchk(4,5);

    end
end


% Does the user want to specify the fid?
if (0==flag_max_speed) && (5 <= nargin)
    temp = varargin{end};
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
else
    fid = 0;
end

flag_do_plots = 0; % Shut off plotting

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
% This finds all the sensors in the dataStructure that have the
% "sensors_to_merge" string insisde the sensor name
sensor_names = fcn_DataClean_findMatchingSensors(dataStructure, sensors_to_merge);


%% STEP 1: Grab the names of both the sensors and their subfields
% storing all in a cell array all_sensors_and_fields

% Create variables to store information
all_field_names{1}  = '';
all_subfield_names{1} = '';

% Loop through the fields and subfields to make a list of all the field and
% subfield names.

Nfields = 0;
for ith_sensor = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{ith_sensor};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking fields within sensor %d of %d: %s\n',ith_sensor,length(sensor_names),sensor_name);
    end
    
    % Loop through subfields
    subfieldNames = fieldnames(sensor_data);
    for ith_subField = 1:length(subfieldNames)
        % Grab the name of the ith subfield
        subFieldName = subfieldNames{ith_subField};
        
        % Save the results
        Nfields = Nfields + 1;        
        all_subfield_names{Nfields} = sensor_name; %#ok<AGROW>
        all_field_names{Nfields}  = subFieldName; %#ok<AGROW>
        
    end % ends loop through subFields
end

%% STEP 2: loop through each of the fields, and check if it is repeated
Nfields = length(all_field_names);
all_total_repeats = nan(Nfields,1); % This is the total number of times the field shows up
all_repeat_count      = zeros(Nfields,1); % This is the instance of the repeat, for example 1st time, 2nd, etc.

% Check if there are repeats
for ith_field = 1:Nfields
    if isnan(all_total_repeats(ith_field))
        field_name = all_field_names{ith_field};
        matched_indicies = contains(lower(all_field_names),lower(field_name))';
        
        % Save the results
        repeat_count = cumsum(matched_indicies);
        all_total_repeats(matched_indicies) = sum(matched_indicies);
        all_repeat_count(matched_indicies) = repeat_count(matched_indicies);
    end
end

%% STEP 3: check which fields have the same data
flags_field_data_is_repeated = zeros(Nfields,1);
% Check if there are repeats in data
for ith_field = 1:Nfields
    if all_total_repeats(ith_field)>1 % This is a repeat
        sensor_name = all_subfield_names{ith_field};
        field_name = all_field_names{ith_field};
        
        % Check which ones match
        matched_indicies = find(contains(lower(all_field_names),lower(field_name)));
        
        % Seach only indicies larger than the current one
        matched_indicies = matched_indicies(matched_indicies>ith_field);
        reference_data = dataStructure.(sensor_name).(field_name);
        for ith_repeat = 1:length(matched_indicies)
            comparison_field = matched_indicies(ith_repeat);
            sensor_name_to_check = all_subfield_names{comparison_field};
            field_name_to_check = all_field_names{comparison_field};
            data_to_check = dataStructure.(sensor_name_to_check).(field_name_to_check);

            % Check to see if data are equal!
            
            if (isequal(reference_data,data_to_check))|(all([all(isnan(reference_data)), all(isnan(data_to_check))]))
                flags_field_data_is_repeated(comparison_field) = ith_field;
            end

        end % Ends for loop through repeat checks
    end % Ends if statement to check if repeats on this field
end % Ends loop down the field list

%% Print results so far?
if fid>0
    % Find the longest sensor name
    longest_sensor_string = 0;
    for ith_name = 1:length(all_subfield_names)
        if length(all_subfield_names{ith_name})>longest_sensor_string
            longest_sensor_string = length(all_subfield_names{ith_name});
        end
    end
    longest_sensor_string = max(longest_sensor_string,10);

    % Find the longest field name
    longest_field_string = 0;
    for ith_name = 1:length(all_field_names)
        if length(all_field_names{ith_name})>longest_field_string
            longest_field_string = length(all_field_names{ith_name});
        end
    end
    longest_field_string = max(longest_field_string,10);

    % Print results
    fprintf(fid,'\n\t Attempting merge of ''%s'' sensors to create ''%s'', using method ''%s'' on the following sensors and fields: \n\n',sensors_to_merge,merged_sensor_name,method_name);
    
    % Print start time table
    NdataColumn = 30;
    row_title_string       = fcn_DebugTools_debugPrintStringToNCharacters('Row:',7);
    sensor_title_string    = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',longest_sensor_string);
    field_title_string     = fcn_DebugTools_debugPrintStringToNCharacters('Fields:',longest_field_string);
    total_repeats_string   = fcn_DebugTools_debugPrintStringToNCharacters('N Repeats Across Sensors:',NdataColumn);
    repeat_instance_string = fcn_DebugTools_debugPrintStringToNCharacters('Field Repeat Instance:',NdataColumn);
    data_repeated_string   = fcn_DebugTools_debugPrintStringToNCharacters('Data Repeated? (row):',NdataColumn);
    
    fprintf(fid,'\t \t %s \t %s \t %s \t %s \t %s \t %s \n',row_title_string, sensor_title_string,field_title_string,total_repeats_string,repeat_instance_string,data_repeated_string);
    for ith_data = 1:length(all_subfield_names)
        row_data_string         = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%d:',ith_data),7);
        sensor_data_string      = fcn_DebugTools_debugPrintStringToNCharacters(all_subfield_names{ith_data},longest_sensor_string);
        field_data_string       = fcn_DebugTools_debugPrintStringToNCharacters(all_field_names{ith_data},longest_field_string);
        total_data_string       = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%d',all_total_repeats(ith_data)),NdataColumn);
        repeat_instance_string  = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%d',all_repeat_count(ith_data)),NdataColumn);
        data_repeated_string    = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%d',flags_field_data_is_repeated(ith_data)),NdataColumn);
        fprintf(fid,'\t \t %s \t %s \t %s \t %s \t %s \t %s \n',row_data_string, sensor_data_string,field_data_string,total_data_string,repeat_instance_string,data_repeated_string);
    end
    fprintf(fid,'\n');
end

%% STEP 4: fill in the merged structure
% Initialize the merged structure
merged_sensor = struct;

% Initialize the output
updated_dataStructure = dataStructure;

for ith_sensor = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{ith_sensor};
    
    % Clean the data that was transferred out of the updated_dataStructure
    updated_dataStructure = rmfield(updated_dataStructure,sensor_name);
end

% Loop through the fields, keeping the fields as flagged above
for ith_field = 1:Nfields
    % Grab the sensor and field names
    field_name  = all_field_names{ith_field};
    sensor_name = all_subfield_names{ith_field};
    
    if 0~=fid
        fprintf(fid,'\t Merging field %d of %d, %s from sensor %s\n',ith_field,Nfields,field_name, sensor_name);
    end
    
    
    % Is this field a repeat?
    if all_repeat_count(ith_field)==1
        merged_sensor.(field_name) = dataStructure.(sensor_name).(field_name);
    else
        % Both sensors have the same subfields - how do we merge them?
        switch method_name
            case 'keep_all'
                %            'keep_all': the fields from all sensors are kept. If a field
                %            is repeated from one sensor to another, the repeated name is
                %            appended with "2", then "3", etc.
                new_name = sprintf('%s%d',field_name,all_repeat_count(ith_field));
                merged_sensor.(new_name) = dataStructure.(sensor_name).(field_name);
            case 'keep_unique'
                %            'keep_unique': the fields from all sensors
                %            are kept only if their contents are
                %            different. If a field contains new data
                %            and is repeated from one sensor to
                %            another, the repeated name is appended
                %            with "2", then "3", etc.
                if flags_field_data_is_repeated(ith_field)==0
                    if all(isnan(merged_sensor.(field_name)))
                        merged_sensor.(field_name)= dataStructure.(sensor_name).(field_name);
                    else
                        new_name = sprintf('%s%d',field_name,all_repeat_count(ith_field));
                        merged_sensor.(new_name) = dataStructure.(sensor_name).(field_name);
                
                    end
                end
            otherwise
                error('Unrecognized method_name for sensor merging');
        end % Ends switch case
        
    end % Ends if statment checking if field is repeated
    
end % Ends looping through sensors
updated_dataStructure.(merged_sensor_name) = merged_sensor;




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

