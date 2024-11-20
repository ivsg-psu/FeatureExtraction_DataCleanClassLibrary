function calculated_dataStructure = fcn_DataClean_calculateGPSVelocity(dataStructure, varargin)

% fcn_DataClean_calculateGPSVelocity
%
% This function takes dataStructure as input, calculates the
% velocities for GPS units along X, Y and Z directions
% 
% FORMAT:
%
%     calculated_dataStructure = fcn_DataClean_calculateGPSVelocity(dataStructure, (fid), (fig_num))
%
% INPUTS:
%
%      % dataStructure: a data structure to be analyzed 
%
%      (OPTIONAL INPUTS): 
%
%      fid: the fileID where to print. Default is 1, to print results to
%      the console.
%
%      fig_num: a scalar integer value
%
% OUTPUTS:
%
%      calculated_dataStructure: a data structure with calculated GPS
%      velocities added
%
% DEPENDENCIES:
%
%
% EXAMPLES:
%
%     See the script: script_fcn_Transform_estimateVehiclePoseinENU
%     for a full test suite.
%
% This function was written on 2024_11_20 by X. Cao
% Questions or comments? xfc5113@psu.edu

% Revision history
% 2024_11_20 - Xinyu Cao, xfc5113@psu.edu
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
    temp = varargin{4};
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



[cellArray_GPS_Time, GPS_Unit_Names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure,'GPS_Time','gps');
calculated_dataStructure = dataStructure;
N_GPS_Units = length(GPS_Unit_Names);
for idx_GPS_Unit = 1:N_GPS_Units
    GPS_Unit_Name = GPS_Unit_Names{idx_GPS_Unit};
    GPS_dataStructure = calculated_dataStructure.(GPS_Unit_Name);
    GPS_Time = cellArray_GPS_Time{idx_GPS_Unit};
    xEast = GPS_dataStructure.xEast;
    yNorth = GPS_dataStructure.yNorth;
    zUp = GPS_dataStructure.zUp;
    % Calculate velocity with discrete data
    vEast_calculated = diff(xEast)./diff(GPS_Time);
    yNorth_calculated = diff(yNorth)./diff(GPS_Time);
    zUp_calculated = diff(zUp)./diff(GPS_Time);
    % Interpolating velocity to match position data, repeat the first
    % velocity value
    vEast_interp = [vEast_calculated(1); vEast_calculated];
    yNorth_interp = [yNorth_calculated(1); yNorth_calculated];
    zUp_interp = [zUp_calculated(1); zUp_calculated];
    Vel_Magnitude = sqrt(vEast_interp.^2 + yNorth_interp.^2 + zUp_interp.^2);
    % Fill the fields with calculated value
    GPS_dataStructure.velEast = vEast_interp;
    GPS_dataStructure.velNorth = yNorth_interp;
    GPS_dataStructure.velUp = zUp_interp;
    GPS_dataStructure.velMagnitude = Vel_Magnitude;
    calculated_dataStructure.(GPS_Unit_Name) = GPS_dataStructure; 
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
