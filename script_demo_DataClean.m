%
% Known issues:
%  (as of 2019_10_04) - Odometry on the rear encoders is quite wonky. For
%  some reason, need to do absolute value on speeds - unclear why. And the
%  left encoder is clearly disconnected.
%  UPDATE: encoder reattached in 2019_10_15, but still giving positive/negative flipping errors
%  UPDATE2: encoders rebuilt in 2022 summer to fix this issue
%
%  (as of 2019_11_05) - Need to update variance estimates for GPS mode
%  changes in yaw calculations. Presently assumes 0.01 cm mode.
%
%  (as of 2019_10_13 to 2019_10_17) - Need to confirm signs on the XAccel
%  directions - these look wrong. Suspect that coord system on one is off.
%  They align if plotted right - see fcn_mergeAllXAccelSources - but a
%  coordinate transform is necessary.
%
%  (as of 2019_11_26) - Check that the increments in x and y, replotted as
%  velocities, do not cause violations relative to measured absolute
%  velocity.
%
%  (as of 2019_11_26) - Need to add zUp increments throughout, so that we
%  can KF this variable
%
% (as of 2019_12_09) if run
% find(diff(data_struct.Hemisphere_DGPS.GPSTimeOfWeek)==0), it returns many
% values, whcih means hemisphere did not update its time sometimes? check
% fcn_loadRawData line 255, and maybe add a flag for this type of error


%% TO_DO LIST
% For each sensor, we need to characterize three time sources:
% 1) GPS_Time - if it has a "true" time source - such as a GPS sensor that reports UTC
% time which is true to the nanosecond level. For sensors that do not have
% this, let's leave this time field empty.
% 2) Triggered_Time - this is the time stamp assuming the data is
% externally triggered. This time is calculated with reference to the trigger source and thus should be
% accurate to microseconds. All sensors should have this time field filled.
% 3) ROS_time - this is the ROS time, which is accurate (usually) to about 10 milliseconds
%
% In later processing steps, we'll need to fix all the data times using the
% above.
%
% Finally, for each of our functions, we need to make the function call
% have a test script with very simple test cases, make sure the function format matches the IVSG
% standard, and make sure that the README.md file is updated.


% *) fix the KF bugs(check page 25 of documents/Route Data Processing Steps_2021_03_04.pptx) for trips_id =7
% *) Go through the functions and add headers / comments to each, and if
% possible, add argument checking (similar to Path class library)
%
% *) Create a Powerpoint document that shows specific examples and outputs
% of each function, so that we know what each subfunction is doing
%
% *) maybe develop some way of indicating the "worst" data result in each
% subfunction, for example where the data is failing - and where the data
% is "good"?
%
% *) Save the "print" results and key plots automatically to a PDF document
% to log the data processing results
%
% *) Create a KF function to hold all the KF merge sub-functions
% *) Add the lidar data process
% *) Add variance and plot at fcn_DataClean_loadRawData_Lidar ?
% *) Query the data size before query the data. If the data size is too
%    large, split the query into several actions. https://www.postgresqltutorial.com/postgresql-database-indexes-table-size/
%
%             %select table_name, pg_size_pretty( pg_total_relation_size(quote_ident(table_name)) )
%             sqlquery_tablesize = [' select table_name, pg_size_pretty( pg_relation_size(quote_ident(table_name)) )' ...
%                                   ' from information_schema.tables '...
%                                   ' where table_schema = ''public'' '...
%                                   ' order by 2 desc;'];
%             %exec(DB.db_connection,sqlquery_tablesize)
%             sss= fetch(DB.db_connection,sqlquery_tablesize,'DataReturnFormat','table');
%
% *) insert start point to database
%
% 2024_09_28 - S. Brennan
% -- need to change field names in fcn_DataClean_loadMappingVanDataFromFile so that
% they pass the "standard" names listed in fcn_DataClean_renameSensorsToStandardNames
% 2024_11_06 - S. Brennan
% -- fix last test case in
% script_test_fcn_DataClean_checkDataTimeConsistency_GPS. The added error
% that is used for creating a test causes a fail on one of the previous
% flags. The code use to inject failures needs to account for this. (in
% fillTestDataStructure)
% -- delete fcn_DataClean_checkAllSensorsHaveTriggerTime. It can be
% replaced by fcn_DataClean_checkIfFieldInSensors
% -- remove fcn_DataClean_checkDataTimeConsistency_GPS - started moving
% this code into checkDataTimeConsistency
% -- fcn_DataClean_recalculateTriggerTimes needs better test cases, and
% needs to be formatted correctly

%% Prep the workspace
close all

%% Dependencies and Setup of the Code
% The code requires several other libraries to work, namely the following
% * DebugTools - the repo can be found at: https://github.com/ivsg-psu/Errata_Tutorials_DebugTools
% * PathClassLibrary - the repo can be found at: https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary
% * Database - this is a zip of a single file containing the Database class
% * GPS - this is a zip of a single file containing the GPS class
% * Map - this is a zip of a single file containing the Map class
% * MapDatabase - this is a zip of a single file containing the MapDatabase class
%
% The section below installs dependencies in a folder called "Utilities"
% under the root folder, namely ./Utilities/DebugTools/ ,
% ./Utilities/PathClassLibrary/ . If you wish to put these codes in
% different directories, the function below can be easily modified with
% strings specifying the different location.

% List what libraries we need, and where to find the codes for each
clear library_name library_folders library_url

ith_library = 1;
library_name{ith_library}    = 'DebugTools_v2024_12_16';
library_folders{ith_library} = {'Functions','Data'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/archive/refs/tags/DebugTools_v2024_12_16.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'PathClass_v2024_03_14';
library_folders{ith_library} = {'Functions'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary/archive/refs/tags/PathClass_v2024_03_14.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'GPSClass_v2023_06_29';
library_folders{ith_library} = {'Functions'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/FieldDataCollection_GPSRelatedCodes_GPSClass/archive/refs/tags/GPSClass_v2023_06_29.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'LineFitting_v2023_07_24';
library_folders{ith_library} = {'Functions'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/FeatureExtraction_Association_LineFitting/archive/refs/tags/LineFitting_v2023_07_24.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'FindCircleRadius_v2023_08_02';
library_folders{ith_library} = {'Functions'};                                
library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_GeomTools_FindCircleRadius/archive/refs/tags/FindCircleRadius_v2023_08_02.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'BreakDataIntoLaps_v2023_08_25';
library_folders{ith_library} = {'Functions'};                                
library_url{ith_library}     = 'https://github.com/ivsg-psu/FeatureExtraction_DataClean_BreakDataIntoLaps/archive/refs/tags/BreakDataIntoLaps_v2023_08_25.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'PlotRoad_v2024_11_07';
library_folders{ith_library} = {'Functions', 'Data'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad/archive/refs/tags/PlotRoad_v2024_11_07.zip'; 

ith_library = ith_library+1;
library_name{ith_library}    = 'GeometryClass_v2024_08_28';
library_folders{ith_library} = {'Functions'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_GeomTools_GeomClassLibrary/archive/refs/tags/GeometryClass_v2024_08_28.zip';



%% Clear paths and folders, if needed
if 1==0
    clear flag_DataClean_Folders_Initialized
    fcn_INTERNAL_clearUtilitiesFromPathAndFolders;

end

%% Do we need to set up the work space?
if ~exist('flag_DataClean_Folders_Initialized','var')
    this_project_folders = {'Functions','LargeData','Data'};
    fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders);
    flag_DataClean_Folders_Initialized = 1;
end

%% Define Flags and Identifiers
Flags.flag_do_load_SICK = 0;
Flags.flag_do_load_Velodyne = 1;
Flags.flag_do_load_cameras = 0;
Flags.flag_do_load_all_data = 1;
Flags.flag_select_scan_duration = 0;
Flags.flag_do_load_GST = 0;
Flags.flag_do_load_VTG = 0;
Flags.flag_do_load_PVT = 0;
Flags.flag_do_load_Ouster = 0;
clear Identifiers
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.ProjectStage = 'TestTrack'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
Identifiers.WorkZoneScenario = 'Scenario1.1'; % Can be one of the ~20 scenarios, see key
Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

%% Load data set
% fid = 1;
% clear rawDataCellArray
% rootdirs{1} = fullfile(cd,'LargeData','2024-11-26','CCW');
% bagQueryString = 'mapping_van_2024-11-26*';
% rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);
% 
% % Check the results
% assert(iscell(rawDataCellArray));

% OR Load mat file
rawDataCellArray = load('LargeData\2024-11-26\Secnario1_1_CCW_rawData.mat');
% Check the results
assert(iscell(rawDataCellArray));
%% Merge datasets belonging to one collection
% Specify the nearby time
thresholdTimeNearby = 2;

% Spedify the fid
fid = 1; % 1 --> print to console

% List what will be saved
saveFlags.flag_saveMatFile = 1;
saveFlags.flag_saveMatFile_directory = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages = 1;
saveFlags.flag_saveImages_directory  = fullfile(cd,'Data','RawDataMerged',Identifiers.ProjectStage,Identifiers.WorkZoneScenario);
saveFlags.flag_saveImages_name = cat(2,Identifiers.WorkZoneScenario,'_merged');
saveFlags.flag_forceDirectoryCreation = 1;
saveFlags.flag_forceImageOverwrite = 1;
saveFlags.flag_forceMATfileOverwrite = 1;

% List what will be plotted, and the figure numbers
plotFlags.fig_num_plotAllMergedTogether = 1111;
plotFlags.fig_num_plotAllMergedIndividually = 2222;
    
plotFlags.mergedplotFormat.LineStyle = '-';
plotFlags.mergedplotFormat.LineWidth = 2;
plotFlags.mergedplotFormat.Marker = 'none';
plotFlags.mergedplotFormat.MarkerSize = 5;


% Call the function
[mergedRawDataCellArray, uncommonFieldsCellArray] = fcn_DataClean_mergeRawDataStructures(rawDataCellArray, (thresholdTimeNearby), (fid), (saveFlags), (plotFlags));

% Check the results
assert(iscell(mergedRawDataCellArray));
%% Fill the ENU fields in GPS sensors
ref_baseStationLLA = [40.86368573 -77.83592832 344.189]; % Test track base station
% ref_baseStationLLA = [40.44181017, -79.76090840, 327.428]; % Pittsburgh (NOTE: not used)
filledDataStructure =  fcn_DataClean_fillGPSENUFields(mergedRawDataCellArray{1},ref_baseStationLLA);
%% Process the data clean
fig_num = 0;
fid = 1;
cleanDataStruct = fcn_DataClean_cleanData_demo(filledDataStructure, (ref_baseStationLLA), (fid), ([]), (fig_num));


%% Load transformation matrices
load("Data\Transformation\M_calibration_GPS_to_Vehicle_2024-05-15.mat") % GPS calibration matrix
load("Data\Transformation\RearRightGPS_offset_relative_to_VehicleOrigin.mat") % Relative offset from rear right GPS to vehicle origin
load("Data\Transformation\M_transform_LiDARVelodyne_to_RearRightGPS_2025_03_27.mat") % Transformation from Velodyne LiDAR to rear right GPS
%% Transform the LiDAR point cloud from LiDAR coordiante system to ENU coordiante system
ROI = struct;
ROI.X_lim = [-10 10];
ROI.Y_lim = [-3 3];

ROI.Z_lim = [-0.5 1];

LiDAR_DataStructure = cleanDataStruct.Lidar_Velodyne_Rear;
LiDAR_DataStructure_Vehicle = fcn_Transform_transformLiDARToVehicle(LiDAR_DataStructure,RearRightGPS_offset_relative_to_VehicleOrigin,...
    M_calibration_GPS_to_Vehicle, M_transform_LiDARVelodyne_to_RearRightGPS);
LiDAR_DataStructure_Vehicle_filtered = fcn_LaneDetection_filterPointCloudInROI(LiDAR_DataStructure_Vehicle,ROI);

%% Align frames between sensors: To be done








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

%% function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
% Clear out the variables
clear global flag* FLAG*
clear flag*
clear path

% Clear out any path directories under Utilities
if ispc
    path_dirs = regexp(path,'[;]','split');
elseif ismac
    path_dirs = regexp(path,'[:]','split');
elseif isunix
    path_dirs = regexp(path,'[;]','split');
else
    error('Unknown operating system. Unable to continue.');
end

utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir})
    end
end

% Delete the Utilities folder, to be extra clean!
if  exist(utilities_dir,'dir')
    [status,message,message_ID] = rmdir(utilities_dir,'s');
    if 0==status
        error('Unable remove directory: %s \nReason message: %s \nand message_ID: %s\n',utilities_dir, message,message_ID);
    end
end

end % Ends fcn_INTERNAL_clearUtilitiesFromPathAndFolders

%% fcn_INTERNAL_initializeUtilities
function  fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders)
% Reset all flags for installs to empty
clear global FLAG*

fprintf(1,'Installing utilities necessary for code ...\n');

% Dependencies and Setup of the Code
% This code depends on several other libraries of codes that contain
% commonly used functions. We check to see if these libraries are installed
% into our "Utilities" folder, and if not, we install them and then set a
% flag to not install them again.

% Set up libraries
for ith_library = 1:length(library_name)
    dependency_name = library_name{ith_library};
    dependency_subfolders = library_folders{ith_library};
    dependency_url = library_url{ith_library};

    fprintf(1,'\tAdding library: %s ...',dependency_name);
    fcn_INTERNAL_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url);
    clear dependency_name dependency_subfolders dependency_url
    fprintf(1,'Done.\n');
end

% Set dependencies for this project specifically
fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders);

disp('Done setting up libraries, adding each to MATLAB path, and adding current repo folders to path.');
end % Ends fcn_INTERNAL_initializeUtilities

function fcn_INTERNAL_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url, varargin)
%% FCN_DEBUGTOOLS_INSTALLDEPENDENCIES - MATLAB package installer from URL
%
% FCN_DEBUGTOOLS_INSTALLDEPENDENCIES installs code packages that are
% specified by a URL pointing to a zip file into a default local subfolder,
% "Utilities", under the root folder. It also adds either the package
% subfoder or any specified sub-subfolders to the MATLAB path.
%
% If the Utilities folder does not exist, it is created.
%
% If the specified code package folder and all subfolders already exist,
% the package is not installed. Otherwise, the folders are created as
% needed, and the package is installed.
%
% If one does not wish to put these codes in different directories, the
% function can be easily modified with strings specifying the
% desired install location.
%
% For path creation, if the "DebugTools" package is being installed, the
% code installs the package, then shifts temporarily into the package to
% complete the path definitions for MATLAB. If the DebugTools is not
% already installed, an error is thrown as these tools are needed for the
% path creation.
%
% Finally, the code sets a global flag to indicate that the folders are
% initialized so that, in this session, if the code is called again the
% folders will not be installed. This global flag can be overwritten by an
% optional flag input.
%
% FORMAT:
%
%      fcn_DebugTools_installDependencies(...
%           dependency_name, ...
%           dependency_subfolders, ...
%           dependency_url)
%
% INPUTS:
%
%      dependency_name: the name given to the subfolder in the Utilities
%      directory for the package install
%
%      dependency_subfolders: in addition to the package subfoder, a list
%      of any specified sub-subfolders to the MATLAB path. Leave blank to
%      add only the package subfolder to the path. See the example below.
%
%      dependency_url: the URL pointing to the code package.
%
%      (OPTIONAL INPUTS)
%      flag_force_creation: if any value other than zero, forces the
%      install to occur even if the global flag is set.
%
% OUTPUTS:
%
%      (none)
%
% DEPENDENCIES:
%
%      This code will automatically get dependent files from the internet,
%      but of course this requires an internet connection. If the
%      DebugTools are being installed, it does not require any other
%      functions. But for other packages, it uses the following from the
%      DebugTools library: fcn_DebugTools_addSubdirectoriesToPath
%
% EXAMPLES:
%
% % Define the name of subfolder to be created in "Utilities" subfolder
% dependency_name = 'DebugTools_v2023_01_18';
%
% % Define sub-subfolders that are in the code package that also need to be
% % added to the MATLAB path after install; the package install subfolder
% % is NOT added to path. OR: Leave empty ({}) to only add
% % the subfolder path without any sub-subfolder path additions.
% dependency_subfolders = {'Functions','Data'};
%
% % Define a universal resource locator (URL) pointing to the zip file to
% % install. For example, here is the zip file location to the Debugtools
% % package on GitHub:
% dependency_url = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/blob/main/Releases/DebugTools_v2023_01_18.zip?raw=true';
%
% % Call the function to do the install
% fcn_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url)
%
% This function was written on 2023_01_23 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
% 2023_01_23:
% -- wrote the code originally
% 2023_04_20:
% -- improved error handling
% -- fixes nested installs automatically

% TO DO
% -- Add input argument checking

flag_do_debug = 0; % Flag to show the results for debugging
flag_do_plots = 0; % % Flag to plot the final results
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

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(3,4);
end

%% Set the global variable - need this for input checking
% Create a variable name for our flag. Stylistically, global variables are
% usually all caps.
flag_varname = upper(cat(2,'flag_',dependency_name,'_Folders_Initialized'));

% Make the variable global
eval(sprintf('global %s',flag_varname));

if nargin==4
    if varargin{1}
        eval(sprintf('clear global %s',flag_varname));
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



if ~exist(flag_varname,'var') || isempty(eval(flag_varname))
    % Save the root directory, so we can get back to it after some of the
    % operations below. We use the Print Working Directory command (pwd) to
    % do this. Note: this command is from Unix/Linux world, but is so
    % useful that MATLAB made their own!
    root_directory_name = pwd;

    % Does the directory "Utilities" exist?
    utilities_folder_name = fullfile(root_directory_name,'Utilities');
    if ~exist(utilities_folder_name,'dir')
        % If we are in here, the directory does not exist. So create it
        % using mkdir
        [success_flag,error_message,message_ID] = mkdir(root_directory_name,'Utilities');

        % Did it work?
        if ~success_flag
            error('Unable to make the Utilities directory. Reason: %s with message ID: %s\n',error_message,message_ID);
        elseif ~isempty(error_message)
            warning('The Utilities directory was created, but with a warning: %s\n and message ID: %s\n(continuing)\n',error_message, message_ID);
        end

    end

    % Does the directory for the dependency folder exist?
    dependency_folder_name = fullfile(root_directory_name,'Utilities',dependency_name);
    if ~exist(dependency_folder_name,'dir')
        % If we are in here, the directory does not exist. So create it
        % using mkdir
        [success_flag,error_message,message_ID] = mkdir(utilities_folder_name,dependency_name);

        % Did it work?
        if ~success_flag
            error('Unable to make the dependency directory: %s. Reason: %s with message ID: %s\n',dependency_name, error_message,message_ID);
        elseif ~isempty(error_message)
            warning('The %s directory was created, but with a warning: %s\n and message ID: %s\n(continuing)\n',dependency_name, error_message, message_ID);
        end

    end

    % Do the subfolders exist?
    flag_allFoldersThere = 1;
    if isempty(dependency_subfolders{1})
        flag_allFoldersThere = 0;
    else
        for ith_folder = 1:length(dependency_subfolders)
            subfolder_name = dependency_subfolders{ith_folder};

            % Create the entire path
            subfunction_folder = fullfile(root_directory_name, 'Utilities', dependency_name,subfolder_name);

            % Check if the folder and file exists that is typically created when
            % unzipping.
            if ~exist(subfunction_folder,'dir')
                flag_allFoldersThere = 0;
            end
        end
    end

    % Do we need to unzip the files?
    if flag_allFoldersThere==0
        % Files do not exist yet - try unzipping them.
        save_file_name = tempname(root_directory_name);
        zip_file_name = websave(save_file_name,dependency_url);
        % CANT GET THIS TO WORK --> unzip(zip_file_url, debugTools_folder_name);

        % Is the file there?
        if ~exist(zip_file_name,'file')
            error(['The zip file: %s for dependency: %s did not download correctly.\n' ...
                'This is usually because permissions are restricted on ' ...
                'the current directory. Check the code install ' ...
                '(see README.md) and try again.\n'],zip_file_name, dependency_name);
        end

        % Try unzipping
        unzip(zip_file_name, dependency_folder_name);

        % Did this work? If so, directory should not be empty
        directory_contents = dir(dependency_folder_name);
        if isempty(directory_contents)
            error(['The necessary dependency: %s has an error in install ' ...
                'where the zip file downloaded correctly, ' ...
                'but the unzip operation did not put any content ' ...
                'into the correct folder. ' ...
                'This suggests a bad zip file or permissions error ' ...
                'on the local computer.\n'],dependency_name);
        end

        % Check if is a nested install (for example, installing a folder
        % "Toolsets" under a folder called "Toolsets"). This can be found
        % if there's a folder whose name contains the dependency_name
        flag_is_nested_install = 0;
        for ith_entry = 1:length(directory_contents)
            if contains(directory_contents(ith_entry).name,dependency_name)
                if directory_contents(ith_entry).isdir
                    flag_is_nested_install = 1;
                    install_directory_from = fullfile(directory_contents(ith_entry).folder,directory_contents(ith_entry).name);
                    install_files_from = fullfile(directory_contents(ith_entry).folder,directory_contents(ith_entry).name,'*'); % BUG FIX - For Macs, must be *, not *.*
                    install_location_to = fullfile(directory_contents(ith_entry).folder);
                end
            end
        end

        if flag_is_nested_install
            [status,message,message_ID] = movefile(install_files_from,install_location_to);
            if 0==status
                error(['Unable to move files from directory: %s\n ' ...
                    'To: %s \n' ...
                    'Reason message: %s\n' ...
                    'And message_ID: %s\n'],install_files_from,install_location_to, message,message_ID);
            end
            [status,message,message_ID] = rmdir(install_directory_from);
            if 0==status
                error(['Unable remove directory: %s \n' ...
                    'Reason message: %s \n' ...
                    'And message_ID: %s\n'],install_directory_from,message,message_ID);
            end
        end

        % Make sure the subfolders were created
        flag_allFoldersThere = 1;
        if ~isempty(dependency_subfolders{1})
            for ith_folder = 1:length(dependency_subfolders)
                subfolder_name = dependency_subfolders{ith_folder};

                % Create the entire path
                subfunction_folder = fullfile(root_directory_name, 'Utilities', dependency_name,subfolder_name);

                % Check if the folder and file exists that is typically created when
                % unzipping.
                if ~exist(subfunction_folder,'dir')
                    flag_allFoldersThere = 0;
                end
            end
        end
        % If any are not there, then throw an error
        if flag_allFoldersThere==0
            error(['The necessary dependency: %s has an error in install, ' ...
                'or error performing an unzip operation. The subfolders ' ...
                'requested by the code were not found after the unzip ' ...
                'operation. This suggests a bad zip file, or a permissions ' ...
                'error on the local computer, or that folders are ' ...
                'specified that are not present on the remote code ' ...
                'repository.\n'],dependency_name);
        else
            % Clean up the zip file
            delete(zip_file_name);
        end

    end


    % For path creation, if the "DebugTools" package is being installed, the
    % code installs the package, then shifts temporarily into the package to
    % complete the path definitions for MATLAB. If the DebugTools is not
    % already installed, an error is thrown as these tools are needed for the
    % path creation.
    %
    % In other words: DebugTools is a special case because folders not
    % added yet, and we use DebugTools for adding the other directories
    if strcmp(dependency_name(1:10),'DebugTools')
        debugTools_function_folder = fullfile(root_directory_name, 'Utilities', dependency_name,'Functions');

        % Move into the folder, run the function, and move back
        cd(debugTools_function_folder);
        fcn_DebugTools_addSubdirectoriesToPath(dependency_folder_name,dependency_subfolders);
        cd(root_directory_name);
    else
        try
            fcn_DebugTools_addSubdirectoriesToPath(dependency_folder_name,dependency_subfolders);
        catch
            error(['Package installer requires DebugTools package to be ' ...
                'installed first. Please install that before ' ...
                'installing this package']);
        end
    end


    % Finally, the code sets a global flag to indicate that the folders are
    % initialized.  Check this using a command "exist", which takes a
    % character string (the name inside the '' marks, and a type string -
    % in this case 'var') and checks if a variable ('var') exists in matlab
    % that has the same name as the string. The ~ in front of exist says to
    % do the opposite. So the following command basically means: if the
    % variable named 'flag_CodeX_Folders_Initialized' does NOT exist in the
    % workspace, run the code in the if statement. If we look at the bottom
    % of the if statement, we fill in that variable. That way, the next
    % time the code is run - assuming the if statement ran to the end -
    % this section of code will NOT be run twice.

    eval(sprintf('%s = 1;',flag_varname));
end


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

    % Nothing to do!



end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends function fcn_DebugTools_installDependencies



%% fcn_INTERNAL_findTimeFromName
function timeNumber = fcn_INTERNAL_findTimeFromName(fileName)

timeString = [];
if length(fileName)>4
    splitName = strsplit(fileName,{'_','.'});
    for ith_split = 1:length(splitName)
        if contains(splitName{ith_split},'-')
            timeString = splitName{ith_split};
        end
    end
end
timeNumber = datetime(timeString,'InputFormat','yyyy-MM-dd-HH-mm-ss');
end % Ends fcn_INTERNAL_findTimeFromName


%% fcn_INTERNAL_confirmDirectoryExists
function fcn_INTERNAL_confirmDirectoryExists(directoryName)
if 7~=exist(directoryName,'dir')
    warning('on','backtrace');
    warning('Unable to find folder: \n\t%s',directoryName);
    error('Desired directory: %s does not exist!',directoryName);
end
end % Ends fcn_INTERNAL_confirmDirectoryExists
