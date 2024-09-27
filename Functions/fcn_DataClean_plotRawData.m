function fcn_DataClean_plotRawData(rawData, varargin)
% fcn_DataClean_plotRawData
% performs a test plot of the rawData to confirm the location that was
% mapped
%
% FORMAT:
%
%      fcn_DataClean_plotRawData(rawData, (bagName), (plotFormat), (colorMap), (fig_num))
%
% INPUTS:
%
%      rawData: a  data structure containing data fields filled for each
%      ROS topic. If multiple bag files are specified, a cell array of data
%      structures is returned.
%
%      (OPTIONAL INPUTS)
%
%      bagName: the name of the bag file, for example:
%      "mapping_van_2024-07-10-19-36-59_3.bag". If within the name, the
%      extension ".bag" is dropped when naming the image output. If the
%      bagName is given as an empty input, e.g. [], then the entire
%      dataFolderString is queried for bagNames.
%
%      plotFormat: one of the following:
%          * a format string, e.g. 'b-', that dictates the plot style.
%          a colormap is created using this value as 100%, to white as 0%
%          * a [1x3] color vector specifying the RGB ratios from 0 to 1
%          a colormap is created using this value as 100%, to white as 0%
%          * a structure whose subfields for the plot properties to change, for example:
%            plotFormat.LineWideth = 3;
%            plotFormat.MarkerSize = 10;
%            plotFormat.Color = [1 0.5 0.5];
%            A full list of properties can be found by examining the plot
%            handle, for example: h_geoplot = plot(1:10); get(h_geoplot)
%          If a color is specified, a colormap is created using this value
%          as 100%, to white as 0% - this supercedes any colormap.  If no
%          color or colormap is specified, then the default color is used.
%          If no color is specified, but a colormap is given, the colormap
%          is used.
%      See: fcn_plotRoad_plotLLI.m for examples. This is the function used
%      internally for the final plotting.
%
%      colorMap: a string specifying the colormap for the plot, default is
%      to use the 'turbo' colormap in the range from green at start, red at
%      end, with 20 colors.
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      (none)
%
% DEPENDENCIES:
%
%      fcn_plotRoad_plotLLI
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_plotRawData
%     for a full test suite.
%
% This function was written on 2024_09_12 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history
% 2024_09_12 - S. Brennan
% -- wrote the code originally 


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==5 && isequal(varargin{end},-1))
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
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(1,5);

    end
end

% Does user want to specify bagName?
bagName = [];
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        bagName = temp;
    end
end

% Does user want to specify plotFormat?
plotFormat.Color = [0 0.7 0];
plotFormat.Marker = '.';
plotFormat.MarkerSize = 20;
plotFormat.LineStyle = '-';
plotFormat.LineWidth = 3;
if 3 <= nargin
    input = varargin{2};
    if ~isempty(input)
        plotFormat = input;
    end
end


% Does user want to specify colorMapToUse?
% Fill in large colormap data using turbo
colorMapMatrix = colormap('turbo');
colorMapMatrix = colorMapMatrix(100:end,:); % Keep the scale from green to red
% Reduce the colormap
Ncolors = 20;
colorMapToUse = fcn_plotRoad_reduceColorMap(colorMapMatrix, Ncolors, -1);
if (4<=nargin)
    temp = varargin{3};
    if ~isempty(temp)
        colorMapToUse = temp;
        if ischar(colorMapToUse)
            colorMapToUse = colormap(colorMapToUse);
        end
    end
end


% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (5<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp;
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
% Make sure bagName is good
if contains(bagName,'.bag')
    bagName_clean = extractBefore(bagName,'.bag');
else
    bagName_clean = bagName;
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
if (1==flag_do_plots) 
    % Plot some test data
    LLdata = [rawData.GPS_SparkFun_Front_GGA.Latitude rawData.GPS_SparkFun_Front_GGA.Longitude];


    if 1==0
        h_animatedPlot = fcn_plotRoad_animatePlot('plotLL',0,[],LLdata, plotFormat,colorMapToUse,fig_num);

        for ith_time = 1:10:length(LLdata(:,1))
            fcn_plotRoad_animatePlot('plotLL', ith_time, h_animatedPlot, LLdata, (plotFormat), (colorMapToUse), (fig_num));
            set(gca,'ZoomLevel',20,'MapCenter',LLdata(ith_time,1:2));
            pause(0.02);
        end
    else
        Npoints = length(LLdata(:,1));
        Idata = ((1:Npoints)-1)'/(Npoints-1);
        fcn_plotRoad_plotLLI([LLdata Idata], (plotFormat), (colorMapToUse), (fig_num));
        set(gca,'MapCenterMode','auto','ZoomLevelMode','auto');
    end
    title(sprintf('%s',bagName_clean),'Interpreter','none');

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
