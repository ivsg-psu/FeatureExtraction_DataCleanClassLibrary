function SparkFun_GPS_data_structure = fcn_DataClean_loadRawDataFromDB_Sparkfun_GPS(field_data_struct,datatype,field_name,fid)
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


flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

if strcmp(datatype,'gps')
    SparkFun_GPS_data_structure = fcn_DataClean_initializeDataByType(datatype);
    if isempty(field_data_struct.id)
        warning(field_name + 'table is empty!')
    else
        if contains(field_name,"GGA")

            secs = field_data_struct.gpssecs; % For data collected after 2023-06-06, new fields GPSSecs are added
            microsecs = field_data_struct.gpsmicrosecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added

            SparkFun_GPS_data_structure.GPS_Time           = secs + microsecs*10^-6;  % This is the GPS time, UTC, as reported by the unit
            % SparkFun_GPS_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            SparkFun_GPS_data_structure.ROS_Time           = field_data_struct.time;  % This is the ROS time that the data arrived into the bag
            SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            SparkFun_GPS_data_structure.Npoints            = length(field_data_struct.id);  % This is the number of data points in the array
            SparkFun_GPS_data_structure.Latitude           = field_data_struct.latitude;  % The latitude [deg]
            SparkFun_GPS_data_structure.Longitude          = field_data_struct.longitude;  % The longitude [deg]
            SparkFun_GPS_data_structure.Altitude           = field_data_struct.altitude;  % The altitude above sea level [m]
            SparkFun_GPS_data_structure.GeoSep             = field_data_struct.geosep;    %
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
            SparkFun_GPS_data_structure.numSatellites      = field_data_struct.numofsats;  % Number of satelites visible
            SparkFun_GPS_data_structure.DGPS_mode          = field_data_struct.lockstatus;  % Mode indicating DGPS status (for example, navmode 6;
            % SparkFun_GPS_data_structure.Roll_deg           = default_value;  % Roll (angle about X) in degrees, ISO coordinates
            % SparkFun_GPS_data_structure.Roll_deg_Sigma     = default_value;  % Sigma in Roll
            % SparkFun_GPS_data_structure.Pitch_deg          = default_value;  % Pitch (angle about y) in degrees, ISO coordinates
            % SparkFun_GPS_data_structure.Pitch_deg_Sigma    = default_value;  % Sigma in Pitch
            % SparkFun_GPS_data_structure.Yaw_deg            = default_value;  % Yaw (angle about z) in degrees, ISO coordinates
            % SparkFun_GPS_data_structure.Yaw_deg_Sigma      = default_value;  % Sigma in Yaw
            % SparkFun_GPS_data_structure.OneSigmaPos        = default_value;  % Sigma in position
            SparkFun_GPS_data_structure.HDOP               = field_data_struct.hdop; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
            SparkFun_GPS_data_structure.AgeOfDiff          = field_data_struct.ageofdiff;  % Age of correction data [s]
            % Event functions
            % dataStructure.EventFunctions = {}; % These are the functions to determine if something went wrong
            %rawdata.SparkFun_GPS_RearLeft = SparkFun_GPS_RearLeft;
        elseif contains(field_name,"VTG")
            SparkFun_GPS_data_structure.ROS_Time           = field_data_struct.time;  % This is the ROS time that the data arrived into the bag
            SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            SparkFun_GPS_data_structure.Npoints            = length(field_data_struct.id);  % This is the number of data points in the array
            SparkFun_GPS_data_structure.SpdOverGrndKmph    = field_data_struct.spdovergrndkmph;
        elseif contains(field_name,"GST")
            secs = field_data_struct.gpssecs; % For data collected after 2023-06-06, new fields GPSSecs are added
            microsecs = field_data_struct.gpsmicrosecs; % For data collected after 2023-06-06, new fields GPSMicroSecs are added

            SparkFun_GPS_data_structure.GPS_Time           = secs + microsecs*10^-6;  % This is the GPS time, UTC, as reported by the unit
            % SparkFun_GPS_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            SparkFun_GPS_data_structure.ROS_Time           = field_data_struct.time;  % This is the ROS time that the data arrived into the bag
            SparkFun_GPS_data_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            SparkFun_GPS_data_structure.Npoints            = length(field_data_struct.id);  % This is the number of data points in the array
            SparkFun_GPS_data_structure.StdLat             = field_data_struct.stdlat;
            SparkFun_GPS_data_structure.StdLon             = field_data_struct.stdlon;
            SparkFun_GPS_data_structure.StdAlt             = field_data_struct.stdalt;
        end
    end
        
else
    error('Wrong data type requested: %s',dataType)
end


% Close out the loading process
if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end