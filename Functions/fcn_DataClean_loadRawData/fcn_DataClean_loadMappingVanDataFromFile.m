function rawData  = fcn_DataClean_loadMappingVanDataFromFile(dataFolderString, Identifiers, varargin)
% fcn_DataClean_loadMappingVanDataFromFile
% imports raw data from mapping van bag files, and if a figure number is
% given, plots a summary that shows the area of data that was collected
%
% FORMAT:
%
%      rawData = fcn_DataClean_loadMappingVanDataFromFile(dataFolderString, Identifiers, (bagName), (fid), (Flags), (fig_num))
%
% INPUTS:
%
%      dataFolderString: the folder name where the bag files are located as a
%      sub-directory within the LargeData subdirectory of the
%      DataCleanClass library.
%
%      Identifiers: a required structure indicating the labels to attach to
%      the files that are being loaded. The structure has the following
%      format:
%              
%             clear Identifiers
%             Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
%             Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
%             Identifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
%             Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
%             Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
%             Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
%             Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
%             Identifiers.SourceBagFileName =''; % This is filled in automatically for each file
%
%      For a list of allowable Identifiers, see:
%      https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
%
%      (OPTIONAL INPUTS)
%
%      bagName: the name of the bag file, for example:
%      "mapping_van_2024-07-10-19-36-59_3.bag". If within the name, the
%      extension ".bag" is dropped when naming the image output. If the
%      bagName is given as an empty input, e.g. [], then the entire
%      dataFolderString is queried for bagNames.
%
%      fid: the fileID where to print. Default is 1, to print results to
%      the console.
%
%      Flags: a structure containing key flags to set the process. The
%      defaults, and explanation of each, are below:
%
%           Flags.flag_do_load_sick = 0; % Loads the SICK LIDAR data
%           Flags.flag_do_load_velodyne = 0; % Loads the Velodyne LIDAR
%           Flags.flag_do_load_cameras = 0; % Loads camera images
%           Flags.flag_select_scan_duration = 0; % Lets user specify scans from Velodyne
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      rawData: a  data structure containing data fields filled for each
%      ROS topic. If multiple bag files are specified, a cell array of data
%      structures is returned.
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
% functionalized as the function fcn_DataClean_loadrawDataFromFile The
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
% 2023_07_02 - X. Cao
% -- added varagin to choose whether load LiDAR data
% 2024_08_29 - S. Brennan
% -- added debug headers
% -- added varagin for the FID input
% -- added fig_num input (to allow max_speed mode)
% -- fixed input argument checking area to be more clean
% 2024_09_05 - S. Brennan
% -- added automated image summary output
% 2024_09_06 - S. Brennan
% -- moved image output back out of the code
% -- added subPathStrings output


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==6 && isequal(varargin{end},-1))
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS");
    MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG = getenv("MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_fig_num = 999978; %#ok<NASGU>
else
    debug_fig_num = []; %#ok<NASGU>
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

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(2,6);

        % Check if dataFolderString is a directory. If directory is not there, warn
        % the user.
        try
            fcn_DebugTools_checkInputsToFunctions(dataFolderString, 'DoesDirectoryExist');
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
end

% Does user want to specify bagName?
bagName = [];
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        bagName = temp;
    end
end

% Does user want to specify fid?
fid = 1;
if 4 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        fid = temp;
    end
end


% Does user specify Flags?
% Set defaults
Flags.flag_do_load_SICK = 0;
Flags.flag_do_load_Velodyne = 0;
Flags.flag_do_load_cameras = 0;
Flags.flag_select_scan_duration = 0;

if 5 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        Flags = temp;
        
        % try
        %     temp = Flags.flag_select_scan_duration; %#ok<NASGU>
        % catch
        %     prompt = "Do you want to load the LiDAR scan for the entire route? y/n [y]";
        %     user_input_txt = input(prompt,"s");
        %     if isempty(user_input_txt)
        %         user_input_txt = 'y';
        %     end
        %     if strcmp(user_input_txt,'y')
        %         Flags.flag_select_scan_duration = 0;
        %     else
        %         Flags.flag_select_scan_duration = 1;
        %     end
        % end
    end
end


% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (6<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp;
        flag_do_plots = 1;
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

rawData = fcn_INTERNAL_readRawDataFromFolder(dataFolderString, fid, Flags);
if strcmp(dataFolderString(end),filesep)
    dataFolderStringCorrect = dataFolderString(1:end-1);
else
    dataFolderStringCorrect = dataFolderString;
end

% Grab the data's name
folderNames = split(dataFolderStringCorrect,filesep);
Identifiers.SourceBagFileName = folderNames{end};
rawData.Identifiers = Identifiers;

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
if (1==flag_do_plots)

    % Plot the base station
    fcn_plotRoad_plotLL([],[],fig_num);

    % % Test the function
    % clear plotFormat
    % plotFormat.LineStyle = '-';
    % plotFormat.LineWidth = 2;
    % plotFormat.Marker = 'none';
    % plotFormat.MarkerSize = 5;
    % plotFormat.Color = fcn_geometry_fillColorFromNumberOrName(2);


    fcn_DataClean_plotRawData(rawData, (bagName), ([]), ([]), (fig_num))
    h_legend = legend('Base station',bagName);
    set(h_legend,'Interpreter','none')

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

% fcn_INTERNAL_readRawDataFromFolder
function rawData = fcn_INTERNAL_readRawDataFromFolder(dataFolderString, fid, Flags)

flag_do_load_SICK = Flags.flag_do_load_SICK;
flag_do_load_Velodyne = Flags.flag_do_load_Velodyne;
flag_do_load_cameras = Flags.flag_do_load_cameras;
flag_select_scan_duration = Flags.flag_select_scan_duration;


% Grab the list of files in this directory
file_list = dir(dataFolderString);
num_files = length(file_list);

% Initialize an empty structure
rawData = struct;

if fid
    fprintf(fid,'Loading data from files from folder: \n\t%s\n',dataFolderString);
end

% Search the contents of the directory for data files
for file_idx = 1:num_files

    % Check that the list is the file. If it is a directory, the isdir flag
    % will be 1.
    if file_list(file_idx).isdir ~= 1
        % Get the file name
        file_name = file_list(file_idx).name;

        % Remove the extension?
        file_name_noext = extractBefore(file_name,'.');

        topic_name = strrep(file_name_noext,'_slash_','/');


        % Find the type of data for this topic
        datatype = fcn_DataClean_determineDataType(topic_name);

        % Tell the user what we are doing
        if fid
            fprintf(fid,'\t Loading file: %s, with topic name: %s, with datatype: %s \n',file_name, topic_name,datatype);
        end

        full_file_path = fullfile(dataFolderString,file_name);
        % topic name is used to decide the sensor
        %         topic sicm_lms500/sick_time

        if (any([contains(topic_name,'sick_lms500/scan') contains(topic_name,'sick_lms_5xx/scan')])) && flag_do_load_SICK

            SickLiDAR = fcn_DataClean_loadRawDataFromFile_sickLIDAR(full_file_path,datatype,fid);
            rawData.Lidar_Sick_Rear = SickLiDAR;
            % disp('Ignore for 2023-11-15')

        elseif contains(topic_name, 'Bin1')
            Hemisphere_DGPS = fcn_DataClean_loadRawDataFromFile_Hemisphere(full_file_path,datatype,fid);
            rawData.GPS_Hemisphere_SensorPlatform = Hemisphere_DGPS;

        elseif contains(topic_name, 'GPS_Novatel')


            GPS_Novatel = fcn_DataClean_loadRawDataFromFile_Novatel_GPS(full_file_path,datatype,fid);

            rawData.GPS_Novatel_SensorPlatform = GPS_Novatel;

        elseif contains(topic_name, 'Garmin_GPS')


            GPS_Garmin = fcn_DataClean_loadRawDataFromFile_Garmin_GPS(full_file_path,datatype,fid);
            rawData.GPS_Garmin_TopCenter = GPS_Garmin;

        elseif contains(topic_name, 'Novatel_IMU')

            Novatel_IMU = fcn_DataClean_loadRawDataFromFile_IMU_Novatel(full_file_path,datatype,fid);
            rawData.IMU_Novatel_TopCenter = Novatel_IMU;

        elseif contains(topic_name, 'parseEncoder')

            parseEncoder = fcn_DataClean_loadRawDataFromFile_parse_Encoder(full_file_path,datatype,fid);
            rawData.Encoder_Raw = parseEncoder;

        elseif contains(topic_name, 'imu/data_raw')

            adis_IMU_dataraw = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,topic_name);
            rawData.IMU_adis_dataraw = adis_IMU_dataraw;


        elseif contains(topic_name, 'imu/rpy/filtered')

            adis_IMU_filtered_rpy = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,topic_name);
            rawData.IMU_adis_filtered_rpy = adis_IMU_filtered_rpy;

        elseif contains(topic_name, 'imu/data')

            adis_IMU_data = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,topic_name);
            rawData.IMU_adis_data = adis_IMU_data;

        elseif contains(topic_name, 'imu/mag')

            adis_IMU_mag = fcn_DataClean_loadRawDataFromFile_IMU_ADIS(full_file_path,datatype,fid,topic_name);
            rawData.IMU_adis_mag = adis_IMU_mag;

        elseif contains(topic_name, 'adis_msg')

            adis_msg = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,topic_name);
            rawData.adis_msg = adis_msg;


        elseif contains(topic_name, 'adis_temp')

            adis_temp = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,topic_name);
            rawData.adis_temp = adis_temp;

        elseif contains(topic_name, 'adis_press')

            adis_press = fcn_DataClean_loadRawDataFromFile_ADIS(full_file_path,datatype,fid,topic_name);
            rawData.adis_press = adis_press;


        elseif contains(topic_name,'parseTrigger')

            parseTrigger = fcn_DataClean_loadRawDataFromFile_parse_Trigger(full_file_path,datatype,fid);
            rawData.Trigger_Raw = parseTrigger;

        elseif contains(topic_name, 'GPS_SparkFun_RearLeft_GGA')

            SparkFun_GPS_RearLeft_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_LeftRear_GGA = SparkFun_GPS_RearLeft_GGA;

        elseif contains(topic_name, 'GPS_SparkFun_RearLeft_VTG')

            SparkFun_GPS_RearLeft_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_LeftRear_VTG = SparkFun_GPS_RearLeft_VTG;

        elseif contains(topic_name, 'GPS_SparkFun_RearLeft_GST')

            SparkFun_GPS_RearLeft_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_LeftRear_GST = SparkFun_GPS_RearLeft_GST;

        elseif contains(topic_name, 'GPS_SparkFun_RearRight_GGA')
            sparkfun_gps_rear_right_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_RightRear_GGA = sparkfun_gps_rear_right_GGA;

        elseif contains(topic_name, 'GPS_SparkFun_RearRight_VTG')
            sparkfun_gps_rear_right_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_RightRear_VTG = sparkfun_gps_rear_right_VTG;

        elseif contains(topic_name, 'GPS_SparkFun_RearRight_GST')
            sparkfun_gps_rear_right_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_RightRear_GST = sparkfun_gps_rear_right_GST;

        elseif contains(topic_name, 'Trigger_diag')
            diagnostic_trigger = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,topic_name);
            rawData.Diag_Trigger = diagnostic_trigger;

        elseif contains(topic_name, 'Encoder_diag')
            diagnostic_encoder = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,topic_name);
            rawData.Diag_Encoder = diagnostic_encoder;

        elseif contains(topic_name, 'GPS_SparkFun_Front_GGA')
            SparkFun_GPS_Front_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_Front_GGA = SparkFun_GPS_Front_GGA;

        elseif contains(topic_name, 'GPS_SparkFun_Front_VTG')
            SparkFun_GPS_Front_VTG = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_Front_VTG = SparkFun_GPS_Front_VTG;


        elseif contains(topic_name, 'GPS_SparkFun_Front_GST')
            SparkFun_GPS_Front_GST = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_Front_GST = SparkFun_GPS_Front_GST;


        elseif contains(topic_name, 'GPS_SparkFun_Temp_GGA')
            SparkFun_GPS_Temp_GGA = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(full_file_path,datatype,fid,topic_name);
            rawData.GPS_SparkFun_Temp_GGA = SparkFun_GPS_Temp_GGA;

            %             elseif contains(topic_name, 'DIAG_SparkFun_RearLeft')
            %                 sparkfun_gps_diag_rear_left = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,topic_name);
            %                 rawData.Diag_GPS_SparkFun_LeftRear = sparkfun_gps_diag_rear_left;
            %
            %             elseif contains(topic_name, 'DIAG_SparkFun_RearRight')
            %                 sparkfun_gps_diag_rear_right = fcn_DataClean_loadRawDataFromFile_Diagnostic(full_file_path,datatype,fid,topic_name);
            %                 rawData.Diag_GPS_SparkFun_RightRear = sparkfun_gps_diag_rear_right;


            %             elseif contains(topic_name,'ntrip_info')
            %                 ntrip_info = fcn_DataClean_loadRawDataFromFile_NTRIP(full_file_path,datatype,fid);
            %                 rawData.ntrip_info = ntrip_info;
            %           Comment out due to format error with detectImportOptions
            %             elseif (contains(topic_name,'rosout') && ~contains(topic_name,'agg'))
            %
            %                 ROSOut = fcn_DataClean_loadRawDataFromFile_ROSOut(full_file_path,datatype,fid);
            %                 rawData.ROSOut = ROSOut;

        elseif contains(topic_name,'tf')
            transform_struct = fcn_DataClean_loadRawDataFromFile_Transform(full_file_path,datatype,fid);
            rawData.Transform = transform_struct;

        elseif (contains(topic_name,'velodyne_packets')) && (flag_do_load_Velodyne)

            if flag_select_scan_duration
                Velodyne_lidar_struct = fcn_DataClean_loadRawDataFromFile_velodyneLIDAR(full_file_path,datatype,fid,flag_select_scan_duration);
            else
                Velodyne_lidar_struct = fcn_DataClean_loadRawDataFromFile_velodyneLIDAR(full_file_path,datatype,fid);
            end

            rawData.Lidar_Velodyne_Rear = Velodyne_lidar_struct;



        elseif contains(topic_name,'/rear_left_camera/image_rect_color/compressed') && (flag_do_load_cameras)
            rear_left_camera_folder = 'images/rear_left_camera/';
            Camera_Rear_Left_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,rear_left_camera_folder,datatype,fid);
            rawData.Camera_Rear_Left = Camera_Rear_Left_struct;

        elseif contains(topic_name,'/rear_center_camera/image_rect_color/compressed') && (flag_do_load_cameras)
            rear_center_camera_folder = 'images/rear_center_camera/';
            Camera_Rear_Center_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,rear_center_camera_folder,datatype,fid);
            rawData.Camera_Rear_Center = Camera_Rear_Center_struct;

        elseif contains(topic_name,'/rear_right_camera/image_rect_color/compressed') && (flag_do_load_cameras)
            rear_right_camera_folder = 'images/rear_right_camera/';
            Camera_Rear_Right_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,rear_right_camera_folder,datatype,fid);
            rawData.Camera_Rear_Right = Camera_Rear_Right_struct;

        elseif contains(topic_name,'/front_left_camera/image_rect_color/compressed') && (flag_do_load_cameras)
            front_left_camera_folder = 'images/front_left_camera/';
            Camera_Front_Left_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,front_left_camera_folder,datatype,fid);
            rawData.Camera_Front_Left = Camera_Front_Left_struct;

        elseif contains(topic_name,'/front_center_camera/image_rect_color/compressed') && (flag_do_load_cameras)
            front_center_camera_folder = 'images/front_center_camera/';
            Camera_Front_Center_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,front_center_camera_folder,datatype,fid);
            rawData.Camera_Front_Center = Camera_Front_Center_struct;

        elseif contains(topic_name,'/front_right_camera/image_rect_color/compressed') && (flag_do_load_cameras)
            front_right_camera_folder = 'images/front_right_camera/';
            Camera_Front_Right_struct = fcn_DataClean_loadRawDataFromFile_Cameras(file_path,front_right_camera_folder,datatype,fid);
            rawData.Camera_Front_Right = Camera_Front_Right_struct;


        else
            if fid
                fprintf(fid,'\t\tWARNING: Topic not processed: %s\n',topic_name);
            end

        end
    end % Ends check if the directory list is a file
end % Ends loop through directory list

end % fcn_INTERNAL_readRawDataFromFolder

