% script_test_fcn_DataClean_checkDataNameConsistency.m
% tests fcn_DataClean_checkDataNameConsistency.m

% Revision history
% 2023_07_03 - sbrennan@psu.edu
% -- wrote the code originally


%% Set up the workspace
close all
clc





%% Name consistency checks start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   _   _                         _____                _     _                           _____ _               _        
%  | \ | |                       / ____|              (_)   | |                         / ____| |             | |       
%  |  \| | __ _ _ __ ___   ___  | |     ___  _ __  ___ _ ___| |_ ___ _ __   ___ _   _  | |    | |__   ___  ___| | _____ 
%  | . ` |/ _` | '_ ` _ \ / _ \ | |    / _ \| '_ \/ __| / __| __/ _ \ '_ \ / __| | | | | |    | '_ \ / _ \/ __| |/ / __|
%  | |\  | (_| | | | | | |  __/ | |___| (_) | | | \__ \ \__ \ ||  __/ | | | (__| |_| | | |____| | | |  __/ (__|   <\__ \
%  |_| \_|\__,_|_| |_| |_|\___|  \_____\___/|_| |_|___/_|___/\__\___|_| |_|\___|\__, |  \_____|_| |_|\___|\___|_|\_\___/
%                                                                                __/ |                                  
%                                                                               |___/                                   
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Name%20Consistency%20Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Check merging of sensors

% Fill in the initial data
load('ExampleData_checkDataNameConsistency.mat','dataStructure')

% Check Sparkfun_GPS_RearRight_sensors_are_merged 
fid = 1;
[flags, ~] = fcn_DataClean_checkDataNameConsistency(dataStructure,fid);
assert(isequal(flags.Sparkfun_GPS_RearRight_sensors_are_merged,0));

% Check Sparkfun_GPS_RearRight_sensors_are_merged 
assert(isequal(flags.Sparkfun_GPS_RearLeft_sensors_are_merged,0));

% Check Sparkfun_GPS_RearRight_sensors_are_merged - the GPS_Time field is completely missing in all sensors
assert(isequal(flags.ADIS_sensors_are_merged,0));

% Check Sparkfun_GPS_RearRight_sensors_are_merged - the GPS_Time field is completely missing in all sensors
assert(isequal(flags.sensor_naming_standards_are_used,0));


%% Fail conditions
if 1==0

end
