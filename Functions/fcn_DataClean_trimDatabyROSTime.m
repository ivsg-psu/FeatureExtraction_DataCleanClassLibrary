function trimedDataStructure = fcn_DataClean_trimDatabyROSTime(rawDataStructure)

% fcn_DataPreprocessing_FindMaxAndMinTime finds the start and end time for
% each sensor
%
% FORMAT:
%
% time_range = fcn_DataClean_trimDatabyTime(rawDataStructure)
%
% INPUTS:
%
%      rawDataStructure: a structure array containing raw data 
%
%
% OUTPUTS:
%
%      trimedDataStructure: a structure array containing trimmed data
%
%
% DEPENDENCIES:
%
%      fcn_DataClean_FindMaxAndMinTime
%      
%
% EXAMPLES:
%      
%      % BASIC example
%
% 
% See the script: script_test_fcn_DataClean_trimDatabyROSTime
% for a full test suite.
%
% This function was written on 2023_10_20 by X.Cao
% Questions or comments? xfc5113@psu.edu

% Revision history:
% 2023_10_20 - wrote the code
% 2024_01_28 - added more comments, particularly to explain inputs more
% clearly
% 2024_07_24 - rename the function from fcn_DataClean_trimDatabyTime to
% fcn_DataClean_trimDatabyROSTime

%% Debugging and Input checks
flag_do_debug = 1;
if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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
flag_check_inputs = 1; % Flag to perform input checking

if flag_check_inputs == 1
    if ~isstruct(rawDataStructure)
        error('The input of the function should be a structure array')
    end

end

%% Solve for the angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

time_range = fcn_DataClean_FindMaxAndMinTime(rawDataStructure);
sensorfields = fieldnames(rawDataStructure);
trimedDataStructure = rawDataStructure;

for idx_field = 1:length(sensorfields)
    current_field_struct = rawDataStructure.(sensorfields{idx_field});
    trimmed_field_struct = current_field_struct;
    if isfield(current_field_struct,'ROS_Time')
        current_field_struct_ROS_Time = current_field_struct.ROS_Time;
    else
        current_field_struct_ROS_Time = [];
    end
    valid_idxs = (current_field_struct_ROS_Time>=min(time_range))&(current_field_struct_ROS_Time<=max(time_range));
    topicfields = fieldnames(current_field_struct);
    N_topics = length(topicfields);
    for idx_topic = 1:N_topics
        current_topic_content = current_field_struct.(topicfields{idx_topic});
        if length(current_topic_content) > 1
           trimmed_field_struct.(topicfields{idx_topic}) = current_topic_content(valid_idxs,:);
        end
        trimmed_field_struct.centiSeconds = current_field_struct.centiSeconds;
        trimmed_field_struct.Npoints = length(trimmed_field_struct.ROS_Time);

    end
    trimedDataStructure.(sensorfields{idx_field}) = trimmed_field_struct;

end
end