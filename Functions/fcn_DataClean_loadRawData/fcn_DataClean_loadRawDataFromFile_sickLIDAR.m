function sickLIDAR = fcn_DataClean_loadRawDataFromFile_sickLIDAR(data_structure,data_source,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Hemisphere DGPS(format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
% Returned Results:
%      Hemisphere
% Author: Liming Gao
% Created Date: 2020_11_15
% Modify Date: 2019_11_22
%
% Modified by Aneesh Batchu on 2023_06_13
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 1. check if it is reasonable for the calcualtion of Hemisphere.velMagnitude_Sigma
% 
%%

if strcmp(data_source,'mat_file')
    sickLIDAR.Sequence         = data_structure.Sequence;
    sickLIDAR.sec              = data_structure.sec;
    sickLIDAR.nsec             = data_structure.nsec;
    
    sickLIDAR.angle_min        = data_structure.angle_min;
    sickLIDAR.angle_max        = data_structure.angle_max;
    sickLIDAR.angle_increment  = data_structure.angle_increment;
    sickLIDAR.time_increment   = data_structure.time_increment;
    sickLIDAR.scan_time        = data_structure.scan_time;
    sickLIDAR.range_min        = data_structure.range_min;
    sickLIDAR.range_max        = data_structure.range_max;
    sickLIDAR.ranges           = data_structure.ranges;
    sickLIDAR.intensities      = data_structure.intensities;

else
    error('Please indicate the data source')
end



clear data_structure %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return