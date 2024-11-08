function timeFilteredData = fcn_DataClean_timeFilterData(cleanAndTimeAlignedData)
% fcn_DataClean_timeFilterData
% This function performs time-based filtering on the selected data. The
% time filtering is intended to force the data to follow vehicle dynamic
% frequencies. For now, it is just limited to 1 Hz.
%
% FORMAT:
%
%      timeFilteredData = fcn_DataClean_timeFilterData(cleanAndTimeAlignedData)
%
% INPUTS:
%
%      cleanAndTimeAlignedData: 
%
%      (OPTIONAL INPUTS)
%
%      (none)
%
% OUTPUTS:
%
%      timeFilteredData: 
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_timeFilterData
%     for a full test suite.
%
% This function was written on 2019_11_20 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2019_11_20 - first write of the code by sbrennan@psu.edu
% 2019_11_27 - fixed comments, and added sigma filtering to smooth this
%              out.
% 2020_11_10 - changed function names in prep for DataClean class
% 2023_06_19 - Updated the function description according to the IVSG
% format and renamed the function to "fcn_DataClean_removeGPSJumps" from 
% "fcn_DataClean_removeDGPSJumpsFromMergedData"

% TO DO
% 

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

% flag_do_debug = 1;
% 
% if flag_do_debug
%     % Grab function name
%     st = dbstack;
%     namestr = st.name;
% 
%     % Show what we are doing
%     fprintf(1,'\nWithin function: %s\n',namestr);
%     fprintf(1,'Starting iterations through rawData structure to calculate sigma values.\n');    
% end

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
    if nargin < 1 || nargin > 1
        error('Incorrect number of input arguments')
    end
        
    % NOTE: zone types are checked below

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

%% Define which fields to filter
fields_to_calculate_filtered_signals = [...
    {'Yaw_deg'},...
    {'Yaw_deg_from_position'},...
    {'Yaw_deg_from_velocity'},...
    {'velMagnitude'},...
    {'XAccel'}...
    {'YAccel'}...
    {'ZAccel'}...
    {'velNorth'},...
    {'velEast'},...
    {'velUp'},...
    {'velMagnitude'},...
    {'Roll_deg'},...
    {'Pitch_deg'},...
    {'xy_increments'}... % Confirmed
    {'XGyro'}...
    {'YGyro'}...
    {'ZGyro'}...
    {'xEast_increments'}...
    {'yNorth_increments'}...
    {'xEast'}...
    {'yNorth'}...
    ];

% Define a list of sigma values that will be calculated
sigma_fields_to_calculate_filtered_signals = []; % Initialize the vector
for i_field = 1:length(fields_to_calculate_filtered_signals)
    field_name = fields_to_calculate_filtered_signals{i_field};
    sigma_name = cat(2,field_name,'_Sigma');
    sigma_fields_to_calculate_filtered_signals = ...
        [sigma_fields_to_calculate_filtered_signals, {sigma_name}]; %#ok<AGROW>
end

%% Loop through data structure, and find sensors to filter
sensorStrings = fieldnames(cleanAndTimeAlignedData); % Grab all the fields that are in rawData structure
for i_data = 1:length(sensorStrings)
    % Grab the data subfield name
    thisSensorString = sensorStrings{i_data};
    d = cleanAndTimeAlignedData.(thisSensorString);
    
    if flag_do_debug
        fprintf(1,'\n Sensor %d of %d: ',i_data,length(sensorStrings));
        fprintf(1,'Calculating filtered signals for sensor: %s\n',thisSensorString);
    end
    
    subfieldNames = fieldnames(d); % Grab all the subfields
    clear dout; % Make sure dout is empty at start
    for i_subField = 1:length(subfieldNames)
        % Grab the name of the ith subfield
        subFieldName = subfieldNames{i_subField};

        if flag_do_debug
            fprintf(1,'\tProcessing subfield: %s ',subFieldName);
        end
        
        % The sigma fields are calculated separately, so need to not
        % overwrite them.
        if ~any(strcmp(subFieldName,sigma_fields_to_calculate_filtered_signals))
            % Copy over the field itself first
            dout.(subFieldName) = d.(subFieldName);
        end
        
        % Check to see if this subField is in the list for time filtering
        if any(strcmp(subFieldName,fields_to_calculate_filtered_signals))
            % Data is on the list to be filtered... grab it
            data = d.(subFieldName);
            
            % Get the time sample
            if isfield(d,'GPS_Time_deltaT_target')
                deltaT = d.GPS_Time_deltaT_target;
            elseif isfield(d,'ROS_Time_deltaT_target')
                deltaT = d.ROS_Time_deltaT_target;
            else
                error('Time target cannot be determined for: %s ... exiting.',thisSensorString);
            end
            
            w_Nyquist = 1/(2*deltaT);
            
            % Calculate the filtered data
            [b,a] = butter(2,1/w_Nyquist); % Default to 1 Hz filtering for data (fix this later)
            if ~all(isnan(data)) 
                if any(isnan(data))
                    data = fillmissing(data,'linear');
                end
                data_filtered = filtfilt(b,a,data);

            else
                data_filtered = data; % Just pass through the NaNs
            end            
            dout.(subFieldName) = data_filtered;
            
            % Added the following section on 2019_11_27 to fix Sigma
            % dicontinuities:
            % Check the sigma for this field, and if exists, filter that
            % too (but more aggressively)
            sigma_name = cat(2,subFieldName,'_Sigma');
            if isfield(d,sigma_name)
                sigma_data = d.(sigma_name);

                if ~all(isnan(sigma_data))
                    if any(isnan(sigma_data))
                        sigma_data = fillmissing(sigma_data,'linear');
                    end
                    if length(sigma_data(:,1))>20 
                        sigma_data_filtered = movmean(sigma_data,20);
                    else
                        sigma_data_filtered = sigma_data; % Just pass through 
                    end
                else
                    sigma_data_filtered = sigma_data; % Just pass through the NaNs
                end
                dout.(sigma_name) = sigma_data_filtered;
            end
            % End of addition on 2019_11_27
            
            % For debugging: figure; hold on; plot(data); plot(data_filtered)
            % For debugging: figure; hold on; plot(sigma_data); plot(sigma_data_filtered)
            
            if flag_do_debug
                fprintf(1,' <-- calculated the filtered value at 1 Hz\n');
            end
        elseif any(strcmp(subFieldName,sigma_fields_to_calculate_filtered_signals))
            if flag_do_debug
                fprintf(1,' <-- calculated from a moving mean across 1 second\n');
            end
            
        else% Subfield is not on the list - do nothing
            if flag_do_debug
                % fprintf(1,' <-- calculated a sigma, has length: %d\n',length(real_sigma(:,1)));
                fprintf(1,'\n');
            end
            
        end % Ends the if statement to check if subfield is on list
    end % Ends for loop through the subfields

    timeFilteredData.(thisSensorString) = dout; % Save results to main structure
    
end  % Ends for loop through all sensor names in rawData

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
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end


end % Ends the function

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

