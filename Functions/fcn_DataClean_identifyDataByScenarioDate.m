function Identifiers = fcn_DataClean_identifyDataByScenarioDate(scenarioString, dateString, varargin)
% fcn_DataClean_identifyDataByScenarioDate
% Given a string identifying a scenario, and a date of testing, fills in
% the identifiers for that scenario. Also sets system variables for
% plotting that scenario.
%
% FORMAT:
%
%      Identifiers = fcn_DataClean_identifyDataByScenarioDate(scenarioString, dateString, (fid), (fig_num))
%
% INPUTS:
%
%      scenarioString: a string used to denote the scenario
%
%      dateString: a string used to denote the testing date, in form of
%      'YYYY-MM-DD'
%
%      (OPTIONAL INPUTS)
%
%      fid: a file ID to print results of analysis. If not entered, no
%      output is given (FID = 0). Set fid to 1 for printing to console.
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      Identifiers: a structure listing the details of the scenario.
% 
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_identifyDataByScenarioDate
%     for a full test suite.
%
% This function was written on 2024_11_07 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
% 2024_11_07 - sbrennan@psu.edu
% -- wrote the code originally by copying out of
% script_mainDataClean_loadAndSaveAllSitesRawData

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==4 && isequal(varargin{end},-1))
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
if (0 == flag_max_speed)
    if flag_check_inputs
        % Are there the right number of inputs?
        narginchk(2,4);
    end
end

% Does the user want to specify the fid?
fid = 0;
% Check for user input
if 3 <= nargin
    temp = varargin{1};
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

% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (4<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp; %#ok<NASGU>
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


Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
Identifiers.SourceBagFileName =''; % This is filled in automatically for each file

if ~isnan(str2double(scenarioString(1))) || strcmp(scenarioString,'BaseMap')
    % Location for Test Track base station
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');
    Identifiers.ProjectStage = 'TestTrack'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
elseif strcmp(scenarioString,'I376ParkwayPitt')
    % Location for Pittsburgh, site 1
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.44181017');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-79.76090840');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','327.428');
    Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
elseif strcmp(scenarioString,'PA653Normalville')
    % Location for Site 2, Falling water
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','39.995339');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-79.445472');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');
    Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
elseif strcmp(scenarioString,'PA51Aliquippa')
    % Location for Aliquippa, site 3
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.694871');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-80.263755');
    setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','223.294');
    Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
else
    error('Unknown site: %s',scenarioString);    
end


%%%%
% Set the Identifiers
% For details on identifiers, see https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone

if 0~=fid
    fprintf(fid,'Filling in Identifiers for: %s\n',scenarioString);
end
Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
Identifiers.WorkZoneScenario = scenarioString; % Can be one of the ~20 scenarios, see key

switch scenarioString
    case 'BaseMap'
        Identifiers.WorkZoneDescriptor = 'BaseMap'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PreCalibration'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-08-05','2024-08-12','2024-08-13'};    
    case '1.1'
        Identifiers.WorkZoneDescriptor = 'ShoulderWorkWithMinorEncroachment'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.2'
        Identifiers.WorkZoneDescriptor = 'RoadClosureWithDetour'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.3'
        Identifiers.WorkZoneDescriptor = 'SelfRegulatingLaneShiftIntoOpposingLane'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.4'
        Identifiers.WorkZoneDescriptor = 'SelfRegulatingLaneShiftIntoCenterOfTurnLane'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.5'
        Identifiers.WorkZoneDescriptor = 'WorkInCenterTurnLane'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '1.6'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-09-17'};
    case '2.1'
        Identifiers.WorkZoneDescriptor = 'RoadClosureWithDetourAndNumberedTrafficRoute'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '2.2'
        Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithSelfRegulatingStopControl'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '2.3'
        Identifiers.WorkZoneDescriptor = 'LaneShiftToTemporaryRoadway'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-04-19'};
    case '2.4'
        Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithTemporarySignals'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '3.1'
        Identifiers.WorkZoneDescriptor = 'MovingLaneClosure'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '4.1a'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLane'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-08-14','2024-08-15'};
    case '4.1b'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLanePennTurnpike'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-10-24'};
    case '4.2'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneNearExitRamp'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-02-01'};        
    case '4.3'
        Identifiers.WorkZoneDescriptor = 'WorkInEntranceRampWithStopControl'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-02-06','2024-08-15'};
    case '5.1a'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzone'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-09-04'};
    case '5.1b'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzonePennTurnpike'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-07-10','2024-07-11'};
    case '5.2'
        Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithTemporarySignals'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-09-13'};
    case '6.1'
        Identifiers.WorkZoneDescriptor = 'LongTermShoulderUse'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-10-31'};
    case 'I376ParkwayPitt'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-06-24','2024-07-10','2024-07-11','2024-10-16'};
    case 'PA653Normalville'
        Identifiers.WorkZoneDescriptor = 'SingleLaneApproachWithTemporarySignals'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-08-22'};
    case 'PA51Aliquippa'
        Identifiers.WorkZoneDescriptor = 'WorkInRightLaneMobileWorkzone'; % Can be one of the 20 descriptors, see key
        Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
        Identifiers.AggregationType = 'PostRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        validDateStrings = {'2024-09-19','2024-09-20'};
        if strcmp(validDateStrings{1},dateString)
            Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
        end
    otherwise
        warning('on','backtrace');
        warning('Unknown scenario given: %s',scenarioString);
        error('Unknown scenario given. Unable to continue.');
end

% Make sure the date string is valid
if ~any(strcmp(dateString,validDateStrings))
    warning('on','backtrace');
    warning('Invalid date string, %s, given for scenario: %s. Expecting one of:', dateString, scenarioString);    
    for ith_valid = 1:length(validDateStrings)
        fprintf(1,'\t%s\n',validDateStrings{ith_valid});
    end
    error('Unknown scenario date given. Unable to continue.');
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
if flag_do_plots
    
    % Nothing to plot        
    
end

if flag_do_debug
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

