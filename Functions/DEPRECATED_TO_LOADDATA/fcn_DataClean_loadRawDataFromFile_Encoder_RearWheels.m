function Encoder_RearWheels = fcn_DataClean_loadRawDataFromFile_Encoder_RearWheels(data_structure,GPS_Novatel,data_source,flag_do_debug)

% This function is used to load the raw data collected with the Penn State Mapping Van.
% This is the Encoder_RearWheels data
% Input Variables:
%      d = raw data from Encoder_RearWheels(format:struct)
%      GPS_Novatel = GPS_Novatel data (format:struct)
%      data_source = the data source of the raw data, can be 'mat_file' or 'database'(format:struct)
%
% Returned Results:
%      Encoder_RearWheels
% Author: Liming Gao
% Created Date: 2020_12_07
%
% Modified by Aneesh Batchu and Mariam Abdellatief on 2023_06_13
%
% This function is modified to load the raw data (from file) collected with
% the Penn State Mapping Van.
%
%
% Updates:
%
% To do lists:
% 1.
%
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

if strcmp(data_source,'mat_file')
    
    Encoder_RearWheels.GPS_Time           = data_structure.GPS_time;  % This is the GPS time, UTC, as reported by the unit
    Encoder_RearWheels.Trigger_Time       = data_structure.Trigger_Time;  % This is the Trigger time, UTC, as calculated by sample
    Encoder_RearWheels.ROS_Time           = data_structure.ROS_Time;  % This is the ROS time that the data arrived into the bag
    Encoder_RearWheels.centiSeconds       = data_structure.centiSeconds;  % This is the hundreth of a second measurement of sample period (for example, 20 Hz = 5 centiseconds)
    Encoder_RearWheels.Npoints            = data_structure.Npoints;  % This is the number of data points in the array

    Encoder_RearWheels.CountsPerRev       = data_structure.CountsPerRev;  % How many counts are in each revolution of the encoder (with quadrature)
    Encoder_RearWheels.Counts             = data_structure.Counts;  % A vector of the counts measured by the encoder, Npoints long
    Encoder_RearWheels.DeltaCounts        = data_structure.DeltaCounts;  % A vector of the change in counts measured by the encoder, with first value of zero, Npoints long
    Encoder_RearWheels.LastIndexCount     = data_structure.LastIndexCount;  % Count at which last index pulse was detected, Npoints long
    Encoder_RearWheels.AngularVelocity    = data_structure.AngularVelocity;  % Angular velocity of the encoder
    Encoder_RearWheels.AngularVelocity_Sigma    = default_value.AngularVelocity_Sigma;
    % Event functions
    Encoder_RearWheels.EventFunctions = {}; % These are the functions to determine if something went wrong
    
else
    error('Please indicate the data source')
end


% Calculate the wheel radius, on average
t = GPS_Novatel.ROS_Time;
V = GPS_Novatel.velMagnitude;
t_enc = Encoder_RearWheels.ROS_Time;  % encoder time
w = abs(Encoder_RearWheels.AngularVelocityR);
V_enc = interp1(t,V,t_enc,'nearest','extrap'); % velocity in encoder time
Encoder_RearWheels.RadiusAveR_in_meters = w'*w\(w'*V_enc);

% Use the radius to find the velocity
Encoder_RearWheels.VelocityR            = Encoder_RearWheels.RadiusAveR_in_meters*abs(Encoder_RearWheels.AngularVelocityR);

% Calculate the standard deviation in velocity prediction
error = Encoder_RearWheels.VelocityR - V_enc;
% For debugging
% figure; hist(error,10000);
Encoder_RearWheels.VelocityR_Sigma      = std(error);
Encoder_RearWheels.velMagnitude         = Encoder_RearWheels.VelocityR;
Encoder_RearWheels.velMagnitude_Sigma   = Encoder_RearWheels.VelocityR_Sigma;

clear data_structure; %clear temp variable

% Close out the loading process
if flag_do_debug
    % Show what we are doing
    % Grab function name
    st = dbstack;
    namestr = st.name;
    fprintf(1,'\nFinished processing function: %s\n',namestr);
end

return
