% script_test_fcn_DataClean_initializeDataByType.m
% tests fcn_DataClean_initializeDataByType.m

% Revision history
% 2023_06_12 - sbrennan@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter

%% Set up the workspace
close all

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
%      dataType: a string denoting the type of dataStructure to be filled.
%      The fillowing data types are expected:
%      'trigger' - This is the data type for the trigger box data
%      'gps' - This is the data type for GPS data
%      'ins' - This is the data type for INS data
%      'encoder' - This is the data type for Encoder data
%      'diagnostic' - This is the data type for diagnostic data
%      'ntrip'      - This is the data type for NTRIP system data
%      'rosout'     - This is the data type for ROS log message
%      'transform'  - This is the data type for tranformation message
%      'lidar2d' - This is the data type for 2D Lidar data
%      'lidar3d' - This is the data type for 3D Lidar data

%% Test each of the standard calls

types = {'Trigger','GPS','IMU','Encoder','Diagnostic','NTrip','ROSOut','Transform','LIDAR2D','LIDAR3d'};

for ith_type = 1:length(types)
    dataType = types{ith_type};
    dataStructure = fcn_DataClean_initializeDataByType(dataType);

    % Make sure its type is correct
    assert(isstruct(dataStructure));

    fprintf(1,'The data structure for: %s\n',dataType)
    disp(dataStructure)
end

%% Fail conditions
if 1==0
    

end
