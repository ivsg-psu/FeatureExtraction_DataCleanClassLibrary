function fixeddataStructure = fcn_DataClean_fixLowRateGPS(dataStructure, offending_sensor,varargin)

% fcn_DataClean_fixLowRateGPS: Fix the GPS data with low rate
%
% This function fixes a low-rate or missing GPS trajectory (offending_sensor)
% using two other high-frequency GPS signals via relative offset interpolation.
%
% INPUTS:
%   dataStructure - a struct containing three GPS sensors as subfields,
%                       each with .Time, .X, .Y, .Z arrays
%   offending_sensor  - name of the low-frequency GPS field as a string (e.g., 'GPS_SparkFun_RearRight_GGA')
%
% (OPTIONAL INPUTS)
%   ref_baseStationLLA - the LLA coordinate of the reference base station
%
%   fid               - file ID for logging (e.g., 1 for stdout, or a file handle)
%
%   fig_num           - a figure number to plot results.
%
% OUTPUT:
%   fixeddataStructure - updated with reconstructed trajectory for offending_sensor
% This function was written on 2025_05_17 by X. Cao
% Questions or comments? xfc5113@psu.edu

% Revision history:
%     
% 2025_05_17: xfc5113@psu.edu
% -- wrote the code originally 


%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Does user want to specify ref_baseStationLLA?
ref_baseStationLLA = [40.86368573 -77.83592832 344.189]; %#ok<NASGU>
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        ref_baseStationLLA = temp; %#ok<NASGU>
    end
end

% Does user want to specify fid?
fid = 1;
if 4 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        fid = temp;
    end
end

% Does user want to specify fig_num?
flag_do_plots = 0;
if 5<=nargin
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp;
        flag_do_plots = 1;
    end
end
%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Identify valid field names
fields = fieldnames(dataStructure);
gps_indx = cellfun(@(x) contains(x, "GPS"), fields);
gps_fields = fields(gps_indx);


if ~ismember(offending_sensor, gps_fields)
    error('Offending sensor name "%s" is not a recognized GPS field.', offending_sensor);
end

% Identify good sensors
good_gps_fields = gps_fields(~strcmp(gps_fields, offending_sensor));

gps_field_good_A = good_gps_fields{1}; % First GPS with normal rate (A)
gps_field_good_B = good_gps_fields{2}; % Second GPS with normal rate (B)
gps_field_low_rate = offending_sensor; % GPS with low rate (C)

% A and B are good GPS sensors, C is the GPS sensor with low rate
GPS_A = dataStructure.(gps_field_good_A);
GPS_B = dataStructure.(gps_field_good_B);
GPS_C = dataStructure.(gps_field_low_rate);

fprintf(fid, '[INFO] Reconstructing %s using %s and %s\n', ...
    gps_field_low_rate, gps_field_good_A, gps_field_good_B);

% Reference time vector 
time_type = 'GPS_Time';
time_range = fcn_DataClean_FindMaxAndMinTime(dataStructure,time_type);
time_interval = GPS_A.centiSeconds/100;
time_ref_vec = (min(time_range):time_interval:max(time_range)).';

% Interpolate good GPSs (A&B)
GPS_A_interp =  fcn_DataClean_interpolateGPS(GPS_A, time_ref_vec);
GPS_B_interp =  fcn_DataClean_interpolateGPS(GPS_B, time_ref_vec);

GPS_Time_A = GPS_A_interp.GPS_Time;
GPS_Time_B = GPS_B_interp.GPS_Time;
GPS_Time_C = GPS_C.GPS_Time;
[~, idx_AB, idx_C] = intersect(time_ref_vec, GPS_Time_C);  % ∩ C
% Extract the ENU data from GPS data struct
GPS_A_interp_ENU = [GPS_A_interp.xEast, GPS_A_interp.yNorth, GPS_A_interp.zUp];
GPS_B_interp_ENU = [GPS_B_interp.xEast, GPS_B_interp.yNorth, GPS_B_interp.zUp];
GPS_mid_interp_ENU = (GPS_A_interp_ENU + GPS_B_interp_ENU)/2;
GPS_C_ENU = [GPS_C.xEast, GPS_C.yNorth, GPS_C.zUp];

GPS_mid_AB_matched = GPS_mid_interp_ENU(idx_AB,:);
delta_ENU = GPS_C_ENU(idx_C,:) - GPS_mid_AB_matched;

delta_ENU_interp = interp1(GPS_Time_C, delta_ENU, time_ref_vec,'linear','extrap');

% Interpolate bad GPS
GPS_C_interp =  fcn_DataClean_interpolateGPS(GPS_C, time_ref_vec);
% Recalculate ENU with the delta_ENU
GPS_C_ENU_fixed = GPS_mid_interp_ENU + delta_ENU_interp;
% Convert ENU back to LLA and fill the corresponding fields
GPS_C_LLA_fixed = enu2lla(GPS_C_ENU_fixed,ref_baseStationLLA,'ellipsoid');
GPS_C_interp.Latitude = GPS_C_LLA_fixed(:,1);
GPS_C_interp.Longitude = GPS_C_LLA_fixed(:,2);
GPS_C_interp.Altitude = GPS_C_LLA_fixed(:,3);
GPS_C_interp.xEast = GPS_C_ENU_fixed(:,1);
GPS_C_interp.yNorth = GPS_C_ENU_fixed(:,2);
GPS_C_interp.zUp = GPS_C_ENU_fixed(:,3);

% Construct the fixed data structure
fixeddataStructure = dataStructure;
fixeddataStructure.(gps_field_good_A) = GPS_A_interp;
fixeddataStructure.(gps_field_good_B) = GPS_B_interp;
fixeddataStructure.(gps_field_low_rate) = GPS_C_interp;

%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
if flag_do_plots
    figure(fig_num)
    selected_range = 1:100;
    scatter(GPS_C_ENU_fixed(selected_range,1),GPS_C_ENU_fixed(selected_range,2),20,'r','filled')
    hold on
    scatter(GPS_A_interp_ENU(selected_range,1),GPS_A_interp_ENU(selected_range,2),20,'g','filled')
    scatter(GPS_B_interp_ENU(selected_range,1),GPS_B_interp_ENU(selected_range,2),20,'b','filled')
    axis equal
    xlabel('X-East [m]')
    ylabel('Y-North [m]')
end



fprintf(fid, '[DONE] GPS reconstruction of %s complete. %d points\n', gps_field_low_rate, length(time_ref_vec));
end

