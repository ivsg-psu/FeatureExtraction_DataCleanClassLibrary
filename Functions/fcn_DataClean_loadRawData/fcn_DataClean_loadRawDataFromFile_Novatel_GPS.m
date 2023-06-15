function GPS_Novatel = fcn_DataClean_loadRawDataFromFile_Novatel_GPS(d,data_source,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the GPS_Novatel data
% Input Variables:
%      d = raw data from GPS_Novatel(format:struct)
%      Hemisphere = the data from Hemisphere GPS, used to estimate the
%                   GPS_Novatel sigma (format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
% Returned Results:
%      GPS_Novatel
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
% 1. check if it is reasonable to select data from the second d.Time(2:end)';
% 2. check the Yaw_deg between matfile and database
% 3. Hemisphere = d_out;  %%update the interpolated values to raw data?
%%

if strcmp(data_source,'mat_file')
    % % Note: the Novatel and Hemisphere are almost perfectly time aligned, if
    % % dropping the first data point in Novatel (uncomment the following to
    % % see)
    % Hemisphere.GPS_Time(1,1)
    % % ans =
    % %           242007.249999977
    % d.Seconds(1,2)
    % % ans =
    % %              242007.248687
    % % This is why all the vectors below start at 2, not 1
    GPS_Novatel.ROS_Time       = d.Time(2:end)';
    GPS_Novatel.GPS_Time       = d.Seconds(2:end)';
    GPS_Novatel.centiSeconds   = 5; % This is sampled every 5 ms
    
    GPS_Novatel.Npoints        = length(GPS_Novatel.ROS_Time(:,1));
    GPS_Novatel.EmptyVector    = fcn_DataClean_fillEmptyStructureVector(GPS_Novatel); % Fill in empty vector (this is useful later)
    
    GPS_Novatel.Latitude       = d.Latitude(2:end)';
    GPS_Novatel.Longitude      = d.Longitude(2:end)';
    GPS_Novatel.Altitude       = d.Height(2:end)';
    GPS_Novatel.xEast          = d.xEast(2:end)';
    GPS_Novatel.yNorth         = d.yNorth(2:end)';
    GPS_Novatel.zUp            = d.zUp(2:end)';
    GPS_Novatel.velNorth       = d.NorthVelocity(2:end)';
    GPS_Novatel.velEast        = d.EastVelocity(2:end)';
    GPS_Novatel.velUp          = d.UpVelocity(2:end)';
    GPS_Novatel.velMagnitude   = sqrt(d.NorthVelocity(2:end)'.^2+d.EastVelocity(2:end)'.^2);
    GPS_Novatel.velMagnitude_Sigma = std(diff(GPS_Novatel.velMagnitude))*ones(length(GPS_Novatel.velMagnitude(:,1)),1);
    GPS_Novatel.DGPS_is_active = zeros(GPS_Novatel.Npoints,1);
    GPS_Novatel.numSatellites  = GPS_Novatel.EmptyVector;
    GPS_Novatel.navMode        = GPS_Novatel.EmptyVector;
    GPS_Novatel.Roll_deg       = d.Roll(2:end)';
    GPS_Novatel.Pitch_deg      = d.Pitch(2:end)';
    GPS_Novatel.Yaw_deg        = -d.Azimuth(2:end)'+360+90; % Notice sign flip and phase shift due to coord convention and mounting
else
    error('Please indicate the data source')
end


clear d %clear temp variable


% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
