% script_test_fcn_DataClean_cleanNaming.m
% tests fcn_DataClean_cleanNaming.m

% Revision history
% 2024_09_09 - sbrennan@psu.edu
% -- wrote the code originally

% Set up the workspace
close all

%% Test 1: Load and clean a single bag file
fig_num = 1;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


% fullExampleFilePath = fullfile(cd,'Data','ExampleData_cleanData.mat');
fullExampleFilePath = fullfile(cd,'Data','ExampleData_cleanData2.mat');
load(fullExampleFilePath,'dataStructure')

%%%%%
% Run the command
fid = 1;
Flags = [];
dataStructure_cleanedNames = fcn_DataClean_cleanNaming(dataStructure, (fid), (Flags), (fig_num));

% Check the data
assert(isstruct(dataStructure_cleanedNames))

%%

%% Fail conditions
if 1==0
    %% ERROR situation: 
end



































