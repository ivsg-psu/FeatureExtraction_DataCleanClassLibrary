function stitched_dataStructure = fcn_DataClean_stitchDataStructures(rawData_cell)


% Stitch datasets with the same fields
%
% FORMAT:
%
%       stitched_dataStructure = fcn_DataClean_stitchDataStructures(rawData_cell)
%
% INPUTS:
%
%       rawData_cell: a Nx1 cell array contains rawData
%
% OUTPUTS:
%
%       stitched_dataStructure : a data struct contains stitched rawData
% DEPENDENCIES:
%
%
% EXAMPLES: # To be added
%
%
% This function was written on 2024_09_06 by X. Cao
% Questions or comments? xfc5113@psu.edu


% Revision history:
% 2024_09_06 by X. Cao
% -- start writing function
% 2024_09_10 by X. Cao
% -- add fields checking feature

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
flag_check_inputs = 1;
if flag_check_inputs == 1
    % Are there the right number of inputs?
    narginchk(1,1);
    if ~iscell(rawData_cell)
        error("The input should be a cell array")
    
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

N_dataset = length(rawData_cell);
% If rawData_cell only contain one dataset, no stitching needed
stitched_dataStructure = rawData_cell{1};
% If rawData_cell have multiple dataset, stitch each dataset iteratively
% until there is only one dataset in the cell array.
while N_dataset > 1
    dataStructure_initial = rawData_cell{1};
    dataStructure_to_be_added = rawData_cell{2};
    % Grab the fields of two datasets, and stitch them if they have the
    % same fields
    sensorfields_initial= fieldnames(dataStructure_initial);
    sensorfields_to_be_added = fieldnames(dataStructure_to_be_added);
    sensorfields_initial_sorted = sort(sensorfields_initial);
    sensorfields_to_be_added_sorted = sort(sensorfields_to_be_added);
    if ~isequal(sensorfields_initial_sorted,sensorfields_to_be_added_sorted)
        error("Two datasets cannot be stitched since they have different fields")
    end
 
    for idx_field = 1:length(sensorfields_initial)
        current_field_struct = dataStructure_initial.(sensorfields_initial{idx_field});
        current_field_struct_to_be_added = sensorfields_to_be_added.(sensorfields_initial{idx_field});
        stitched_field_struct = current_field_struct;
        topicfields = fieldnames(current_field_struct);
        N_topics = length(topicfields);
        for idx_topic = 1:N_topics
            current_topic_content = current_field_struct.(topicfields{idx_topic});
            current_topic_content_to_be_added = current_field_struct_to_be_added.(topicfields{idx_topic});
            if length(current_topic_content) > 1
                stitched_topic_content = [current_topic_content;current_topic_content_to_be_added];
                stitched_field_struct.(topicfields{idx_topic}) = stitched_topic_content;
            end
        end
        stitched_field_struct.Npoints = length(stitched_topic_content.ROS_Time);
        stitched_dataStructure.(sensorfields_initial{idx_field}) = stitched_field_struct;
    end
    % Once two dataset stitched together, the stitched_dataStructure will
    % replace the initial dataStructure, and remove the second
    % dataStructure which was just stitched
    rawData_cell{1} = stitched_dataStructure;
    rawData_cell(2) = [];
    N_dataset = length(rawData_cell);
end



end


