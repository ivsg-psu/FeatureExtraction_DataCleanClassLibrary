% script_test_fcn_DataClean_pullDataFromFieldAcrossAllSensors.m
% tests fcn_DataClean_pullDataFromFieldAcrossAllSensors

% Revision history
% 2023_06_25 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all
clc
fid = 1;

% Fill in the initial data
dataStructure = fcn_DataClean_fillTestDataStructure;

 

%% CASE 1: Basic Example - pull centiSeconds from every sensor
fprintf(1,'\nCASE 1: Demonstrating pulling centiseconds from every sensor, without being verbose: \n');
[data,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds');

% Print the result in nice table:
fprintf(1,'\nHere is the result, as a table of centiseconds query over all sensors:\n');
fixed_length_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',25);
fprintf(1,'%s \t %s\n',fixed_length_string,'centiSeconds:');
for ith_data = 1:length(data)
    fixed_length_string = fcn_DebugTools_debugPrintStringToNCharacters(sensorNames{ith_data},25);
    fprintf(1,'%s \t %.3f\n',fixed_length_string,data{ith_data});
end
fprintf(1,'\n');

% Make sure it worked
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
for ith_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{ith_data};
    
    % If not empty, check it
    if ~isempty(data{ith_data})
        assert(dataStructure.(sensor_name).centiSeconds(1,1)== data{ith_data});
    end
end

%% CASE 2: Basic Example - pull centiSeconds from every sensor (verbose)
fprintf(1,'\nCASE 2: Demonstrating pulling centiseconds from every sensor, being verbose: \n\n');

[data,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds', [],[], fid);

% Print the result in nice table:
fprintf(1,'Example table of centiseconds query over all sensors:\n');
fixed_length_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',25);
fprintf(1,'%s \t %s\n',fixed_length_string,'centiSeconds:');
for ith_data = 1:length(data)
    fixed_length_string = fcn_DebugTools_debugPrintStringToNCharacters(sensorNames{ith_data},25);
    fprintf(1,'%s \t %.3f\n',fixed_length_string,data{ith_data});
end
fprintf(1,'\n');

% Make sure it worked
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
for ith_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{ith_data};
    
    % If not empty, check it
    if ~isempty(data{ith_data})
        assert(dataStructure.(sensor_name).centiSeconds(1,1)== data{ith_data});
    end
end


%% CASE 3: Basic Example - pull centiSeconds from every GPS sensor
fprintf(1,'\nCASE 3: Demonstrating pulling centiseconds from only GPS sensors, NOT verbose: \n\n');

[data,sensorNames] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds','GPS');

% Print the result in nice table:
fprintf(1,'\nThe results are now shown as a table of centiseconds query over just GPS sensors:\n');
fixed_length_string = fcn_DebugTools_debugPrintStringToNCharacters('Sensors:',25);
fprintf(1,'%s \t %s\n',fixed_length_string,'centiSeconds:');
for ith_data = 1:length(data)
    fixed_length_string = fcn_DebugTools_debugPrintStringToNCharacters(sensorNames{ith_data},25);
    fprintf(1,'%s \t %.3f\n',fixed_length_string,data{ith_data});
end
fprintf(1,'\n');


% Make sure it worked
sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
current_hit = 1;
for ith_data = 1:length(sensor_names)
    % Grab the sensor subfield name
    sensor_name = sensor_names{ith_data};
    
    if contains(lower(sensor_name),lower('GPS'))
        % If not empty, check it
        if ~isempty(data{current_hit})
            assert(dataStructure.(sensor_name).centiSeconds(1,1)== data{current_hit});
            current_hit = current_hit+1;
        end
    end
end


%% Basic Example - pull bad name from every sensor - produces emtpy matrix
data = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'goofybadname');
assert(isempty(cell2mat(data)));

%% Basic Example - pull first_row value from GPS_Time, for all sensors
[data, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','','first_row');
assert(isequal(cell2mat(data),zeros(1,8)));

%% Basic Example - pull first_row value from GPS_Time, for all GPS sensors
[data, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS','first_row');
assert(isequal(cell2mat(data),[0 0 0]));

%% Basic Example - pull first_row value from GPS_Time, for all GPS sensors
[data, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS','last_row');
assert(isequal(cell2mat(data),[5 5 5]));

%% Fail conditions
if 1==0
    
    %% ERROR for point-type, due to bad alignment
    % Note that this is 5 seconds of data, and the Hemisphere is starting
    % after all the other sensors ended
    BadDataStructure = dataStructure;
    BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time = BadDataStructure.GPS_Sparkfun_RearRight.GPS_Time - 1;
    BadDataStructure.GPS_Hemisphere.GPS_Time = BadDataStructure.GPS_Hemisphere.GPS_Time + 5.1;
    
    dataStructure = fcn_DataClean_trimDataToCommonStartEndGPSTimes(BadDataStructure,fid);


end
