function ROSLog_structure = fcn_DataClean_loadRawDataFromFile_ROSOut(file_path,datatype,flag_do_debug)

%% History
% Created by Xinyu Cao on 6/20/2023

%% Function 
% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the ROS log message
% Input Variables:
%      file_path = file path of the transform data (format csv)
%      datatype  = the datatype should be rosout
% Returned Results:
%      ROSLog_structure
% Warning: The 'frame_id' field is empty in the parsed csv file, which
% results in a format error with detectImportOptions and readtable, manualy
% filled the field in the csv file and the function is working. 
% This function is commented out from the
% fcn_DataClean_loadMappingVanDataFromFile.m


if strcmp(datatype,'rosout')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    Npoints = height(datatable);
    ROSLog_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    secs = datatable.secs;
    nsecs = datatable.nsecs;

    ROSLog_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % NTRIP_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    ROSLog_structure.ROS_Time           = datatable.rosbagTimestamp;  % This is the ROS time that the data arrived into the bag
    ROSLog_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    ROSLog_structure.Npoints            = height(datatable);  % This is the number of data points in the array
    ROSLog_structure.Seq                = datatable.seq;
    ROSLog_structure.Level              = datatable.level;
    ROSLog_structure.msg                = datatable.msg;
    ROSLog_structure.file               = datatable.file;
    ROSLog_structure.function           = datatable.function;
    ROSLog_structure.line               = datatable.line;
    ROSLog_structure.topics             = datatable.topics;
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