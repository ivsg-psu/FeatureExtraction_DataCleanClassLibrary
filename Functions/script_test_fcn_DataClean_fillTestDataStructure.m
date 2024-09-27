% script_test_fcn_DataClean_fillTestDataStructure.m
% tests fcn_DataClean_fillTestDataStructure.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all

%% Basic call
testDataStructure = fcn_DataClean_fillTestDataStructure;

% Make sure its type is correct
assert(isstruct(testDataStructure));

fprintf(1,'The data structure for testDataStructure: \n')
disp(testDataStructure)

%% Basic call in verbose mode
fprintf(1,'\n\nDemonstrating "verbose" mode by printing to console: \n');
error_type = [];
fid = 1;
testDataStructure = fcn_DataClean_fillTestDataStructure(error_type,fid);

% Make sure its type is correct
assert(isstruct(testDataStructure));

fprintf(1,'The data structure for testDataStructure: \n')
disp(testDataStructure)

%% Standard noise call
testDataStructure = fcn_DataClean_fillTestDataStructure(1);

% Make sure its type is correct
assert(isstruct(testDataStructure));

fprintf(1,'The data structure for testDataStructure: \n')
disp(testDataStructure)

%% Fail conditions
if 1==0
    
end
