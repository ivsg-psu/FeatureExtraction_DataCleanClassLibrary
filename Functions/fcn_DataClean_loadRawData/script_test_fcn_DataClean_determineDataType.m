% script_test_fcn_DataClean_determineDataType.m
% tests fcn_DataClean_determineDataType.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc


%% Check assertions for basic path operations and function testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              _   _                 
%      /\                     | | (_)                
%     /  \   ___ ___  ___ _ __| |_ _  ___  _ __  ___ 
%    / /\ \ / __/ __|/ _ \ '__| __| |/ _ \| '_ \/ __|
%   / ____ \\__ \__ \  __/ |  | |_| | (_) | | | \__ \
%  /_/    \_\___/___/\___|_|   \__|_|\___/|_| |_|___/
%                                                    
%                                                    
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Assertions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Basic test - 'Bin1' is 'gps'
topic_name = '/Bin1';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'gps'));

%% Basic test - 'GPS_fix' is 'gps'
topic_name = '/GPS_fix';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'gps'));

%% Basic test - 'adis_msg' is 'ins'
topic_name = '/adis_msg';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'ins'));

%% Basic test - 'adis_press' is 'ins'
topic_name = '/adis_press';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'ins'))

%% Basic test - 'adis_temp' is 'ins'
topic_name = '/adis_press';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'ins'))

%% Basic test - 'diagnostic_encoder' is 'encoder'
topic_name = '/diagnostic_encoder';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'encoder'))

%% Basic test - 'diagnostic_trigger' is 'trigger'
topic_name = '/diagnostic_trigger';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'trigger'))

%% Basic test - 'imu/data' is 'ins'
topic_name = '/imu/data';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'ins'))

%% Basic test - 'imu/data_raw' is 'ins'
topic_name = '/imu/data_raw';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'ins'))

%% Basic test - 'imu/mag' is 'ins'
topic_name = '/imu/mag';
datatype = fcn_DataClean_determineDataType(topic_name);
assert(strcmp(datatype,'ins'))

%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagFolderName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName);
end