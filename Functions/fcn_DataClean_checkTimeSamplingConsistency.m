function [flags,offending_sensor,return_flag] = fcn_DataClean_checkTimeSamplingConsistency(dataStructure, field_name, varargin)

% fcn_DataClean_checkTimeSamplingConsistency
% Checks to see if the sensor's observed, average sampling time in
% centiSeconds matches the actual sampling time
%
% FORMAT:
%
%      [flags,offending_sensor] = fcn_DataClean_checkTimeSamplingConsistency(...
%          dataStructure,field_name,...
%          (flags), (sensors_to_check), (fid), (fig_num))
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed
%
%      field_name: the field to be checked
%
%      (OPTIONAL INPUTS)
%
%      flags: If a structure is entered, it will append the flag result
%      into the structure to allow a pass-through of flags structure
%
%      sensors_to_check: a string listing the sensors to check. For
%      example, 'GPS' will check every sensor in the dataStructure whose
%      name contains 'GPS'. Default is empty, which checks all sensors.
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (FID = 0). Set fid to 1 for printing to console.
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
%
% OUTPUTS:
%
%      flags: a data structure containing subfields that define the results
%      of the verification check. The name of the flag is formatted by the
%      argument inputs. 
%
%      offending_sensor: this is the string corresponding to the sensor
%      field in the data structure that caused a flag to become zero. 
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_checkTimeSamplingConsistency
%     for a full test suite.
%
% This function was written on 2023_07_01 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     
% 2023_07_01: sbrennan@psu.edu
% -- wrote the code originally 
% 2024_09_29: sbrennan@psu.edu
% -- updated top comments
% -- added debug flag area
% -- added fig_num input, fixed the plot flag
% -- fixed warning and errors

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==6 && isequal(varargin{end},-1))
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS");
    MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG = getenv("MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_fig_num = 999978; %#ok<NASGU>
else
    debug_fig_num = []; %#ok<NASGU>
end

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
if (0==flag_max_speed)
    if flag_check_inputs
        % Are there the right number of inputs?
        narginchk(2,6);
    end
end

% Does the user want to specify the flags?
flags = struct;
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        flags = temp;
    end
end

% Does the user want to specify the sensors_to_check?
sensors_to_check = '';
if 4 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        sensors_to_check = temp;
    end
end


% Does the user want to specify the fid?
fid = 0;
if (0==flag_max_speed)
    % Check for user input
    if 5 <= nargin
        temp = varargin{3};
        if ~isempty(temp)
            % Check that the FID works
            try
                temp_msg = ferror(temp); %#ok<NASGU>
                % Set the fid value, if the above ferror didn't fail
                fid = temp;
            catch ME
                warning('on','backtrace');
                warning('User-specified FID does not correspond to a file. Unable to continue.');
                throwAsCaller(ME);
            end
        end
    end
end


% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (6<=nargin)
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

if isempty(sensors_to_check)
    flag_check_all_sensors = 1;    
else
    flag_check_all_sensors = 0;
end

% Set up the field name
if flag_check_all_sensors
    flag_name = cat(2,field_name,'_has_same_sample_rate_as_centiSeconds');
else
    flag_name = cat(2,field_name,sprintf('_has_same_sample_rate_as_centiSeconds_in_%s_sensors',sensors_to_check));
end

% Initialize offending_sensor
offending_sensor = '';
return_flag = 0;

% Produce a list of all the sensors (each is a field in the structure)
if flag_check_all_sensors
    sensor_names = fieldnames(dataStructure); % Grab all the fields that are in dataStructure structure
else
    % Produce a list of all the sensors that meet the search criteria, and grab
    % their data also
    [~,sensor_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, field_name,sensors_to_check);
end


if 0~=fid
    fprintf(fid,'Checking consistency of expected and actual time sampling rates of ''%s''',field_name);
    if flag_check_all_sensors
        fprintf(fid,': --> %s\n', flag_name);
    else
        fprintf(fid,' in all %s sensors: --> %s\n', sensors_to_check, flag_name);
    end
end

Ndata = length(sensor_names);

allTimeDifferences = cell(Ndata,1);
for i_data = 1:Ndata
    
    % Grab the sensor subfield name
    GPS_sensor_name = sensor_names{i_data};
    sensor_data = dataStructure.(GPS_sensor_name);
    
    if 0~=fid
        fprintf(fid,'\t Checking sensor %d of %d: %s\n',i_data,length(sensor_names),GPS_sensor_name);
    end
    
    flags_dataTimeIntervalMatchesIntendedSamplingRate = 1;
    centiSeconds = sensor_data.centiSeconds(1);

    % Calculate the time differences. Repeat the last one so that the
    % differences match the data length
    timeDifferences = diff(sensor_data.(field_name));
    timeDifferences = [timeDifferences; timeDifferences(end)]; %#ok<AGROW>
    allTimeDifferences{i_data,1} = timeDifferences;

    meanSamplingInterval = mean(timeDifferences);
    effective_centiSeconds = round(100*meanSamplingInterval);
    if centiSeconds > effective_centiSeconds
        flags_dataTimeIntervalMatchesIntendedSamplingRate = 0;
    end
    if centiSeconds ~= effective_centiSeconds
        warning('on','backtrace');
        warning('The sensor: %s is missing so much data that the field: %s effectively has an incorrect sample rate.\n \t The commanded centiSeconds: %d \n\t The effective centiSeconds: %d \n\t The mean time sampling difference (centiSec): %.4f \n',...
            GPS_sensor_name,field_name,centiSeconds,effective_centiSeconds,meanSamplingInterval*100);
    end
       
    
    % Set the flag and then exit immediately
    flags.(flag_name) = flags_dataTimeIntervalMatchesIntendedSamplingRate;    
    if 0==flags.(flag_name)
        offending_sensor = GPS_sensor_name; % Save the name of the sensor
        return_flag = 1; % Indicate that the return was forced
        return; % Exit the function immediately to avoid more processing
    end
end


% Tell the user what is happening?
if 0~=fid
    fprintf(fid,'\n\t Flag %s set to: %.0d\n\n',flag_name, flags_dataTimeIntervalMatchesIntendedSamplingRate);
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
if flag_do_plots && isempty(findobj('Number',fig_num))

    figure(fig_num);
    
    % check whether the figure already has data
    % temp_h = figure(fig_num); 
    % flag_rescale_axis = 0;
    % if isempty(get(temp_h,'Children'))
    %     flag_rescale_axis = 1;
    % end

    tiledlayout('flow')

    for i_data = 1:Ndata
        nexttile

        % make plots
        data = allTimeDifferences{i_data,1};
        histogram(data*100,100,'Normalization','percentage');
        
        title(sprintf('%s',sensor_names{i_data}),'Interpreter','none');
        xlabel('Sampling Interval (centiSeconds)');
        ylabel('Percentage');
    end

    %% Plot GPS locations

    % Test the function
    clear plotFormat

    plotFormat.Color = [0 0.7 0];
    plotFormat.Marker = '.';
    plotFormat.MarkerSize = 10;
    plotFormat.LineStyle = 'none';
    plotFormat.LineWidth = 3;

    % Does user want to specify colorMapToUse?
    % Fill in large colormap data using turbo
    colorMapMatrix = colormap('turbo');
    colorMapMatrix = colorMapMatrix(100:end,:); % Keep the scale from green to red
    % Reduce the colormap
    Ncolors = 20;
    colorMapToUse = fcn_plotRoad_reduceColorMap(colorMapMatrix, Ncolors, -1);

    % Is this a GPS sensor
    GPS_indicies = find(contains(sensor_names,'GPS'));
    GPS_sensor_names = cell(length(GPS_indicies),1);
    for ith_sensor = 1:length(GPS_indicies)
        GPS_sensor_names{ith_sensor} = sensor_names{GPS_indicies(ith_sensor)}; 
    end

    % legend_entries = GPS_sensor_names;
    for ith_sensor = 1:length(GPS_sensor_names)

        nexttile

        % Grab the sensor subfield name
        GPS_sensor_name = GPS_sensor_names{ith_sensor};
        sensor_data = dataStructure.(GPS_sensor_name);

        LLdata = [sensor_data.Latitude sensor_data.Longitude];

        % Convert LLA to ENU
        reference_latitude = 40.86368573;
        reference_longitude = -77.83592832;
        reference_altitude = 344.189;
        MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE = getenv("MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE");
        MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE = getenv("MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE");
        MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE = getenv("MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE");
        if ~isempty(MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE) && ~isempty(MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE) && ~isempty(MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE)
            reference_latitude  = str2double(MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE);
            reference_longitude = str2double(MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE);
            reference_altitude  = str2double(MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE);
        end
        gps_object = GPS(reference_latitude,reference_longitude,reference_altitude); % Load the GPS class
        ENU_coordinates = gps_object.WGSLLA2ENU(LLdata(:,1),LLdata(:,2),reference_altitude*ones(length(LLdata(:,1)),1),reference_latitude,reference_longitude,reference_altitude);

        
        if 1==0
            % Plot all the points with time errors
            NdataThisSensor = length(allTimeDifferences{ith_sensor,1}(:,1));
            Idata = 0.1*ones(NdataThisSensor,1);
            Idata(round(allTimeDifferences{ith_sensor,1}*100)>centiSeconds) = 0.9;
        else
            searchRadiusAndAngles = 10;

            [~, Nnearby]  = fcn_DataClean_findNearPoints(ENU_coordinates, searchRadiusAndAngles, (-1));

            bad_Indicies = find(round(allTimeDifferences{ith_sensor,1}*100)>centiSeconds);
            ENU_badData = ENU_coordinates(bad_Indicies,1:2); %#ok<FNDSB>
            Npoints = length(ENU_coordinates(:,1));
            NbadNearby = nan(Npoints,1);
            for ith_point = 1:Npoints
                this_point = ENU_coordinates(ith_point,1:2);
                distances = sum((this_point - ENU_badData).^2,2).^0.5;
                NbadNearby(ith_point,1) = sum(distances<=searchRadiusAndAngles);
            end
            
            Idata = max(NbadNearby,0)./max(Nnearby,1);

        end


        fcn_plotRoad_plotLLI([LLdata Idata], (plotFormat), colorMapToUse, (fig_num));

        % h_legend = legend(legend_entries);
        % set(h_legend,'Interpreter','none','FontSize',6)

        % Force the plot to fit
        geolimits('auto');
        title(sprintf('GPS errors for %s',GPS_sensor_name),'interpreter','none','FontSize',12)
        cb = colorbar();
        ylabel(cb,'% drop in last 1 second')
    end

    
    sgtitle('Histograms of time samples');

    % % Make axis slightly larger?
    % if flag_rescale_axis
    %     temp = axis;
    %     %     temp = [min(points(:,1)) max(points(:,1)) min(points(:,2)) max(points(:,2))];
    %     axis_range_x = temp(2)-temp(1);
    %     axis_range_y = temp(4)-temp(3);
    %     percent_larger = 0.3;
    %     axis([temp(1)-percent_larger*axis_range_x, temp(2)+percent_larger*axis_range_x,  temp(3)-percent_larger*axis_range_y, temp(4)+percent_larger*axis_range_y]);
    % end
    % 
end

if  flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function




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

