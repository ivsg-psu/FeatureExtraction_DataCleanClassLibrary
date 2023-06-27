function rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName)
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
%      (none)
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
% TO DO
% -- Discuss how to merge the sparkfun gps topics into one topic for each
% SparkFun GPS receiver

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

dataFolder = fullfile(pwd, 'LargeData', bagFolderName);

if flag_check_inputs
    % Are there the right number of inputs?
    if nargin < 1 || nargin > 1
        error('Incorrect number of input arguments')
    end
        
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
flag_do_debug = 1;

% Initialize an empty structure
rawdata = struct;

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
        full_file_path = fullfile(dataFolder,file_name);
        % topic name is used to decide the sensor
%         topic sicm_,ms500/sick_time 
        if contains(topic_name,'sick_lms500/scan')

            SickLiDAR = fcn_DataClean_loadRawDataFromFile_sickLIDAR(full_file_path,datatype,flag_do_debug);
            rawdata.SickLiDAR = SickLiDAR;

        else
            if contains(topic_name, 'Bin1')
                Hemisphere_DGPS = fcn_DataClean_loadRawDataFromFile_Hemisphere(full_file_path,datatype,flag_do_debug);
                rawdata.Hemisphere_DGPS = Hemisphere_DGPS;

            elseif contains(topic_name, 'GPS_Novatel')


                GPS_Novatel = fcn_DataClean_loadRawDataFromFile_Novatel_GPS(full_file_path,datatype,flag_do_debug);

                rawdata.GPS_Novatel = GPS_Novatel;

            elseif contains(topic_name, 'Garmin_GPS')


                GPS_Garmin = fcn_DataClean_loadRawDataFromFile_Garmin_GPS(full_file_path,datatype,flag_do_debug);
                rawdata.Garmin_GPS = GPS_Garmin;

            elseif contains(topic_name, 'Novatel_IMU')

                Novatel_IMU = fcn_DataClean_loadRawDataFromFile_IMU_Novatel(full_file_path,datatype,flag_do_debug);
                rawdata.Novatel_IMU = Novatel_IMU;

            elseif contains(topic_name, 'parseEncoder')

                parseEncoder = fcn_DataClean_loadRawDataFromFile_parse_Encoder(full_file_path,datatype,flag_do_debug);
                rawdata.Raw_Encoder = parseEncoder;

            elseif contains(topic_name, 'imu/data_raw')

                adis_IMU_dataraw = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.adis_IMU_dataraw = adis_IMU_dataraw;


            elseif contains(topic_name, 'imu/rpy/filtered')

                adis_IMU_filtered_rpy = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.adis_IMU_filtered_rpy = adis_IMU_filtered_rpy;

            elseif contains(topic_name, 'imu/data')

                adis_IMU_data = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.adis_IMU_data = adis_IMU_data;
            
            elseif contains(topic_name, 'imu/mag')

                adis_IMU_mag = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.adis_IMU_mag = adis_IMU_mag;

            elseif contains(topic_name, 'adis_msg')

                adis_msg = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.adis_msg = adis_msg;


            elseif contains(topic_name, 'adis_temp')

                adis_temp = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.adis_temp = adis_temp;

            elseif contains(topic_name, 'adis_press')

                adis_press = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.adis_press = adis_press;
           

            elseif contains(topic_name,'parseTrigger')

                parseTrigger = fcn_DataClean_loadRawDataFromFile_parse_Trigger(full_file_path,datatype,flag_do_debug);
                rawdata.RawTrigger = parseTrigger;

            elseif contains(topic_name, 'sparkfun_gps_rear_left_GGA')

                SparkFun_GPS_RearLeft_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.SparkFun_GPS_RearLeft_GGA = SparkFun_GPS_RearLeft_GGA;
            
            elseif contains(topic_name, 'sparkfun_gps_rear_left_VTG')

                SparkFun_GPS_RearLeft_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.SparkFun_GPS_RearLeft_VTG = SparkFun_GPS_RearLeft_VTG;

            elseif contains(topic_name, 'sparkfun_gps_rear_left_GST')

                SparkFun_GPS_RearLeft_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.SparkFun_GPS_RearLeft_GST = SparkFun_GPS_RearLeft_GST;

            elseif contains(topic_name, 'sparkfun_gps_rear_right_GGA')
                sparkfun_gps_rear_right_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.SparkFun_GPS_RearRight = sparkfun_gps_rear_right_GGA;
            
            elseif contains(topic_name, 'sparkfun_gps_rear_right_VTG')
                sparkfun_gps_rear_right_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.SparkFun_GPS_RearRight_VTG = sparkfun_gps_rear_right_VTG;
            
            elseif contains(topic_name, 'sparkfun_gps_rear_right_GST')
                sparkfun_gps_rear_right_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.SparkFun_GPS_RearRight_GST = sparkfun_gps_rear_right_GST;

            elseif contains(topic_name, 'Trigger_diag')
                diagnostic_trigger = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.diagnostic_trigger = diagnostic_trigger;
    
            elseif contains(topic_name, 'Encoder_diag')
                diagnostic_encoder = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.diagnostic_encoder = diagnostic_encoder;
            
            elseif contains(topic_name, 'sparkfun_gps_diag_rear_left')
                sparkfun_gps_diag_rear_left = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.sparkfun_gps_diag_rear_left = sparkfun_gps_diag_rear_left;
    
            elseif contains(topic_name, 'sparkfun_gps_diag_rear_right')
                sparkfun_gps_diag_rear_right = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,flag_do_debug,topic_name);
                rawdata.sparkfun_gps_diag_rear_right = sparkfun_gps_diag_rear_right;


            elseif contains(topic_name,'ntrip_info')
                ntrip_info = fcn_DataClean_loadRawDataFromFile_NTRIP(full_file_path,datatype,flag_do_debug);
                rawdata.ntrip_info = ntrip_info;
%           Comment out due to format error with detectImportOptions
%             elseif (contains(topic_name,'rosout') && ~contains(topic_name,'agg'))
% 
%                 ROSOut = fcn_DataClean_loadRawDataFromFile_ROSOut(full_file_path,datatype,flag_do_debug);
%                 rawdata.ROSOut = ROSOut;

            elseif contains(topic_name,'tf')
                transform_struct = fcn_DataClean_loadRawDataFromFile_Transform(full_file_path,datatype,flag_do_debug);
                rawdata.transform = transform_struct;

            else
                fprintf(1,'WARNING: Topic not processed: %s\n',topic_name)
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
