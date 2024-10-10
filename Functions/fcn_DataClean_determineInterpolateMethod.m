function interp_method = fcn_DataClean_determineInterpolateMethod(field_name, varargin)
% fcn_DataClean_determineInterpolateMethod
% Determines field-specific methods of interpolation for missing data,
% according to the field name
%
% FORMAT:
%
%      interp_method = fcn_DataClean_determineInterpolateMethod(field_name, (fig_num))
%
% INPUTS:
%
%      field_name: the name of the field to be interpolated.
%
%      (OPTIONAL INPUTS)
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      interp_method: a string of 'nearest' or 'linear' defining the
%      interpolation type
%
% DEPENDENCIES:
%
%      (none)
%
% EXAMPLES:
%
%      See script_test_fcn_DataClean_determineInterpolateMethod
%
% This function was written on 2024_09_15 by X. Cao, updated on 2024_10_09
% by S. Brennan
% Questions or comments? xfc5113@psu.edu or sbrennan@psu.edu

% Revision history:
% 2024_10_08 - S. Brennan
% -- updated top comments
% -- added debug flag area
% -- added fig_num input
% -- fixed warning and errors

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==2 && isequal(varargin{end},-1))
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS");
    MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG = getenv("MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS);
    end
end

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

if (0 == flag_max_speed)
    if flag_check_inputs
        % Are there the right number of inputs?
        if nargin < 1 || nargin > 2            
            error('Incorrect number of input arguments')
        end
    end
end

% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (2<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp; %#ok<NASGU>
        flag_do_plots = 1;
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


% fields_names=["GPS_Time",...
%         "Trigger_Time",...
%         "ROS_Time",...
%         "centiSeconds",...
%         "Npoints",...
%         "MessageID",...
%         "Latitude",...
%         "StdLat",...
%         "Longitude",...
%         "StdLon",...
%         "Altitude",...
%         "StdAlt",...
%         "GeoSep",...
%         "xEast",...
%         "yNorth",...
%         "zUp",...
%         "velNorth",...
%         "velEast",...
%         "velUp",...
%         "velMagnitude",...
%         "numSatellites",...
%         "DGPS_mode",...
%         "Roll_deg",...
%         "Pitch_deg",...
%         "Yaw_deg",...
%         "OneSigmaPos",...
%         "HDOP",...
%         "AgeOfDiff",...
%         "StdDevResid",...
%         "SpdOverGrndKmph",...
%         "TrueTrack",...
%         "GPS_EventFunctions",...
%         "ROS_Time2",...
%         "ROS_Time3",...
%         "Npoints3"];

relationship_FieldName_to_InterpType = {
    "ROS_Time", 1; ...
    "StdLat",   1; ...
    "StdLon", 1; ...
    "StdAlt", 1; ...
    "GeoSep", 0; ...
    "numSatellites", 0; ...
    "DGPS_mode", 0; ...
    "HDOP", 0; ...
    "AgeOfDiff", 0;...
    "SpdOverGrndKmph", 1;...
    "GPS_Time2", 1;...
    "ROS_Time2", 1;...
    "ROS_Time3", 1;};

fields_names = [relationship_FieldName_to_InterpType{:,1}];
interp_methods = [relationship_FieldName_to_InterpType{:,2}];

d = dictionary(fields_names,interp_methods);
interp_method_number = d(field_name);

if interp_method_number == 0
    interp_method = 'nearest';
elseif interp_method_number == 1
    interp_method = 'linear';
else
    warning('on','backtrace');
    warning('Unknown interpolation number found. Unable to continue.');
    error('unknown interpolation number?');
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
