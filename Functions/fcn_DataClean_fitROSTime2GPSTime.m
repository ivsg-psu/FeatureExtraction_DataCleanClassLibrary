function [flags, fitting_parameters, fit_sensors] = fcn_DataClean_fitROSTime2GPSTime(dataStructure, varargin)
% fcn_DataClean_fitROSTime2GPSTime
% Checks a given dataStructure to check, for each sensor, whether the field
% is there. If so, it sets a flag = 1 whose name is customized by the input
% settings. If not, it sets the flag = 0 and immediately exits.
%
% FORMAT:
%
%      [flags,offending_sensor] = fcn_DataClean_fitROSTime2GPSTime(...
%          dataStructure, (fid), (fig_num))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed
%
%      (OPTIONAL INPUTS)
%
%      flags: If a structure is entered, it will append the flag result
%      into the structure to allow a pass-through of flags structure
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (FID = 0). Set fid to 1 for printing to console.
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      flags: a data structure containing subfields that define the results
%      of the verification check. The name of the flag is formatted by the
%      argument inputs. 
%
%      fitting_parameters: a cell array of fit parameters, one for each GPS
%      sensor
%
%      fit_sensors: a cell array of the string names of each GPS sensor used
%      for fitting
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_fitROSTime2GPSTime
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2024_11_18: sbrennan@psu.edu
% -- wrote the code originally 

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==4 && isequal(varargin{end},-1))
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

if 0 == flag_max_speed
    if flag_check_inputs
        % Are there the right number of inputs?
        narginchk(1,4);
    end
end

% Does the user want to specify the flags?
flags = struct;
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        flags = temp;
    end
end


% Does the user want to specify the fid?
fid = 0;
% Check for user input
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        % Check that the FID works
        try
            temp_msg = ferror(temp); %#ok<NASGU>
            % Set the fid value, if the above ferror didn't fail
            fid = temp;
        catch ME
            warning('on','backtrace');
            warning('User-specified FID does not correspond to a file. Unable to continue.');
            throwAsCaller(ME);
        end
    end
end

% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (4<=nargin)
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

% Set up output flag name string
flag_name = 'ROS_Time_calibrated_to_GPS_Time';


% Tell the user what is happening?
if 0~=fid
    fprintf(fid,'Calibrating ROS time to GPS time');
    fprintf(fid,': --> %s\n', flag_name);    
end
    

% Examine the offset deviations between the different time sources
% [cell_array_centiSeconds,~]        = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds','GPS');
[cell_array_GPS_Time,~]            = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time',    'GPS');
% [cell_array_Trigger_Time,~]        = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'Trigger_Time','GPS');
[cell_array_ROS_Time,sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time',    'GPS');

fit_sensors = sensor_names;

% Make sure that length of GPS Times and ROS Times match
for ith_array = 1:length(cell_array_GPS_Time)
    NdataGPS_Time = length(cell_array_GPS_Time{ith_array}(:,1));
    NdataROS_Time = length(cell_array_ROS_Time{ith_array}(:,1));
    if NdataGPS_Time~=NdataROS_Time
        warning('on','backtrace');
        warning('Fundamental error on ROS_time: count does not match GPS time');
        error('Number of GPS and ROS time points must match!');
    end
end

% Perform regressions
fitting_parameters = cell(length(cell_array_GPS_Time),1);
fitting_errors     = cell(length(cell_array_GPS_Time),1);

for ith_array = 1:length(cell_array_GPS_Time)
    this_GPS_Time = cell_array_GPS_Time{ith_array} - cell_array_GPS_Time{ith_array}(1,1);
    this_ROS_Time = cell_array_ROS_Time{ith_array} - cell_array_GPS_Time{ith_array}(1,1);
    Ndata = length(this_GPS_Time);

    % Perform regression fit
    % y = [x 1]*m
    % X'*y = (X'*X)*m
    % m = (X'*X)*(X'*y)
    X = [this_ROS_Time ones(Ndata,1)];
    y = this_GPS_Time;
    m = (X'*X)\(X'*y);
    fitting_parameters{ith_array} = m;

    this_GPS_Time_predicted = X*m;
    fitting_errors{ith_array} = this_GPS_Time - this_GPS_Time_predicted;
end
return_flag = 1;

if 0==return_flag
    flags.(flag_name) = 0;
else
    flags.(flag_name) = 1;
end

% Tell the user what is happening?
if 0~=fid
    fprintf(fid,'\n\t Flag %s set to: %.0f\n\n',flag_name, flags.(flag_name));
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

    % Calculate GPS_Time_predicted - GPS_Time_actual, plot this versus duration
    figure(fig_num);
    clf;

    tiledlayout('flow')
        
    nexttile

    hold on;
    grid on;
    xlabel('Duration of Data Collection (seconds)');
    ylabel('Deviations in Time (seconds)');
    title('Differences, true GPS time - GPS Time calculated from ROS Time','Interpreter','none');
    for ith_sensor = 1:length(sensor_names)
        this_GPS_Time = cell_array_GPS_Time{ith_array} - cell_array_GPS_Time{ith_array}(1,1);
        plot(this_GPS_Time,fitting_errors{ith_sensor});
    end
    legend(sensor_names,'Interpreter','none')

    for ith_sensor = 1:length(sensor_names)
        nexttile
        histogram(fitting_errors{ith_sensor},50);
        xlabel('Timing Error (sec)')
        ylabel('Count')
        title(sensor_names{ith_sensor},'Interpreter','none');
    end

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



