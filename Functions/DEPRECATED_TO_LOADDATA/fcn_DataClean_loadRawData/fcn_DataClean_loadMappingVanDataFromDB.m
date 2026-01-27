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

% if flag_check_inputs
%     % Are there the right number of inputs?
%     narginchk(1,3);
%         
%     % Check if dataFolder is a directory. If directory is not there, warn
%     % the user.
%     try
%         fcn_DebugTools_checkInputsToFunctions(dataFolder, 'DoesDirectoryExist');
%     catch ME
%         warning(['It appears that data was not pushed into a folder: ' ...
%             '\\DataCleanClassLibrary\LargeData ' ...
%             'which is the folder where large data is imported for processing. ' ...
%             'Note that this folder is too large to include in the code repository, ' ...
%             'so it must be copied over from a data storage location. Within IVSG, ' ...
%             'this storage location is the OndeDrive folder called GitHubMirror.']);
%         rethrow(ME)
%     end
% end

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
    field_name = fields{field_idx};
  
    datatype = fcn_DataClean_determineDataType(field_name);
        
        % Tell the user what we are doing
    if fid
       fprintf(fid,'\t Loading database: %s, with field name: %s, with datatype: %s \n',database_name, field_name, datatype);
    end

  % topic name is used to decide the sensor
%         topic sicm_,ms500/sick_time 
    if contains(field_name,'Hemisphere_DGPS')
        Hemisphere = fcn_DataClean_loadRawDataFromDB_Hemisphere(result.Hemisphere_DGPS,datatype,fid);
        rawData.GPS_Hemisphere = Hemisphere;

    elseif contains(field_name,'Lidar_Sick')

        SickLiDAR = fcn_DataClean_loadRawDataFromDB_sickLIDAR(result.Lidar_Sick,datatype,fid);
        rawData.Lidar_Sick_Rear = SickLiDAR;
  
    elseif contains(field_name, 'GPS_SparkFun_LeftRear_GGA')
     
        SparkFun_GPS_RearLeft_GGA = fcn_DataClean_loadRawDataFromDB_Sparkfun_GPS(result.GPS_SparkFun_LeftRear_GGA,datatype,field_name,fid);
        rawData.GPS_SparkFun_LeftRear_GGA = SparkFun_GPS_RearLeft_GGA;
            
    elseif contains(field_name, 'GPS_SparkFun_LeftRear_VTG')

        SparkFun_GPS_RearLeft_VTG = fcn_DataClean_loadRawDataFromDB_Sparkfun_GPS(result.GPS_SparkFun_LeftRear_VTG,datatype,field_name,fid);
        rawData.GPS_SparkFun_LeftRear_VTG = SparkFun_GPS_RearLeft_VTG;
            
    elseif contains(field_name, 'GPS_SparkFun_LeftRear_GST')

        SparkFun_GPS_RearLeft_GST = fcn_DataClean_loadRawDataFromDB_Sparkfun_GPS(result.GPS_SparkFun_LeftRear_GST,datatype,field_name,fid);
        rawData.GPS_SparkFun_LeftRear_GST = SparkFun_GPS_RearLeft_GST;
           
    elseif contains(field_name, 'GPS_SparkFun_RightRear_GGA')

        SparkFun_GPS_RearRight_GGA = fcn_DataClean_loadRawDataFromDB_Sparkfun_GPS(result.GPS_SparkFun_RightRear_GGA,datatype,field_name,fid);
        rawData.GPS_SparkFun_RightRear_GGA = SparkFun_GPS_RearRight_GGA;

    elseif contains(field_name, 'GPS_SparkFun_RightRear_VTG')
  
        SparkFun_GPS_RearRight_VTG = fcn_DataClean_loadRawDataFromDB_Sparkfun_GPS(result.GPS_SparkFun_RightRear_VTG,datatype,field_name,fid);
        rawData.GPS_SparkFun_RightRear_VTG = SparkFun_GPS_RearRight_VTG;

    elseif contains(field_name, 'GPS_SparkFun_RightRear_GST')

        SparkFun_GPS_RearRight_GST = fcn_DataClean_loadRawDataFromDB_Sparkfun_GPS(result.GPS_SparkFun_RightRear_GST,datatype,field_name,fid);
        rawData.GPS_SparkFun_RightRear_GST = SparkFun_GPS_RearRight_GST;
            
    elseif contains(field_name,'parseTrigger')
        parseTrigger = fcn_DataClean_loadRawDataFromDB_parseTrigger(result.parseTrigger,datatype,fid);
        rawData.parseTrigger = parseTrigger;

    elseif contains(field_name,'parseEncoder')
        parseEncoder = fcn_DataClean_loadRawDataFromDB_parseEncoder(result.parseEncoder,datatype,fid);
        rawData.parseEncoder = parseEncoder;

    elseif contains(field_name,'adis_IMU_data')
        adis_IMU_data = fcn_DataClean_loadRawDataFromDB_IMU_ADIS(result.adis_IMU_data,datatype,fid);
        rawData.IMU_adis_data = adis_IMU_data;

    elseif contains(field_name, 'GPS_Novatel')

        GPS_Novatel = fcn_DataClean_loadRawDataFromDB_Novatel_GPS(result.GPS_Novatel,datatype,fid);
        rawData.GPS_Novatel_SensorPlatform = GPS_Novatel;
   
    elseif contains(field_name, 'Garmin_GPS')

        GPS_Garmin = fcn_DataClean_loadRawDataFromDB_Garmin_GPS(result.Garmin_GPS,datatype,fid);
        rawData.GPS_Garmin_TopCenter = GPS_Garmin;

    elseif contains(field_name,'Lidar_Velodyne')
        Velodyne_lidar_struct = fcn_DataClean_loadRawDataFromDB_velodyneLIDAR(result.Lidar_Velodyne,datatype,fid);
        rawData.Lidar_Velodyne_Rear = Velodyne_lidar_struct;

%     elseif contains(field_name, 'Novatel_IMU')
% 
%         Novatel_IMU = fcn_DataClean_loadRawDataFromDB_IMU_Novatel(result.Novatel_IMU,datatype,fid);
%         rawData.IMU_Novatel_TopCenter = Novatel_IMU;

%     elseif contains(topic_name,'tf')
%         transform_struct = fcn_DataClean_loadRawDataFromDB_Transform(full_file_path,datatype,fid);
%         rawData.Transform = transform_struct;

    

    else
        fprintf(fid,'\t\tWARNING: Topic not processed: %s\n',field_name);
    end
end % Ends for loop through all sensor names in rawData
return % Ends the function
