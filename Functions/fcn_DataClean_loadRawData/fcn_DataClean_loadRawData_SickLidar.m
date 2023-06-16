function Lidar = fcn_DataClean_loadRawData_SickLidar(d,data_source,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the SICK Lidar data
% Input Variables:
%      d = raw data from Lidar(format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
% Returned Results:
%      Lidar
% Author: Liming Gao
% Created Date: 2021_07_06
% Modify Date: 
%
% Updates:
%
% To do lists:
% 1. 
% 
%%
flag_plot = 0;

% the field name from mat_file is different from database, so we process
% them seperately
if strcmp(data_source,'mat_file')
    
    
elseif strcmp(data_source,'database')
    Lidar.ROS_Time         = d.time;
    Lidar.scan_time         = d.scan_time;
    Lidar.secs        = d.seconds;
    Lidar.nsecs         = d.nanoseconds;
    %Lidar.datetime         = d.timestamp;
    
    Lidar.centiSeconds     = 4 ; % This is sampled every 0.04s, 25Hz
    
    Lidar.Npoints          = length(Lidar.ROS_Time(:,1));
    Lidar.EmptyVector      = fcn_DataClean_fillEmptyStructureVector(Lidar); % Fill in empty vector (this is useful later)
    
    Lidar.angle_min = d.parameters.angle_min(1);
    Lidar.angle_max = d.parameters.angle_max(1);
    Lidar.angle_increment = d.parameters.angle_increment(1);
    Lidar.time_increment = d.parameters.time_increment(1);
    Lidar.range_min = d.parameters.range_min(1);
    Lidar.range_max = d.parameters.range_max(1);
    Lidar.ranges = cell2mat(d.ranges);
    Lidar.intensities = cell2mat(d.intensities);
           
else
    error('Please indicate the data source')
end

%% Variacne and Plot

%{
% Update the variances in the position information, based on GPS status?
if 1==0
    Index_DGPS_active = Lidar.DGPS_is_active==1;
    Lidar.OneSigmaPos = 0.5 * ones(length(Lidar.EmptyVector),1); % Sigma value with DGPS inactive is roughly 50 cm, assuming WAAS
    Lidar.OneSigmaPos(Index_DGPS_active)    = 0.015; % Sigma value with DGPS active is roughly 1.5 cm.
end

Lidar.xEast_Sigma    = Lidar.OneSigmaPos;
Lidar.yNorth_Sigma   = Lidar.OneSigmaPos;
Lidar.zUp_Sigma      = Lidar.OneSigmaPos;

% Calculate the increments
Lidar = fcn_DataClean_fillPositionIncrementsFromGPSPosition(Lidar);

% Calculate the apparent yaw angle from ENU positions
Lidar = fcn_DataClean_fillRawYawEstimatesFromGPSPosition(Lidar);

% Estimate the variance associated with the estimated yaw
Lidar.Yaw_deg_from_position_Sigma = fcn_DataClean_predictYawSigmaFromPosition(Lidar.xy_increments);

% Estimate the variance associated with the estimated yaw based on velocity
Lidar.Yaw_deg_from_position_Sigma = 0*Lidar.xy_increments;  % Initialize array to zero
good_indices = find(Lidar.DGPS_is_active==1);
Lidar.Yaw_deg_from_position_Sigma(good_indices) = ...
    fcn_DataClean_predictYawSigmaFromPosition(Lidar.xy_increments(good_indices))/5;
bad_indices = find(Lidar.DGPS_is_active==0);
Lidar.Yaw_deg_from_position_Sigma(bad_indices)...
    = fcn_DataClean_predictYawSigmaFromPosition(Lidar.xy_increments(bad_indices));

% Calculate the apparent yaw angle from ENU velocities
Lidar = fcn_DataClean_fillRawYawEstimatesFromGPSVelocity(Lidar);


% Estimate the variance associated with the estimated yaw based on velocity
speeds = (Lidar.velNorth.^2+Lidar.velEast.^2).^0.5;
filt_speeds = medfilt1(speeds,20,'truncate');
Lidar.Yaw_deg_from_velocity_Sigma...
    = fcn_DataClean_predictYawSigmaFromVelocity(filt_speeds,Lidar.OneSigmaPos);

% The Hemisphere's yaw covariance grows much faster than position
% covariance, so we have to update this here to allow that...
% updates. See:
%     figure(454); plot(Hemisphere.GPS_Time - ceil(Hemisphere.GPS_Time(1,1)), Hemisphere.OneSigmaPos); xlim([539 546]);
% figure(46464);
% clf;
% plot(Hemisphere.GPS_Time - Hemisphere.GPS_Time(1,1), Hemisphere.Yaw_deg_from_velocity,'r');
% hold on;
% plot(Hemisphere.GPS_Time - Hemisphere.GPS_Time(1,1), Hemisphere.Yaw_deg_from_velocity+2*Hemisphere.Yaw_deg_from_velocity_Sigma,'Color',[1 0.5 0.5]);
% plot(Hemisphere.GPS_Time - Hemisphere.GPS_Time(1,1), Hemisphere.Yaw_deg_from_velocity-2*Hemisphere.Yaw_deg_from_velocity_Sigma,'Color',[1 0.5 0.5]);
% xlim([539 546]);

% This should show the variance inflate inbetween updates. Because it is
% not doing this correctly, we'll need to estimate this and fix it..
time_offset = -0.35;
time = Lidar.GPS_Time  + time_offset;
t_fraction = time - floor(time);
%figure(46346); plot(Hemisphere.GPS_Time - Hemisphere.GPS_Time(1,1),t_fraction); xlim([539 546]);

a = 0.03;  % Units are centimeters - this is an estimate of how much the GPS will linearly drift after 1 second, without corrections
b = .7;  % Units are centimeters per t^0.5. This reprents the random walk rate of the GPS without corrections
new_variance = Lidar.OneSigmaPos + a*t_fraction + b*t_fraction.^0.5;

% Recalculate based on quadratic growth model given above
Lidar.Yaw_deg_from_velocity_Sigma...
    = fcn_DataClean_predictYawSigmaFromVelocity(filt_speeds,new_variance);
if flag_plot
    figure(46464);
    clf;
    plot(Lidar.GPS_Time - Lidar.GPS_Time(1,1), Lidar.Yaw_deg_from_velocity,'r');
    hold on;
    plot(Lidar.GPS_Time - Lidar.GPS_Time(1,1), Lidar.Yaw_deg_from_velocity+2*Lidar.Yaw_deg_from_velocity_Sigma,'Color',[1 0.5 0.5]);
    plot(Lidar.GPS_Time - Lidar.GPS_Time(1,1), Lidar.Yaw_deg_from_velocity-2*Lidar.Yaw_deg_from_velocity_Sigma,'Color',[1 0.5 0.5]);
    xlim([539 546]);
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
%}
return