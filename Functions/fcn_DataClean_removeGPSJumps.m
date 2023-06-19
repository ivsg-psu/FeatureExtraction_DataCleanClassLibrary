function mergedData = fcn_DataClean_removeGPSJumps(mergedData,rawData,base_station)

% fcn_DataClean_removeGPSJumps
% This function removes jumps from merged data caused by GPS outages
%
% FORMAT:
%
%      mergedData = fcn_DataClean_removeGPSJumps(mergedData,rawData,base_station)
%
% INPUTS:
%
%      mergedData - This is the filtered data via Baysian averaging across 
%                   same state
%
%      rawData - This is the raw data. The original data
%
%      base_station - These are the coordinates of the base station
%
%      (OPTIONAL INPUTS)
%
%      (none)
%
% OUTPUTS:
%
%      mergedData: This data have no jumps caused by GPS outages
%      
%      
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_removeGPSJumps
%     for a full test suite.
%
% This function was written on 2019_12_01 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2019_12_01 - sbrennan@psu.edu
% -- wrote the code originally 

% TO DO
% 

flag_do_debug = 0;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

% %% Let the user know what we are doing --  This was used in the initial
% code
% if flag_do_debug
%     % Grab function name
%     st = dbstack;
%     namestr = st.name;
% 
%     % Show what we are doing
%     fprintf(1,'\nWithin function: %s\n',namestr);
%     fprintf(1,'Correct differntial jumps in xEast and yNorth, in merged data.\n');   
%     fprintf(1,'Length of data vector going in: %d\n',length(mergedData.MergedGPS.xEast));
% end

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
    if nargin < 1 || nargin > 1
        error('Incorrect number of input arguments')
    end
        
    % NOTE: zone types are checked below

end


data_to_fit = rawData.GPS_Hemisphere;
xEast_pred_increments  = mergedData.MergedGPS.velMagnitude*0.05 .* cos(mergedData.MergedGPS.Yaw_deg*pi/180);
yNorth_pred_increments = mergedData.MergedGPS.velMagnitude*0.05 .* sin(mergedData.MergedGPS.Yaw_deg*pi/180);


%% Find valid intervals where DGPS is active
pairings = fcn_DataClean_findStartEndPairsWhereDGPSDrops(data_to_fit.DGPS_is_active);
    
%% Using the valid intervals above, start fixing the data

if ~isempty(pairings)
    for i_pairing = 1:length(pairings(:,1))

        % ONLY NEED THE FOLLOWING IF DOING TIME PLOTS, OR ANALYSIS TO FIND TIME
        % LOCATIONS OF DROP-OUTS
        %     startTime = data_to_fit.GPS_Time(pairings(i_pairing,1)) - data_to_fit.GPS_Time(i_pairing,1);
        %     endTime = data_to_fit.GPS_Time(pairings(i_pairing,2))  - data_to_fit.GPS_Time(i_pairing,1);
        %
        %     plottingFlags.TimeZoomPoint = [startTime endTime]; % Strange jump in xEast data
        %
        %
        %     % First, grab the data
        %     t_min = min(plottingFlags.TimeZoomPoint)+data_to_fit.GPS_Time(1,1);
        %     t_max = max(plottingFlags.TimeZoomPoint)+data_to_fit.GPS_Time(1,1);


        indices_of_interest = pairings(i_pairing,1):pairings(i_pairing,2);
        DGPS_is_active = data_to_fit.DGPS_is_active(indices_of_interest);

        % Fix xEast data
        xEast = data_to_fit.xEast(indices_of_interest);   
        xEast_increment_pred = xEast_pred_increments(indices_of_interest);
        [xEast_clean,~] = fcn_DataClean_medianFilterViaIncrementTemplate(xEast,xEast_increment_pred,DGPS_is_active);
        mergedData.MergedGPS.xEast(indices_of_interest) = xEast_clean;

        % Fix yNorth data
        yNorth = data_to_fit.yNorth(indices_of_interest);   
        yNorth_increment_pred = yNorth_pred_increments(indices_of_interest);
        [yNorth_clean,~] = fcn_DataClean_medianFilterViaIncrementTemplate(yNorth,yNorth_increment_pred,DGPS_is_active);
        mergedData.MergedGPS.yNorth(indices_of_interest) = yNorth_clean;    
    end
end 

% convert  ENU to LLA (for geoplot)
[mergedData.MergedGPS.latitude,mergedData.MergedGPS.longitude,mergedData.MergedGPS.altitude] ...
    = enu2geodetic(mergedData.MergedGPS.xEast,mergedData.MergedGPS.yNorth,mergedData.MergedGPS.zUp,...
    base_station.latitude,base_station.longitude, base_station.altitude,wgs84Ellipsoid);



% if flag_do_debug   -   This was used in the
% initial code
%     % Show what we are doing
%     fprintf(1,'Exiting function: %s\n',namestr);
%     fprintf(1,'Length of data vector going out: %d\n',length(mergedData.MergedGPS.xEast));
% end

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
if flag_do_plots
    
    % Nothing to plot        
    
end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end


return % Ends main function

%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§




function pairings = fcn_DataClean_findStartEndPairsWhereDGPSDrops(DGPS_is_active)
%%
% Find all the locations where DGPS shuts off and then on. Require that
% DGPS needs to be on at least 1 second (20 samples) to be "on". Can set
% this number higher if needed
n_samples_on = 100;

% Set the start and end points of status to zero, to indicate DGPS is
% gained/lost at these points
temp_DGPS_status = [0; DGPS_is_active]; % Artificially shut off at first index
temp_DGPS_status(end,1) = 0; % Artificially shut off at last index

diff_DGPS = diff(temp_DGPS_status);
indices_DGPS_found = find(diff_DGPS==1);
indices_DGPS_lost = find(diff_DGPS==-1);

% Initialize the good_diff vector
good_DGPS_status = temp_DGPS_status;

% To enforce the requirement that the DGPS be on at least n_samples_on
% before a loss valid, we loop through all the locations where DGPS is
% lost, and set all the n_samples prior to this to zero.
for i_loss=1:length(indices_DGPS_lost)
    current_index = indices_DGPS_lost(i_loss); % Grab the current location where DGPS was lost
    start_index = max(1,current_index-n_samples_on);
    good_DGPS_status(start_index:current_index,1) = 0;    
end  

% To enforce the requirement that the DGPS be on at least n_samples_on
% after a loss return, we loop through all the locations where DGPS is
% gained, and set all the n_samples after to this to zero.
for i_found=1:length(indices_DGPS_found)
    current_index = indices_DGPS_found(i_found); % Grab the current location where DGPS was lost
    end_index = min(length(diff_DGPS),current_index+n_samples_on);
    good_DGPS_status(current_index:end_index,1) = 0;    
end  

% Now the vector good_diff_GPS only goes off/on at index intervals that
% satisfy the requirement
diff_DGPS = diff(good_DGPS_status);
indices_DGPS_found = find(diff_DGPS==1);
indices_DGPS_lost = find(diff_DGPS==-1);

% Form pairings:
pairings = [];
for i_lost = 1:length(indices_DGPS_lost)
    
    i_found = find(indices_DGPS_found>indices_DGPS_lost(i_lost),1);
    if ~isempty(i_found) % found a pair
        pairings = [pairings; [indices_DGPS_lost(i_lost) indices_DGPS_found(i_found)]]; %#ok<AGROW>
    end
end

if 1==0
    % Check results
    for i_pair = 1:length(pairings(:,1))
        index_start = pairings(i_pair,1);
        index_end = pairings(i_pair,2);
        ydata = data_to_fit.DGPS_is_active(index_start:index_end,1);
        xdata = (index_start:index_end)'*0.05;
        figure(36363);
        clf;
        plot(xdata,ydata,'k');
        xlabel('Time (sec)');
        ylabel('DGPS status');
        xlim([index_start index_end]*0.05);
        pause;
    end
end