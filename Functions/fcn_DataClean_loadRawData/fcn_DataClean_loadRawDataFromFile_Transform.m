function Transform_structure = fcn_DataClean_loadRawDataFromFile_Transform(file_path,datatype,flag_do_debug)

%% History
% Created by Xinyu Cao on 6/20/2023

%% Function 
% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the transform data
% Input Variables:
%      file_path = file path of the transform data (format csv)
%      datatype  = the datatype should be transform
% Returned Results:
%      Transform_structure
% For transform data, there is a problem during the parseing process need
% to be fixed. There is an offset between the column name and variables,
% thus Var1 to Var19 are used as column names.


if strcmp(datatype,'transform')
    opts = detectImportOptions(file_path);
    opts.PreserveVariableNames = true;
    datatable = readtable(file_path,opts);
    Npoints = height(datatable);
    Transform_structure = fcn_DataClean_initializeDataByType(datatype,Npoints);
    secs = datatable.Var6;
    nsecs = datatable.Var7;

    Transform_structure.GPS_Time           = secs + nsecs*10^-9;  % This is the GPS time, UTC, as reported by the unit
    % NTRIP_data_structure.Trigger_Time       = default_value;  % This is the Trigger time, UTC, as calculated by sample
    Transform_structure.ROS_Time           = datatable.Var1;  % This is the ROS time that the data arrived into the bag
%     Transform_structure.centiSeconds       = 10;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    Transform_structure.Npoints            = height(datatable);  % This is the number of data points in the array
    Transform_structure.XTranslation       = datatable.Var12;
    Transform_structure.YTranslation       = datatable.Var13;
    Transform_structure.ZTranslation       = datatable.Var14;
    Transform_structure.XRotation          = datatable.Var16;
    Transform_structure.YRotation          = datatable.Var17;
    Transform_structure.ZRotation          = datatable.Var18;
    Transform_structure.WRotation          = datatable.Var19;
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