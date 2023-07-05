function updated_dataStructure = fcn_DataClean_renameSensorsToStandardNames(dataStructure,varargin)

% fcn_DataClean_renameSensorsToStandardNames
% renames sensor fields to standard names
%
% FORMAT:
%
%      updated_dataStructure = fcn_DataClean_renameSensorsToStandardNames(dataStructure,(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be corrected
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
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_renameSensorsToStandardNames
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
%
% 2023_07_04: sbrennan@psu.edu
% -- wrote the code originally

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
    narginchk(1,2);
    
end


% Does the user want to specify the fid?
if 2 <= nargin
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

%% Create a dictionary mapping bad names to good ones
correct_names = {...
'GPS_Hemisphere_TopCenter';
'DIAGNOSTIC_USDigital_RearAxle';
'DIAGNOSTIC_TrigBox_RearTop';
'NTRIP_Hotspot_Rear';
'ENCODER_USDigital_RearAxle';
'TRIGGER_TrigBox_RearTop';
'LIDAR_Sick_Rear';
'DIAGNOSTIC_Sparkfun_RearLeft';
'DIAGNOSTIC_Sparkfun_RearRight';
'TRANSFORM_ROS_Rear';
'GPS_SparkFun_RearRight';
'GPS_SparkFun_RearLeft';
'IMU_Adis_TopCenter'};
Ngood = length(correct_names);

name_pairs = {...
'Hemisphere_DGPS','GPS_Hemisphere_TopCenter';
'diagnostic_encoder','DIAGNOSTIC_USDigital_RearAxle';
'diagnostic_trigger','DIAGNOSTIC_TrigBox_RearTop';
'ntrip_info','NTRIP_Hotspot_Rear';
'Raw_Encoder','ENCODER_USDigital_RearAxle';
'RawTrigger','TRIGGER_TrigBox_RearTop';
'SickLiDAR','LIDAR_Sick_Rear';
'sparkfun_gps_diag_rear_left', 'DIAGNOSTIC_Sparkfun_RearLeft';
'sparkfun_gps_diag_rear_right', 'DIAGNOSTIC_Sparkfun_RearRight';
'transform', 'TRANSFORM_ROS_Rear';
};

[Npairs,~] = size(name_pairs);
for ith_pair = 1:Npairs    
    badNames{ith_pair} = name_pairs{ith_pair,1}; %#ok<AGROW>
    goodNames{ith_pair} = name_pairs{ith_pair,2}; %#ok<AGROW>
end
for ith_pair = 1:Ngood    
    badNames{ith_pair+Npairs} = correct_names{ith_pair};
    goodNames{ith_pair+Npairs} = correct_names{ith_pair};
end


M = containers.Map(badNames,goodNames);
% IF using 2022b or later, --> BETTER: d = dictionary(badNames,goodNames);


%% Loop through all the fields, fixing them

sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure

%% Print results so far?
if fid
    % Find the longest from name
    longest_from_string = 0;
    for ith_name = 1:length(sensor_names)
        if length(sensor_names{ith_name})>longest_from_string
            longest_from_string = length(sensor_names{ith_name});
        end
    end
    longest_from_string = max(longest_from_string,10);

    % Find the longest to name
    longest_to_string = 0;
    for ith_name = 1:length(sensor_names)
        if length(M(sensor_names{ith_name}))>longest_to_string
            longest_to_string = length(M(sensor_names{ith_name}));
        end
    end
    longest_to_string = max(longest_to_string,10);

    % Print results
    fprintf(fid,'\n\t Converting sensor names to standard notion:\n');
    
    % Print start time table
    row_title_string       = fcn_DebugTools_debugPrintStringToNCharacters('Sensor number:',7);
    sensor_from_string    = fcn_DebugTools_debugPrintStringToNCharacters('From:',longest_from_string);
    sensor_to_string     = fcn_DebugTools_debugPrintStringToNCharacters('To:',longest_to_string);    
    fprintf(fid,'\t \t %s \t %s \t %s \n',row_title_string, sensor_from_string,sensor_to_string);

    for ith_data = 1:length(sensor_names)
        row_data_string         = fcn_DebugTools_debugPrintStringToNCharacters(sprintf('%d:',ith_data),7);
        sensor_from_data_string      = fcn_DebugTools_debugPrintStringToNCharacters(sensor_names{ith_data},longest_from_string);
        sensor_to_data_string       = fcn_DebugTools_debugPrintStringToNCharacters(M(sensor_names{ith_data}),longest_to_string);
        fprintf(fid,'\t \t %s \t %s \t %s \n',row_data_string, sensor_from_data_string,sensor_to_data_string);
    end
    fprintf(fid,'\n');
end


for ith_sensor = 1:length(sensor_names)

    sensor_name = sensor_names{ith_sensor};
    updated_dataStructure.(M(sensor_name)) = dataStructure.(sensor_name);
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

