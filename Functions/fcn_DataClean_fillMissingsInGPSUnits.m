function fixed_dataStructure = fcn_DataClean_fillMissingsInGPSUnits(dataStructure,ref_basestation,varargin)

% fcn_DataClean_fillMissingsInGPSUnits
% Interpolate the GPS_Time field for all GPS sensors. This is done by
% using the centiSeconds field and the effective start and end GPS_Times,
% determined by taking the maximum start time and minimum end time over all
% sensors.
%
% FORMAT:
%
%      fixed_dataStructure = fcn_DataClean_fillMissingsInGPSUnits(dataStructure,ref_basestation,(fid))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      ref_basestation: base station that used for the dataset
%
%      (OPTIONAL INPUTS)
%
%
%      fid: a file ID to print results of analysis. If not entered, the
%      console (FID = 1) is used.
%
% OUTPUTS:
%
%      fixed_dataStructure: a data structure to be analyzed that includes the following
%      fields:
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES: # To be Done
%
%
% This function was written on 2024_08_15 by X. Cao
% Questions or comments? xfc5113@psu.edu

% Revision history:
%     
% TO DO

% Set default fid (file ID) first:
flag_do_debug = 1;  %#ok<NASGU> % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking


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

if flag_check_inputs
    % Are there the right number of inputs?
    if nargin < 1 || nargin > 3
        error('Incorrect number of input arguments')
    end
        
end

% Does the user want to specify the fid?
% Check for user input
fid = 0; % Default case is to NOT print to the console
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        fid = temp;
    end
end
        

if fid
    st = dbstack; %#ok<*UNRCH>
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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

% The method this is done is to:
% 1. Find the effective start and end GPS_Times, determined by taking the maximum start time and minimum end time over all
% sensors.
% 2.  Fill and interpolate the missing data in GPS units


%% Step 1: Find the effective start and end GPS and ROS times over all sensors


[cell_array_GPS_Time, sensor_names_GPS_Time] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'GPS_Time','GPS');
[cell_array_ROS_Time,sensor_names_ROS_Time]  = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'ROS_Time','GPS');

if ~isequal(sensor_names_GPS_Time,sensor_names_ROS_Time)
    error('Sensors were found that were missing either GPS_Time or ROS_Time. Unable to calculate .');
end

[cell_array_centiSeconds, ~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'centiSeconds','GPS');
N_GPS_Units = length(cell_array_GPS_Time);
%% Define fields need to be interpolated

fields_need_to_be_interpolated=["ROS_Time",...
                                "StdLat",...
                                "StdLon",...
                                "StdAlt",...
                                "GeoSep",...
                                "numSatellites",...
                                "DGPS_mode",...
                                "HDOP",...
                                "AgeOfDiff",...
                                "SpdOverGrndKmph",...
                                "GPS_Time2",...
                                "ROS_Time2",...
                                "ROS_Time3"];

%% Interate over GPS units and interpolate data

fixed_dataStructure = dataStructure;
for idx_gps_unit = 1:N_GPS_Units
    GPSUnitName = sensor_names_GPS_Time{idx_gps_unit};
    GPSdataStructure = fixed_dataStructure.(GPSUnitName);
    centiSeconds = cell_array_centiSeconds{idx_gps_unit};
    sub_fields = fieldnames(GPSdataStructure);
    N_fields = length(sub_fields);
    GPS_Time = cell_array_GPS_Time{idx_gps_unit};

    ROS_Time = cell_array_ROS_Time{idx_gps_unit};

    offset_between_GPSTime_and_ROSTime = ROS_Time - GPS_Time;
    % 
    start_GPSTime = GPS_Time(1);
    end_GPSTime = GPS_Time(end);
    start_GPSTime_centiSeconds = 100*start_GPSTime/centiSeconds*centiSeconds;
    end_GPSTime_centiSeconds = 100*end_GPSTime/centiSeconds*centiSeconds;
    newGPSTime_centiSeconds = (start_GPSTime_centiSeconds:centiSeconds:end_GPSTime_centiSeconds).';
    newGPSTime = newGPSTime_centiSeconds/100;
    % Calculate and interpolate X, Y and Z of current GPS unit
    GPS_LLA = [GPSdataStructure.Latitude, GPSdataStructure.Longitude, GPSdataStructure.Altitude];
    GPS_ENU = lla2enu(GPS_LLA,ref_basestation,'ellipsoid');
    GPS_ENU_interp = interp1(GPS_Time,GPS_ENU,newGPSTime,'linear','extrap');
    GPS_LLA_interp = enu2lla(GPS_ENU_interp,ref_basestation,'ellipsoid');
    %% Find number of ROS_Time in the subfields, which indicates the number of NMEA messages merged for current GPS unit
    N_NMEA_sentences = length(find(contains(sub_fields,"ROS_Time")));

    if N_NMEA_sentences == 1
        GST_Fields = [];
        VTG_Fields = [];
        disp("VTG and GST fields do not exist")

    elseif N_NMEA_sentences == 2
        if all(isnan(GPSdataStructure.SpdOverGrndKmph))
            disp("VTG fields do not exist")
            GST_Fields = ["ROS_Time2","GPS_Time2","StdLat","StdLon","StdAlt"];
            VTG_Fields = [];
        else
            GST_Fields = [];
            VTG_Fields = ["ROS_Time2","SpdOverGrndKmph"];
            ROS_Time_need_to_be_checked = GPSdataStructure.ROS_Time2;
            disp("GST field does not exist")
             % Find matched GPS time for different NMEA sentences
    GPS_Time_matched = fcn_DataClean_calculateGPSTimeForMergedData(ROS_Time_need_to_be_checked,GPS_Time,centiSeconds,offset_between_GPSTime_and_ROSTime);
        end
    elseif N_NMEA_sentences == 3
        VTG_Fields = ["ROS_Time3","SpdOverGrndKmph"];
        GST_Fields = ["ROS_Time2","GPS_Time2","StdLat","StdLon","StdAlt"];
        ROS_Time_need_to_be_checked = GPSdataStructure.ROS_Time3;
         % Find matched GPS time for different NMEA sentences
    GPS_Time_matched = fcn_DataClean_calculateGPSTimeForMergedData(ROS_Time_need_to_be_checked,GPS_Time,centiSeconds,offset_between_GPSTime_and_ROSTime);
    end
   
    if any(contains(sub_fields,"GPS_Time2"))
        original_GPS_Time2 = GPSdataStructure.GPS_Time2;
    end
    % Interpolate each field except LLA fields and scalar field
    for idx_field = 1:N_fields
        sub_field = sub_fields{idx_field};
        current_field = GPSdataStructure.(sub_field);
        if length(current_field)>1
            if any(strcmp(fields_need_to_be_interpolated,sub_field))
                interp_method = fcn_DataClean_determineInterpolateMethod(sub_field);
                if any(strcmp(VTG_Fields,sub_field))
                    original_GPS_Time = GPS_Time_matched;
                elseif any(strcmp(GST_Fields,sub_field))
                    if any(contains(sub_fields,"GPS_Time2"))
                        original_GPS_Time = original_GPS_Time2;
                    else
                        original_GPS_Time = GPS_Time;
                    end
                else
                    original_GPS_Time = GPS_Time;
                end

                % if length(current_field_unique)>1
                current_field_interp = interp1(original_GPS_Time,current_field,newGPSTime,interp_method,"extrap");
                % else
                    % current_field_interp = current_field_unique;
                % end
                GPSdataStructure.(sub_field) = current_field_interp;

            end  
        end
        
    end
    % Fill the position fields
    GPSdataStructure.GPS_Time = newGPSTime;
    GPSdataStructure.Latitude = GPS_LLA_interp(:,1);
    GPSdataStructure.Longitude = GPS_LLA_interp(:,2);
    GPSdataStructure.Altitude = GPS_LLA_interp(:,3);
    GPSdataStructure.xEast = GPS_ENU_interp(:,1);
    GPSdataStructure.yNorth = GPS_ENU_interp(:,2);
    GPSdataStructure.zUp = GPS_ENU_interp(:,3);
    GPSdataStructure.centiSeconds = centiSeconds;
    GPSdataStructure.Npoints = length(newGPSTime);
    
    fixed_dataStructure.(GPSUnitName) = GPSdataStructure;

end

