% script_geoplotSparkFunGPS.m


% Revision history
% 2023_06_22 - xfc5113@psu.edu
% -- wrote the code originally, using Laps_checkZoneType as starter

%% Set up the workspace
close all
clc
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
library_name{ith_library}    = 'DebugTools_v2023_04_22';
library_folders{ith_library} = {'Functions','Data'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/archive/refs/tags/DebugTools_v2023_04_22.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'PathClass_v2023_02_01';
library_folders{ith_library} = {'Functions'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary/blob/main/Releases/PathClass_v2023_02_01.zip?raw=true';

ith_library = ith_library+1;
library_name{ith_library}    = 'GPSClass_v2023_04_21';
library_folders{ith_library} = {'Functions'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/FieldDataCollection_GPSRelatedCodes_GPSClass/archive/refs/tags/GPSClass_v2023_04_21.zip';


%% Clear paths and folders, if needed
if 1==0

    fcn_INTERNAL_clearUtilitiesFromPathAndFolders;

end

%% Do we need to set up the work space?
if ~exist('flag_DataClean_Folders_Initialized','var')
    this_project_folders = {'Functions','Data'};
    fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders);
    flag_DataClean_Folders_Initialized = 1;
end


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
%%
%% Load static LiDAR scan
fid = 1;
clear rawDataCellArray
rootdirs{1} = fullfile(cd,'LargeData','2024-11-08');
bagQueryString = 'mapping_van_2024-11-08*';
rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers,bagQueryString, fid,Flags);
%%
GGA_GPS_Time = rawDataCellArray{1}.GPS_SparkFun_Front_GGA.GPS_Time;
GGA_ROS_Time = rawDataCellArray{1}.GPS_SparkFun_Front_GGA.ROS_Time;
PVT_GPS_Time = rawDataCellArray{1}.GPS_SparkFun_Front_PVT.GPS_Time;
PVT_ROS_Time = rawDataCellArray{1}.GPS_SparkFun_Front_PVT.ROS_Time;
figure(1234)
plot(GGA_GPS_Time)
hold on
plot(PVT_GPS_Time)
plot(GGA_ROS_Time)
plot(PVT_ROS_Time)
PVT_GPS_Time(1:20) - GGA_GPS_Time(1:20)
% rawDataCellArray{1}.GPS_SparkFun_Front_PVT.GPS_Time - rawDataCellArray{1}.GPS_SparkFun_Front_GGA.GPS_Time
%%
format long
index_to_check = 1;

temp1 = rawDataCellArray{index_to_check}.GPS_SparkFun_RightRear_GGA.GPS_Time(1:20,:) - rawDataCellArray{index_to_check}.GPS_SparkFun_RightRear_GGA.GPS_Time(1,1);
temp2 = rawDataCellArray{index_to_check}.GPS_SparkFun_LeftRear_GGA.GPS_Time(1:20,:)  - rawDataCellArray{index_to_check}.GPS_SparkFun_LeftRear_GGA.GPS_Time(1,1);
temp3 = rawDataCellArray{index_to_check}.GPS_SparkFun_Front_GGA.GPS_Time(1:20,:) - rawDataCellArray{index_to_check}.GPS_SparkFun_Front_GGA.GPS_Time(1,1);
fprintf(1,'GPS_SparkFun_RightRear_GGA   GPS_SparkFun_LeftRear_GGA    GPS_SparkFun_Front_GGA\n')
%% Choose data folder and bag name

% Data from "mapping_van_2023-06-05-1Lap.bag" is set as the default value
% used in this test script.
% All files are saved on OneDrive, in
% \\IVSG\GitHubMirror\MappingVanDataCollection\ParsedData, to use data from other files,
% change the data_folder variable and bagname variable to corresponding path and bag
% name.
% bagFolderName = "mapping_van_2023-06-22-1Lap_0";
% bagFolderName = "mapping_van_2023-06-27-10s-Curve
bagFolderName = "mapping_van_2023-06-29-5s";
rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName,1);
%% Grab sparkfun gps fields from raw data
sparkfun_gps_rear_left = rawdata.SparkFun_GPS_RearLeft_GGA;
sparkfun_gps_rear_right = rawdata.SparkFun_GPS_RearRight_GGA;
%% Extract GPS Time and LLA Coordinates
sparkfun_gps_rear_left_RefTime = sparkfun_gps_rear_left.GPS_Time - min(sparkfun_gps_rear_left.GPS_Time);
sparkfun_gps_rear_right_RefTime = sparkfun_gps_rear_right.GPS_Time - min(sparkfun_gps_rear_right.GPS_Time);
diff_t_left = diff(sparkfun_gps_rear_left_RefTime);
diff_t_right = diff(sparkfun_gps_rear_right_RefTime);

sparkfun_gps_rear_left_LLA = [sparkfun_gps_rear_left.Latitude,sparkfun_gps_rear_left.Longitude,sparkfun_gps_rear_left.Altitude];
sparkfun_gps_rear_right_LLA = [sparkfun_gps_rear_right.Latitude,sparkfun_gps_rear_right.Longitude,sparkfun_gps_rear_right.Altitude];
%%
%% Geoplot
TestTrack_Base_LLA = [40.86368573, -77.83592832, 344.189]; % Test Track Base Station LLA coordinates
figure(1)
clf
s = geoplot(sparkfun_gps_rear_left_LLA(:,1),sparkfun_gps_rear_left_LLA(:,2),'color','blue','LineWidth',2,'marker','.','MarkerSize',20);
hold on
geoplot(sparkfun_gps_rear_right_LLA(:,1),sparkfun_gps_rear_right_LLA(:,2),'color','red','LineWidth',2,'marker','.','MarkerSize',20);
geoplot(TestTrack_Base_LLA(:,1),TestTrack_Base_LLA(:,2),'color','magenta','LineWidth',2,'marker','+','MarkerSize',20);
% plot the start and end point with green and black
geoplot(sparkfun_gps_rear_left_LLA(1,1),sparkfun_gps_rear_left_LLA(1,2),'color','green','LineWidth',2,'marker','x','MarkerSize',20);
geoplot(sparkfun_gps_rear_left_LLA(end,1),sparkfun_gps_rear_left_LLA(end,2),'color','black','LineWidth',2,'marker','x','MarkerSize',20);
geoplot(sparkfun_gps_rear_right_LLA(1,1),sparkfun_gps_rear_right_LLA(1,2),'color','green','LineWidth',2,'marker','x','MarkerSize',20);
geoplot(sparkfun_gps_rear_right_LLA(end,1),sparkfun_gps_rear_right_LLA(end,2),'color','black','LineWidth',2,'marker','x','MarkerSize',20);
geobasemap 'satellite'
s.Parent.FontSize = 24;
grid on
title('SparkFun GPS LLA Coordinates at the Test Track 2023-06-05', 'FontSize',28)       
legend('Rear Left SparkFun GPS', 'Rear Right SparkFun GPS','Test Track Base Station','Start Point','End Point')


%% Interpolate Raw Data
% Create an array containing time and LLA coordinates
% sparkfun_gps_rear_left_TimeSpace = [sparkfun_gps_rear_left_RefTime,sparkfun_gps_rear_left_LLA];
% sparkfun_gps_rear_right_TimeSpace = [sparkfun_gps_rear_right_RefTime,sparkfun_gps_rear_right_LLA];
% % Grab the datapoints without repetitions
% sparkfun_gps_rear_left_unique = unique(sparkfun_gps_rear_left_TimeSpace,'rows','stable');
% sparkfun_gps_rear_right_unique = unique(sparkfun_gps_rear_right_TimeSpace,'rows','stable');
% Npoints_left = length(sparkfun_gps_rear_left_unique);
% Npoints_right = length(sparkfun_gps_rear_right_unique);
% % Align the datapoitns using linear interpolation
% CentiSecs_SparkFun_GPS = sparkfun_gps_rear_left.centiSeconds;
% Time_Standard = (min(sparkfun_gps_rear_left_unique(:,1)):CentiSecs_SparkFun_GPS/100:max(sparkfun_gps_rear_left_unique(:,1)));
% sparkfun_gps_rear_left_interp = interp1(sparkfun_gps_rear_left_unique(:,1),sparkfun_gps_rear_left_unique(:,2:4),Time_Standard.');
% sparkfun_gps_rear_right_interp = interp1(sparkfun_gps_rear_right_unique(:,1),sparkfun_gps_rear_right_unique(:,2:4),Time_Standard.');
% 
% %% Geoplot
% TestTrack_Base_LLA = [40.86368573, -77.83592832, 344.189]; % Test Track Base Station LLA coordinates
% figure(1)
% clf
% s = geoplot(sparkfun_gps_rear_left_interp(:,1),sparkfun_gps_rear_left_interp(:,2),'color','blue','LineWidth',2,'marker','.','MarkerSize',20);
% hold on
% geoplot(sparkfun_gps_rear_right_interp(:,1),sparkfun_gps_rear_right_interp(:,2),'color','red','LineWidth',2,'marker','.','MarkerSize',20);
% geoplot(TestTrack_Base_LLA(:,1),TestTrack_Base_LLA(:,2),'color','magenta','LineWidth',2,'marker','+','MarkerSize',20);
% % plot the start and end point with green and black
% geoplot(sparkfun_gps_rear_left_interp(1,1),sparkfun_gps_rear_left_interp(1,2),'color','green','LineWidth',2,'marker','x','MarkerSize',20);
% geoplot(sparkfun_gps_rear_left_interp(end,1),sparkfun_gps_rear_left_interp(end,2),'color','black','LineWidth',2,'marker','x','MarkerSize',20);
% geoplot(sparkfun_gps_rear_right_interp(1,1),sparkfun_gps_rear_right_interp(1,2),'color','green','LineWidth',2,'marker','x','MarkerSize',20);
% geoplot(sparkfun_gps_rear_right_interp(end,1),sparkfun_gps_rear_right_interp(end,2),'color','black','LineWidth',2,'marker','x','MarkerSize',20);
% geobasemap 'satellite'
% s.Parent.FontSize = 24;
% grid on
% title('SparkFun GPS LLA Coordinates at the Test Track 2023-06-05', 'FontSize',28)       
% legend('Rear Left SparkFun GPS', 'Rear Right SparkFun GPS','Test Track Base Station','Start Point','End Point')
% 
% 
% %% Convert LLA to ENU using the Test Track Base Station LLA as a reference
% 
% sparkfun_gps_rear_left_ENU = lla2enu(sparkfun_gps_rear_left_interp,TestTrack_Base_LLA,'ellipsoid');
% sparkfun_gps_rear_right_ENU = lla2enu(sparkfun_gps_rear_right_interp,TestTrack_Base_LLA,'ellipsoid');
% figure(2)
% plot(sparkfun_gps_rear_left_ENU(:,1),sparkfun_gps_rear_left_ENU(:,2),'color','blue','LineWidth',2,'marker','.','MarkerSize',20)
% hold on
% plot(sparkfun_gps_rear_right_ENU(:,1),sparkfun_gps_rear_right_ENU(:,2),'color','red','LineWidth',2,'marker','.','MarkerSize',20)
% scatter(0, 0, 500,"magenta","+",'LineWidth',2)
% scatter(sparkfun_gps_rear_left_ENU(1,1),sparkfun_gps_rear_left_ENU(1,2),500,"green","x",'LineWidth',2)
% scatter(sparkfun_gps_rear_left_ENU(end,1),sparkfun_gps_rear_left_ENU(end,2),500,"black","x",'LineWidth',2)
% scatter(sparkfun_gps_rear_right_ENU(1,1),sparkfun_gps_rear_right_ENU(1,2),500,"green","x",'LineWidth',2)
% scatter(sparkfun_gps_rear_right_ENU(end,1),sparkfun_gps_rear_right_ENU(end,2),500,"black","x",'LineWidth',2)
% grid on
% grid minor
% dist = vecnorm(sparkfun_gps_rear_left_ENU-sparkfun_gps_rear_right_ENU,2,2);
% xlabel('xEast [m]','FontSize',24)
% ylabel('yNorth [m]','FontSize',24)
% axis equal
% title('SparkFun GPS ENU Coordinates at the Test Track 2023-06-05', 'FontSize',28)       
% legend('Rear Left SparkFun GPS', 'Rear Right SparkFun GPS','Test Track Base Station','Start Point','End Point','FontSize',24)
