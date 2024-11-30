function flag_recalculate_ROS_Time = fcn_DataClean_checkDataTimeConsistency_LiDARVelodyne(dataStructure, varargin)

% fcn_DataClean_checkDataTimeConsistency_LiDARVelodyne
%
% This function takes data structure as input, check the time consistency
% of the Velodyne LiDAR, the function focuses on the checking the transmit
% time from ROS node to the ROS bag (transmit_time = ROS_Bag_Time -
% ROS_Header_Time
% 
% FORMAT:
%
%      flag_recalculate_ROS_Time = fcn_DataClean_checkDataTimeConsistency_LiDARVelodyne(dataStructure, (fid), (plotFlags))
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
%
%      fig_num: a scalar integer value for creating a figure
% OUTPUTS:
%
%      flag_recalculate_ROS_Time: A flag indicates whether ROS_Time field
%      for Velodyne LiDAR need to be calculated

% DEPENDENCIES:
%
%
% EXAMPLES:
%
%     See the script: script_fcn_DataClean_checkDataTimeConsistency_Velodyne
%     for a full test suite.
%
% This function was written on 2024_11_29 by X. Cao
% Questions or comments? xfc5113@psu.edu

% Revision history
% 2024_11_29 - Xinyu Cao, xfc5113@psu.edu
% -- wrote the code originally


% To do list:
% Edit the comments
% Add comments to some new created functions
%% Debugging and Input checks

flag_do_debug = 0; % % % % Flag to plot the results for debugging
flag_check_inputs = 1; % Flag to perform input checking

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


if flag_check_inputs == 1
    % Are there the right number of inputs?
    narginchk(1,3);
end



% Does user want to specify fid?
fid = 0;
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        fid = temp;
    end
end

% Does user want to specify fig_num?
fig_num = -1;
flag_do_plots = 0;
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        fig_num = temp;
        flag_do_plots = 1;
    end
end


if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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



[ROS_Time_CellArray,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'ROS_Time','Velodyne');
[Bag_Time_CellArray,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'Bag_Time','Velodyne');
LiDAR_ROS_Time = ROS_Time_CellArray{1};
LiDAR_Bag_Time = Bag_Time_CellArray{1};
if length(LiDAR_ROS_Time)~=length(LiDAR_Bag_Time)
    error(['Transmit time cannot be calculated since LiDAR Header Time ' ...
        'and LiDAR ROS Time have differnet length'])
    LiDAR_Transmit_Time = NaN;
else
    LiDAR_Transmit_Time = LiDAR_Bag_Time - LiDAR_ROS_Time;
end
N_total_timestamps = length(LiDAR_Transmit_Time);
% The regular transmit time is around 0.1 second, use 0.1 +/-
% std(LiDAR_Transmit_Time) as tolerances
Typical_Transmit_Time = 0.1;
LiDAR_Transmit_Time_std = std(LiDAR_Transmit_Time);
Transmit_Time_Upper_boundary = Typical_Transmit_Time + 3*LiDAR_Transmit_Time_std;
Transmit_Time_Lower_boundary = Typical_Transmit_Time - 3*LiDAR_Transmit_Time_std;
Valid_Transmit_Time_Indices = find((LiDAR_Transmit_Time>=Transmit_Time_Lower_boundary)&(LiDAR_Transmit_Time<=Transmit_Time_Upper_boundary));
N_valid_timestamps = length(Valid_Transmit_Time_Indices);
valid_timestamps_ratio = N_valid_timestamps/N_total_timestamps;
if valid_timestamps_ratio > 0.9
    flag_recalculate_ROS_Time = 0;
else
    flag_recalculate_ROS_Time = 1;

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
    figure(fig_num)
    time_indices = (1:N_total_timestamps).';
    plot(time_indices, LiDAR_ROS_Time,'blue','LineWidth',2)
    hold on
    plot(time_indices, LiDAR_BAG_Time,'red','LineWidth',2)
    xlabel('Time Index')
    ylabel('Time [s]')
    legend('ROS Header Time', 'ROS Bag Time')
    title('Comparison between Header Time and Bag Time for Velodyne LiDAR')
end

if flag_do_debug
    if fid~=0
        fprintf(fid,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
    end
end

end