%% History
% Created by Mariam Abdellatief on 6/15/2023

%% Function 
% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Hemisphere data
% Input Variables:
%      data_structure = raw data from Sparkfun GPS (format:struct)
%      data_source = mat_file
% Returned Results:
%      diagnostic_trigger

function diagnostic_trigger = fcn_DataClean_loadRawData_diagnostic_trigger(data_structure,data_source)

if strcmp(data_source,'mat_file')
    diagnostic_trigger.rosbagTimestamp  = data_structure.Time';
    diagnostic_trigger.data             = data_structure.data; 
else
    error('Please upload data structure in ".mat" format or speify data source')
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