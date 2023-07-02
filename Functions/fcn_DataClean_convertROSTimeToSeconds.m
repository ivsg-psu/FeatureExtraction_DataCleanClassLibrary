function fixed_dataStructure = fcn_DataClean_convertROSTimeToSeconds(dataStructure,varargin)
% fcn_DataClean_convertROSTimeToSeconds
% Checks whether ROS time is mis-scaled relative to GPS Time. If it is, it
% is fixed to the correct scaling
%
% Also allows the type of sensor, for example 'GPS', to be selected.
%
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_convertROSTimeToSeconds(...
%         dataStructure,(sensors_to_check),(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed 
%
%      (OPTIONAL INPUTS)
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
%     See the script: script_test_fcn_DataClean_convertROSTimeToSeconds
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
    narginchk(1,3);

end


% Check for user-defined field_name input
sensors_to_check = 'GPS'; % Set the default
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        sensors_to_check = temp;
    end
end

% Does the user want to specify the fid?
fid = 0; % Default case is to NOT print to the console
if 3 <= nargin
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
    fprintf(fid,'Checking for ROS_Time that have scale factor errors\n');
    fprintf(fid,'in all %s sensors:\n', sensors_to_check);
end

% Initialize the outputs
fixed_dataStructure = dataStructure;

% Produce a list of all the sensors that meet the search criteria, and grab
% their data also
[~,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time',sensors_to_check);

% Keep track of which ones are good
flags_data_good = ones(length(sensorNames),1);

for i_data = 1:length(sensorNames)
    % Grab the sensor subfield name
    sensor_name = sensorNames{i_data};
    sensor_data = dataStructure.(sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensorNames),sensor_name);
    end
    
    GPS_Time = sensor_data.GPS_Time;
    ROS_Time = sensor_data.ROS_Time;

    if length(GPS_Time(:,1)) ~= length(ROS_Time(:,1))
        error('Dissimilar ROS and GPS time lengths detected. This indicates a major sensor error.');
    end
    
    % Calculate the ratio of times
    mean_ratio = mean(ROS_Time./GPS_Time);
    
    % Check if the ratio is off by almost exactly 1E9
    if (0.95*1E9)<mean_ratio && mean_ratio<(1.05*1E9)
        flags_data_good(i_data,1) = 0;
    elseif 0.95 > mean_ratio || mean_ratio>1.05
        % Make sure the ratio is close to 1, if it is not 1E9
        error('Strange ratio detected between ROS Time and GPS Time');
    end            
end

%% Perform the fix
sensorsToFix = sensorNames(flags_data_good==0);

% Were any of the sensors bad?
if ~isempty(sensorsToFix)
    
    for ith_data = 1:length(sensorsToFix)
        % Grab the sensor subfield name and the data
        sensor_name = sensorsToFix{ith_data};
        sensor_data = dataStructure.(sensor_name);
        ROS_Time = sensor_data.ROS_Time;
                
        fixed_dataStructure.(sensor_name).ROS_Time = ROS_Time/1E9;            
    end % Ends for loop
    
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
