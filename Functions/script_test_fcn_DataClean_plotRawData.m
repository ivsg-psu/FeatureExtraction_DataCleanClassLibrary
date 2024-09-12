% script_test_fcn_DataClean_plotRawData.m
% tests fcn_DataClean_plotRawData.m

% Revision history
% 2024_09_12 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all


%% Test 1: Plotting with defaults
fig_num = 1;
figure(fig_num);
clf;

clear rawData
fid = 1;
dataFolderString = "LargeData";
dateString = '2024-07-10';
bagName = "mapping_van_2024-07-10-19-41-49_0";
bagPath = fullfile(pwd, dataFolderString,dateString, bagName);
Flags = [];
[rawData, ~] = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), (-1));

% Plot the data
plotFormat = [];
colorMap = [];
fcn_DataClean_plotRawData(rawData, (bagName), (plotFormat), (colorMap), (fig_num))

%% Test 2: Plotting with formats
fig_num = 2;
figure(fig_num);
clf;

clear rawData
fid = 1;
dataFolderString = "LargeData";
dateString = '2024-07-10';
bagName = "mapping_van_2024-07-10-19-41-49_0";
bagPath = fullfile(pwd, dataFolderString,dateString, bagName);
Flags = [];
[rawData, ~] = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), (-1));


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

fcn_DataClean_plotRawData(rawData, (bagName), (plotFormat), (colorMap), (fig_num))

%% Test 3: Plotting a color
fig_num = 3;
figure(fig_num);
clf;

clear rawData
fid = 1;
dataFolderString = "LargeData";
dateString = '2024-07-10';
bagName = "mapping_van_2024-07-10-19-41-49_0";
bagPath = fullfile(pwd, dataFolderString,dateString, bagName);
Flags = [];
[rawData, ~] = fcn_DataClean_loadMappingVanDataFromFile(bagPath, (bagName), (fid), (Flags), (-1));

% Plot the base station
fcn_plotRoad_plotLL([],[],fig_num);

% Test the function
clear plotFormat
plotFormat.LineStyle = '-';
plotFormat.LineWidth = 2;
plotFormat.Marker = 'none';
plotFormat.MarkerSize = 5;
plotFormat.Color = fcn_geometry_fillColorFromNumberOrName(2);

colorMap = plotFormat.Color;
fcn_DataClean_plotRawData(rawData, (bagName), (plotFormat), (colorMap), (fig_num))
h_legend = legend('Base station',bagName);
set(h_legend,'Interpreter','none')

%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_plotRawData(bagName, bagName);
end
