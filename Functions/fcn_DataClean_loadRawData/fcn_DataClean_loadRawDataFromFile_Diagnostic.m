function diagnostic_structure = fcn_DataClean_loadRawDataFromFile_Diagnostic(file_path,datatype,fid,topic_name)

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
% 2023_06_26 - X. Cao
% -- The old diagnostic topics 'diagnostic_trigger' and
% 'diagnostic_encoder' are replaced with 'Trigger_diag' and 'Encoder_diag'
% 2023_06_29 - S. Brennan
% -- fixed bug where centiSeconds is being filled with NaNs
% 2023_07_04 sbrennan@psu.edu
% -- fixed return at end of function to be 'end', keeping in function
% format
% -- added fid to fprint to allow printing to file

% To do lists:
% 
% Reference:
% 



flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


%%
if strcmp(datatype, 'diagnostic')
    
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    Npoints = height(datatable);
    diagnostic_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    switch topic_name
        case '/Trigger_diag'
            time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            % diagnostic_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % diagnostic_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            % diagnostic_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
            diagnostic_structure.ROS_Time           = time_stamp;
            diagnostic_structure.centiSeconds       = 100;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            % diagnostic_structure.Npoints            = height(datatable);  % This is the number of data points in the array
            diagnostic_structure.Seq                = datatable.seq;
            diagnostic_structure.err_failed_mode_count             = datatable.err_failed_mode_count; 
            diagnostic_structure.err_failed_checkInformation       = datatable.err_failed_checkInformation;
            diagnostic_structure.err_failed_XI_format              = datatable.err_failed_XI_format;
            diagnostic_structure.err_trigger_unknown_error_occured = datatable.err_trigger_unknown_error_occured;
            diagnostic_structure.err_bad_uppercase_character       = datatable.err_bad_uppercase_character;
            diagnostic_structure.err_bad_lowercase_character       = datatable.err_bad_lowercase_character;
            diagnostic_structure.err_bad_three_adj_element         = datatable.err_bad_three_adj_element;
            diagnostic_structure.err_bad_first_element             = datatable.err_bad_first_element;
            diagnostic_structure.err_bad_character                 = datatable.err_bad_character;
            diagnostic_structure.err_wrong_element_length          = datatable.err_wrong_element_length;

        case '/Encoder_diag'
            time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            % diagnostic_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % diagnostic_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            % diagnostic_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
            diagnostic_structure.ROS_Time           = time_stamp;
            diagnostic_structure.centiSeconds       = 1;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)            
            % diagnostic_structure.Npoints            = height(datatable);  % This is the number of data points in the array
            diagnostic_structure.Seq                = datatable.seq;
            diagnostic_structure.err_wrong_element_length_encoder  = datatable.err_wrong_element_length;
            diagnostic_structure.err_bad_element_structure         = datatable.err_bad_element_structure;
            diagnostic_structure.err_failed_time                   = datatable.err_failed_time;
            diagnostic_structure.err_bad_uppercase_character_encoder = datatable.err_bad_uppercase_character; 
            diagnostic_structure.err_bad_lowercase_character_encoder = datatable.err_bad_lowercase_character; 
            diagnostic_structure.err_bad_character_encoder           = datatable.err_bad_character;
  
        case '/sparkfun_gps_diag_rear_left'
            time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            % diagnostic_structure.GPS_Time    = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            % diagnostic_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
            diagnostic_structure.ROS_Time           = time_stamp;
            diagnostic_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            % diagnostic_structure.Npoints            = height(datatable);  % This is the number of data points in the array
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
            time_stamp = (datatable.rosbagTimestamp)*10^-9; % This is rosbag timestamp
            secs = datatable.secs;
            nsecs = datatable.nsecs;
            % diagnostic_structure.GPS_Time    = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
            % dataStructure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
            diagnostic_structure.ROS_Time           = secs + nsecs*10^-9;  % This is the ROS time that the data arrived into the bag
            diagnostic_structure.ROS_Time           = time_stamp;
            diagnostic_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
            % diagnostic_structure.Npoints            = height(datatable);  % This is the number of data points in the array
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

% Close out the loading process
if flag_do_debug
    fprintf(fid,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end
