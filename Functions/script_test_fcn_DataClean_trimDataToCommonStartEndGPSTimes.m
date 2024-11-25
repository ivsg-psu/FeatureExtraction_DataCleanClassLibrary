% script_test_fcn_DataClean_trimDataToCommonStartEndGPSTimes.m
% tests fcn_DataClean_trimDataToCommonStartEndGPSTimes.m

% Revision history
% 2023_06_25 - sbrennan@psu.edu
% -- wrote the code originally
% 2024_11_22 - sbrennan@psu.edu
% -- major rewrite to use reference time sequence instead of start/end
% trimming

%% Set up the workspace
close all

%% CASE 1: simple test, pass by construction, only trimming GPS sensors
fig_num = 1;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


GPScentiSeconds = 10;
SensorCentiSeconds = 10;

startTime = 0.7;
endTime = 2.4;

roundedUpStartTime = ceil(startTime);
roundedDownEndTime = floor(endTime);

initial_test_structure = struct;
good_time_data = (startTime:(GPScentiSeconds*0.01):2.4)';
std_dev = 0; % Small changes in time?
good_time_data = good_time_data + std_dev * randn(length(good_time_data(:,1)),1);
bad_data = flipud(good_time_data);

initial_test_structure.GPS_cow1.GPS_Time= good_time_data;
initial_test_structure.GPS_cow2.GPS_Time= good_time_data;
initial_test_structure.GPS_cow3.GPS_Time= good_time_data;
initial_test_structure.GPS_cow1.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow2.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow3.centiSeconds = GPScentiSeconds;

initial_test_structure.GPS_cow1.measurements = bad_data;
initial_test_structure.GPS_cow2.measurements = bad_data;
initial_test_structure.GPS_cow3.measurements = bad_data;

initial_test_structure.GPS_cow1.values = good_time_data;
initial_test_structure.GPS_cow2.values = good_time_data;
initial_test_structure.GPS_cow3.values = good_time_data;

initial_test_structure.pig1.GPS_Time= good_time_data;
initial_test_structure.pig2.GPS_Time= good_time_data;
initial_test_structure.pig3.GPS_Time= bad_data;
initial_test_structure.pig1.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig2.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig3.centiSeconds = SensorCentiSeconds;

initial_test_structure.pig1.measurements = good_time_data;
initial_test_structure.pig2.measurements = good_time_data;
initial_test_structure.pig3.measurements = good_time_data;

dataStructure = initial_test_structure;

fill_type = 1;
fid = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, ('GPS_Time'), ('GPS'), (fill_type), (fid));

% Show GPS are all trimmed
assert(all(~isnan(trimmed_dataStructure.GPS_cow1.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow2.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow3.GPS_Time)));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(end,1),roundedDownEndTime));

% Show non GPS data are unchanged
assert(isequal(initial_test_structure.pig1,trimmed_dataStructure.pig1));
assert(isequal(initial_test_structure.pig2,trimmed_dataStructure.pig2));
assert(isequal(initial_test_structure.pig3,trimmed_dataStructure.pig3));

%% CASE 2: simple test, pass by construction, all sensors changed
fig_num = 1;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


GPScentiSeconds = 10;
SensorCentiSeconds = 10;

startTime = 0.7;
endTime = 2.4;

roundedUpStartTime = ceil(startTime);
roundedDownEndTime = floor(endTime);

initial_test_structure = struct;
good_time_data = (startTime:(GPScentiSeconds*0.01):2.4)';
std_dev = 0; % Small changes in time?
good_time_data = good_time_data + std_dev * randn(length(good_time_data(:,1)),1);
bad_data = flipud(good_time_data);

initial_test_structure.GPS_cow1.GPS_Time= good_time_data;
initial_test_structure.GPS_cow2.GPS_Time= good_time_data;
initial_test_structure.GPS_cow3.GPS_Time= good_time_data;
initial_test_structure.GPS_cow1.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow2.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow3.centiSeconds = GPScentiSeconds;

initial_test_structure.GPS_cow1.measurements = bad_data;
initial_test_structure.GPS_cow2.measurements = bad_data;
initial_test_structure.GPS_cow3.measurements = bad_data;

initial_test_structure.GPS_cow1.values = good_time_data;
initial_test_structure.GPS_cow2.values = good_time_data;
initial_test_structure.GPS_cow3.values = good_time_data;

initial_test_structure.pig1.GPS_Time= good_time_data;
initial_test_structure.pig2.GPS_Time= good_time_data;
initial_test_structure.pig3.GPS_Time= bad_data;
initial_test_structure.pig1.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig2.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig3.centiSeconds = SensorCentiSeconds;

initial_test_structure.pig1.measurements = good_time_data;
initial_test_structure.pig2.measurements = good_time_data;
initial_test_structure.pig3.measurements = good_time_data;

dataStructure = initial_test_structure;

fill_type = 1;
fid = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, ('GPS_Time'), ([]), (fill_type), (fid));

% Show GPS are all trimmed
assert(all(~isnan(trimmed_dataStructure.GPS_cow1.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow2.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow3.GPS_Time)));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(end,1),roundedDownEndTime));

% Show non GPS data are changed
assert(~isequal(initial_test_structure.pig1,trimmed_dataStructure.pig1));
assert(~isequal(initial_test_structure.pig2,trimmed_dataStructure.pig2));
assert(~isequal(initial_test_structure.pig3,trimmed_dataStructure.pig3));

assert(isequal(trimmed_dataStructure.pig1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.pig2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.pig3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.pig1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.pig2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.pig3.GPS_Time(end,1),roundedDownEndTime));

%% CASE 3: simple test, forward data overlap on one sensor
fig_num = 3;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


GPScentiSeconds = 10;
SensorCentiSeconds = 10;

startTime = 0.7;
endTime = 2.4;

roundedUpStartTime = ceil(startTime);
roundedDownEndTime = floor(endTime);

initial_test_structure = struct;
good_time_data = (startTime:(GPScentiSeconds*0.01):2.4)';

std_dev = 0; % Small changes in time?
bad_time_data = good_time_data + std_dev * randn(length(good_time_data(:,1)),1);
% Shift some of the data forward in time to force overlap
bad_time_data(9:11,1) = bad_time_data(9:11,1) + GPScentiSeconds*0.7*0.01;

bad_data = flipud(good_time_data);

initial_test_structure.GPS_cow1.GPS_Time= bad_time_data;

initial_test_structure.GPS_cow2.GPS_Time= good_time_data;
initial_test_structure.GPS_cow3.GPS_Time= good_time_data;
initial_test_structure.GPS_cow1.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow2.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow3.centiSeconds = GPScentiSeconds;

initial_test_structure.GPS_cow1.measurements = bad_data;
initial_test_structure.GPS_cow2.measurements = bad_data;
initial_test_structure.GPS_cow3.measurements = bad_data;

initial_test_structure.GPS_cow1.values = good_time_data;
initial_test_structure.GPS_cow2.values = good_time_data;
initial_test_structure.GPS_cow3.values = good_time_data;

initial_test_structure.pig1.GPS_Time= good_time_data;
initial_test_structure.pig2.GPS_Time= good_time_data;
initial_test_structure.pig3.GPS_Time= bad_data;
initial_test_structure.pig1.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig2.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig3.centiSeconds = SensorCentiSeconds;

initial_test_structure.pig1.measurements = good_time_data;
initial_test_structure.pig2.measurements = good_time_data;
initial_test_structure.pig3.measurements = good_time_data;

dataStructure = initial_test_structure;

fill_type = 1;
fid = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, ('GPS_Time'), ('GPS'), (fill_type), (fid));

% Show GPS are all trimmed
assert(all(~isnan(trimmed_dataStructure.GPS_cow1.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow2.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow3.GPS_Time)));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(end,1),roundedDownEndTime));

% Show non GPS data are unchanged
assert(isequal(initial_test_structure.pig1,trimmed_dataStructure.pig1));
assert(isequal(initial_test_structure.pig2,trimmed_dataStructure.pig2));
assert(isequal(initial_test_structure.pig3,trimmed_dataStructure.pig3));

%% CASE 4: simple test, forward data overlap on one sensor
fig_num = 4;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


GPScentiSeconds = 10;
SensorCentiSeconds = 10;

startTime = 0.7;
endTime = 2.4;

roundedUpStartTime = ceil(startTime);
roundedDownEndTime = floor(endTime);

initial_test_structure = struct;
good_time_data = (startTime:(GPScentiSeconds*0.01):2.4)';

std_dev = 0; % Small changes in time?
bad_time_data = good_time_data + std_dev * randn(length(good_time_data(:,1)),1);
% Shift some of the data backward in time to force overlap
bad_time_data(9:11,1) = bad_time_data(9:11,1) - GPScentiSeconds*0.7*0.01;

bad_data = flipud(good_time_data);

initial_test_structure.GPS_cow1.GPS_Time= bad_time_data;

initial_test_structure.GPS_cow2.GPS_Time= good_time_data;
initial_test_structure.GPS_cow3.GPS_Time= good_time_data;
initial_test_structure.GPS_cow1.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow2.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow3.centiSeconds = GPScentiSeconds;

initial_test_structure.GPS_cow1.measurements = bad_data;
initial_test_structure.GPS_cow2.measurements = bad_data;
initial_test_structure.GPS_cow3.measurements = bad_data;

initial_test_structure.GPS_cow1.values = good_time_data;
initial_test_structure.GPS_cow2.values = good_time_data;
initial_test_structure.GPS_cow3.values = good_time_data;

initial_test_structure.pig1.GPS_Time= good_time_data;
initial_test_structure.pig2.GPS_Time= good_time_data;
initial_test_structure.pig3.GPS_Time= bad_data;
initial_test_structure.pig1.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig2.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig3.centiSeconds = SensorCentiSeconds;

initial_test_structure.pig1.measurements = good_time_data;
initial_test_structure.pig2.measurements = good_time_data;
initial_test_structure.pig3.measurements = good_time_data;

dataStructure = initial_test_structure;

fill_type = 1;
fid = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, ('GPS_Time'), ('GPS'), (fill_type), (fid));

% Show GPS are all trimmed
assert(all(~isnan(trimmed_dataStructure.GPS_cow1.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow2.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow3.GPS_Time)));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(end,1),roundedDownEndTime));

% Show non GPS data are unchanged
assert(isequal(initial_test_structure.pig1,trimmed_dataStructure.pig1));
assert(isequal(initial_test_structure.pig2,trimmed_dataStructure.pig2));
assert(isequal(initial_test_structure.pig3,trimmed_dataStructure.pig3));

%% CASE 5: simple test, two data samples within same interval selecting lower
fig_num = 5;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


GPScentiSeconds = 10;
SensorCentiSeconds = 10;

startTime = 0.7;
endTime = 2.4;

roundedUpStartTime = ceil(startTime);
roundedDownEndTime = floor(endTime);

initial_test_structure = struct;
good_time_data = (startTime:(GPScentiSeconds*0.01):2.4)';

std_dev = 0; % Small changes in time?
bad_time_data = good_time_data + std_dev * randn(length(good_time_data(:,1)),1);
% Shift some of the data forward in time to force overlap
bad_time_data = [bad_time_data(1:8,:); bad_time_data(9,:)-GPScentiSeconds*0.3*0.01; bad_time_data(9,:)+GPScentiSeconds*0.4*0.01; bad_time_data(10:end,:)];

% Make the good time data same length
good_time_data = (startTime:(GPScentiSeconds*0.01):2.5)';

bad_data = flipud(good_time_data);

initial_test_structure.GPS_cow1.GPS_Time= bad_time_data;

initial_test_structure.GPS_cow2.GPS_Time= good_time_data;
initial_test_structure.GPS_cow3.GPS_Time= good_time_data;
initial_test_structure.GPS_cow1.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow2.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow3.centiSeconds = GPScentiSeconds;

initial_test_structure.GPS_cow1.measurements = bad_data;
initial_test_structure.GPS_cow2.measurements = bad_data;
initial_test_structure.GPS_cow3.measurements = bad_data;

initial_test_structure.GPS_cow1.values = good_time_data;
initial_test_structure.GPS_cow2.values = good_time_data;
initial_test_structure.GPS_cow3.values = good_time_data;

initial_test_structure.pig1.GPS_Time= good_time_data;
initial_test_structure.pig2.GPS_Time= good_time_data;
initial_test_structure.pig3.GPS_Time= bad_data;
initial_test_structure.pig1.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig2.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig3.centiSeconds = SensorCentiSeconds;

initial_test_structure.pig1.measurements = good_time_data;
initial_test_structure.pig2.measurements = good_time_data;
initial_test_structure.pig3.measurements = good_time_data;

dataStructure = initial_test_structure;

fill_type = 1;
fid = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, ('GPS_Time'), ('GPS'), (fill_type), (fid));

% Show GPS are all trimmed
assert(all(~isnan(trimmed_dataStructure.GPS_cow1.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow2.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow3.GPS_Time)));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(end,1),roundedDownEndTime));

% Show non GPS data are unchanged
assert(isequal(initial_test_structure.pig1,trimmed_dataStructure.pig1));
assert(isequal(initial_test_structure.pig2,trimmed_dataStructure.pig2));
assert(isequal(initial_test_structure.pig3,trimmed_dataStructure.pig3));

%% CASE 6: simple test, two data samples within same interval selecting higher
fig_num = 6;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


GPScentiSeconds = 10;
SensorCentiSeconds = 10;

startTime = 0.7;
endTime = 2.4;

roundedUpStartTime = ceil(startTime);
roundedDownEndTime = floor(endTime);

initial_test_structure = struct;
good_time_data = (startTime:(GPScentiSeconds*0.01):2.4)';

std_dev = 0; % Small changes in time?
bad_time_data = good_time_data + std_dev * randn(length(good_time_data(:,1)),1);
% Shift some of the data forward in time to force overlap
bad_time_data = [bad_time_data(1:8,:); bad_time_data(9,:)-GPScentiSeconds*0.4*0.01; bad_time_data(9,:)+GPScentiSeconds*0.3*0.01; bad_time_data(10:end,:)];

% Make the good time data same length
good_time_data = (startTime:(GPScentiSeconds*0.01):2.5)';

bad_data = flipud(good_time_data);

initial_test_structure.GPS_cow1.GPS_Time= bad_time_data;

initial_test_structure.GPS_cow2.GPS_Time= good_time_data;
initial_test_structure.GPS_cow3.GPS_Time= good_time_data;
initial_test_structure.GPS_cow1.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow2.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow3.centiSeconds = GPScentiSeconds;

initial_test_structure.GPS_cow1.measurements = bad_data;
initial_test_structure.GPS_cow2.measurements = bad_data;
initial_test_structure.GPS_cow3.measurements = bad_data;

initial_test_structure.GPS_cow1.values = good_time_data;
initial_test_structure.GPS_cow2.values = good_time_data;
initial_test_structure.GPS_cow3.values = good_time_data;

initial_test_structure.pig1.GPS_Time= good_time_data;
initial_test_structure.pig2.GPS_Time= good_time_data;
initial_test_structure.pig3.GPS_Time= bad_data;
initial_test_structure.pig1.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig2.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig3.centiSeconds = SensorCentiSeconds;

initial_test_structure.pig1.measurements = good_time_data;
initial_test_structure.pig2.measurements = good_time_data;
initial_test_structure.pig3.measurements = good_time_data;

dataStructure = initial_test_structure;

fill_type = 1;
fid = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, ('GPS_Time'), ('GPS'), (fill_type), (fid));

% Show GPS are all trimmed
assert(all(~isnan(trimmed_dataStructure.GPS_cow1.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow2.GPS_Time)));
assert(all(~isnan(trimmed_dataStructure.GPS_cow3.GPS_Time)));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(end,1),roundedDownEndTime));

% Show non GPS data are unchanged
assert(isequal(initial_test_structure.pig1,trimmed_dataStructure.pig1));
assert(isequal(initial_test_structure.pig2,trimmed_dataStructure.pig2));
assert(isequal(initial_test_structure.pig3,trimmed_dataStructure.pig3));


%% CASE 7: simple test, GPS data missing and is kept as NaN values
fig_num = 7;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


GPScentiSeconds = 10;
SensorCentiSeconds = 10;

startTime = 0.7;
endTime = 2.4;

roundedUpStartTime = ceil(startTime);
roundedDownEndTime = floor(endTime);

initial_test_structure = struct;
good_time_data = (startTime:(GPScentiSeconds*0.01):2.4)';
good_data = flipud(good_time_data);

std_dev = 0; % Small changes in time?
bad_time_data = good_time_data + std_dev * randn(length(good_time_data(:,1)),1);

% Add 2 gaps into the data, at 7 and 10
bad_time_data = [bad_time_data(1:6,:); bad_time_data(8:9,:); bad_time_data(11:end,:)];
bad_data = flipud(bad_time_data);

initial_test_structure.GPS_cow1.GPS_Time= bad_time_data;
initial_test_structure.GPS_cow2.GPS_Time= bad_time_data;
initial_test_structure.GPS_cow3.GPS_Time= bad_time_data;
initial_test_structure.GPS_cow1.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow2.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow3.centiSeconds = GPScentiSeconds;

initial_test_structure.GPS_cow1.measurements = bad_data;
initial_test_structure.GPS_cow2.measurements = bad_data;
initial_test_structure.GPS_cow3.measurements = bad_data;

initial_test_structure.GPS_cow1.values = bad_time_data;
initial_test_structure.GPS_cow2.values = bad_time_data;
initial_test_structure.GPS_cow3.values = bad_time_data;

initial_test_structure.pig1.GPS_Time= good_time_data;
initial_test_structure.pig2.GPS_Time= good_time_data;
initial_test_structure.pig3.GPS_Time= good_time_data;
initial_test_structure.pig1.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig2.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig3.centiSeconds = SensorCentiSeconds;

initial_test_structure.pig1.measurements = good_data;
initial_test_structure.pig2.measurements = good_data;
initial_test_structure.pig3.measurements = good_data;

dataStructure = initial_test_structure;

fill_type = 0;
fid = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, ('GPS_Time'), ('GPS'), (fill_type), (fid));

% Show GPS are all trimmed
assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(end,1),roundedDownEndTime));

% Show that GPS_cow1, which has missing data, now contains NaN values
assert(any(isnan(trimmed_dataStructure.GPS_cow1.GPS_Time)));
assert(any(isnan(trimmed_dataStructure.GPS_cow2.GPS_Time)));
assert(any(isnan(trimmed_dataStructure.GPS_cow3.GPS_Time)));

% Show non GPS data are unchanged
assert(isequal(initial_test_structure.pig1,trimmed_dataStructure.pig1));
assert(isequal(initial_test_structure.pig2,trimmed_dataStructure.pig2));
assert(isequal(initial_test_structure.pig3,trimmed_dataStructure.pig3));



%% CASE 8: simple test, GPS data missing and is swapped with reference time
fig_num = 8;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


GPScentiSeconds = 10;
SensorCentiSeconds = 10;

startTime = 0.7;
endTime = 2.4;

roundedUpStartTime = ceil(startTime);
roundedDownEndTime = floor(endTime);

initial_test_structure = struct;
good_time_data = (startTime:(GPScentiSeconds*0.01):2.4)';
good_data = flipud(good_time_data);

std_dev = 0; % Small changes in time?
bad_time_data = good_time_data + std_dev * randn(length(good_time_data(:,1)),1);

% Add 2 gaps into the data, at 7 and 10
bad_time_data = [bad_time_data(1:6,:); bad_time_data(8:9,:); bad_time_data(11:end,:)];
bad_data = flipud(bad_time_data);

initial_test_structure.GPS_cow1.GPS_Time= bad_time_data;
initial_test_structure.GPS_cow2.GPS_Time= bad_time_data;
initial_test_structure.GPS_cow3.GPS_Time= bad_time_data;
initial_test_structure.GPS_cow1.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow2.centiSeconds = GPScentiSeconds;
initial_test_structure.GPS_cow3.centiSeconds = GPScentiSeconds;

initial_test_structure.GPS_cow1.measurements = bad_data;
initial_test_structure.GPS_cow2.measurements = bad_data;
initial_test_structure.GPS_cow3.measurements = bad_data;

initial_test_structure.GPS_cow1.values = bad_time_data;
initial_test_structure.GPS_cow2.values = bad_time_data;
initial_test_structure.GPS_cow3.values = bad_time_data;

initial_test_structure.pig1.GPS_Time= good_time_data;
initial_test_structure.pig2.GPS_Time= good_time_data;
initial_test_structure.pig3.GPS_Time= good_time_data;
initial_test_structure.pig1.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig2.centiSeconds = SensorCentiSeconds;
initial_test_structure.pig3.centiSeconds = SensorCentiSeconds;

initial_test_structure.pig1.measurements = good_data;
initial_test_structure.pig2.measurements = good_data;
initial_test_structure.pig3.measurements = good_data;

dataStructure = initial_test_structure;

fill_type = 1; % <--- This says to swap with reference time
fid = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, ('GPS_Time'), ('GPS'), (fill_type), (fid));

% Show GPS are all trimmed
assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(1,1),roundedUpStartTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(1,1),roundedUpStartTime));

assert(isequal(trimmed_dataStructure.GPS_cow1.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow2.GPS_Time(end,1),roundedDownEndTime));
assert(isequal(trimmed_dataStructure.GPS_cow3.GPS_Time(end,1),roundedDownEndTime));

% Show that GPS_cow1, which has missing data, now contains now NaN values
assert(~any(isnan(trimmed_dataStructure.GPS_cow1.GPS_Time)));
assert(~any(isnan(trimmed_dataStructure.GPS_cow2.GPS_Time)));
assert(~any(isnan(trimmed_dataStructure.GPS_cow3.GPS_Time)));

% Show non GPS data are unchanged
assert(isequal(initial_test_structure.pig1,trimmed_dataStructure.pig1));
assert(isequal(initial_test_structure.pig2,trimmed_dataStructure.pig2));
assert(isequal(initial_test_structure.pig3,trimmed_dataStructure.pig3));




%% Corrupt the GPS times on some of the sensors to mis-align them
fig_num = 2;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end


% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;
fid = 1;

BadDataStructure = dataStructure;
BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - 1.03; 
BadDataStructure.GPS_Hemisphere.GPS_Time = BadDataStructure.GPS_Hemisphere.GPS_Time + 1.11; 

fprintf(fid,'\nData created with shifted up/down GPS_Time fields');

% Show that the data are not aligned by performing a consistency check. It
% should show that the GPS_Sparkfun_RearRight has the lowest time, and
% GPS_Hemisphere has the largest time
[flags, offending_sensor] = fcn_DataClean_checkDataTimeConsistency(BadDataStructure,fid);

assert(isequal(flags.GPS_Time_has_consistent_start_end_across_GPS_sensors,0));
assert(strcmp(offending_sensor,'Start values of: GPS_Sparkfun_RearRight GPS_Hemisphere'));

% Fix the data
field_name = 'GPS_Time';
sensors_to_check = [];
fill_type = 1;
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(BadDataStructure, (field_name), (sensors_to_check), (fill_type), (fid));

% Make sure it worked
% [first_times,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(trimmed_dataStructure, field_name, sensors_to_check,'first_row');
% [last_times,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(trimmed_dataStructure, field_name, sensors_to_check,'last_row');

sensor_names = fieldnames(trimmed_dataStructure); % Grab all the fields that are in dataStructure structure
start_time = round(trimmed_dataStructure.(sensor_names{1}).GPS_Time(1));
end_time   = round(trimmed_dataStructure.(sensor_names{1}).GPS_Time(end));
for i_data = 2:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{i_data};
        
    % Make sure the sensor stops within one sampling period of start/end
    % times (it is different for each sensor)
    assert(trimmed_dataStructure.(sensor_name).GPS_Time(1,1)>= start_time - trimmed_dataStructure.(sensor_name).centiSeconds);
    assert(trimmed_dataStructure.(sensor_name).GPS_Time(end,1)<= end_time + trimmed_dataStructure.(sensor_name).centiSeconds);
end


%% CASE 900: Real world data
fig_num = 900;
if ~isempty(findobj('Number',fig_num))
    figure(fig_num);
    clf;
end

fullExampleFilePath = fullfile(cd,'Data','ExampleData_trimDataToCommonStartEndGPSTimes.mat');
load(fullExampleFilePath,'dataStructure');

fid = 1;
fill_type = 1;
field_name = 'GPS_Time';
sensors_to_check = 'GPS';
trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, (field_name), (sensors_to_check), (fill_type), (fid));

% Make sure it worked
[first_times,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(trimmed_dataStructure, field_name, sensors_to_check,'first_row');
temp = [first_times{:}]' - first_times{1};
assert(all(abs(temp)<0.1));

[last_times,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(trimmed_dataStructure, field_name, sensors_to_check,'last_row');
temp = [last_times{:}]' - last_times{1};
assert(all(abs(temp)<0.1));

%% CASE 903: Real world data
% fig_num = 903;
% if ~isempty(findobj('Number',fig_num))
%     figure(fig_num);
%     clf;
% end
% 
% fullExampleFilePath = fullfile(cd,'Data','ExampleData_trimDataToCommonStartEndGPSTimes3.mat');
% load(fullExampleFilePath,'dataStructure');
% 
% field_name = 'ROS_Time';
% sensors_to_check = 'GPS';
% fill_type = 1;
% trimmed_dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(dataStructure, (field_name), (sensors_to_check), (fill_type), (fid));
% 
% % Show it worked
% assert(any(isnan(dataStructure.GPS_SparkFun_Front.ROS_Time)));
% assert(any(isnan(dataStructure.GPS_SparkFun_RightRear.ROS_Time)));
% 
% assert(~any(isnan(trimmed_dataStructure.GPS_SparkFun_Front.ROS_Time)));
% assert(~any(isnan(trimmed_dataStructure.GPS_SparkFun_RightRear.ROS_Time)));

%% Fail conditions
if 1==0
    


end
