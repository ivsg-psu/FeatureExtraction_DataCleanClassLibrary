function datatype = fcn_DataClean_determineDataType(topic_name)
% fcn_DataClean_determineDataType
% determines which standard data type relates to a ROS topic
%
% FORMAT:
%
%      datatype = fcn_DataClean_determineDataType(topic_name)
%
% INPUTS:
%
%      topic_name: the name of the ROS topic.
%
%      (OPTIONAL INPUTS)
%
%      (none)
%
% OUTPUTS:
%
%      datatype: a string listing the data type, one of:
%         'gps', 'ins', 'trigger', 'encoder', 'lidar2d', 'lidar3d'
%      if the data type is not recognized, it lists 'other'.
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_determineDataType
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history
% 2023_06_16 - Xinyu Cao
% -- first functionalization of the code
% 2023_06_19 - S. Brennan
% -- added structure

% TO DO
% 

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

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

if flag_check_inputs
    % Are there the right number of inputs?
    if nargin < 1 || nargin > 1
        error('Incorrect number of input arguments')
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


topic_name_lower = lower(topic_name);
if any([contains(topic_name_lower,'sparkfun_gps_rear'), contains(topic_name_lower,'bin1')])
    datatype = 'gps';
elseif any([contains(topic_name_lower,'ins'), contains(topic_name_lower,'imu'),contains(topic_name_lower, 'adis')])
    datatype = 'ins';
elseif contains(topic_name_lower,'parsetrigger')
    datatype = 'trigger';
elseif contains(topic_name_lower,'parseencoder')
    datatype = 'encoder';
elseif contains(topic_name_lower,'sick_lms500/scan')
    datatype = 'lidar2d';
elseif contains(topic_name_lower,'velodyne')
    datatype = 'lidar3d';
elseif contains(topic_name_lower,'diag')
    datatype = 'diagnostic';
elseif contains(topic_name_lower,'ntrip')
    datatype = 'ntrip';
elseif contains(topic_name_lower,'rosout')
    datatype = 'rosout';
elseif contains(topic_name_lower,'tf')
    datatype = 'transform';
else
    datatype = 'other';
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

if flag_do_debug
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
