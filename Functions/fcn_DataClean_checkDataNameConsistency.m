function [flags,offending_sensor] = fcn_DataClean_checkDataNameConsistency(dataStructure,varargin)

% fcn_DataClean_checkDataNameConsistency
% Checks a given dataset to verify whether data meets key time consistency
% requirements. 
%
% Name consistency refers to the raw data names and whether these are all
% logically consistent.
%
% The input is a structure that has as sub-fields each sensor, which in
% turn is a structure that also has key recordings each saved as
% sub-sub-fields. Many key features are tested in the data, changing
% certain flag values in a structure called "flags". 
% 
% The output is a structure 'flags' with subfield flags which are set so
% that the flag = 1 condition represents data that passes that particular
% consistency test. If any flags fail, the flag for that test is
% immediately set to zero and the offending sensor causing the failure is
% noted as a string output. The function immediately exits without checking
% any further flags.
%
% If no flag errors are detected, e.g. all flags = 1, then the
% 'offending_sensor' output is an empty string.
%
% FORMAT:
%
%      [flags,offending_sensor] = fcn_DataClean_checkDataNameConsistency(dataStructure,(fid),(fig_num))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      (OPTIONAL INPUTS)
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (FID = 0). Set fid to 1 for printing to console.
%
% OUTPUTS:
%
%      flags: a data structure containing subfields that define the results
%      of each verification check. 
%
%         # Sensor name tests include:
%         ## GPS_Sparkfun_sensors_are_merged  <--- WRITE THIS
%         ## Adis_Sparkfun_sensors_are_merged  <--- WRITE THIS
%         ## Sensors_follow_standard_convention (GPS_Hemisphere, for example) <--- WRITE THIS
% 
%         The above issues are explained in more detail in the following
%         sub-sections of the code:
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_checkDataNameConsistency
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_07_03: sbrennan@psu.edu
% -- wrote the code originally, using
% fcn_DataClean_checkDataTimeConsistency as a reference

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
    if nargin < 1 || nargin > 2
        error('Incorrect number of input arguments')
    end
        
end


% Does the user want to specify the fid?
fid = 0;
% Check for user input
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

offending_sensor = '';

% Initialize flags
flags = struct;
% flags.GPS_Time_exists_in_at_least_one_sensor = 0;

%         ## GPS_Sparkfun_sensors_are_merged  <--- WRITE THIS
%         ## Adis_Sparkfun_sensors_are_merged  <--- WRITE THIS
%         ## Sensors_follow_standard_convention (GPS_Hemisphere, for example) <--- WRITE THIS


%% Name consistency checks start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   _   _                         _____                _     _                           _____ _               _        
%  | \ | |                       / ____|              (_)   | |                         / ____| |             | |       
%  |  \| | __ _ _ __ ___   ___  | |     ___  _ __  ___ _ ___| |_ ___ _ __   ___ _   _  | |    | |__   ___  ___| | _____ 
%  | . ` |/ _` | '_ ` _ \ / _ \ | |    / _ \| '_ \/ __| / __| __/ _ \ '_ \ / __| | | | | |    | '_ \ / _ \/ __| |/ / __|
%  | |\  | (_| | | | | | |  __/ | |___| (_) | | | \__ \ \__ \ ||  __/ | | | (__| |_| | | |____| | | |  __/ (__|   <\__ \
%  |_| \_|\__,_|_| |_| |_|\___|  \_____\___/|_| |_|___/_|___/\__\___|_| |_|\___|\__, |  \_____|_| |_|\___|\___|_|\_\___/
%                                                                                __/ |                                  
%                                                                               |___/                                   
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Name%20Consistency%20Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%         ## GPS_Sparkfun_sensors_are_merged  <--- WRITE THIS
%         ## Adis_Sparkfun_sensors_are_merged  <--- WRITE THIS
%         ## Sensors_follow_standard_convention (GPS_Hemisphere, for example) <--- WRITE THIS
%

% The above issues are explained in more detail in the following
% sub-sections of the code:


%% Check if Sparkfun_GPS_RearRight_sensors_are_merged
%    ### ISSUES with this:
%    * The Sparkfun GPS unit requires several different datagrams to fully
%    capture its output
%    * The data grams are spread across different sensor datasets
%    corresponding to each topic, but are actually one
%    * If they are kept separate, the data are not correlated correctly
%    ### DETECTION:
%    * Examine if the Sparkfun sensors are fields within the current
%    datastructure
%    ### FIXES:
%    * Merge the data from the fields together

% Check if Sparkfun_GPS_RearRight_sensors_are_merged
[flags,~] = fcn_INTERNAL_checkSensorsAreMerged(dataStructure,flags,'Sparkfun_GPS_RearRight',fid);

% Check if Sparkfun_GPS_RearLeft_sensors_are_merged
[flags,~] = fcn_INTERNAL_checkSensorsAreMerged(dataStructure,flags,'Sparkfun_GPS_RearLeft',fid);

% Check if ADIS_sensors_are_merged
[flags,~] = fcn_INTERNAL_checkSensorsAreMerged(dataStructure,flags,'ADIS',fid);

%% Check if sensor_naming_standards_are_used
%    ### ISSUES with this:
%    * The sensors used on the mapping van follow a standard naming
%    convention, such as:
%    ### DETECTION:
%    * Examine if the sensor core names appear outside of the standard
%    convention
%    ### FIXES:
%    * Rename the fields

% Check if sensor_naming_standards_are_used
[flags,~] = fcn_INTERNAL_checkSensorsFollowNameConvention(dataStructure,flags,fid);



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


%% fcn_INTERNAL_checkSensorsFollowNameConvention
function [flags,offending_sensor] = fcn_INTERNAL_checkSensorsFollowNameConvention(dataStructure, flags, fid)
% Checks to see if each sensor name follows standard convention:
% TYPE_Manufacturer_Location

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
names_match = zeros(length(sensor_names),1);

for ith_sensor = 1:length(sensor_names)
    sensor_name = sensor_names{ith_sensor};
    string_parts = regexp(sensor_name,'_','split');    

    flag_good_name = 1;
    if length(string_parts)~=3
        flag_good_name = 0;
    elseif ~any(strcmp(string_parts{1},{'GPS','ENCODER','IMU','TRIGGER','NTRIP','LIDAR','TRANSFORM','DIAGNOSTIC'}))
        flag_good_name = 0;
    elseif ~any(strcmp(string_parts{3}(1:3),{'Rea','Fro','Top','Rig','Lef','Cen'})) % For Rear, Front, Top, Right, Left, Center
        flag_good_name = 0;
    end
    names_match(ith_sensor,1) = flag_good_name;

end

flag_sensor_names_are_good = 1;
if any(names_match==0)
    flag_sensor_names_are_good = 0;
end

flag_name = 'sensor_naming_standards_are_used';
flags.(flag_name) = flag_sensor_names_are_good;

offending_sensor = sensor_name; % Save the name of the sensor

end % Ends fcn_INTERNAL_checkSensorsFollowNameConvention



%% fcn_INTERNAL_checkSensorsAreMerged
function [flags,offending_sensor] = fcn_INTERNAL_checkSensorsAreMerged(dataStructure,flags,field_name,~)
% Checks if a sensor string exists in multiple sensors

% Produce a list of all the sensors (each is a field in the structure)
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
names_match = zeros(length(sensor_names),1);
for ith_sensor = 1:length(sensor_names)
    sensor_name = sensor_names{ith_sensor};
    if contains(lower(sensor_name),lower(field_name))
        names_match(ith_sensor,1) = 1;
    end
end

% Check if they are merged
flag_sensors_are_merged = 1;

num_matches = sum(names_match);
if num_matches>1
    flag_sensors_are_merged = 0;
end

flag_name = sprintf('%s_sensors_are_merged',field_name);
flags.(flag_name) = flag_sensors_are_merged;


offending_sensor = sensor_name; % Save the name of the sensor

end % Ends fcn_INTERNAL_checkSensorsAreMerged