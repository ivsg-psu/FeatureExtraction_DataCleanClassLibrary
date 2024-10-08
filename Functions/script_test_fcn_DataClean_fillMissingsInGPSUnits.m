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

% % Location for Test Track base station
% setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
% setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
% setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');

%% Check merging of sensors where all are true
% Note that, if a field is missing, it still counts as 'merged'
goodTime = (0:0.1:10)';
testTime = goodTime(1:4,6:end,:);

% Create some test data
GPSdataStructure.GPS_Time = ;
GPSdataStructure.Latitude = 40.86368573*ones(length(testTime),1);
GPSdataStructure.Longitude = -77.83592832*ones(length(testTime),1);
GPSdataStructure.Altitude = 344.189*ones(length(testTime),1);
GPSdataStructure.centiSeconds = 10;
GPSdataStructure.Npoints = length(testTime);

testStructure = struct;
testStructure.GPS_SparkFun_RightRear = GPSdataStructure;

% Check structure
fid = 1;
[flags, ~] = fcn_DataClean_checkDataNameConsistency(testStructure,fid);

% Check flags




%% Fail conditions
if 1==0

end
