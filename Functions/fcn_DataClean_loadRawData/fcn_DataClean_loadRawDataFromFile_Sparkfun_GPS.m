function SparkFun_GPS_data_structure = fcn_DataClean_loadRawDataFromFile_Sparkfun_GPS(file_path,datatype,fid,topic_name)
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

% Updates:
% 2023_06_26 - X. Cao
% -- Each sparkfun gps has three topics, sparkfun_gps_GGA, sparkfun_gps_VTG
% and sparkfun_gps_GST. An if else statement was added to load different
% topics.
% 2023_07_04 sbrennan@psu.edu
% -- fixed return at end of function to be 'end', keeping in function
% format
% -- added fid to fprint to allow printing to file
% -- added entry and exit debugging prints
% -- removed variable clearing at end of function because this is automatic
% 2024_09_15 xfc5113@psu.edu
% -- added Trigger_Time field for VTG messages


flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

if strcmp(datatype,'gps')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    % Npoints = height(datatable);
    % SparkFun_GPS_data_structure = struct; % fcn_DataClean_initializeDataByType(datatype,Npoints);
    
    if contains(topic_name,"GGA")
        SparkFun_GPS_data_structure = fcn_DataClean_initializeDataByType(datatype);
        GPSsecs = datatable.GPSSecs; % For data collected after 2023-06-06, new fields GPSSecs are added
        GPSmicrosecs = datatable.GPSMicroSecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added
        time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp
        

        
        SparkFun_GPS_data_structure.GPS_Time     = GPSsecs + GPSmicrosecs*10^-6;  % This is the GPS time, UTC, as reported by the unit

        
        % FOR DEBUGGING:
        % fprintf(1,'GPS microseconds:\n');
        % format long
        % disp(GPSmicrosecs(1:20,1));
        
        SparkFun_GPS_data_structure.Bag_Time           = time_stamp;  % This is the ROS time that the data arrived into the bag
        SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        % SparkFun_GPS_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
        header_time_secs = datatable.secs;
        header_time_nsecs = datatable.nsecs;
        header_time = header_time_secs + header_time_nsecs*(1E-9);
        SparkFun_GPS_data_structure.ROS_Time       = header_time; % This is the ROS_Time when the message generated
        
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
        % time_diff = time_stamp - SparkFun_GPS_data_structure.ROS_Time;
        SparkFun_GPS_data_structure.HDOP               = datatable.HDOP; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
        SparkFun_GPS_data_structure.AgeOfDiff          = datatable.AgeOfDiff;  % Age of correction data [s]
        
        % Event functions
    % dataStructure.EventFunctions = {}; % These are the functions to determine if something went wrong
     %rawdata.SparkFun_GPS_RearLeft = SparkFun_GPS_RearLeft;
    elseif contains(topic_name,"VTG")
        SparkFun_GPS_data_structure = struct;

        time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp
  
        SparkFun_GPS_data_structure.Trigger_Time       = nan;
        SparkFun_GPS_data_structure.ROS_Time           = time_stamp;
        SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        % SparkFun_GPS_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
        SparkFun_GPS_data_structure.SpdOverGrndKmph    = datatable.SpdOverGrndKmph;
    elseif contains(topic_name,"GST")
        SparkFun_GPS_data_structure = struct;
        GPSsecs = datatable.GPSSecs; % For data collected after 2023-06-06, new fields GPSSecs are added
        GPSmicrosecs = datatable.GPSMicroSecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added
        time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp
        SparkFun_GPS_data_structure.GPS_Time           = GPSsecs + GPSmicrosecs*10^-6;  % This is the GPS time, UTC, as reported by the unit
        % SparkFun_GPS_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
        SparkFun_GPS_data_structure.ROS_Time           = time_stamp;
        SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
        % SparkFun_GPS_data_structure.Npoints            = height(datatable);  % This is the number of data points in the array
        SparkFun_GPS_data_structure.StdLat             = datatable.StdLat;
        SparkFun_GPS_data_structure.StdLon             = datatable.StdLon;
        SparkFun_GPS_data_structure.StdAlt             = datatable.StdAlt;
    elseif contains(topic_name,"PVT")
        SparkFun_GPS_data_structure = fcn_DataClean_initializeDataByType(datatype);
        time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp
        SparkFun_GPS_data_structure.ROS_Time = time_stamp;
        SparkFun_GPS_data_structure.iTOW = datatable.iTOW; % GPS Millisecond time of week [ms]
        SparkFun_GPS_data_structure.Year = datatable.year;
        SparkFun_GPS_data_structure.Month = datatable.month;
        SparkFun_GPS_data_structure.Day = datatable.day;
        SparkFun_GPS_data_structure.Hour = datatable.hour;
        SparkFun_GPS_data_structure.Minute = datatable.min;
        SparkFun_GPS_data_structure.Second = datatable.sec;
        SparkFun_GPS_data_structure.Valid = datatable.valid; % Validity flags, need to check later, might be a structure contain differnet flags
        SparkFun_GPS_data_structure.timeAccuracy = datatable.tAcc; % time accuracy estimate [ns] (UTC)
        SparkFun_GPS_data_structure.nanoSecs = datatable.nano;
        % Calculate GPS time in second, the actual GPS epoch is 1980/01/06,
        % use 1970/01/01 here to have the same time line with UTC Time
        % (Need to discuss)
        gps_epoch = datetime(1970,1,1,0,0,0,'TimeZone','UTC');
        current_utc_time = datetime(datatable.year, datatable.month, datatable.day, datatable.hour, datatable.min, datatable.sec, 'TimeZone', 'UTC');
        elapsed_seconds = seconds(current_utc_time - gps_epoch);
        GPS_TimeSeconds = elapsed_seconds;
        SparkFun_GPS_data_structure.GPS_Time = GPS_TimeSeconds+SparkFun_GPS_data_structure.nanoSecs*(10^-9);
        SparkFun_GPS_data_structure.fixType = datatable.fixType; % DGPS Mode, need to discuss whether we want to use our standard
        SparkFun_GPS_data_structure.flags = datatable.flags; %
        SparkFun_GPS_data_structure.flags2 = datatable.flags2;
        SparkFun_GPS_data_structure.numSatellites = datatable.numSV;
        SparkFun_GPS_data_structure.Latitude     = datatable.lat;  % The latitude [deg/1e-7]
        SparkFun_GPS_data_structure.Longitude    = datatable.lon;  % The longitude [deg/1e-7]
        SparkFun_GPS_data_structure.Altitude     = datatable.height;  % The altitude above Ellipsoid [mm]
        SparkFun_GPS_data_structure.HightAboveSea  = datatable.hMSL;  % The altitude above sea level [mm]
        SparkFun_GPS_data_structure.HonAccuracyEst   = datatable.hAcc;  % Horizontal accuracy estimate [mm]
        SparkFun_GPS_data_structure.VerAccuracyEst    = datatable.vAcc;  % Vertical accuracy estimate [mm]
        SparkFun_GPS_data_structure.velEast    = datatable.velE;  % NED East Velocity [mm/s]
        SparkFun_GPS_data_structure.velNorth    = datatable.velN;  % NED North Velocity [mm/s]
        SparkFun_GPS_data_structure.velDown    = datatable.vAcc;  % NED Down Velocity [mm/s]
        SparkFun_GPS_data_structure.goundSpeed  = datatable.gSpeed;  % Ground Speed [mm/s]
        SparkFun_GPS_data_structure.headingMotion    = datatable.heading;  % Heading of motion [deg /1e-5]
        SparkFun_GPS_data_structure.SpeedAccuracyEst    = datatable.sAcc;  % Speed accuracy estimate [mm/s]
        SparkFun_GPS_data_structure.HeadingAccuracyEst    = datatable.headAcc;  % Heading accuracy estimate [deg /1e-5]
        SparkFun_GPS_data_structure.PDOP  = datatable.pDOP;  % Position DOP [1/0.01]

        SparkFun_GPS_data_structure.reserved = datatable.reserved1; % Reserved (Don't understand)
        SparkFun_GPS_data_structure.headingVehicle = datatable.headVeh; % Heading of vehicle [deg/1e-5]
        SparkFun_GPS_data_structure.MagneticDec = datatable.magDec; % # Magnetic declination [deg/1e-2]
        SparkFun_GPS_data_structure.MagneticAccuracyEst = datatable.magAcc; % Magnetic declination accuracy [deg 1e-2]
    end
        
else
    error('Wrong data type requested: %s',dataType)
end


% Close out the loading process
if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end