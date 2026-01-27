function SparkFun_GPS_data_structure = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS_merge(file_path,datatype,flag_do_debug,topic_name)

% This function is used to load the raw data collected with the Penn State Mapping Van.

% This is the SparkFun GPS data, whose data type is gps
% Input Variables:
%      file_path = file path of the SparkFun GPS data,
%      datatype  = the datatype should be gps
%      topic_name = name of the topic
% Returned Results:
%      SparkFun_GPS_data_structure
% Author: Xinyu Cap
% Created Date: 2023_06_16
%
% Updates:
% 2023_06_26 - X. Cao
% -- Each sparkfun gps has three topics, sparkfun_gps_GGA, sparkfun_gps_VTG
% and sparkfun_gps_GST. An if else statement was added to load different
% topics.
% 2023_07_02 - X. Cao
% -- Merge three NMEA sentences into one 

% To do lists:
% 
% Reference:
% 


if strcmp(datatype,'gps')
%   The measurement frequency of the SparkFun GPS is 10Hz, so the
%   centisecond is 10
    centiSeconds = 10;
    tolerance = centiSeconds*0.5;
    share_file_path = extractBefore(file_path,"GGA");
    GGA_file_path = file_path; % File path contains GGA message
    VTG_file_path = share_file_path + "VTG"; % File path contains VTG message
    GST_file_path = share_file_path + "GST"; % File path contains GST message

    GGA_opts = detectImportOptions(GGA_file_path);
    GGA_opts.PreserveVariableNames = true;
    GGA_datatable = readtable(GGA_file_path,GGA_opts);
    GGA_Npoints = height(GGA_datatable);
    
    VTG_opts = detectImportOptions(VTG_file_path);
    VTG_opts.PreserveVariableNames = true;
    VTG_datatable = readtable(VTG_file_path,VTG_opts);
    VTG_Npoints = height(VTG_datatable);

    GST_opts = detectImportOptions(GST_file_path);
    GST_opts.PreserveVariableNames = true;
    GST_datatable = readtable(GST_file_path,GST_opts);
    GST_Npoints = height(GST_datatable);
    Npoints = max(GGA_Npoints,VTG_Npoints,GST_Npoints);
    
%   

%   Use GGA_ROStime as a reference, time difference within the same
%   tolernace will be saved in the same row.

%   GGA message is the main message we are tracking, so fill the fields
%   belonging to NMEA GGA first

    SparkFun_GPS_data_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    GGA_GPSsecs = GGA_datatable.GPSSecs; % For data collected after 2023-06-06, new fields GPSSecs are added
    GGA_GPSmicrosecs = GGA_datatable.GPSMicroSecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added
    GGA_GPSTime = GGA_GPSsecs + GGA_GPSmicrosecs*10^(-9);
    GGA_ROSsecs = GGA_datatable.secs;
    GGA_ROSnsecs = GGA_datatable.nsecs;
    GGA_ROSTime = GGA_ROSsecs + GGA_ROSnsecs*10^(-9);

    
    SparkFun_GPS_data_structure.GPS_Time           = GGA_GPSsecs + GGA_GPSmicrosecs*10^-6;  % This is the GPS time, UTC, as reported by the unit
    % SparkFun_GPS_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    SparkFun_GPS_data_structure.ROS_Time           = GGA_ROSTime;  % This is the ROS time that the data arrived into the bag
    SparkFun_GPS_data_structure.centiSeconds       = centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    SparkFun_GPS_data_structure.Npoints            = GGA_Npoints;  % This is the number of data points in the array
    SparkFun_GPS_data_structure.Latitude           = GGA_datatable.Latitude;  % The latitude [deg]
    SparkFun_GPS_data_structure.Longitude          = GGA_datatable.Longitude;  % The longitude [deg]
    SparkFun_GPS_data_structure.Altitude           = GGA_datatable.Altitude;  % The altitude above sea level [m]
    SparkFun_GPS_data_structure.GeoSep             = GGA_datatable.GeoSep;    %
    % SparkFun_GPS_data_structure.xEast = default_value;
    % SparkFun_GPS_data_structure.xEast_Sigma        = default_value;  % Sigma in xEast [m]
    % SparkFun_GPS_data_structure.yNorth = default_value;
    % SparkFun_GPS_data_structure.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
    % SparkFun_GPS_data_structure.zUp = default_value;
    % SparkFun_GPS_data_structure.zUp_Sigma          = default_value;  % Sigma in zUp [m]

    % SparkFun_GPS_data_structure.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
    % SparkFun_GPS_data_structure.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
    % SparkFun_GPS_data_structure.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
    % SparkFun_GPS_data_structure.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
    % SparkFun_GPS_data_structure.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
    % SparkFun_GPS_data_structure.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
    % SparkFun_GPS_data_structure.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s]
    % SparkFun_GPS_data_structure.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
    SparkFun_GPS_data_structure.numSatellites      = GGA_datatable.NumOfSats;  % Number of satelites visible
    SparkFun_GPS_data_structure.DGPS_mode          = GGA_datatable.LockStatus;  % Mode indicating DGPS status (for example, navmode 6;
    % SparkFun_GPS_data_structure.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
    % SparkFun_GPS_data_structure.Roll_deg_Sigma     = default_value;  % Sigma in Roll
    % SparkFun_GPS_data_structure.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
    % SparkFun_GPS_data_structure.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
    % SparkFun_GPS_data_structure.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
    % SparkFun_GPS_data_structure.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
    % SparkFun_GPS_data_structure.OneSigmaPos        = default_value;  % Sigma in position
    SparkFun_GPS_data_structure.HDOP               = GGA_datatable.HDOP; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
    SparkFun_GPS_data_structure.AgeOfDiff          = GGA_datatable.AgeOfDiff;  % Age of correction data [s]
    % Event functions
    % dataStructure.EventFunctions = {}; % These are the functions to determine if something went wrong

%   For other NMEA GST message, fill the GST data according to the GPS time
    GST_GPSsecs = GST_datatable.GPSSecs; % For data collected after 2023-06-06, new fields GPSSecs are added
    GST_GPSmicrosecs = GST_datatable.GPSMicroSecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added
    GST_GPSTime = GST_GPSsecs + GST_GPSmicrosecs*10^(-6);


    GPSTime_diff_GGA_GST = GST_GPSTime - 
    SparkFun_GPS_data_structure.GPS_Time           = GGA_GPSsecs + GST_GPSmicrosecs*10^-6;  % This is the GPS time, UTC, as reported by the unit
    VTG_ROSsecs = VTG_datatable.secs;
    VTG_ROSnsecs = VTG_datatable.nsecs;
    VTG_ROStime = VTG_ROSsecs + VTG_ROSnsecs*10^(-9);

    GST_ROSsecs = GST_datatable.secs;
    GST_ROSnsecs = GST_datatable.nsecs;
    GST_ROStime = GST_ROSsecs + GST_ROSnsecs*10^(-9);




    if contains(topic_name,"GGA")

        GGA_GPSsecs = datatable.GPSSecs; % For data collected after 2023-06-06, new fields GPSSecs are added
        GGA_GPSmicrosecs = datatable.GPSMicroSecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added
    
        SparkFun_GPS_data_structure.GPS_Time           = GGA_GPSsecs + GGA_GPSmicrosecs*10^-6;  % This is the GPS time, UTC, as reported by the unit
        % SparkFun_GPS_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        SparkFun_GPS_data_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
        SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        SparkFun_GPS_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
        SparkFun_GPS_data_structure.Latitude           = datatable.Latitude;  % The latitude [deg]
        SparkFun_GPS_data_structure.Longitude          = datatable.Longitude;  % The longitude [deg]
        SparkFun_GPS_data_structure.Altitude           = datatable.Altitude;  % The altitude above sea level [m]
        SparkFun_GPS_data_structure.GeoSep             = datatable.GeoSep;    % 
        % SparkFun_GPS_data_structure.xEast = default_value;
        % SparkFun_GPS_data_structure.xEast_Sigma        = default_value;  % Sigma in xEast [m]
        % SparkFun_GPS_data_structure.yNorth = default_value;
        % SparkFun_GPS_data_structure.yNorth_Sigma       = default_value;  % Sigma in yNorth [m]
        % SparkFun_GPS_data_structure.zUp = default_value;
        % SparkFun_GPS_data_structure.zUp_Sigma          = default_value;  % Sigma in zUp [m]

        % SparkFun_GPS_data_structure.velNorth           = default_value;  % Velocity in north direction (ENU) [m/s]
        % SparkFun_GPS_data_structure.velNorth_Sigma     = default_value;  % Sigma in velNorth [m/s]
        % SparkFun_GPS_data_structure.velEast            = default_value;  % Velocity in east direction (ENU) [m/s]
        % SparkFun_GPS_data_structure.velEast_Sigma      = default_value;  % Sigma in velEast [m/s]
        % SparkFun_GPS_data_structure.velUp              = default_value;  % Velocity in up direction (ENU) [m/s]
        % SparkFun_GPS_data_structure.velUp_Sigma        = default_value;  % Velocity in up direction (ENU) [m/s]
        % SparkFun_GPS_data_structure.velMagnitude       = default_value;  % Velocity magnitude (ENU) [m/s]
        % SparkFun_GPS_data_structure.velMagnitude_Sigma = default_value;  % Sigma in velMagnitude [m/s]
        SparkFun_GPS_data_structure.numSatellites      = datatable.NumOfSats;  % Number of satelites visible
        SparkFun_GPS_data_structure.DGPS_mode          = datatable.LockStatus;  % Mode indicating DGPS status (for example, navmode 6;
        % SparkFun_GPS_data_structure.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
        % SparkFun_GPS_data_structure.Roll_deg_Sigma     = default_value;  % Sigma in Roll
        % SparkFun_GPS_data_structure.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
        % SparkFun_GPS_data_structure.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
        % SparkFun_GPS_data_structure.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
        % SparkFun_GPS_data_structure.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
        % SparkFun_GPS_data_structure.OneSigmaPos        = default_value;  % Sigma in position
        SparkFun_GPS_data_structure.HDOP               = datatable.HDOP; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
        SparkFun_GPS_data_structure.AgeOfDiff          = datatable.AgeOfDiff;  % Age of correction data [s]
    % Event functions
    % dataStructure.EventFunctions = {}; % These are the functions to determine if something went wrong
     %rawdata.SparkFun_GPS_RearLeft = SparkFun_GPS_RearLeft;

        
    elseif contains(topic_name,"VTG")
        SparkFun_GPS_data_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
        SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        SparkFun_GPS_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
        SparkFun_GPS_data_structure.SpdOverGrndKmph    = datatable.SpdOverGrndKmph;
    elseif contains(topic_name,"GST")
        GGA_GPSsecs = datatable.GPSSecs; % For data collected after 2023-06-06, new fields GPSSecs are added
        GGA_GPSmicrosecs = datatable.GPSMicroSecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added
    
        SparkFun_GPS_data_structure.GPS_Time           = GGA_GPSsecs + GGA_GPSmicrosecs*10^-6;  % This is the GPS time, UTC, as reported by the unit
        % SparkFun_GPS_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        SparkFun_GPS_data_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
        SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        SparkFun_GPS_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
        SparkFun_GPS_data_structure.StdLat             = datatable.StdLat;
        SparkFun_GPS_data_structure.StdLon             = datatable.StdLon;
        SparkFun_GPS_data_structure.StdAlt             = datatable.StdAlt;
    end
        
else
    error('Wrong data type requested: %s',dataType)
end

clear datatable %clear temp variable

% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return