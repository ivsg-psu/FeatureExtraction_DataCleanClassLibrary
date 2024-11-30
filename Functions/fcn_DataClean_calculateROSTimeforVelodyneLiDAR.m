function recalculated_dataStructure = fcn_DataClean_calculateROSTimeforVelodyneLiDAR(dataStructure, varargin)


% fcn_DataClean_calculateROSTimeforVelodyneLiDAR
%
% This function takes data structure as input, and calculate the ROS Time
% for Velodyne LiDAR if needed
% 
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_checkDataTimeConsistency_LiDARVelodyne(dataStructure, (fid), (plotFlags))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the
%      sensors fields
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
%      fixed_dataStructure: a data structure with Velodyne LiDAR ROS_Time
%      recalculated

% DEPENDENCIES:
%
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_calculateROSTimeforVelodyneLiDAR
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
% Pull the bag time
[Bag_Time_CellArray,LiDAR_Names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'Bag_Time','Velodyne');
Velodyne_LiDAR_Field_Name = LiDAR_Names{1};
LiDAR_Bag_Time = Bag_Time_CellArray{1};
% Recalculate the ROS Time based on the bag timestamp
LiDAR_ROS_Time = LiDAR_Bag_Time - 0.1;
recalculated_dataStructure = dataStructure;
recalculated_dataStructure.(Velodyne_LiDAR_Field_Name).ROS_Time = LiDAR_ROS_Time;
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