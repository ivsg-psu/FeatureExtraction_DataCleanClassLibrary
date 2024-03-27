function rawdata = fcn_DataClean_loadMappingVanDataFromFile(dataFolder,fid)
% fcn_DataClean_loadMappingVanDataFromFile
% imports raw data from mapping van bag files
%
% FORMAT:
%
%      rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName)
%
% INPUTS:
%
%      bagFolderName: the folder name where the bag files are located as a
%      sub-directory within the LargeData subdirectory of the
%      DataCleanClass library.
%
%      (OPTIONAL INPUTS)
%
%      lane_folder: the sub-folder where the bag files are located
%
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
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history
% 2023_06_16 - Xinyu Cao
% -- wrote the code originally as a script, using data from
% mapping_van_2023-06-05-1Lap as starter, the main part of the code will be
% functionalized as the function fcn_DataClean_loadRawDataFromFile The
% result of the code will be a structure store raw data from bag file
% 2023_06_19 - S. Brennan
% -- first functionalization of the code
% 2023_06_22 - S. Brennan
% -- fixed fcn_DataClean_loadRawDataFromFile_SickLidar filename
% -- to correct: fcn_DataClean_loadRawDataFromFile_sickLIDAR
% 2023_06_22 - S. Brennan
% AGAIN - someone reverted the edits
% -- fixed fcn_DataClean_loadRawDataFromFile_SickLidar filename
% -- to correct: fcn_DataClean_loadRawDataFromFile_sickLIDAR
% 2023_06_26 - X. Cao
% -- modified fcn_DataClean_loadRawDataFromFile_Diagnostic
% -- The old diagnostic topics 'diagnostic_trigger' and
% 'diagnostic_encoder' are replaced with 'Trigger_diag' and 'Encoder_diag'
% -- modified fcn_DataClean_loadRawDataFromFile_SparkFun_GPS
% -- each sparkfun gps has three topics, sparkfun_gps_GGA, sparkfun_gps_VTG
% and sparkfun_gps_GST. 
% 2023_07_04 - S. Brennan
% -- added FID to fprint to allow printing to file
% -- moved loading print statements to this file, not subfiles


flag_do_debug = 1;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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

% if nargin <= 3
%     dataFolder = fullfile(pwd, 'LargeData',date, bagFolderName);
% else
%     laneName = varargin{1};
%     dataFolder = fullfile(pwd, 'LargeData', date,laneName,bagFolderName);
% end

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(2,4);
        
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
file_list = dir(dataFolder);
num_files = length(file_list);

% Initialize an empty structure
rawdata = struct;

if fid
    fprintf(fid,'Loading data from files in folder: %s\n',dataFolder);
end

% Search the contents of the directory for data files
for file_idx = 1:num_files

    % Check that the list is the file. If it is a directory, the isdir flag
    % will be 1.
    if file_list(file_idx).isdir ~= 1 
        % Get the file name
        file_name = file_list(file_idx).name;

        % Remove the extension
        file_name_noext = extractBefore(file_name,'.');

        topic_name = strrep(file_name_noext,'_slash_','/');
        


        datatype = fcn_DataClean_determineDataType(topic_name);
        
        % Tell the user what we are doing
        if fid
            fprintf(fid,'\t Loading file: %s, with topic name: %s, with datatype: %s \n',file_name, topic_name,datatype);
        end
        
        full_file_path = fullfile(dataFolder,file_name);
        % topic name is used to decide the sensor
%         topic sicm_,ms500/sick_time 
        if any([contains(topic_name,'sick_lms500/scan') contains(topic_name,'sick_lms_5xx/scan')])

            SickLiDAR = fcn_DataClean_loadRawDataFromFile_sickLIDAR(full_file_path,datatype,fid);
            rawdata.Lidar_Sick_Rear = SickLiDAR;

        else
            if contains(topic_name, 'Bin1')
                Hemisphere_DGPS = fcn_DataClean_loadRawDataFromFile_Hemisphere(full_file_path,datatype,fid);
                rawdata.GPS_Hemisphere_SensorPlatform = Hemisphere_DGPS;

            elseif contains(topic_name, 'GPS_Novatel')


                GPS_Novatel = fcn_DataClean_loadRawDataFromFile_Novatel_GPS(full_file_path,datatype,fid);

                rawdata.GPS_Novatel_SensorPlatform = GPS_Novatel;

            elseif contains(topic_name, 'Garmin_GPS')


                GPS_Garmin = fcn_DataClean_loadRawDataFromFile_Garmin_GPS(full_file_path,datatype,fid);
                rawdata.GPS_Garmin_TopCenter = GPS_Garmin;

            elseif contains(topic_name, 'Novatel_IMU')

                Novatel_IMU = fcn_DataClean_loadRawDataFromFile_IMU_Novatel(full_file_path,datatype,fid);
                rawdata.IMU_Novatel_TopCenter = Novatel_IMU;

            elseif contains(topic_name, 'parseEncoder')

                parseEncoder = fcn_DataClean_loadRawDataFromFile_parse_Encoder(full_file_path,datatype,fid);
                rawdata.Encoder_Raw = parseEncoder;

            elseif contains(topic_name, 'imu/data_raw')

                adis_IMU_dataraw = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,topic_name);
                rawdata.IMU_adis_dataraw = adis_IMU_dataraw;


            elseif contains(topic_name, 'imu/rpy/filtered')

                adis_IMU_filtered_rpy = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,topic_name);
                rawdata.IMU_adis_filtered_rpy = adis_IMU_filtered_rpy;

            elseif contains(topic_name, 'imu/data')

                adis_IMU_data = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,topic_name);
                rawdata.IMU_adis_data = adis_IMU_data;
            
            elseif contains(topic_name, 'imu/mag')

                adis_IMU_mag = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,topic_name);
                rawdata.IMU_adis_mag = adis_IMU_mag;

            elseif contains(topic_name, 'adis_msg')

                adis_msg = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,topic_name);
                rawdata.adis_msg = adis_msg;


            elseif contains(topic_name, 'adis_temp')

                adis_temp = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,topic_name);
                rawdata.adis_temp = adis_temp;

            elseif contains(topic_name, 'adis_press')

                adis_press = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,topic_name);
                rawdata.adis_press = adis_press;
           

            elseif contains(topic_name,'parseTrigger')

                parseTrigger = fcn_DataClean_loadRawDataFromFile_parse_Trigger(full_file_path,datatype,fid);
                rawdata.Trigger_Raw = parseTrigger;

            elseif contains(topic_name, 'GPS_SparkFun_RearLeft_GGA')

                SparkFun_GPS_RearLeft_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_LeftRear_GGA = SparkFun_GPS_RearLeft_GGA;
            
            elseif contains(topic_name, 'GPS_SparkFun_RearLeft_VTG')

                SparkFun_GPS_RearLeft_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_LeftRear_VTG = SparkFun_GPS_RearLeft_VTG;

            elseif contains(topic_name, 'GPS_SparkFun_RearLeft_GST')

                SparkFun_GPS_RearLeft_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_LeftRear_GST = SparkFun_GPS_RearLeft_GST;

            elseif contains(topic_name, 'GPS_SparkFun_RearRight_GGA')
                sparkfun_gps_rear_right_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_RightRear_GGA = sparkfun_gps_rear_right_GGA;
            
            elseif contains(topic_name, 'GPS_SparkFun_RearRight_VTG')
                sparkfun_gps_rear_right_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_RightRear_VTG = sparkfun_gps_rear_right_VTG;
            
            elseif contains(topic_name, 'GPS_SparkFun_RearRight_GST')
                sparkfun_gps_rear_right_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_RightRear_GST = sparkfun_gps_rear_right_GST;

            elseif contains(topic_name, 'Trigger_diag')
                diagnostic_trigger = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,topic_name);
                rawdata.Diag_Trigger = diagnostic_trigger;
    
            elseif contains(topic_name, 'Encoder_diag')
                diagnostic_encoder = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,topic_name);
                rawdata.Diag_Encoder = diagnostic_encoder;
               
            elseif contains(topic_name, 'GPS_SparkFun_Front_GGA')
                SparkFun_GPS_Front_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_Front_GGA = SparkFun_GPS_Front_GGA;

           elseif contains(topic_name, 'GPS_SparkFun_Front_VTG')
                SparkFun_GPS_Front_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_Front_VTG = SparkFun_GPS_Front_VTG;


           elseif contains(topic_name, 'GPS_SparkFun_Front_GST')
                SparkFun_GPS_Front_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_Front_GST = SparkFun_GPS_Front_GST;


            elseif contains(topic_name, 'GPS_SparkFun_Temp_GGA')
                SparkFun_GPS_Temp_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
                rawdata.GPS_SparkFun_Temp_GGA = SparkFun_GPS_Temp_GGA;
            
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
                rawdata.Transform = transform_struct;

            elseif contains(topic_name,'velodyne_packets')
                Velodyne_lidar_struct = fcn_DataClean_loadRawDataFromFile_velodyneLIDAR(full_file_path,datatype,fid);
                rawdata.Lidar_Velodyne_Rear = Velodyne_lidar_struct;

            elseif contains(topic_name,'/rear_left_camera/image_color/compressed')
                rear_left_camera_folder = 'images/rear_left_camera/';
                Camera_Rear_Left_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,rear_left_camera_folder,datatype,fid);
                rawdata.Camera_Rear_Left = Camera_Rear_Left_struct;

            elseif contains(topic_name,'/rear_center_camera/image_color/compressed')
                rear_center_camera_folder = 'images/rear_center_camera/';
                Camera_Rear_Center_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,rear_center_camera_folder,datatype,fid);
                rawdata.Camera_Rear_Center = Camera_Rear_Center_struct;

            elseif contains(topic_name,'/rear_right_camera/image_color/compressed')
                rear_right_camera_folder = 'images/rear_right_camera/';
                Camera_Rear_Right_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,rear_right_camera_folder,datatype,fid);
                rawdata.Camera_Rear_Right = Camera_Rear_Right_struct;

            elseif contains(topic_name,'/front_left_camera/image_color/compressed')
                front_left_camera_folder = 'images/front_left_camera/';
                Camera_Front_Left_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,front_left_camera_folder,datatype,fid);
                rawdata.Camera_Front_Left = Camera_Front_Left_struct;

            elseif contains(topic_name,'/front_center_camera/image_color/compressed')
                front_center_camera_folder = 'images/front_center_camera/';
                Camera_Front_Center_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,front_center_camera_folder,datatype,fid);
                rawdata.Camera_Front_Center = Camera_Front_Center_struct;

            elseif contains(topic_name,'/front_right_camera/image_color/compressed')
                front_right_camera_folder = 'images/front_right_camera/';
                Camera_Front_Right_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,front_right_camera_folder,datatype,fid);
                rawdata.Camera_Front_Right = Camera_Front_Right_struct;


            else
                fprintf(fid,'\t\tWARNING: Topic not processed: %s\n',topic_name);
            end
        end
    end % Ends check if the directory list is a file
end % Ends loop through directory list

%%
fprintf(1,'\nLoading completed\n')

%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots
    
    % Nothing to plot        
    
end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function




%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§
