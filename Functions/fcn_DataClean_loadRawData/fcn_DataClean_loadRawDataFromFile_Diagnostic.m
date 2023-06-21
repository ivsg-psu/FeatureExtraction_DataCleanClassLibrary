function diagnostic_structure = fcn_DataClean_loadRawDataFromFile_Diagnostic(file_path,datatype,flag_do_debug,topic_name)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the parse diagnostic data, whose data type is diagnostic
% Input Variables:
%      file_path = file path of the diagnostic data
%      datatype  = the datatype should be diagnostic
% Returned Results:
%      diagnostic_structure

% Author: Liming Gao
% Created Date: 2020_11_15
% Modify Date: 2023_06_16
%
% Modified by Xinyu Cao, Aneesh Batchu and Mariam Abdellatief on 2023_06_16
% 
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 
% Reference:
% 
%%
if strcmp(datatype, 'diagnostic')
    
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    Npoints = height(datatable);
    diagnostic_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    switch topic_name
        case '/diagnostic_trigger'
            % secs = datatable.secs;
            % nsecs = datatable.nsecs;
            % diagnostic_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % diagnostic_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            diagnostic_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % diagnostic_structure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            diagnostic_structure.Npoints            = height(datatable);  % This is the number of data points in the array
            diagnostic_structure.Seq                = datatable.data; 

        case '/diagnostic_encoder'
            % secs = datatable.secs;
            % nsecs = datatable.nsecs;
            % diagnostic_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % diagnostic_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            diagnostic_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % diagnostic_structure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            diagnostic_structure.Npoints            = height(datatable);  % This is the number of data points in the array
            diagnostic_structure.Seq                = datatable.data; 
  
        case '/sparkfun_gps_diag_rear_left'
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            diagnostic_structure.GPS_Time    = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            diagnostic_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            diagnostic_structure.Npoints            = height(datatable);  % This is the number of data points in the array
            % Data related to trigger box and encoder box
            diagnostic_structure.Seq                = datatable.seq;  % This is the sequence of the topic
            % Data related to SparkFun GPS Diagnostic
            diagnostic_structure.DGPS_mode          = datatable.LockStatus;  % Mode indicating DGPS status (for example, navmode 6)
            diagnostic_structure.numSatellites      = datatable.NumOfSats;  % Number of satelites visible
            diagnostic_structure.BaseStationID      = datatable.BaseStationID;  % Base station that was used for correction
            diagnostic_structure.HDOP               = datatable.HDOP; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
            diagnostic_structure.AgeOfDiff          = datatable.AgeOfDiff;  % Age of correction data [s]
            diagnostic_structure.NTRIP_Status       = datatable.NTRIP_Status;  % The status of NTRIP connection (Ture, conencted, False, disconencted)

        case '/sparkfun_gps_diag_rear_right'
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            diagnostic_structure.GPS_Time    = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            diagnostic_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
            % dataStructure.centiSeconds       = default_value;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            diagnostic_structure.Npoints            = height(datatable);  % This is the number of data points in the array
            % Data related to trigger box and encoder box
            diagnostic_structure.Seq                = datatable.seq;  % This is the sequence of the topic
            % Data related to SparkFun GPS Diagnostic
            diagnostic_structure.DGPS_mode          = datatable.LockStatus;  % Mode indicating DGPS status (for example, navmode 6)
            diagnostic_structure.numSatellites      = datatable.NumOfSats;  % Number of satelites visible
            diagnostic_structure.BaseStationID      = datatable.BaseStationID;  % Base station that was used for correction
            diagnostic_structure.HDOP               = datatable.HDOP; % DOP in horizontal position (ratio, usually close to 1, smaller is better)
            diagnostic_structure.AgeOfDiff          = datatable.AgeOfDiff;  % Age of correction data [s]
            diagnostic_structure.NTRIP_Status       = datatable.NTRIP_Status;  % The status of NTRIP connection (Ture, conencted, False, disconencted)
   
        otherwise
            error('Unrecognized topic requested: %s',topic_name)
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
