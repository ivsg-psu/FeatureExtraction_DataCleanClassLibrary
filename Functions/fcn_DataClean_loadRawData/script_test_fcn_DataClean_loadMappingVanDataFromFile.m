% script_test_fcn_DataClean_loadMappingVanDataFromFile.m
% tests fcn_DataClean_loadMappingVanDataFromFile.m

% Revision history
% 2023_06_19 - sbrennan@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter
% 2023_06_25 - sbrennan@psu.edu
% -- fixed typo in comments where script had wrong name! 
% 2023_06_26 - xfc5113@psu.edu
% -- Update the default data information

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

%% Choose data folder and bag name, read before running the script
% 2023_06_19
% Data from "mapping_van_2023-06-05-1Lap.bag" is set as the default value
% used in this test script.
% All files are saved on OneDrive, in
% \\IVSG\GitHubMirror\MappingVanDataCollection\ParsedData, to use data from other files,
% change the data_folder variable and bagname variable to corresponding path and bag
% name.

% 2023_06_24
% Data from "mapping_van_2023-06-22-1Lap_0.bag" and "mapping_van_2023-06-22-1Lap_1.bag"
% will be used as the default data used in this test script. 
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy mapping_van_2023-06-22-1Lap_0 and
% mapping_van_2023-06-22-1Lap_1 folder to the LargeData folder.

% 2023_06_26
% New test data 'mapping_van_2023-06-26-Parking5s.bag',
% 'mapping_van_2023-06-26-Parking10s.bag',
% 'mapping_van_2023-06-26-Parking20s.bag', and
% 'mapping_van_2023-06-26-Parking30s.bag' will be used as the default data
% in this script.
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.
% mapping_van_2023-06-26-Parking5s folder will also be placed in the Data
% folder and will be pushed to GitHub repo.

%% Test 1: Load the entire bag file
fid = 1;
dataFolder = "LargeData";
date = '2024-06-20';
bagName = "mapping_van_2024-06-20-15-21-04_0";
bagPath = fullfile(pwd, 'LargeData',date, bagName);
rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagPath,fid);
%%
locked_ROS_Time = fcn_DataClean_grabTriggerLockedTime(rawdata);
%%
RawDataWithoutTimeGaps = fcn_DataClean_removeTimeGapsFromRawData(rawdata);
%%
trimedDataStructure = fcn_DataClean_trimDatabyTime(rawdata);
%%
field_string = 'centiSeconds';
[centiSecondsCell, sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(trimedDataStructure, field_string);
centiSecondsArray = (cell2mat(centiSecondsCell)).';

%%

centiSecondMin = min(centiSecondsArray);
rawTriggerMode = trimedDataStructure.Trigger_Raw.mode;
ROSTime_TriggerBox = trimedDataStructure.Trigger_Raw.ROS_Time;
rawTriggerModeCount = trimedDataStructure.Trigger_Raw.modeCount;
rawTriggerTime = trimedDataStructure.Trigger_Raw.Trigger_Time;
N_time_to_be_filled = size(rawTriggerTime,1);
for idx_row = 1:N_time_to_be_filled
    currentTriggerMode = rawTriggerMode(idx_row);
    currentTriggerModeCount = rawTriggerModeCount(idx_row);
    if strcmp(currentTriggerMode,"L")
        rawTriggerTime(idx_row,:) = currentTriggerModeCount;
    end
end
rawTriggerTimeNonNan = rawTriggerTime(~isnan(rawTriggerTime));
ROSTime_TriggerBox_NonNan = ROSTime_TriggerBox(~isnan(rawTriggerTime));
rawTriggerTimeMin = min(rawTriggerTimeNonNan);
rawTriggerTimeMax = max(rawTriggerTimeNonNan);
ROSTimeMin_TriggerBox = min(ROSTime_TriggerBox_NonNan);
ROSTimeMax_TriggerBox = max(ROSTime_TriggerBox_NonNan);
%%
k = polyfit(ROSTime_TriggerBox_NonNan,rawTriggerTimeNonNan,1);
a = k(1);
b = k(2);
% trigger_time = a*ROSTime+b;
%%
trimmedEncoderBox = trimedDataStructure.Encoder_Raw;
ROSTime_trimmedEncoderBox = trimmedEncoderBox.ROS_Time;
ROSTime_diff = diff(ROSTime_trimmedEncoderBox);
valid_ROSTime = (ROSTime_trimmedEncoderBox>=ROSTimeMin_TriggerBox)&(ROSTime_trimmedEncoderBox<=ROSTimeMax_TriggerBox);
ROSTime_trimmedEncoderBox_Valid = ROSTime_trimmedEncoderBox(valid_ROSTime);
ROSTime_diff_valid = diff(ROSTime_trimmedEncoderBox_Valid);
triggerTime_trimmedEncoderBox = a*ROSTime_trimmedEncoderBox_Valid+b;
std(ROSTime_diff_valid)/0.01
%%

rawTriggerTimeDiff = rawTriggerTimeMax - rawTriggerTimeMin;
ROSTime_diff = ROSTimeMax_TriggerBox - ROSTimeMin_TriggerBox;
deltaTime = centiSecondMin/100;
time_offset = rawTriggerTimeDiff - ROSTime_diff;

rawTriggerTimeNoGap = (rawTriggerTimeMin:1:rawTriggerTimeMax).';
N_time_segment = length(rawTriggerTimeNoGap)-1;
segmentLength = 100/centiSecondMin;
ROSTime_Resampled = nan(N_time_segment*segmentLength+1,1);
TriggerTime_Resampled = nan(N_time_segment*segmentLength+1,1);
% for idx_time_segment = 1:N_time_segment
%     current_TriggerTime = rawTriggerTimeNoGap(idx_time_segment);
%     current_ROSTime = ROSTime_TriggerBox_NonNan(idx_time_segment);
%     if ismember(current_TriggerTime,rawTriggerTimeNonNan)
%         ROSTime_Resampled((idx_time_segment-1)*segmentLength+1:idx_time_segment*segmentLength,:) = (current_ROSTime:deltaTime:current_ROSTime+1-deltaTime).';
% 
% 
%     end
% 
% end
% ROSTime_Resampled(end,:) = ROSTime_TriggerBox_NonNan(end,:);
% if time_offset < deltaTime
%     ROSTimeMax_TriggerBox_correction = ROSTimeMin_TriggerBox+rawTriggerTimeDiff;
% end
% ROSTime_Resampled = (ROSTimeMin_TriggerBox:deltaTime:ROSTimeMax_TriggerBox_correction).';
% TriggerTime_Resampled = (rawTriggerTimeMin:deltaTime:rawTriggerTimeMax).';
% 
% time_Diff = ROSTime_Resampled - TriggerTime_Resampled;
% timeMappingObj = fit(ROSTime_Resampled,TriggerTime_Resampled,'poly1');
%%
plot(timeMappingObj,ROSTime_Resampled,TriggerTime_Resampled)
%% Test 2: Load part of the bag file
fid = 1;
dataFolder = "LargeData";
date = '2024-06-20';
bagName = "mapping_van_2024-06-20-15-21-04_0";
bagPath = fullfile(pwd, 'LargeData',date, bagName);
Flags = struct;
Flags.flag_do_load_sick = 0;
Flags.flag_do_load_velodyne = 1;
Flags.flag_do_load_cameras = 0;
rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagPath,fid,Flags);
%%

%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagName);
end
