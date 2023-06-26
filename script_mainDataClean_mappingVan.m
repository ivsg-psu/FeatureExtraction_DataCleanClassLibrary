%% script_mainDataClean_mappingVan.m
% 
% This main script is used to test the DataClean functions. It was
% originally written to process and plot the mapping van DGPS data
% collected for the Wahba route on 2019_09_17 with the Penn State Mapping
% Van.
%
% Author: Sean Brennan and Liming Gao
% Original Date: 2019_09_24
% modify Date: 2023_06_19
%
% Updates:
% 2019_10_03 - Functionalization of data loading, error analysis, plotting
% 2019_10_05 - Additional processing routines added for velocity
% 2019_10_06 to 07 - worked on time alignment concerns.
% 2019_10_12 - put in the kinematic regression filter for yawrate.
% 2019_10_14 - added sigma calculations for raw data.
% 2019_10_19 - added XY delta calculations.
% 2019_10_20 - added Bayesian averaging. Collapsed plotting functions.
% 2019_10_23 - break timeFilteredData into laps instead of only one
% 2019_10_21 - added zoom capability. Noticed that sigmas are not passing
% correctly for Hemisphere.
% 2019_11_09 - fixed errors in standard deviation calculations, fixed
% goodIndices, and fixed GPS info showing up in ADIS IMU fields
% 2019_11_15 - documented program flow, fixed bug in plotting routines,
% corrected sigma calculations for yaw based on velocity to include
% variance growth between DGPS updates, updated plotting functions to
% allow merged data
% 2019_11_17 - fixed kinematic filtering in clean data
% of yaw angle (bug fix).
% 2019_11_19 - Adding this comment so that Liming can see it :)
% 2019_11_21 - Continued working on KF signal merging for yaw angle
% 2019_11_22 - Added time check, as some time vectors are not counting up
% 2019_11_23 - Fixed plotting to work with new time gaps in NaN from above
% time check.
% 2019_11_24 - Fixed bugs in plotting (zUp was missing). Added checks for
% NaN values.
% 2019_11_25 - Fixed bugs in time alignment, where deltaT was wrong.
% 2019_11_26 - Fixed plotting routines to allow linking during plotting.
% 2019_11_27
% -- Worked on KF and Merge functionality. Cleaned up code flow.
% -- Added filtering of Sigma values.
% 2019_12_01
% -- Did post-processing after merge functions, but before
%    Kalman filter, adding another function to remove jumps in xData and
%    yData in Hemisphere, due to DGPS being lost. Fixed a few bugs in the KF
%    area. Code now runs end to end, producing what appears to be a valid XY
%    profile. Exports results to KML. (suggest code branch at this point)
% 2020_02_05 - fix bugs when DGPS ia active all time
% 2020_05_20 - fixed bug on the yaw angle plots
%  2020_06_20 - add raw data query functions
% 2020_08_30 - add database query method
% 2020_10_20 - functionalize the database query
% 2021_01_07
% -- started new DataClean class funtionality, code works now ONLY
%    for mapping van data
% 2021_01_08
% -- create a function to query data from database or load from file
% 2021-01-10
% -- Integrate the updated database query as a stand-alone function, to clean
%    up large amount of code at top of this script(Done by Liming)
% 2021-01-10
% -- Add geoplot capability to results so that we can see XY plots on the map
%    automatically (Done by Liming)
% 2021_10_15 - added ability to process LIDAR time data
% 2022_08_19
% -- added Debug library dependency and usage
% 2023_06_11
% -- automated dependency installs
% -- checked subfields to determine if LIDAR is there
% -- commented out code that doesn't work
% 2023_06_25
% -- added loop-type structure to check data consistency
% -- within the loop, tries to fix inconsistencies

%
% Known issues:
%  (as of 2019_10_04) - Odometry on the rear encoders is quite wonky. For
%  some reason, need to do absolute value on speeds - unclear why. And the
%  left encoder is clearly disconnected.
%  UPDATE: encoder reattached in 2019_10_15, but still giving positive/negative flipping errors
%  UPDATE2: encoders rebuilt in 2022 summer to fix this issue
%
%  (as of 2019_10_04) - Steering system is giving very poor data. A quick
%  calculation shows that the resolution is no better than 0.05 inches, and
%  with a stroke length of 10 inches, this is only 200 counts. The data
%  show that we need a high resolution encoder on the steering shaft
%  somehow.
%  UPDATE: encoder added to steering in 2022 summer to fix this issue
%
%  (as of 2019_10_05) - Need the GPS time from all GPS receivers to ensure
%  alignment with ROS time. (UPDATE: have this as of 10_07 for Hemisphere)
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


% (as of 2021_07_06 centiSeconds of each sensor is wrong, e.g. GPS is 50ms not 5 ms)

%% TO_DO LIST
% AS OF 2023_06_12
% We should separate out codes that LOAD data from a source, away from
% codes that process data. The function stack that starts with
% fcn_DataClean_queryRawData, then goes to fcn_DataClean_loadRawData, which
% then calls the sensor-specific calls:
% fcn_DataClean_loadRawData_Hemisphere,
% fcn_DataClean_loadRawData_Novatel_GPS, 
% etc.
% completely mix up data loading and data processing, and thus the data
% processing is very confusing as it is done two different ways all the way
% down to the sensor level; the codes are different from DB versus from
% file.
%
% To fix this, we may need to:
% 
% Separate out the fcn_DataClean_queryRawData into two functions for loading data:
% -- fcn_DataClean_queryRawDataFromDB
% -- fcn_DataClean_queryRawDataFromFile
% The first function should ONLY have the DB queries, the second should work
% with a file input. We may need to write a third one to handle multiple
% files similar to the formats now produced by the mapping van. 
% 
% Then,
% Move the dB versus file functionality out of fcn_DataClean_loadRawData, 
% and use this function to ONLY prepare data from each sensor. Perhaps
% rename it to "loadSensorData"?
% 
% Then, 
% Fix each sensor load call, for example,
% fcn_DataClean_loadRawData_Hemisphere, try to unify the loading process
% for these so that all the GPS systems have the same format, all Encoders,
% all INS, etc. Each function type, say "GPS" should start off with a
% template data structure that is filled at the top with empty values, and
% then each field is fixed inside the file. The custom file for each sensor
% can create a LOT of problems as we get deeper into the codes.
%
% ALSO: MUST ADD THE TRIGGER SOURCE as a SENSOR input!!!
%
% As well, for each sensor, we need to characterize three time sources:
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



% %% Dependencies and Setup of the Code
% % The code requires several other libraries to work, namely the following
% %
% % * DebugTools - the repo can be found at: https://github.com/ivsg-psu/Errata_Tutorials_DebugTools
% % * PathClassLibrary - the repo can be found at: https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary
% % * Database - this is a zip of a single file containing the Database class
% % * GPS - this is a zip of a single file containing the GPS class
% % * Map - this is a zip of a single file containing the Map class
% % * MapDatabase - this is a zip of a single file containing the MapDatabase class
% %
% % Each is automatically installed in a folder called "Utilities" under the root
% % folder, namely ./Utilities/DebugTools/ , ./Utilities/PathClassLibrary/, etc.
% % If you wish to put these codes in different directories, the function
% % below can be easily modified with strings specifying the different
% % location.

%% Prep the workspace
close all
clc

fid = 0; % The file ID to use for printing messages from the code below

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


%% Specify the data to use
% bagFolderName = "mapping_van_2023-06-05-1Lap"; 
bagFolderName = "mapping_van_2023-06-22-1Lap_0";


%% ======================= Load the raw data =========================
% This data will have outliers, be unevenly sampled, have multiple and
% inconsistent measurements of the same variable. In other words, it is the
% raw data. It can be loaded either from a database or a file - details are
% in the function below.

flag.DBquery = false; %true; %set to true to query raw data from database 
flag.DBinsert = false; %set to true to insert cleaned data to cleaned data database
flag.SaveQueriedData = true; % 

if ~exist('dataset','var')
    if flag.DBquery == true
        % Load the raw data from the database
        queryCondition = 'trip'; % Default: 'trip'. raw data can be queried by 'trip', 'date', or 'driver'
        [rawData,trip_name,trip_id_cleaned,base_station,Hemisphere_gps_week] = fcn_DataClean_queryRawDataFromDB(flag.DBquery,'mapping_van_raw',queryCondition); % more query condition can be set in the function
    else
        % Load the raw data from file
        dataset{1} = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName);
    end
end

%% Fill in test cases?
% Fill in the initial data - we use this for testing
% dataStructure = fcn_DataClean_fillTestDataStructure;

%% Start the looping process to iteratively clean data
% The method used below is as follows:
% -- The data is initialized before the loop by loading (see above)
% -- The loop is started, and for each version of the loop, the data is
%    checked to see if there are any errors measured in the data.
% -- For each error type, a flag is set that is used to initiate a process
%    that seeks to remove that type of error.
% 
% For example: say the data has wrap-around error on yaw angle due to angle
% roll-over. This is checked and reported, and a function is called if this
% is detected to fix that error.

flag_stay_in_main_loop = 1;
N_max_loops = 30;

% Preallocate the data array
data_structure_sequence{N_max_loops} = struct;

main_data_cleaan_loop_iteration_number = 1; % The first iteration corresponds to the raw data loading
while 1==flag_stay_in_main_loop
    dataStructure = dataset{1};
    main_data_cleaan_loop_iteration_number = main_data_cleaan_loop_iteration_number+1;
    
    %% Check data for errors
    [flags, offending_sensor] = fcn_DataClean_checkDataConsistency(dataStructure,fid);
    
    %% Data cleaning processes to fix the latest error start here

    %% Check if there are no data collected that have GPS time (UTC time) recorded
    %    ### ISSUES with this:
    %    * There is no absolute time base to use for the data
    %    * The tracking of vehicle data relative to external sourses is no
    %    longer possible
    %    ### DETECTION:
    %    * Examine if GPS time fields exist on any GPS sensor
    %    ### FIXES:
    %    * Catastrophic error. Data collection should end.
    %    * One option? Check if ROS_Time recorded, and is locked to UTC via NTP, use ROS
    %    Time as stand-in
    %    * Otherwise, complete failure of sensor recordings
    
    if 0==flags.GPS_Time_exists_in_at_least_one_sensor
        error('Catastrophic data error detected: no GPS_Time data detected in any sensor.');
    end
    
    
    %% Check if at least one GPS sensor is missing GPS time
    %    ### ISSUES with this:
    %    * There is no absolute time base to use for the sensor
    %    * This usually indicates back lock for the GPS
    %    ### DETECTION:
    %    * Examine if GPS time fields exist on all GPS sensors
    %    ### FIXES:
    %    * If another GPS is available, use its time alongside the GPS data
    %    * Remove this GPS data field
    if 0==flags.GPS_Time_exists_in_GPS_sensors
        error('Catastrophic data error detected: the following GPS sensor is missing GPS_Time data: %s.',offending_sensor);        
    end
    
    %% Check if the centiSeconds field is missing on one of the GPS sensors
    %    ### ISSUES with this:
    %    * This field defines the expected sample rate for each sensor
    %    ### DETECTION:
    %    * Examine if centiSeconds fields exist on all sensors
    %    ### FIXES:
    %    * Manually fix, or
    %    * Remove this sensor
    if 0==flags.centiSeconds_exists_in_GPS_sensors
        error('Catastrophic data error detected: the following GPS sensor is missing centiSeconds: %s.',offending_sensor);                
    end
    
    %% Check if inconsistency between expected and actual time sampling for GPS_Time
    %    ### ISSUES with this:
    %    * This field is used to confirm GPS sampling rates for all
    %    GPS-triggered sensors
    %    * These sensors are used to correct ROS timings, so if misisng, the
    %    timing and thus positioning of vehicle data may be wrong
    %    * The GPS unit may be configured wrong
    %    * The GPS unit may be faililng or operating incorrectly
    %    ### DETECTION:
    %    * Make sure centiSeconds exists in all GPS sensors
    %    * Examine if centiSeconds calculation of time interval matches GPS
    %    time interval for data collection, on average
    %    ### FIXES:
    %    * Manually fix, or
    %    * Remove this sensor
    if 0==flags.GPS_Time_has_same_sample_rate_as_centiSeconds_in_GPS_sensors
        error('Inconsistent data detected: the following GPS sensor has an average sampling rate different than predicted from centiSeconds: %s.',offending_sensor);                
    end
    
    %% Inconsistency between start and end times for GPS_Time
    %    ### ISSUES with this:
    %    * The start times and end times of all data collection assumes all GPS
    %    systems are operating simultaneously
    %    * The calculation of Trigger_Time assumes that all start times are the
    %    same, and all end times are the same
    %    * If they are not the same, the count of data in one sensor may be
    %    different than another, especially if each were referencing different
    %    GPS sources.
    %    ### DETECTION:
    %    * Seach through the GPS time fields for all sensors, rounding them to
    %    their appropriate centi-second values
    %    * Check that they all agree
    %    ### FIXES:
    %    * Crop all data to same starting centi-second value
    
    %% Check consistency between start times for GPS_Time
    if 0==flags.consistent_start_and_end_times_across_GPS_sensors
        error('Need to fix this!');
    end
    
    %% Exiting conditions
    % Check if all the flags work, so we can exit!
    flag_fields = fieldnames(flags); % Grab all the flags
    flag_array = zeros(length(flag_fields),1);
    for ith_field = 1:length(flag_fields)
        flag_array(ith_field,1) = flags.(flag_fields{ith_field});
    end
    if all(flag_array==1)
        flag_stay_in_main_loop = 0;
    end
    
    % Have we done too many loops?
    if main_data_cleaan_loop_iteration_number>N_max_loops
        flag_stay_in_main_loop = 0;
    end
          
end


 
% %% ======================= Raw Data Clean and Merge =========================
% % Step 1: we check if the time is incrementing uniformly. If it does not,
% % the data around this is set to NaN. In later steps, this is interpolated.
% rawDataTimeFixed = fcn_DataClean_removeTimeGapsFromRawData(rawData);
% %fcn_DataClean_searchAllFieldsForNaN(rawDataTimeFixed)
% 
% % Step 2: assign to each data a measured or calculated variance.
% % Fill in the sigma values for key fields. This just calculates the sigma
% % values for key fields (velocities, accelerations, angular rates in
% % particular), useful for doing outlier detection, etc. in steps that
% % follow.
% rawDataWithSigmas = fcn_DataClean_loadSigmaValuesFromRawData(rawDataTimeFixed);
% 
% % NOTE: the following function changes the yaw angles to wind (correctly)
% % up or down)
% 
% % Step 3: Remove outliers on key fields via median filtering
% % This removes outliers by median filtering key values.
% rawDataWithSigmasAndMedianFiltered = fcn_DataClean_medianFilterFromRawAndSigmaData(rawDataWithSigmas);
% 
% % PLOTS to show winding up or down:
% % figure(2); plot(mod(rawDataWithSigmas.GPS_Novatel.Yaw_deg,360),'b')
% % figure(3); plot(mod(rawDataWithSigmasAndMedianFiltered.GPS_Novatel.Yaw_deg,360),'k')
% % figure(4); plot(rawDataWithSigmasAndMedianFiltered.GPS_Novatel.Yaw_deg,'r')
% 
% % Step 4: Remove additional data artifacts such as yaw angle wrapping. This
% % is the cleanData structure. This has to be done before filtering to avoid
% % smoothing these artificial discontinuities. Clean the raw data
% cleanData = fcn_DataClean_cleanRawDataBeforeTimeAlignment(rawDataWithSigmasAndMedianFiltered);
% 
% % Step 5: Time align the data to GPS time. and make time a "sensor" field This step aligns
% % all the time vectors to GPS time, and ensures that the data has an even time sampling.
% cleanAndTimeAlignedData = fcn_DataClean_alignToGPSTimeAllData(cleanData);
% 
% % Step 6: Time filter the signals
% timeFilteredData = fcn_DataClean_timeFilterData(cleanAndTimeAlignedData);
% 
% % Step 7: Merge each signal by those that are common along the same state.
% % This is in the structure mergedData. Calculate merged data via Baysian
% % averaging across same state
% mergedData = fcn_DataClean_mergeTimeAlignedData(timeFilteredData);
% 
% % Step 8: Remove jumps from merged data caused by DGPS outages
% mergedDataNoJumps = fcn_DataClean_removeDGPSJumpsFromMergedData(mergedData,rawData,base_station);
% 
% 
% % Step 9: Calculate the KF fusion of single signals
% mergedByKFData = mergedDataNoJumps;  % Initialize the structure with prior data
% 
% % KF the yawrate and yaw together
% t_x1 = mergedByKFData.MergedGPS.GPS_Time;
% x1 = mergedByKFData.MergedGPS.Yaw_deg;
% x1_Sigma = mergedByKFData.MergedGPS.Yaw_deg_Sigma;
% t_x1dot = mergedByKFData.MergedIMU.GPS_Time;
% x1dot = mergedByKFData.MergedIMU.ZGyro*180/pi;
% x1dot_Sigma = mergedByKFData.MergedIMU.ZGyro_Sigma*180/pi;
% nameString = 'Yaw_deg';
% [x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
% x_kf_resampled = interp1(t_x1dot,x_kf,t_x1,'linear','extrap');
% sigma_x_resampled = interp1(t_x1dot,sigma_x,t_x1,'linear','extrap');
% mergedByKFData.MergedGPS.Yaw_deg = x_kf_resampled;
% mergedByKFData.MergedGPS.Yaw_deg_Sigma = sigma_x_resampled;
% 
% % KF the xEast_increments and xEast together
% t_x1 = mergedByKFData.MergedGPS.GPS_Time;
% x1 = mergedByKFData.MergedGPS.xEast;
% x1_Sigma = mergedByKFData.MergedGPS.xEast_Sigma;
% t_x1dot = mergedByKFData.MergedGPS.GPS_Time;
% x1dot = mergedByKFData.MergedGPS.xEast_increments/0.05;  % The increments are raw changes, not velocities. Have to divide by time step.
% x1dot_Sigma = mergedByKFData.MergedGPS.xEast_increments_Sigma/0.05;
% nameString = 'xEast';
% [x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
% mergedByKFData.MergedGPS.xEast = x_kf;
% mergedByKFData.MergedGPS.xEast_Sigma = sigma_x;
% 
% % KF the yNorth_increments and yNorth together
% t_x1 = mergedByKFData.MergedGPS.GPS_Time;
% x1 = mergedByKFData.MergedGPS.yNorth;
% x1_Sigma = mergedByKFData.MergedGPS.yNorth_Sigma;
% t_x1dot = mergedByKFData.MergedGPS.GPS_Time;
% x1dot = mergedByKFData.MergedGPS.yNorth_increments/0.05;  % The increments are raw changes, not velocities. Have to divide by time step.
% x1dot_Sigma = mergedByKFData.MergedGPS.yNorth_increments_Sigma/0.05;
% nameString = 'yNorth';
% [x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
% mergedByKFData.MergedGPS.yNorth = x_kf;
% mergedByKFData.MergedGPS.yNorth_Sigma = sigma_x;
% 
% % convert ENU to LLA (used for geoplot)
% [mergedByKFData.MergedGPS.latitude,mergedByKFData.MergedGPS.longitude,mergedByKFData.MergedGPS.altitude] ...
%     = enu2geodetic(mergedByKFData.MergedGPS.xEast,mergedByKFData.MergedGPS.yNorth,mergedByKFData.MergedGPS.zUp,...
%     base_station.latitude,base_station.longitude, base_station.altitude,wgs84Ellipsoid);
% 
% %% Step 10: Add interpolation to Lidar data to create field in Lidar that has GPS position in ENU
% % NOTE: as of 2023-06-11
% % The following does NOT work yet, and needs to be corrected via transforms
% % [mergedDataNoJumps,mergedByKFData] = fcn_DataClean_AddLocationToLidar(mergedDataNoJumps,mergedByKFData,base_station);
% 
% % Note: mergedDataNoJumps may have better GPS location data than
% % mergedByKFData if the Kalman filter fusion does not work well, for
% % example, the data at test track with trip_id =2.
% 
% % add Hemisphere_gps_week to mergedDataNoJumps and mergedByKFData
% if length(Hemisphere_gps_week) >1
%     error('More than one week data was collected in the trip!')
% end
% mergedDataNoJumps.MergedGPS.GPS_week = Hemisphere_gps_week;
% mergedDataNoJumps.Lidar.GPS_week = Hemisphere_gps_week;
% mergedByKFData.MergedGPS.GPS_week = Hemisphere_gps_week;
% mergedByKFData.Lidar.GPS_week = Hemisphere_gps_week;
% 
% % Probably can delete the following if statement (VERY old)
% if 1==0
%     % The following shows that we should NOT use yaw angles to calculate yaw rate
%     fcn_plotArtificialYawRateFromYaw(MergedData,timeFilteredData);
% 
%     % Now to check to see if raw integration of YawRate can recover the yaw
%     % angle
%     fcn_plotArtificialYawFromYawRate(MergedData,timeFilteredData);
% 
% 
%     %fcn_plotArtificialVelocityFromXAccel(MergedData,timeFilteredData);
%     fcn_plotArtificialPositionFromIncrementsAndVelocity(MergedData,cleanAndTimeAlignedData)
% end
% 
% 
% %% Update plotting flags to allow merged data to now appear hereafter
% 
% clear plottingFlags
% plottingFlags.fields_to_plot = [...
%     %     {'All_AllSensors_velMagnitude'}...
%     %     {'All_AllSensors_ZGyro'},...
%     %     {'All_AllSensors_yNorth_increments'}...
%     %     {'All_AllSensors_xEast_increments'}...
%     %     {'All_AllSensors_xEast'}...
%     %     {'All_AllSensors_yNorth'}...
%     %     {'xEast'}...
%     %     {'yNorth'}...
%     %     {'xEast_increments'}...
%     %     {'yNorth_increments'}...
%     %     {'All_AllSensors_Yaw_deg'},...
%     %     {'Yaw_deg'},...
%     %     {'ZGyro_merged'},...
%     %     {'All_AllSensors_ZGyro_merged'},...
%     {'XYplot'},...
%     %     {'All_AllSensors_XYplot'},...
%     ];
% % Define what is plotted
% plottingFlags.flag_plot_Garmin = 0;
% 
% %
% % % THE TEMPLATE FOR ALL PLOTTING
% % fieldOrdering = [...
% %     {'Yaw_deg'},...                 % Yaw variables
% %     {'Yaw_deg_from_position'},...
% %     {'Yaw_deg_from_velocity'},...
% %     {'All_SingleSensor_Yaw_deg'},...
% %     {'All_AllSensors_Yaw_deg'},...
% %     {'Yaw_deg_merged'},...
% %     {'All_AllSensors_Yaw_deg_merged'},...
% %     {'ZGyro'},...                   % Yawrate (ZGyro) variables
% %     {'All_AllSensors_ZGyro'},...
% %     {'velMagnitude'},...            % velMagnitude variables
% %     {'All_AllSensors_velMagnitude'},...
% %     {'XAccel'},...                  % XAccel variables
% %     {'All_AllSensors_XAccel'},...
% %     {'xEast_increments'},...        % Position increment variables
% %     {'All_AllSensors_xEast_increments'},...
% %     {'yNorth_increments'},...
% %     {'All_AllSensors_yNorth_increments'},...
% %     {'zUp_increments'},...
% %     {'All_AllSensors_zUp_increments'},...
% %     {'XYplot'},...                  % XY plots
% %     {'All_AllSensors_XYplot'},...
% %     {'xEast'},...                   % xEast and yNorth plots
% %     {'All_AllSensors_xEast'},...
% %     {'yNorth'},...
% %     {'All_AllSensors_yNorth'},...
% %     {'zUp'},...
% %     {'All_AllSensors_zUp'},...
% %     {'DGPS_is_active'},...
% %     {'All_AllSensors_DGPS_is_active'},...
% %     %     {'velNorth'},...                % Remaining are not yet plotted - just kept here for now as  placeholders
% %     %     {'velEast'},...
% %     %     {'velUp'},...
% %     %     {'Roll_deg'},...
% %     %     {'Pitch_deg'},...
% %     %     {'xy_increments'}... % Confirmed
% %     %     {'YAccel'},...
% %     %     {'ZAccel'},...
% %     %     {'XGyro'},...
% %     %     {'YGyro'},...
% %     %     {'VelocityR},...
% %     ];
% 
% % Define which sensors to plot individually
% plottingFlags.SensorsToPlotIndividually = [...
%     {'GPS_Hemisphere'}...
%     {'GPS_Novatel'}...
%     {'MergedGPS'}...
%     %    {'VelocityProjectedByYaw'}...
%     %     {'GPS_Garmin'}...
%     %     {'IMU_Novatel'}...
%     %     {'IMU_ADIS'}...
%     %     {'Input_Steering'}...
%     %     {'Encoder_RearWheels'}...
%     %     {'MergedIMU'}...
%     ];
% 
% % Define zoom points for plotting
% % plottingFlags.XYZoomPoint = [-4426.14413504648 -4215.78947791467 1601.69022519862 1709.39208889317]; % This is the corner after Toftrees, where the DGPS lock is nearly always bad
% % plottingFlags.TimeZoomPoint = [297.977909295872          418.685505549775];
% % plottingFlags.TimeZoomPoint = [1434.33632953011          1441.17612419014];
% % plottingFlags.TimeZoomPoint = [1380   1600];
% % plottingFlags.TimeZoomPoint = [760 840];
% % plottingFlags.TimeZoomPoint = [596 603];  % Shows a glitch in the Yaw_deg_all_sensors plot
% % plottingFlags.TimeZoomPoint = [1360   1430];  % Shows lots of noise in the individual Yaw signals
% % plottingFlags.TimeZoomPoint = [1226 1233]; % This is the point of time discontinuity in the raw dat for Hemisphere
% % plottingFlags.TimeZoomPoint = [580 615];  % Shows a glitch in xEast_increments plot
% % plottingFlags.TimeZoomPoint = [2110 2160]; % This is the point of discontinuity in xEast
% % plottingFlags.TimeZoomPoint = [2119 2129]; % This is the location of a discontinuity produced by a variance change
% % plottingFlags.TimeZoomPoint = [120 150]; % Strange jump in xEast data
% plottingFlags.TimeZoomPoint = [185 185+30]; % Strange jump in xEast data
% 
% 
% % if isfield(plottingFlags,'TimeZoomPoint')
% %     plottingFlags = rmfield(plottingFlags,'TimeZoomPoint');
% % end
% 
% 
% % These set common y limits on values
% % plottingFlags.ylim.('xEast') = [-4500 500];
% plottingFlags.ylim.('yNorth') = [500 2500];
% 
% plottingFlags.ylim.('xEast_increments') = [-1.5 1.5];
% plottingFlags.ylim.('All_AllSensors_xEast_increments') = [-1.5 1.5];
% plottingFlags.ylim.('yNorth_increments') = [-1.5 1.5];
% plottingFlags.ylim.('All_AllSensors_yNorth_increments') = [-1.5 1.5];
% 
% plottingFlags.ylim.('velMagnitude') = [-5 35];
% plottingFlags.ylim.('All_AllSensors_velMagnitude') = [-5 35];
% 
% 
% plottingFlags.PlotDataDots = 0; % If set to 1, then the data is plotted as dots as well as lines. Useful to see data drops.
% 
% %% Plot the results
% fcn_DataClean_plotStructureData(rawData,plottingFlags);
% %fcn_DataClean_plotStructureData(rawDataTimeFixed,plottingFlags);
% %fcn_DataClean_plotStructureData(rawDataWithSigmas,plottingFlags);
% %fcn_DataClean_plotStructureData(rawDataWithSigmasAndMedianFiltered,plottingFlags);
% %fcn_DataClean_plotStructureData(cleanData,plottingFlags);
% %fcn_DataClean_plotStructureData(cleanAndTimeAlignedData,plottingFlags);
% %fcn_DataClean_plotStructureData(timeFilteredData,plottingFlags);
% %fcn_DataClean_plotStructureData(mergedData,plottingFlags);
% fcn_DataClean_plotStructureData(mergedDataNoJumps,plottingFlags);
% fcn_DataClean_plotStructureData(mergedByKFData,plottingFlags);
% 
% % The following function allows similar plots, made when there are repeated
% % uncommented versions above, to all scroll/zoom in unison.
% %fcn_plotAxesLinkedTogetherByField;
% 
% 
% %% geoplot
% figure(123)
% clf
% geoplot(mergedByKFData.GPS_Hemisphere.Latitude,mergedByKFData.GPS_Hemisphere.Longitude,'b', ...
%     mergedByKFData.MergedGPS.latitude,mergedByKFData.MergedGPS.longitude,'r',...
%     mergedDataNoJumps.MergedGPS.latitude,mergedDataNoJumps.MergedGPS.longitude,'g', 'LineWidth',2)
% 
% % geolimits([45 62],[-149 -123])
% legend('mergedByKFData.GPS\_Hemisphere','mergedByKFData.MergedGPS','mergedDataNoJumps.MergedGPS')
% geobasemap satellite
% %geobasemap street
% %% OLD STUFF
% 
% % %% Export results to Google Earth?
% % %fcn_exportXYZ_to_GoogleKML(rawData.GPS_Hemisphere,'rawData_GPS_Hemisphere.kml');
% % %fcn_exportXYZ_to_GoogleKML(mergedData.MergedGPS,'mergedData_MergedGPS.kml');
% % fcn_exportXYZ_to_GoogleKML(mergedDataNoJumps.MergedGPS,[dir.datafiles 'mergedDataNoJumps_MergedGPS.kml']);
% %
% %
% % %% Save cleaned data to .mat file
% % % The following is not used
% % newStr = regexprep(trip_name{1},'\s','_'); % replace whitespace with underscore
% % newStr = strrep(newStr,'-','_');
% % cleaned_fileName = [newStr,'_cleaned'];
% % eval([cleaned_fileName,'=mergedByKFData'])
% % save(strcat(dir.datafiles,cleaned_fileName,'.mat'),cleaned_fileName)
% 
% %
% % fields = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% % I99_Altoona33_to_StateCollege73 = rmfield(mergedByKFData.MergedGPS,fields);
% % save('I99_Altoona33_to_StateCollege73_20210123.mat','I99_Altoona33_to_StateCollege73')
% % if trip_id_cleaned == 7
% %     fields_rm = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% %     I99_StateCollege73_to_Altoona33 = rmfield(mergedByKFData.MergedGPS,fields_rm);
% %     save('I99_StateCollege73_to_Altoona33_20210123.mat','I99_StateCollege73_to_Altoona33')
% % 
% %     fields_rm = {'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% %     I99_StateCollege73_to_Altoona33_mergedDataNoJumps = rmfield(mergedDataNoJumps.MergedGPS,fields_rm);
% %     I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station = [0; cumsum(sqrt(diff(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.xEast).^2+diff(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.yNorth).^2))];
% %     save('I99_StateCollege73_to_Altoona33_mergedDataNoJumps_20210123.mat','I99_StateCollege73_to_Altoona33_mergedDataNoJumps')
% % end
% 
% % extract TestTrack data
% % fields = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% % TestTrack_all = rmfield(mergedByKFData.MergedGPS,fields);
% % TestTrack_all_table = struct2table(TestTrack_all);
% % TestTrack_table = TestTrack_all_table(6000:9398,:);
% % TestTrack = table2struct(TestTrack_table,'ToScalar',true);
% % save('TestTrack.mat','TestTrack')
% %
% % figure(1234)
% % clf
% % geoplot(TestTrack.latitude,TestTrack.longitude,'b', ...
% % TestTrack.latitude(1),TestTrack.longitude(1),'r.',...
% % TestTrack.latitude(end),TestTrack.longitude(end),'g.','LineWidth',2)
% % % geolimits([45 62],[-149 -123])
% % legend('Merged')
% % geobasemap satellite
% 
% %%  Yaw Rate and Curvature Comparision
% if 1 ==0
%     [~, ~, ~, ~,R_spiral,UnitNormalV,concavity]=fnc_parallel_curve(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.xEast, I99_StateCollege73_to_Altoona33_mergedDataNoJumps.yNorth, 1, 0,1,100);
% 
%     yaw_rate = [0; diff(mergedDataNoJumps.MergedGPS.Yaw_deg)./diff(mergedDataNoJumps.MergedGPS.GPS_Time)];
% 
%     figure(23)
%     clf
%     hold on
%     % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,I99_StateCollege73_to_Altoona33_mergedDataNoJumps.altitude)
%     plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,mergedDataNoJumps.MergedGPS.Yaw_deg,'b','LineWidth',1)
%     plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,yaw_rate,'r','LineWidth',1)
% 
%     grid on
%     box on
%     xlabel('station (m)')
%     ylabel('yaw and yaw rate (deg)')
%     % ylim([0 0.01])
% 
% 
%     figure(24)
%     clf
%     hold on
%     Ux = mergedDataNoJumps.GPS_Hemisphere.velEast.*cosd(mergedDataNoJumps.MergedGPS.Yaw_deg) + ...
%         mergedDataNoJumps.GPS_Hemisphere.velNorth.*sind(mergedDataNoJumps.MergedGPS.Yaw_deg);
%     plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,Ux,'b','LineWidth',1)
%     plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,mergedDataNoJumps.GPS_Hemisphere.velNorth,'g')
%     plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,mergedDataNoJumps.GPS_Hemisphere.velEast,'r','LineWidth',1)
% 
%     % plot(mergedDataNoJumps.IMU_Novatel.GPS_Time,mergedDataNoJumps.IMU_Novatel.ZAccel,'b')
%     grid on
%     box on
%     xlabel('time (s)')
%     ylabel('velocity (m/s)')
%     % ylim([0 0.01])
% 
%     curvature_ss  = (yaw_rate*pi/180)./Ux;
% 
%     figure(22)
%     clf
%     % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,I99_StateCollege73_to_Altoona33_mergedDataNoJumps.altitude)
%     hold on
%     % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,curvature_ss,'g','LineWidth',1)
%     plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,abs(concavity).*1./R_spiral,'r','LineWidth',1)
%     grid on
%     box on
%     xlabel('Station (m)')
%     ylabel('Curvature')
%     ylim([-0.01 0.04])
% 
% 
% end
% %% ======================= Insert Cleaned Data to 'mapping_van_cleaned' database =========================
% % Input trips information
% %
% % tripsInfo.id = trip_id_cleaned;
% % tripsInfo.vehicle_id = 1;
% % tripsInfo.base_stations_id = base_station.id;
% % tripsInfo.name = trip_name;
% % if trip_id_cleaned == 2
% %
% %     tripsInfo.description = {'Test Track MappingVan night middle speed'};
% %     tripsInfo.date = {'2019-10-18 20:39:30'};
% %     tripsInfo.driver = {'Liming Gao'};
% %     tripsInfo.passengers = {'N/A'};
% %     tripsInfo.notes = {'without traffic light, at night. DGPS mode was activated. middle speed. 7 traversals'};
% %     cleanedData  = mergedDataNoJumps;
% %
% %     start_point.start_longitude=-77.833842140800000;  %deg
% %     start_point.start_latitude =40.862636161300000;   %deg
% %     start_point.start_xEast=1345.204537286125; % meters
% %     start_point.start_yNorth=6190.884280063217; % meters
% %
% %     start_point.end_longitude=-77.833842140800000;  %deg
% %     start_point.end_latitude =40.862636161300000;   %deg
% %     start_point.end_xEast=1345.204537286125; % meters
% %     start_point.end_yNorth=6190.884280063217; % meters
% %
% %     start_point.start_yaw_angle = 37.38; %deg
% %     start_point.expectedRouteLength = 1555.5; % meters
% %     start_point.direction = 'CCW'; %
% %     cleanedData.start_point = start_point;
% % elseif trip_id_cleaned == 7
% %
% %     tripsInfo.description = {'Map I99 from State College(exit 73) to Altoona (exit 33)'};
% %     tripsInfo.date = {'2021-01-23 15:00:00'};
% %     tripsInfo.driver = {'Wushuang Bai'};
% %     tripsInfo.passengers = {'Liming Gao'};
% %     tripsInfo.notes = {'Mapping from State College(exit 73) to Altoona (exit 33) through I-99. Lost DGPS mode when approaching Altoona. Drving on the right lane.'};
% %     cleanedData  = mergedByKFData;
% % elseif trip_id_cleaned == 8
% %     tripsInfo.description = {'Map I99 from Altoona (exit 33) to State College(exit 73)'};
% %     tripsInfo.date = {'2021-01-23 16:00:00'};
% %     tripsInfo.driver = {'Wushuang Bai'};
% %     tripsInfo.passengers = {'Liming Gao'};
% %     tripsInfo.notes = {'Mapping from Altoona (exit 33) to State College(exit 73) through I-99. Nexver lost DGPS mode except for passing below bridge or traffic sign. Drving on the right lane.'};
% %     cleanedData  = mergedByKFData;
% % else
% %     error("Wrong Trip ID");
% % end
% % % insert cleaned data
% % fcn_DataClean_insertCleanedData(cleanedData,rawData,tripsInfo,flag);
% % % save('cleanedData.mat','cleanedData')
% %


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
path_dirs = regexp(path,'[;]','split');
utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir});
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

