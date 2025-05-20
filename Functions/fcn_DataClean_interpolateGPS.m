function GPS_struct_interp = fcn_DataClean_interpolateGPS(GPS_struct, time_ref_vec)
% fcn_DataClean_interpolateGPS
%
% Interpolates all numerical fields in a GPS structure to a reference time vector.
% Special handling is applied to certain fields like 'DGPS_mode' using nearest neighbor.
%
% INPUTS:
%   GPS_struct     - Struct containing GPS fields (e.g., GPS_Time, Latitude, etc.)
%   time_ref_vec   - Target time vector (Nx1) to interpolate all GPS fields onto
%
% OUTPUT:
%   GPS_struct_interp - Struct containing interpolated GPS fields

% This function was written on 2025_04_23 by X. Cao
% Questions or comments? xfc5113@psu.edu

% Revision history
% 2025_04_23 - Xinyu Cao, xfc5113@psu.edu
% -- wrote the code originally
% -----------------------------

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

if length(time_ref_vec) < 3
    error("The reference time vector is too short")

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
GPS_fields = fieldnames(GPS_struct);
N_gps_fields = length(GPS_fields);

% Extract time vector (must exist as GPS_Time)
if isfield(GPS_struct, 'GPS_Time')
    GPS_Time_temp = GPS_struct.GPS_Time(:);
else
    error('Field "GPS_Time" not found in the input structure.');
end

% Initialize output
GPS_struct_interp = GPS_struct;

% Loop through each field
for idx_GPS_field = 1:N_gps_fields
    GPS_field_temp = GPS_struct.(GPS_fields{idx_GPS_field});
    % Only interpolate non-cell numeric vectors of length > 1
    if ~iscell(GPS_field_temp) && isnumeric(GPS_field_temp)
        if ~isempty(GPS_field_temp) && length(GPS_field_temp) > 1 && all(~isnan(GPS_field_temp))
            if contains(GPS_fields{idx_GPS_field},'DGPS_mode')
                GPS_field_interp = interp1(GPS_Time_temp, GPS_field_temp,time_ref_vec,'previous','extrap');
            else
                GPS_field_interp = interp1(GPS_Time_temp, GPS_field_temp,time_ref_vec,'linear','extrap');
            end
            GPS_struct_interp.(GPS_fields{idx_GPS_field}) = GPS_field_interp;
        end
    end
end


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