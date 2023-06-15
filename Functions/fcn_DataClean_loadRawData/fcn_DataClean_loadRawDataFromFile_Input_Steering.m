function Input_Steering = fcn_DataClean_loadRawDataFromFile_Input_Steering(d,data_source,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Input_Steering data
% Input Variables:
%      d = raw data from Input_Steering(format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
%
% Returned Results:
%      Input_Steering
% Author: Liming Gao
% Created Date: 2020_12_07
%
% Modified by Aneesh Batchu and Mariam Abdellatief on 2023_06_13
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
% Updates:
%
% To do lists:
% 1.
%
%

%%

% the field name from mat_file is different from database, so we process
% them seperately
if strcmp(data_source,'mat_file')
    Input_Steering.ROS_Time        = d.Time';
    Input_Steering.centiSeconds    = 1; % This is sampled every 1 ms
    Input_Steering.Npoints         = length(Input_Steering.ROS_Time(:,1));
    Input_Steering.EmptyVector     = fcn_DataClean_fillEmptyStructureVector(Input_Steering); % Fill in empty vector (this is useful later)
    %Input_Steering.GPS_Time        = Input_Steering.EmptyVector;
    Input_Steering.deltaT_ROS      = mean(diff(Input_Steering.ROS_Time));
    %Input_Steering.deltaT_GPS      = mean(diff(Input_Steering.GPS_Time));
    Input_Steering.LeftAngle       = -1*d.LeftAngle;
    Input_Steering.RightAngle      = 1*d.RightAngle;
    Input_Steering.Angle           = d.Angle;
    Input_Steering.LeftCountsFilt  = d.LeftCountsFiltered;
    Input_Steering.RightCountsFilt = d.RightCountsFiltered;
else
    error('Please indicate the data source')
end

clear d; %clear temp variable

% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
