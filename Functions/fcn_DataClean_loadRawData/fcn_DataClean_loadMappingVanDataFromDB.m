function [rawData,varargout] = fcn_DataClean_loadMappingVanDataFromDB(result,database_name,fid)

% Purpose: This function is used to load and preprocess the raw data collected with the Penn State Mapping Van.
%
% Input Variables:
%      rawdata: data queried from the database
% OUTPUTS:
%
%      rawdata: a  data structure containing data fields filled for each
%      ROS topic
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_loadMappingVanDataFromFile
%     for a full test suite.
%
% Author:
% Xinyu Cao
% Created Date: 2023_09_06
%
% Revision history
% 2023_09_06 - Xinyu Cao
% -- wrote the code originally as a function, modified based on
% fcn_DataClean_loadMappingVanDataFromFile.m

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_do_debug = 1;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

if flag_do_debug
    % Grab function name
    st = dbstack;
    namestr = st.name;
    
    % Show what we are doing
    fprintf(1,'\nWithin function: %s\n',namestr);
    fprintf(1,'Starting load of rawData structure from source files.\n');
end

%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(fid)
    fid = 1;
end

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(1,2);
        
    % Check if dataFolder is a directory. If directory is not there, warn
    % the user.
    try
        fcn_DebugTools_checkInputsToFunctions(dataFolder, 'DoesDirectoryExist');
    catch ME
        warning(['It appears that data was not pushed into a folder: ' ...
            '\\DataCleanClassLibrary\LargeData ' ...
            'which is the folder where large data is imported for processing. ' ...
            'Note that this folder is too large to include in the code repository, ' ...
            'so it must be copied over from a data storage location. Within IVSG, ' ...
            'this storage location is the OndeDrive folder called GitHubMirror.']);
        rethrow(ME)
    end
end

%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Main script

% This part will be functionalized later

fields = fieldnames(result);
num_fields = length(fields);

% Initialize an empty structure
rawData = struct;

if fid
    fprintf(fid,'Loading data from database!');
end

%%
for field_idx = 1:num_fields

    % Check that the list is the file. If it is a directory, the isdir flag
    % will be 1.
    field_name = fields{field};
    datatype = fcn_DataClean_determineDataType(field_name);
        
        % Tell the user what we are doing
    if fid
       fprintf(fid,'\t Loading database: %s, with field name: %s, with datatype: %s \n',database_name, field_name, datatype);
    end
        
  % topic name is used to decide the sensor
%         topic sicm_,ms500/sick_time 
    if contains(field_name,'Hemisphere_DGPS')
        try
            Hemisphere = fcn_DataClean_loadRawDataFromDB_Hemisphere(result.Hemisphere_DGPS,datatype,fid);
            rawData.GPS_Hemisphere = Hemisphere;
        catch
    
            fprintf(1,'There is no GPS_Hemisphere field! \n');
        end
    end

    if contains(field_name,'Lidar')
        try

            SickLiDAR = fcn_DataClean_loadRawDataFromDB_sickLIDAR(result.Lidar,datatype,fid);
            rawData.Lidar_Sick_Rear = SickLiDAR;
        catch
            fprintf(1,'There is no Sick Lidar field! \n');
        end
    end

    if contains(field_name, 'GPS_Novatel')
        try 
                GPS_Novatel = fcn_DataClean_loadRawDataFromFile_Novatel_GPS(full_file_path,datatype,fid);

                rawData.GPS_Novatel_SensorPlatform = GPS_Novatel;
        catch
            fprintf(1,'There is no GPS_Novatel field! \n');
        end
    end
            

    if contains(topic_name, 'Garmin_GPS')


                GPS_Garmin = fcn_DataClean_loadRawDataFromFile_Garmin_GPS(full_file_path,datatype,fid);
                rawData.GPS_Garmin_TopCenter = GPS_Garmin;

            elseif contains(topic_name, 'Novatel_IMU')

                Novatel_IMU = fcn_DataClean_loadRawDataFromFile_IMU_Novatel(full_file_path,datatype,fid);
                rawData.IMU_Novatel_TopCenter = Novatel_IMU;

            elseif contains(topic_name, 'parseEncoder')

                parseEncoder = fcn_DataClean_loadRawDataFromFile_parse_Encoder(full_file_path,datatype,fid);
                rawData.Encoder_Raw = parseEncoder;

            elseif contains(topic_name, 'imu/data_raw')

                adis_IMU_dataraw = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,field_name);
                rawData.IMU_adis_dataraw = adis_IMU_dataraw;


            elseif contains(topic_name, 'imu/rpy/filtered')

                adis_IMU_filtered_rpy = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,field_name);
                rawData.IMU_adis_filtered_rpy = adis_IMU_filtered_rpy;

            elseif contains(topic_name, 'imu/data')

                adis_IMU_data = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,field_name);
                rawData.IMU_adis_data = adis_IMU_data;
            
            elseif contains(topic_name, 'imu/mag')

                adis_IMU_mag = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,field_name);
                rawData.IMU_adis_mag = adis_IMU_mag;

            elseif contains(topic_name, 'adis_msg')

                adis_msg = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,field_name);
                rawData.adis_msg = adis_msg;


            elseif contains(topic_name, 'adis_temp')

                adis_temp = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,field_name);
                rawData.adis_temp = adis_temp;

            elseif contains(topic_name, 'adis_press')

                adis_press = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,field_name);
                rawData.adis_press = adis_press;
           

            elseif contains(topic_name,'parseTrigger')

                parseTrigger = fcn_DataClean_loadRawDataFromFile_parse_Trigger(full_file_path,datatype,fid);
                rawData.Trigger_Raw = parseTrigger;

            elseif contains(topic_name, 'GPS_SparkFun_RearLeft_GGA')

                SparkFun_GPS_RearLeft_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,field_name);
                rawData.GPS_SparkFun_LeftRear_GGA = SparkFun_GPS_RearLeft_GGA;
            
            elseif contains(topic_name, 'GPS_SparkFun_RearLeft_VTG')

                SparkFun_GPS_RearLeft_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,field_name);
                rawData.GPS_SparkFun_LeftRear_VTG = SparkFun_GPS_RearLeft_VTG;

            elseif contains(topic_name, 'GPS_SparkFun_RearLeft_GST')

                SparkFun_GPS_RearLeft_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,field_name);
                rawData.GPS_SparkFun_LeftRear_GST = SparkFun_GPS_RearLeft_GST;

            elseif contains(topic_name, 'GPS_SparkFun_RearRight_GGA')
                sparkfun_gps_rear_right_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,field_name);
                rawData.GPS_SparkFun_RightRear_GGA = sparkfun_gps_rear_right_GGA;
            
            elseif contains(topic_name, 'GPS_SparkFun_RearRight_VTG')
                sparkfun_gps_rear_right_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,field_name);
                rawData.GPS_SparkFun_RightRear_VTG = sparkfun_gps_rear_right_VTG;
            
            elseif contains(topic_name, 'GPS_SparkFun_RearRight_GST')
                sparkfun_gps_rear_right_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,field_name);
                rawData.GPS_SparkFun_RightRear_GST = sparkfun_gps_rear_right_GST;

            elseif contains(topic_name, 'Trigger_diag')
                diagnostic_trigger = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,field_name);
                rawData.Diag_Trigger = diagnostic_trigger;
    
            elseif contains(topic_name, 'Encoder_diag')
                diagnostic_encoder = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,field_name);
                rawData.Diag_Encoder = diagnostic_encoder;
            
%             elseif contains(topic_name, 'DIAG_SparkFun_RearLeft')
%                 sparkfun_gps_diag_rear_left = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,topic_name);
%                 rawdata.Diag_GPS_SparkFun_LeftRear = sparkfun_gps_diag_rear_left;
%     
%             elseif contains(topic_name, 'DIAG_SparkFun_RearRight')
%                 sparkfun_gps_diag_rear_right = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,topic_name);
%                 rawdata.Diag_GPS_SparkFun_RightRear = sparkfun_gps_diag_rear_right;


%             elseif contains(topic_name,'ntrip_info')
%                 ntrip_info = fcn_DataClean_loadRawDataFromFile_NTRIP(full_file_path,datatype,fid);
%                 rawdata.ntrip_info = ntrip_info;
%           Comment out due to format error with detectImportOptions
%             elseif (contains(topic_name,'rosout') && ~contains(topic_name,'agg'))
% 
%                 ROSOut = fcn_DataClean_loadRawDataFromFile_ROSOut(full_file_path,datatype,fid);
%                 rawdata.ROSOut = ROSOut;

            elseif contains(topic_name,'tf')
                transform_struct = fcn_DataClean_loadRawDataFromFile_Transform(full_file_path,datatype,fid);
                rawData.Transform = transform_struct;

            elseif contains(topic_name,'velodyne_packets')
                Velodyne_lidar_struct = fcn_DataClean_loadRawDataFromFile_velodyneLIDAR(full_file_path,bagFolderName,datatype,fid);
                rawData.Lidar_Velodyne_Rear = Velodyne_lidar_struct;

            else
                fprintf(fid,'\t\tWARNING: Topic not processed: %s\n',field_name);
            end
        end
    end % Ends check if the directory list is a file
end % Ends loop through directory list

%% step1: determine the input data type
if isstring(varargin{1}) || ischar(varargin{1}) % input is a file, filename and variable name
    fprintf(1,'\n The data source is a file: %s\n',varargin{1});
    data_source = 'mat_file';
    filename = varargin{1};
    variable_names = varargin{2};
    
    %%Load the data
    data{1}.filename = filename;% 'Route_Wahba.mat';
    data{1}.variable_names ={variable_names}; % {'Route_WahbaLoop'};
    
    for i_data = 1:length(data)
        ith_filename = data{i_data}.filename;
        ith_variable_name = data{i_data}.variable_names{1}; % Need to do this as a loop if more than one variable
        if flag_do_debug
            % Show what we are doing
            fprintf(1,'Source file: %s is being used to load variable %s\n',ith_filename,ith_variable_name);
        end
        data_name = load(ith_filename,ith_variable_name);
    end
    data_struct = data_name.(ith_variable_name); %Accessing Data Using Dynamic Field Names
    varargout{1} = unique(data_struct.Hemisphere_DGPS.GPSWeek); % gps week of time
elseif isstruct(varargin{1}) % input is a struct type data queried from DB
    fprintf(1,'\n The data source is database. \n');
    data_source = 'database';
    data_struct = varargin{1};
elseif istable(varargin{1}) % input is a table type data parsed from csv and txt files
    fprintf(1,'\n The data source is . \n');

else
    msg = 'the data source format is not recognized.';
    error(msg);
end

%% step2: pre-processing the data sensor by sensor
%%Process data from the Hemisphere GPS

% call function to load and pre-process the Hemisphere GPS raw data
try
    Hemisphere = fcn_DataClean_loadRawData_Hemisphere(data_struct.Hemisphere_DGPS,data_source,flag_do_debug);
    rawData.GPS_Hemisphere = Hemisphere;
catch
    
    fprintf(1,'There is no GPS_Hemisphere data! \n');
end


%%Process data from Novatel GPS
try
    GPS_Novatel = fcn_DataClean_loadRawData_Novatel_GPS(data_struct.GPS_Novatel,Hemisphere,data_source,flag_do_debug);
    rawData.GPS_Novatel = GPS_Novatel;
catch
    
    fprintf(1,'There is no GPS_Novatel data!\n');
end


%%Process data from the Garmin
try
    GPS_Garmin = fcn_DataClean_loadRawData_Garmin_GPS(data_struct.Garmin_GPS,data_source,flag_do_debug);
    rawData.GPS_Garmin = GPS_Garmin;
catch
    
    fprintf('There is no GPS_Garmin data!\n');
end


%%Process data from the Novatel IMU
try
    IMU_Novatel = fcn_DataClean_loadRawData_IMU_Novatel(data_struct.Novatel_IMU,data_source,flag_do_debug);
    rawData.IMU_Novatel = IMU_Novatel;
catch
    
    fprintf('There is no IMU_Novatel data!\n');
end


%%Process data from the ADIS IMU
try
    IMU_ADIS = fcn_DataClean_loadRawData_IMU_ADIS(data_struct.adis_IMU_data,data_source,flag_do_debug);
    rawData.IMU_ADIS = IMU_ADIS;
catch
    
    fprintf('There is no IMU_ADIS data!\n');
end


%%Process data from the steering sensor - the sensor stinks, so we won't use it

try
    Input_Steering = fcn_DataClean_loadRawData_Input_Steering(data_struct.Steering_angle,data_source,flag_do_debug);
    rawData.Input_Steering = Input_Steering;
catch
    
    fprintf('There is no steering angle data data!\n');
end
%%Process data from the wheel encoders
% Note: left encoder looks disconnected, and counts on both are not working
% try
%     Encoder_RearWheels = fcn_DataClean_loadRawData_Encoder_RearWheels(data_struct.Raw_encoder,GPS_Novatel, data_source,flag_do_debug);
%     rawData.Encoder_RearWheels = Encoder_RearWheels;
% catch ME
%     fprintf('There is no Encoder_RearWheels data!\n');
%     rethrow(ME)
% 
% end

try
    Lidar = fcn_DataClean_loadRawData_Lidar(data_struct.Lidar,data_source,flag_do_debug);
    rawData.Lidar = Lidar;
catch
    
    fprintf('There is no Encoder_RearWheels data!\n');
end

% %% Process data from the Route_Wahba.mat file
% steeringAngleTime = data_struct.Steering_angle.Time - ...
%     data_struct.Steering_angle.Time(1);
% steeringAngleLeft_in_deg = data_struct.Steering_angle.LeftAngle*180/pi;
% steeringAngleRight_in_deg = data_struct.Steering_angle.RightAngle*180/pi;
% steeringAngle_in_deg = data_struct.Steering_angle.Angle*180/pi;
%
% % Plot results?Rou
% h_fig = figure(16262);
% set(h_fig,'Name','Raw_yaw_angle_in_deg');
% p1 = subplot(2,1,1);
% plot(steeringAngleTime,...
%     steeringAngleLeft_in_deg,'b'); hold on;
% p2 = subplot(2,1,2);
% plot(rawTime,...
%     [0; diff(yaw_angles_in_deg_from_velocity)],'k'); hold on;
%
% linkaxes([p1,p2],'x')


%% step3: Perform consistency checks
fcn_DataClean_checkConsistency(rawData,flag_do_debug);

%% step4: Close out the loading process
if flag_do_debug
    % Show what we are doing
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return

% ====================================================================================
% local functions
%   _                     _   ______                _   _
%  | |                   | | |  ____|              | | (_)
%  | |     ___   ___ __ _| | | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  | |    / _ \ / __/ _` | | |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |___| (_) | (_| (_| | | | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |______\___/ \___\__,_|_| |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% ========================================================================
function fcn_DataClean_checkConsistency(rawData,flag_do_debug)

if flag_do_debug
    % Grab function name
    st = dbstack;
    namestr = st.name;
    
    % Show what we are doing
    fprintf(1,'\nWithin subfunction: %s\n',namestr);
    fprintf(1,'Starting iterations through data structure to ensure there are no NaN.\n');
end

sensor_names = fieldnames(rawData); % Grab all the fields that are in rawData structure

for i_data = 1:length(sensor_names)
    % Grab the data subfield name
    sensor_name = sensor_names{i_data};
    d = rawData.(sensor_name);
    
    if flag_do_debug
        fprintf(1,'\n Sensor %d of %d: ',i_data,length(sensor_names));
    end
    
    % Check consistency of time data
    if flag_do_debug
        fprintf(1,'Checking time consitency:\n');
    end
    centiSeconds = d.centiSeconds;
    
    if isfield(d,'GPS_Time')
        if centiSeconds ~= round(100*mean(diff(d.GPS_Time)))
            error('For sensor: %s, the centiSeconds does not match the calculated time difference in GPS_Time',sensor_name);
        end
    end
    
    
    if flag_do_debug
        fprintf(1,'Searching NaN within fields for sensor: %s\n',sensor_name);
    end
    subfieldNames = fieldnames(d); % Grab all the subfields
    for i_subField = 1:length(subfieldNames)
        % Grab the name of the ith subfield
        subFieldName = subfieldNames{i_subField};
        
        if flag_do_debug
            fprintf(1,'\tProcessing subfield: %s ',subFieldName);
        end
        
        % Check to see if this subField has any NaN
        if ~iscell(d.(subFieldName))
            if any(isnan(d.(subFieldName)))
                if flag_do_debug
                    fprintf(1,' <-- contains an NaN value\n');
                end
            else % No NaNs found
                if flag_do_debug
                    fprintf(1,'\n');
                end
                
            end % Ends the if statement to check if subfield is on list
        end  % Ends if to check if the fiel is a call
    end % Ends for loop through the subfields
    
end  % Ends for loop through all sensor names in rawData
return % Ends the function
