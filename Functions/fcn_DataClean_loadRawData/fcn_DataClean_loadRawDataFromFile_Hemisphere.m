function Hemisphere = fcn_DataClean_loadRawDataFromFile_Hemisphere(data_structure,data_source,flag_do_debug)

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
% Modified by Aneesh Batchu and Mariam Abdellatief on 2023_06_13
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

% the field name from mat_file is different from database, so we process
% them seperately
if strcmp(data_source,'mat_file')
    Hemisphere.ROS_Time         = data_structure.Time';
    Hemisphere.GPS_Time         = data_structure.GPSTimeOfWeek';
    Hemisphere.centiSeconds     = 5; % This is sampled every 5 ms
    
    Hemisphere.Npoints          = length(Hemisphere.ROS_Time(:,1));
    Hemisphere.EmptyVector      = fcn_DataClean_fillEmptyStructureVector(Hemisphere); % Fill in empty vector (this is useful later)
    
    Hemisphere.Latitude         = data_structure.Latitude';
    Hemisphere.Longitude        = data_structure.Longitude';
    Hemisphere.Altitude         = data_structure.Height';
    Hemisphere.xEast            = data_structure.xEast';
    Hemisphere.yNorth           = data_structure.yNorth';
    Hemisphere.zUp              = data_structure.zUp';
    Hemisphere.velNorth         = data_structure.VNorth';
    Hemisphere.velEast          = data_structure.VEast';
    Hemisphere.velUp            = data_structure.VUp';
    Hemisphere.velMagnitude     = sqrt(Hemisphere.velNorth.^2 + Hemisphere.velEast.^2 + Hemisphere.velUp.^2);
    % for debugging - shows that the Hemisphere's velocity signal is horribly bad
    % figure;plot(Hemisphere.ROS_Time-Hemisphere.ROS_Time(1,1),Hemisphere.velMagnitude);
    % figure;plot(Hemisphere.ROS_Time-Hemisphere.ROS_Time(1,1),Hemisphere.velNorth);
    % figure;plot(Hemisphere.ROS_Time-Hemisphere.ROS_Time(1,1),Hemisphere.velEast);
    % figure;plot(Hemisphere.ROS_Time-Hemisphere.ROS_Time(1,1),Hemisphere.velUp);
    
    Hemisphere.velMagnitude_Sigma = std(Hemisphere.velMagnitude)*ones(length(Hemisphere.velMagnitude(:,1)),1);
    %Hemisphere.numSatellites    = Hemisphere.EmptyVector;
    Hemisphere.DGPS_is_active   = 1.00*(data_structure.NavMode==6)';
    %Hemisphere.Roll_deg         = Hemisphere.EmptyVector;
    %Hemisphere.Pitch_deg        = Hemisphere.EmptyVector;
    %Hemisphere.Yaw_deg          = Hemisphere.EmptyVector;
    %Hemisphere.Yaw_deg_Sigma    = Hemisphere.EmptyVector;
    Hemisphere.OneSigmaPos      = data_structure.StdDevResid';
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