%%
% This main script is used to test the DataClean functions. It was
% originally written to process and plot the mapping van DGPS data
% collected for the Wahba route on 2019_09_17 with the Penn State Mapping
% Van.
%
% Author: Sean Brennan and Liming Gao
% Original Date: 2019_09_24
% modify Date: 2021_10_15
%
% Updates:
%  2019_10_03 - Functionalization of data loading, error analysis, plotting
%  2019_10_05 - Additional processing routines added for velocity
%  2019_10_06 to 07 - worked on time alignment concerns.
%  2019_10_12 - put in the kinematic regression filter for yawrate.
%  2019_10_14 - added sigma calculations for raw data.
%  2019_10_19 - added XY delta calculations.
%  2019_10_20 - added Bayesian averaging. Collapsed plotting functions.
%  2019_10_23 - break timeFilteredData into laps instead of only one
%  2019_10_21 - added zoom capability. Noticed that sigmas are not passing
%  correctly for Hemisphere.
%  2019_11_09 - fixed errors in standard deviation calculations, fixed
%  goodIndices, and fixed GPS info showing up in ADIS IMU fields
%  2019_11_15 - documented program flow, fixed bug in plotting routines,
%  corrected sigma calculations for yaw based on velocity to include
%  variance growth between DGPS updates, updated plotting functions to
%  allow merged data
%  2019_11_17 - fixed kinematic filtering in clean data
%  of yaw angle (bug fix).
%  2019_11_19 - Adding this comment so that Liming can see it :)
%  2019_11_21 - Continued working on KF signal merging for yaw angle
%  2019_11_22 - Added time check, as some time vectors are not counting up
%  2019_11_23 - Fixed plotting to work with new time gaps in NaN from above
%  time check.
%  2019_11_24 - Fixed bugs in plotting (zUp was missing). Added checks for
%  NaN values.
%  2019_11_25 - Fixed bugs in time alignment, where deltaT was wrong.
%  2019_11_26 - Fixed plotting routines to allow linking during plotting.
%  2019_11_27 - Worked on KF and Merge functionality. Cleaned up code flow.
%  Added filtering of Sigma values.
%  2019_12_01 - Did post-processing after merge functions, but before
%  Kalman filter, adding another function to remove jumps in xData and
%  yData in Hemisphere, due to DGPS being lost. Fixed a few bugs in the KF
%  area. Code now runs end to end, producing what appears to be a valid XY
%  profile. Exports results to KML. (suggest code branch at this point)
%  2020_02_05 - fix bugs when DGPS ia active all time
%  2020_05_20 - fixed bug on the yaw angle plots
%  2020_06_20 - add raw data query functions
%  2020_08_30 - add database query method
%  2020_10_20 - functionalize the database query
%  2021_01_07
%       -- started new DataClean class funtionality, code works now ONLY
%       for mapping van data
%  2021_01_08
%       -- create a function to query data from database or load from file
%  2021-01-10
%       -- Integrate the updated database query as a stand-alone function, to clean
%       up large amount of code at top of this script(Done by Liming)
%  2021-01-10
%       -- Add geoplot capability to results so that we can see XY plots on the map
%       automatically (Done by Liming)
%  2021_10_15 - added ability to process LIDAR time data

%
% Known issues:
%  (as of 2019_10_04) - Odometry on the rear encoders is quite wonky. For
%  some reason, need to do absolute value on speeds - unclear why. And the
%  left encoder is clearly disconnected. (UPDATE: encoder reattached in
%  2019_10_15, but still giving positive/negative flipping errors)
%
%  (as of 2019_10_04) - Steering system is giving very poor data. A quick
%  calculation shows that the resolution is no better than 0.05 inches, and
%  with a stroke length of 10 inches, this is only 200 counts. The data
%  show that we need a high resolution encoder on the steering shaft
%  somehow.
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

%
%% Prep the workspace

% Clear the command window and workspace
clc
% clear all %#ok<CLALL>
close all 

% Make sure we can see the utilities folder
addpath '../Utilities';
addpath '../data'; % add the data path
addpath('./fcn_DataClean_loadRawData/'); % all the functions and wrapper class

%% ======================= Load the raw data=========================
% This data will have outliers, be unevenly sampled, have multiple and
% inconsistent measurements of the same variable. In other words, it is the
% raw data. It can be loaded either from a database or a file - details are
% in the function below.

%flag.DBquery = true; %set to true if you want to query raw data from database insteading of loading from default *.mat file
%flag.DBinsert = true; %set to true if you want to insert cleaned data to cleaned data database

flag.DBquery = false; %set to true if you want to query raw data from database insteading of loading from default *.mat file
flag.DBinsert = false; %set to true if you want to insert cleaned data to cleaned data database
% flag.LoadToWorkspace = false; % set to true if you want to load variables directly to workspace
flag.SaveQueriedData = true; 

try
    fprintf('Starting the code using variable rawData of length: %d\n', length(rawData));
catch

        if flag.DBquery == true
            %       database_name = 'mapping_van_raw';
            queryCondition = 'trip'; % Default: 'trip'. raw data can be queried by 'trip', 'date', or 'driver'
            [rawData,trip_name,trip_id_cleaned,base_station,Hemisphere_gps_week] = fcn_DataClean_queryRawData(flag.DBquery,'mapping_van_raw',queryCondition); % more query condition can be set in the function
            if flag.SaveQueriedData && (trip_id_cleaned==2)
                save('../data/TestTrack_rawData_2019_10_18.mat','rawData','trip_name','trip_id_cleaned','base_station','Hemisphere_gps_week');
            end
            
        else
            
            % Load the raw data from file
            % test one
            %filename  = 'MappingVan_DecisionMaking_03132020.mat';
            %variable_names = 'MappingVan_DecisionMaking_03132020';
            %base_station.id = 2;%1:test track, 2: LTI, Larson  Transportation Institute
            
            % test two
            % filename  = 'Route_Wahba.mat';
            % variable_names = 'Route_WahbaLoop';
            % base_station.id = 2;%1:test track, 2: LTI, Larson  Transportation Institute
            % base_station.latitude= 40.8068919389;
            % base_station.longitude= -77.8497968306;
            % base_station.altitude= 337.665496826;
            %
            % [rawData,trip_name,trip_id_cleaned,~,Hemisphere_gps_week] = fcn_DataClean_queryRawData(flag.DBquery,filename,variable_names); % more query condition can be set in the function
            
            % test three
            load('TestTrack_rawData_2019_10_18.mat');  % Loads TestTrack data and creates 'rawData' variable directly

        end
end

%% ======================= Raw Data Clean and Merge =========================
% Step 1: we check if the time is incrementing uniformly. If it does not,
% the data around this is set to NaN. In later steps, this is interpolated.
rawDataTimeFixed = fcn_DataClean_removeTimeGapsFromRawData(rawData);
%fcn_DataClean_searchAllFieldsForNaN(rawDataTimeFixed)

% Step 2: assign to each data a measured or calculated variance.
% Fill in the sigma values for key fields. This just calculates the sigma
% values for key fields (velocities, accelerations, angular rates in
% particular), useful for doing outlier detection, etc. in steps that
% follow.
rawDataWithSigmas = fcn_DataClean_loadSigmaValuesFromRawData(rawDataTimeFixed);

% NOTE: the following function changes the yaw angles to wind (correctly)
% up or down)

% Step 3: Remove outliers on key fields via median filtering
% This removes outliers by median filtering key values.
rawDataWithSigmasAndMedianFiltered = fcn_DataClean_medianFilterFromRawAndSigmaData(rawDataWithSigmas);

% PLOTS to show winding up or down:
% figure(2); plot(mod(rawDataWithSigmas.GPS_Novatel.Yaw_deg,360),'b')
% figure(3); plot(mod(rawDataWithSigmasAndMedianFiltered.GPS_Novatel.Yaw_deg,360),'k')
% figure(4); plot(rawDataWithSigmasAndMedianFiltered.GPS_Novatel.Yaw_deg,'r')

% Step 4: Remove additional data artifacts such as yaw angle wrapping. This
% is the cleanData structure. This has to be done before filtering to avoid
% smoothing these artificial discontinuities. Clean the raw data
cleanData = fcn_DataClean_cleanRawDataBeforeTimeAlignment(rawDataWithSigmasAndMedianFiltered);

% Step 5: Time align the data to GPS time. and make time a "sensor" field This step aligns
% all the time vectors to GPS time, and ensures that the data has an even time sampling.
cleanAndTimeAlignedData = fcn_DataClean_alignToGPSTimeAllData(cleanData);

% Step 6: Time filter the signals
timeFilteredData = fcn_DataClean_timeFilterData(cleanAndTimeAlignedData);

% Step 7: Merge each signal by those that are common along the same state.
% This is in the structure mergedData. Calculate merged data via Baysian
% averaging across same state
mergedData = fcn_DataClean_mergeTimeAlignedData(timeFilteredData);

% Step 8: Remove jumps from merged data caused by DGPS outages
mergedDataNoJumps = fcn_DataClean_removeDGPSJumpsFromMergedData(mergedData,rawData,base_station);


% Step 9: Calculate the KF fusion of single signals
mergedByKFData = mergedDataNoJumps;  % Initialize the structure with prior data

% KF the yawrate and yaw together
t_x1 = mergedByKFData.MergedGPS.GPS_Time;
x1 = mergedByKFData.MergedGPS.Yaw_deg;
x1_Sigma = mergedByKFData.MergedGPS.Yaw_deg_Sigma;
t_x1dot = mergedByKFData.MergedIMU.GPS_Time;
x1dot = mergedByKFData.MergedIMU.ZGyro*180/pi;
x1dot_Sigma = mergedByKFData.MergedIMU.ZGyro_Sigma*180/pi;
nameString = 'Yaw_deg';
[x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
x_kf_resampled = interp1(t_x1dot,x_kf,t_x1,'linear','extrap');
sigma_x_resampled = interp1(t_x1dot,sigma_x,t_x1,'linear','extrap');
mergedByKFData.MergedGPS.Yaw_deg = x_kf_resampled;
mergedByKFData.MergedGPS.Yaw_deg_Sigma = sigma_x_resampled;

% KF the xEast_increments and xEast together
t_x1 = mergedByKFData.MergedGPS.GPS_Time;
x1 = mergedByKFData.MergedGPS.xEast;
x1_Sigma = mergedByKFData.MergedGPS.xEast_Sigma;
t_x1dot = mergedByKFData.MergedGPS.GPS_Time;
x1dot = mergedByKFData.MergedGPS.xEast_increments/0.05;  % The increments are raw changes, not velocities. Have to divide by time step.
x1dot_Sigma = mergedByKFData.MergedGPS.xEast_increments_Sigma/0.05;
nameString = 'xEast';
[x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
mergedByKFData.MergedGPS.xEast = x_kf;
mergedByKFData.MergedGPS.xEast_Sigma = sigma_x;

% KF the yNorth_increments and yNorth together
t_x1 = mergedByKFData.MergedGPS.GPS_Time;
x1 = mergedByKFData.MergedGPS.yNorth;
x1_Sigma = mergedByKFData.MergedGPS.yNorth_Sigma;
t_x1dot = mergedByKFData.MergedGPS.GPS_Time;
x1dot = mergedByKFData.MergedGPS.yNorth_increments/0.05;  % The increments are raw changes, not velocities. Have to divide by time step.
x1dot_Sigma = mergedByKFData.MergedGPS.yNorth_increments_Sigma/0.05;
nameString = 'yNorth';
[x_kf,sigma_x] = fcn_DataClean_KFmergeStateAndStateDerivative(t_x1,x1,x1_Sigma,t_x1dot,x1dot,x1dot_Sigma,nameString);
mergedByKFData.MergedGPS.yNorth = x_kf;
mergedByKFData.MergedGPS.yNorth_Sigma = sigma_x;

% convert ENU to LLA (used for geoplot)
[mergedByKFData.MergedGPS.latitude,mergedByKFData.MergedGPS.longitude,mergedByKFData.MergedGPS.altitude] ...
    = enu2geodetic(mergedByKFData.MergedGPS.xEast,mergedByKFData.MergedGPS.yNorth,mergedByKFData.MergedGPS.zUp,...
    base_station.latitude,base_station.longitude, base_station.altitude,wgs84Ellipsoid);

%% Step 10: Add interpolation to Lidar data to create field in Lidar that has GPS position in ENU

[mergedDataNoJumps,mergedByKFData] = fcn_DataClean_AddLocationToLidar(mergedDataNoJumps,mergedByKFData,base_station);
% Note: mergedDataNoJumps may have better GPS location data than
% mergedByKFData if the Kalman filter fusion does not work well, for
% example, the data at test track with trip_id =2.

% add Hemisphere_gps_week to mergedDataNoJumps and mergedByKFData
if length(Hemisphere_gps_week) >1
    error('More than one week data was collected in the trip!')
end
mergedDataNoJumps.MergedGPS.GPS_week = Hemisphere_gps_week;
mergedDataNoJumps.Lidar.GPS_week = Hemisphere_gps_week;
mergedByKFData.MergedGPS.GPS_week = Hemisphere_gps_week;
mergedByKFData.Lidar.GPS_week = Hemisphere_gps_week;

% Probably can delete the following if statement (VERY old)
if 1==0
    % The following shows that we should NOT use yaw angles to calculate yaw rate
    fcn_plotArtificialYawRateFromYaw(MergedData,timeFilteredData);
    
    % Now to check to see if raw integration of YawRate can recover the yaw
    % angle
    fcn_plotArtificialYawFromYawRate(MergedData,timeFilteredData);
    
    
    %fcn_plotArtificialVelocityFromXAccel(MergedData,timeFilteredData);
    fcn_plotArtificialPositionFromIncrementsAndVelocity(MergedData,cleanAndTimeAlignedData)
end


%% Update plotting flags to allow merged data to now appear hereafter

clear plottingFlags
plottingFlags.fields_to_plot = [...
    %     {'All_AllSensors_velMagnitude'}...
    %     {'All_AllSensors_ZGyro'},...
    %     {'All_AllSensors_yNorth_increments'}...
    %     {'All_AllSensors_xEast_increments'}...
    %     {'All_AllSensors_xEast'}...
    %     {'All_AllSensors_yNorth'}...
    %     {'xEast'}...
    %     {'yNorth'}...
    %     {'xEast_increments'}...
    %     {'yNorth_increments'}...
    %     {'All_AllSensors_Yaw_deg'},...
    %     {'Yaw_deg'},...
    %     {'ZGyro_merged'},...
    %     {'All_AllSensors_ZGyro_merged'},...
    {'XYplot'},...
    %     {'All_AllSensors_XYplot'},...
    ];
% Define what is plotted
plottingFlags.flag_plot_Garmin = 0;

%
% % THE TEMPLATE FOR ALL PLOTTING
% fieldOrdering = [...
%     {'Yaw_deg'},...                 % Yaw variables
%     {'Yaw_deg_from_position'},...
%     {'Yaw_deg_from_velocity'},...
%     {'All_SingleSensor_Yaw_deg'},...
%     {'All_AllSensors_Yaw_deg'},...
%     {'Yaw_deg_merged'},...
%     {'All_AllSensors_Yaw_deg_merged'},...
%     {'ZGyro'},...                   % Yawrate (ZGyro) variables
%     {'All_AllSensors_ZGyro'},...
%     {'velMagnitude'},...            % velMagnitude variables
%     {'All_AllSensors_velMagnitude'},...
%     {'XAccel'},...                  % XAccel variables
%     {'All_AllSensors_XAccel'},...
%     {'xEast_increments'},...        % Position increment variables
%     {'All_AllSensors_xEast_increments'},...
%     {'yNorth_increments'},...
%     {'All_AllSensors_yNorth_increments'},...
%     {'zUp_increments'},...
%     {'All_AllSensors_zUp_increments'},...
%     {'XYplot'},...                  % XY plots
%     {'All_AllSensors_XYplot'},...
%     {'xEast'},...                   % xEast and yNorth plots
%     {'All_AllSensors_xEast'},...
%     {'yNorth'},...
%     {'All_AllSensors_yNorth'},...
%     {'zUp'},...
%     {'All_AllSensors_zUp'},...
%     {'DGPS_is_active'},...
%     {'All_AllSensors_DGPS_is_active'},...
%     %     {'velNorth'},...                % Remaining are not yet plotted - just kept here for now as  placeholders
%     %     {'velEast'},...
%     %     {'velUp'},...
%     %     {'Roll_deg'},...
%     %     {'Pitch_deg'},...
%     %     {'xy_increments'}... % Confirmed
%     %     {'YAccel'},...
%     %     {'ZAccel'},...
%     %     {'XGyro'},...
%     %     {'YGyro'},...
%     %     {'VelocityR},...
%     ];

% Define which sensors to plot individually
plottingFlags.SensorsToPlotIndividually = [...
    {'GPS_Hemisphere'}...
    {'GPS_Novatel'}...
    {'MergedGPS'}...
    %    {'VelocityProjectedByYaw'}...
    %     {'GPS_Garmin'}...
    %     {'IMU_Novatel'}...
    %     {'IMU_ADIS'}...
    %     {'Input_Steering'}...
    %     {'Encoder_RearWheels'}...
    %     {'MergedIMU'}...
    ];

% Define zoom points for plotting
% plottingFlags.XYZoomPoint = [-4426.14413504648 -4215.78947791467 1601.69022519862 1709.39208889317]; % This is the corner after Toftrees, where the DGPS lock is nearly always bad
% plottingFlags.TimeZoomPoint = [297.977909295872          418.685505549775];
% plottingFlags.TimeZoomPoint = [1434.33632953011          1441.17612419014];
% plottingFlags.TimeZoomPoint = [1380   1600];
% plottingFlags.TimeZoomPoint = [760 840];
% plottingFlags.TimeZoomPoint = [596 603];  % Shows a glitch in the Yaw_deg_all_sensors plot
% plottingFlags.TimeZoomPoint = [1360   1430];  % Shows lots of noise in the individual Yaw signals
% plottingFlags.TimeZoomPoint = [1226 1233]; % This is the point of time discontinuity in the raw dat for Hemisphere
% plottingFlags.TimeZoomPoint = [580 615];  % Shows a glitch in xEast_increments plot
% plottingFlags.TimeZoomPoint = [2110 2160]; % This is the point of discontinuity in xEast
% plottingFlags.TimeZoomPoint = [2119 2129]; % This is the location of a discontinuity produced by a variance change
% plottingFlags.TimeZoomPoint = [120 150]; % Strange jump in xEast data
plottingFlags.TimeZoomPoint = [185 185+30]; % Strange jump in xEast data


% if isfield(plottingFlags,'TimeZoomPoint')
%     plottingFlags = rmfield(plottingFlags,'TimeZoomPoint');
% end


% These set common y limits on values
% plottingFlags.ylim.('xEast') = [-4500 500];
plottingFlags.ylim.('yNorth') = [500 2500];

plottingFlags.ylim.('xEast_increments') = [-1.5 1.5];
plottingFlags.ylim.('All_AllSensors_xEast_increments') = [-1.5 1.5];
plottingFlags.ylim.('yNorth_increments') = [-1.5 1.5];
plottingFlags.ylim.('All_AllSensors_yNorth_increments') = [-1.5 1.5];

plottingFlags.ylim.('velMagnitude') = [-5 35];
plottingFlags.ylim.('All_AllSensors_velMagnitude') = [-5 35];


plottingFlags.PlotDataDots = 0; % If set to 1, then the data is plotted as dots as well as lines. Useful to see data drops.

%% Plot the results
fcn_DataClean_plotStructureData(rawData,plottingFlags);
%fcn_DataClean_plotStructureData(rawDataTimeFixed,plottingFlags);
%fcn_DataClean_plotStructureData(rawDataWithSigmas,plottingFlags);
%fcn_DataClean_plotStructureData(rawDataWithSigmasAndMedianFiltered,plottingFlags);
%fcn_DataClean_plotStructureData(cleanData,plottingFlags);
%fcn_DataClean_plotStructureData(cleanAndTimeAlignedData,plottingFlags);
%fcn_DataClean_plotStructureData(timeFilteredData,plottingFlags);
%fcn_DataClean_plotStructureData(mergedData,plottingFlags);
fcn_DataClean_plotStructureData(mergedDataNoJumps,plottingFlags);
fcn_DataClean_plotStructureData(mergedByKFData,plottingFlags);

% The following function allows similar plots, made when there are repeated
% uncommented versions above, to all scroll/zoom in unison.
%fcn_plotAxesLinkedTogetherByField;

% Step 9: Lidar data process
mergedByKFData.Lidar = rawData.Lidar;


%% geoplot
figure(123)
clf
geoplot(mergedByKFData.GPS_Hemisphere.Latitude,mergedByKFData.GPS_Hemisphere.Longitude,'b', ...
    mergedByKFData.MergedGPS.latitude,mergedByKFData.MergedGPS.longitude,'r',...
    mergedDataNoJumps.MergedGPS.latitude,mergedDataNoJumps.MergedGPS.longitude,'g', 'LineWidth',2)

% geolimits([45 62],[-149 -123])
legend('mergedByKFData.GPS\_Hemisphere','mergedByKFData.MergedGPS','mergedDataNoJumps.MergedGPS')
geobasemap satellite
%geobasemap street
%% OLD STUFF

% %% Export results to Google Earth?
% %fcn_exportXYZ_to_GoogleKML(rawData.GPS_Hemisphere,'rawData_GPS_Hemisphere.kml');
% %fcn_exportXYZ_to_GoogleKML(mergedData.MergedGPS,'mergedData_MergedGPS.kml');
% fcn_exportXYZ_to_GoogleKML(mergedDataNoJumps.MergedGPS,[dir.datafiles 'mergedDataNoJumps_MergedGPS.kml']);
%
%
% %% Save cleaned data to .mat file
% % The following is not used
% newStr = regexprep(trip_name{1},'\s','_'); % replace whitespace with underscore
% newStr = strrep(newStr,'-','_');
% cleaned_fileName = [newStr,'_cleaned'];
% eval([cleaned_fileName,'=mergedByKFData'])
% save(strcat(dir.datafiles,cleaned_fileName,'.mat'),cleaned_fileName)

%
% fields = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% I99_Altoona33_to_StateCollege73 = rmfield(mergedByKFData.MergedGPS,fields);
% save('I99_Altoona33_to_StateCollege73_20210123.mat','I99_Altoona33_to_StateCollege73')
if trip_id_cleaned == 7
    fields_rm = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
    I99_StateCollege73_to_Altoona33 = rmfield(mergedByKFData.MergedGPS,fields_rm);
    save('I99_StateCollege73_to_Altoona33_20210123.mat','I99_StateCollege73_to_Altoona33')
    
    fields_rm = {'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
    I99_StateCollege73_to_Altoona33_mergedDataNoJumps = rmfield(mergedDataNoJumps.MergedGPS,fields_rm);
    I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station = [0; cumsum(sqrt(diff(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.xEast).^2+diff(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.yNorth).^2))];
    save('I99_StateCollege73_to_Altoona33_mergedDataNoJumps_20210123.mat','I99_StateCollege73_to_Altoona33_mergedDataNoJumps')
end

% extract TestTrack data
% fields = {'Yaw_deg';'Yaw_deg_Sigma';'velMagnitude_Sigma';'xEast_increments';'xEast_increments_Sigma';'yNorth_increments';'yNorth_increments_Sigma';'xEast_Sigma';'yNorth_Sigma';'zUp_Sigma';};
% TestTrack_all = rmfield(mergedByKFData.MergedGPS,fields);
% TestTrack_all_table = struct2table(TestTrack_all);
% TestTrack_table = TestTrack_all_table(6000:9398,:);
% TestTrack = table2struct(TestTrack_table,'ToScalar',true);
% save('TestTrack.mat','TestTrack')
%
% figure(1234)
% clf
% geoplot(TestTrack.latitude,TestTrack.longitude,'b', ...
% TestTrack.latitude(1),TestTrack.longitude(1),'r.',...
% TestTrack.latitude(end),TestTrack.longitude(end),'g.','LineWidth',2)
% % geolimits([45 62],[-149 -123])
% legend('Merged')
% geobasemap satellite

%%  Yaw Rate and Curvature Comparision
if 1 ==0
    [~, ~, ~, ~,R_spiral,UnitNormalV,concavity]=fnc_parallel_curve(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.xEast, I99_StateCollege73_to_Altoona33_mergedDataNoJumps.yNorth, 1, 0,1,100);
    
    yaw_rate = [0; diff(mergedDataNoJumps.MergedGPS.Yaw_deg)./diff(mergedDataNoJumps.MergedGPS.GPS_Time)];
    
    figure(23)
    clf
    hold on
    % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,I99_StateCollege73_to_Altoona33_mergedDataNoJumps.altitude)
    plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,mergedDataNoJumps.MergedGPS.Yaw_deg,'b','LineWidth',1)
    plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,yaw_rate,'r','LineWidth',1)
    
    grid on
    box on
    xlabel('station (m)')
    ylabel('yaw and yaw rate (deg)')
    % ylim([0 0.01])
    
    
    figure(24)
    clf
    hold on
    Ux = mergedDataNoJumps.GPS_Hemisphere.velEast.*cosd(mergedDataNoJumps.MergedGPS.Yaw_deg) + ...
        mergedDataNoJumps.GPS_Hemisphere.velNorth.*sind(mergedDataNoJumps.MergedGPS.Yaw_deg);
    plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,Ux,'b','LineWidth',1)
    plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,mergedDataNoJumps.GPS_Hemisphere.velNorth,'g')
    plot(mergedDataNoJumps.GPS_Hemisphere.GPS_Time,mergedDataNoJumps.GPS_Hemisphere.velEast,'r','LineWidth',1)
    
    % plot(mergedDataNoJumps.IMU_Novatel.GPS_Time,mergedDataNoJumps.IMU_Novatel.ZAccel,'b')
    grid on
    box on
    xlabel('time (s)')
    ylabel('velocity (m/s)')
    % ylim([0 0.01])
    
    curvature_ss  = (yaw_rate*pi/180)./Ux;
    
    figure(22)
    clf
    % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,I99_StateCollege73_to_Altoona33_mergedDataNoJumps.altitude)
    hold on
    % plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,curvature_ss,'g','LineWidth',1)
    plot(I99_StateCollege73_to_Altoona33_mergedDataNoJumps.station,abs(concavity).*1./R_spiral,'r','LineWidth',1)
    grid on
    box on
    xlabel('Station (m)')
    ylabel('Curvature')
    ylim([-0.01 0.04])
    
    
end
%% ======================= Insert Cleaned Data to 'mapping_van_cleaned' database =========================
% Input trips information

tripsInfo.id = trip_id_cleaned;
tripsInfo.vehicle_id = 1;
tripsInfo.base_stations_id = base_station.id;
tripsInfo.name = trip_name;
if trip_id_cleaned == 2
    
    tripsInfo.description = {'Test Track MappingVan night middle speed'};
    tripsInfo.date = {'2019-10-18 20:39:30'};
    tripsInfo.driver = {'Liming Gao'};
    tripsInfo.passengers = {'N/A'};
    tripsInfo.notes = {'without traffic light, at night. DGPS mode was activated. middle speed. 7 traversals'};
    cleanedData  = mergedDataNoJumps;
    
    start_point.start_longitude=-77.833842140800000;  %deg
    start_point.start_latitude =40.862636161300000;   %deg
    start_point.start_xEast=1345.204537286125; % meters
    start_point.start_yNorth=6190.884280063217; % meters
    
    start_point.end_longitude=-77.833842140800000;  %deg
    start_point.end_latitude =40.862636161300000;   %deg
    start_point.end_xEast=1345.204537286125; % meters
    start_point.end_yNorth=6190.884280063217; % meters
    
    start_point.start_yaw_angle = 37.38; %deg
    start_point.expectedRouteLength = 1555.5; % meters
    start_point.direction = 'CCW'; %
    cleanedData.start_point = start_point;
elseif trip_id_cleaned == 7
    
    tripsInfo.description = {'Map I99 from State College(exit 73) to Altoona (exit 33)'};
    tripsInfo.date = {'2021-01-23 15:00:00'};
    tripsInfo.driver = {'Wushuang Bai'};
    tripsInfo.passengers = {'Liming Gao'};
    tripsInfo.notes = {'Mapping from State College(exit 73) to Altoona (exit 33) through I-99. Lost DGPS mode when approaching Altoona. Drving on the right lane.'};
    cleanedData  = mergedByKFData;
elseif trip_id_cleaned == 8
    tripsInfo.description = {'Map I99 from Altoona (exit 33) to State College(exit 73)'};
    tripsInfo.date = {'2021-01-23 16:00:00'};
    tripsInfo.driver = {'Wushuang Bai'};
    tripsInfo.passengers = {'Liming Gao'};
    tripsInfo.notes = {'Mapping from Altoona (exit 33) to State College(exit 73) through I-99. Nexver lost DGPS mode except for passing below bridge or traffic sign. Drving on the right lane.'};
    cleanedData  = mergedByKFData;
else
    error("Wrong Trip ID");
end
% insert cleaned data
fcn_DataClean_insertCleanedData(cleanedData,rawData,tripsInfo,flag);
% save('cleanedData.mat','cleanedData')