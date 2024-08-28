function matched_dataStructure = fcn_DataClean_matchOtherSensorsToGPSUnits(dataStructure,varargin)
% fcn_DataClean_matchOtherSensorsToGPSUnits(dataStructure,fid)
% fcn_DataClean_matchOtherSensorsToGPSUnits
% Given a data structure, match other sensors data to GPS units
%
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_matchOtherSensorsToGPSUnits(dataStructure,(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed
%
%      (OPTIONAL INPUTS)
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (FID = 0). Set fid to 1 for printing to console.
%
% OUTPUTS:
%
%      matched_dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES: # to be done
%
%     See the script: script_test_fcn_DataClean_matchOtherSensorsToGPSUnits
%     for a full test suite.
%
% This function was written on 2024_08_09 by X. Cao
% Questions or comments? xfc5113@psu.edu 

% Revision history:
%     
% 2024_08_09: xfc5113@psu.edu
% -- wrote the code originally 


flag_do_debug = 1;  %#ok<NASGU> % Flag to show the results for debugging
flag_do_plots = 0;  % Flag to plot the final results
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

% Does the user want to specify the specify the fid?
fid = 0; % Default case is to NOT print to the console
if 1 < nargin
    temp = varargin{1};
    if ~isempty(temp)
        fid = temp;
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

% The method this is done is to:
% 1. Find the common Trigger_Time for all sensors
% 2. Grab Trigger_Time field for all sensors. 
% 3. Match other sensors data according to Trigger_Time


%% Find the common Trigger_Time for all sensors
matched_dataStructure = dataStructure;
time_type = 'Trigger_Time';
time_range = fcn_DataClean_FindMaxAndMinTime(dataStructure,time_type);
%% Grab Trigger_time field for all sensors and match other sensors data according to Trigger_Time
sensorfields = fieldnames(dataStructure);

N_sensors = length(sensorfields);
for idx_field = 1:N_sensors
    sensorName = sensorfields{idx_field};
    current_field_struct = dataStructure.(sensorName);
    matched_field_struct = current_field_struct;
    if isfield(current_field_struct,time_type)
        current_field_struct_Trigger_Time = current_field_struct.(time_type);
        current_field_struct_centiSeconds = current_field_struct.centiSeconds;
        time_range_centiSeconds = round(time_range*100/current_field_struct_centiSeconds)*current_field_struct_centiSeconds;
        Trigger_Time_censitime_original = round(100*current_field_struct_Trigger_Time/current_field_struct_centiSeconds)*current_field_struct_centiSeconds;
        Trigger_Time_censitime_common = (min(time_range_centiSeconds):current_field_struct_centiSeconds:max(time_range_centiSeconds)).';
    end
  
    topicfields = fieldnames(current_field_struct);
    N_topics = length(topicfields);
    for idx_topic = 1:N_topics
        topic_name = topicfields{idx_topic};
        current_topic_content = current_field_struct.(topic_name);
        
        if length(current_topic_content) > 1
            if iscell(current_topic_content)
                matched_current_topic_content = cell(size(Trigger_Time_censitime_common));
            else
                matched_current_topic_content = nan(size(Trigger_Time_censitime_common,1),size(current_topic_content,2));
            end
            
            for idx_time = 1:length(Trigger_Time_censitime_original)
                time_diff = abs(Trigger_Time_censitime_common-Trigger_Time_censitime_original(idx_time));
                [~,closest_idx] = min(time_diff);
                if strcmp(topic_name,'Trigger_Time')
                    matched_current_topic_content(closest_idx,:) = Trigger_Time_censitime_common(closest_idx,:)/100;
                else
                    matched_current_topic_content(closest_idx,:) = current_topic_content(idx_time,:);
                end
            end
            if strcmp(topic_name,'Trigger_Time')
                matched_current_topic_content = fillmissing(matched_current_topic_content,'linear');
            end
            matched_field_struct.(topicfields{idx_topic}) = matched_current_topic_content;
        else
            matched_field_struct.Npoints = length(matched_field_struct.Trigger_Time);
        end    
    end
    matched_dataStructure.(sensorfields{idx_field}) = matched_field_struct;
end

