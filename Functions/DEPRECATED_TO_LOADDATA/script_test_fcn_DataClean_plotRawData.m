% script_test_fcn_DataClean_plotRawData.m
% tests fcn_DataClean_plotRawData.m

% Revision history
% 2024_09_12 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all

% Location for Pittsburgh, site 1
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.44181017');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-79.76090840');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','327.428');


%% Test 1: Plotting with defaults
fig_num = 1;
figure(fig_num);
clf;

fullExampleFilePath = fullfile(cd,'Data','ExampleData_plotRawData.mat');
load(fullExampleFilePath,'dataStructure')
rawData = dataStructure;
bagName = dataStructure.Identifiers.mergedName;

% Plot the data
plotFormat = [];
colorMapToUse = [];
fcn_DataClean_plotRawData(rawData, (bagName), (plotFormat), (colorMapToUse), (fig_num))

%% Test 2: Plotting with formats
fig_num = 2;
figure(fig_num);
clf;

fullExampleFilePath = fullfile(cd,'Data','ExampleData_plotRawData.mat');
load(fullExampleFilePath,'dataStructure')
rawData = dataStructure;
bagName = dataStructure.Identifiers.mergedName;


% Test the function
clear plotFormat
plotFormat.LineStyle = '-';
plotFormat.LineWidth = 3;
plotFormat.Marker = 'none';
plotFormat.MarkerSize = 5;

colorMapMatrix = colormap('hot');
% Reduce the colormap
Ncolors = 20;
colorMapToUse = fcn_plotRoad_reduceColorMap(colorMapMatrix, Ncolors, -1);

fcn_DataClean_plotRawData(rawData, (bagName), (plotFormat), (colorMapToUse), (fig_num))

%% Test 3: Plotting a color
fig_num = 3;
figure(fig_num);
clf;

fullExampleFilePath = fullfile(cd,'Data','ExampleData_plotRawData.mat');
load(fullExampleFilePath,'dataStructure')
rawData = dataStructure;
bagName = dataStructure.Identifiers.mergedName;

% Test the function
clear plotFormat
plotFormat.LineStyle = '-';
plotFormat.LineWidth = 2;
plotFormat.Marker = 'none';
plotFormat.MarkerSize = 5;
plotFormat.Color = fcn_geometry_fillColorFromNumberOrName(2);

colorMapToUse = plotFormat.Color;
fcn_DataClean_plotRawData(rawData, (bagName), (plotFormat), (colorMapToUse), (fig_num))
h_legend = legend(bagName);
set(h_legend,'Interpreter','none')

%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_plotRawData(bagName, bagName);
end
