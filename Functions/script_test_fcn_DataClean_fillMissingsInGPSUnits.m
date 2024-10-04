% script_test_fcn_DataClean_fillMissingsInGPSUnits.m
% tests fcn_DataClean_fillMissingsInGPSUnits.m

% Revision history
% 2024_10_02 - xfc5113@psu.edu
% -- wrote the code originally


%% Set up the workspace
close all



%% Name consistency checks start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
%  ______ _ _ _   __  __ _         _               _____          _____ _____   _____   _    _       _ _
% |  ____(_) | | |  \/  (_)       (_)             |_   _|        / ____|  __ \ / ____| | |  | |     (_) |
% | |__   _| | | | \  / |_ ___ ___ _ _ __   __ _    | |  _ __   | |  __| |__) | (___   | |  | |_ __  _| |_ ___
% |  __| | | | | | |\/| | / __/ __| | '_ \ / _` |   | | | '_ \  | | |_ |  ___/ \___ \  | |  | | '_ \| | __/ __|
% | |    | | | | | |  | | \__ \__ \ | | | | (_| |  _| |_| | | | | |__| | |     ____) | | |__| | | | | | |_\__ \
% |_|    |_|_|_| |_|  |_|_|___/___/_|_| |_|\__, | |_____|_| |_|  \_____|_|    |_____/   \____/|_| |_|_|\__|___/
%                                           __/ |
%                                          |___/
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Fill%20Missing%20In%20GPS%20Units
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check merging of sensors where all are true
% Note that, if a field is missing, it still counts as 'merged'

% Create some test data
testStructure = struct;
testStructure.GPS_SparkFun_RightRear = 'abc';

% Check structure
fid = 1;
[flags, ~] = fcn_DataClean_checkDataNameConsistency(testStructure,fid);

% Check flags
assert(isequal(flags.GPS_SparkFun_RightRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_LeftRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_Front_sensors_are_merged,1));
assert(isequal(flags.ADIS_sensors_are_merged,1));
assert(isequal(flags.sensor_naming_standards_are_used,1));


%% Check merging of sensors where one is repeated false

% Create some test data
testStructure = struct;
testStructure.GPS_SparkFun_RightRear1 = 'abc';
testStructure.GPS_SparkFun_RightRear2 = 'def';

% Check structure
fid = 1;
[flags, ~] = fcn_DataClean_checkDataNameConsistency(testStructure,fid);

% Check flags
assert(isequal(flags.GPS_SparkFun_RightRear_sensors_are_merged,0));
assert(isequal(flags.GPS_SparkFun_LeftRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_Front_sensors_are_merged,1));
assert(isequal(flags.ADIS_sensors_are_merged,1));
assert(isequal(flags.sensor_naming_standards_are_used,1));


%% Check merging of sensors where location is bad

% Create some test data
testStructure = struct;
testStructure.GPS_SparkFun_BadLocation = 'abc';

% Check structure
fid = 1;
[flags, ~] = fcn_DataClean_checkDataNameConsistency(testStructure,fid);

% Check flags
assert(isequal(flags.GPS_SparkFun_RightRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_LeftRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_Front_sensors_are_merged,1));
assert(isequal(flags.ADIS_sensors_are_merged,1));
assert(isequal(flags.sensor_naming_standards_are_used,0));

%% Check merging of sensors where type is bad

% Create some test data
testStructure = struct;
testStructure.Diag_Encoder = 'abc';

% Check structure
fid = 1;
[flags, ~] = fcn_DataClean_checkDataNameConsistency(testStructure,fid);

% Check flags
assert(isequal(flags.GPS_SparkFun_RightRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_LeftRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_Front_sensors_are_merged,1));
assert(isequal(flags.ADIS_sensors_are_merged,1));
assert(isequal(flags.sensor_naming_standards_are_used,0));

%% Check merging of sensors where type is good

% Create some test data
testStructure = struct;
testStructure.Diagostic_IVSG_RearEncoders = 'abc';

% Check structure
fid = 1;
[flags, ~] = fcn_DataClean_checkDataNameConsistency(testStructure,fid);

% Check flags
assert(isequal(flags.GPS_SparkFun_RightRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_LeftRear_sensors_are_merged,1));
assert(isequal(flags.GPS_SparkFun_Front_sensors_are_merged,1));
assert(isequal(flags.ADIS_sensors_are_merged,1));
assert(isequal(flags.sensor_naming_standards_are_used,0));

%% Check merging of sensors for a typical sensor


% Fill in the initial data
fullExampleFilePath = fullfile(cd,'Data','ExampleData_checkDataNameConsistency.mat');
load(fullExampleFilePath,'dataStructure')

% Check structure
fid = 1;
[flags, ~] = fcn_DataClean_checkDataNameConsistency(dataStructure,fid);

% Check flags
assert(isequal(flags.GPS_SparkFun_RightRear_sensors_are_merged,0));
assert(isequal(flags.GPS_SparkFun_LeftRear_sensors_are_merged,0));
assert(isequal(flags.GPS_SparkFun_Front_sensors_are_merged,0));
assert(isequal(flags.ADIS_sensors_are_merged,1));
assert(isequal(flags.sensor_naming_standards_are_used,0));


%% Fail conditions
if 1==0

end
