function matDataCellArray  = fcn_DataClean_loadMatDataFromDirectories(rootdirs, varargin)
% fcn_DataClean_loadMatDataFromDirectories
% imports MATLAB data from files contained in specified root
% directories, including all subdirectories. Stores each result into a cell
% array, one for each mat data file. Produces plots of the data via
% optional plotting flags.
%
% FORMAT:
%
%     matDataCellArray = fcn_DataClean_loadMatDataFromDirectories(rootdirs, (searchIdentifiers), (matQueryString), (fid), (plotFlags));
%
% INPUTS:
%
%      rootdirs: either a string containing the folder name where the mat
%      files are located, or a cell array of names of folder locations.
%      NOTE: the folder locations should be complete paths.
%
%      (OPTIONAL INPUTS)
%
%      searchIdentifiers: a required structure indicating the labels to attach to
%      the files that are being loaded. The structure has the following
%      format:
% 
%             clear searchIdentifiers
%             searchIdentifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
%             searchIdentifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
%             searchIdentifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
%             searchIdentifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
%             searchIdentifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
%             searchIdentifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
%             searchIdentifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
%             searchIdentifiers.SourceBagFileName =''; % This is filled in automatically for each file
%
%      For a list of allowable Identifiers, see:
%      https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
%
%      matQueryString: the prefix used to perform the query to search for
%      mat file directories. All directories within the rootdirectors, and
%      any subdirectories of these, are processed. The default
%      matQueryString, if left empty, is: 'mapping_van_'.
%
%      fid: the fileID where to print. Default is 1, to print results to
%      the console.
%
%      plotFlags: a structure of figure numbers to plot results. If set to
%      -1, skips any input checking or debugging, no figures will be
%      generated, and sets up code to maximize speed. The structure has the
%      following format:
%
%         plotFlags.fig_num_plotAllMatTogether = 1111; % This is the figure
%         where all the mat files are plotted together
%
%         plotFlags.fig_num_plotAllMatIndividually = 2222; % This is the
%         number starting the count for all the figures that open,
%         individually, for each mat file after it is loaded.
%
%     the default is to not plot the results
%
% OUTPUTS:
%
%     matDataCellArray: a cell array of data structures containing data
%      fields filled for each mat file
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%      fcn_DataClean_loadMappingVanDataFromFile
%      fcn_DataClean_plotRawData
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_loadMatDataFromDirectories
%     for a full test suite.
%
% This function was written on 2024_09_13 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history
% 2024_09_13 - Sean Brennan, sbrennan@psu.edu
% -- wrote the code originally

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==5 && isequal(varargin{end},-1))
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

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(1,5);

        % Check if rootdirs is a string. If so, convert it to a cell array
        if ~iscell(rootdirs) && (isstring(rootdirs) || ischar(rootdirs))
            rootdirs{1} = rootdirs;
        end

        % Loop through all the directories and make sure they are there
        for ith_directory = 1:length(rootdirs)
            folderName = rootdirs{ith_directory};
            try
                fcn_DebugTools_checkInputsToFunctions(folderName, 'DoesDirectoryExist');
            catch ME
                warning(['It appears that data was not pushed into a folder, for example: ' ...
                    '\\DataCleanClassLibrary\LargeData ' ...
                    'which is the folder where large data is imported for processing. ' ...
                    'Note that this folder is too large to include in the code repository, ' ...
                    'so it must be copied over from a data storage location. Within IVSG, ' ...
                    'this storage location is the OndeDrive folder called GitHubMirror.']);
                warning('The missing folder is: %s',folderName);
                rethrow(ME)
            end
        end

    end
end

% Does user specify?
clear searchIdentifiers
searchIdentifiers.Project = ''; % This is the project sponsoring the data collection
searchIdentifiers.ProjectStage = ''; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
searchIdentifiers.WorkZoneScenario = ''; % Can be one of the ~20 scenarios, see key
searchIdentifiers.WorkZoneDescriptor = ''; % Can be one of the 20 descriptors, see key
searchIdentifiers.Treatment = ''; % Can be one of 9 options, see key
searchIdentifiers.DataSource = ''; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
searchIdentifiers.AggregationType = ''; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
searchIdentifiers.SourceBagFileName = ''; % This is filled in automatically for each file
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        searchIdentifiers = temp;
    end
end


% Does user want to specify matQueryString?
matQueryString = 'mapping_van_';
if 3 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        matQueryString = temp;
    end
end

% Does user want to specify fid?
fid = 1;
if 4 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        fid = temp;
    end
end


% Does user want to specify plotFlags?
% Set defaults
plotFlags.fig_num_plotAllMatTogether = [];
plotFlags.fig_num_plotAllMatIndividually = [];
flag_do_plots = 0;
if (0==flag_max_speed) &&  (5<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        plotFlags = temp;
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

%% Find all the directories that will be queried
only_directory_filelist = [];
for ith_rootDirectory = 1:length(rootdirs)
    rootdir = rootdirs{ith_rootDirectory};
    if fid
        fprintf(fid,'\n\nLoading directory candidates from directory: %s\n',rootdir);
    end
    directoryQuery = fullfile(rootdir, '**',cat(2,matQueryString,'.mat'));
    filelist = dir(directoryQuery);  % gets list of files and folders in any subfolder that start with name 'mapping_van_'
    only_directory_filelist = [only_directory_filelist; filelist([filelist.isdir]==0)];  %#ok<AGROW> % keep only files from list
end


%% Loop through all the directories
% Initialize key storage variables
NdataSets = length(only_directory_filelist);
matDataCellArray = cell(1,1);

% Loop through all the Bag folders in each directory
NgoodDataSets = 0;
for ith_folder = 1:NdataSets

    % Load the mat data
    matName = only_directory_filelist(ith_folder).name;
    dataFolderString = only_directory_filelist(ith_folder).folder;
    matPath = fullfile(dataFolderString, matName);

    % Check that the fields all match
    tempLoad = load(matPath);
    tempFieldNames = fieldnames(tempLoad);
    assert(length(tempFieldNames)==1,'No main field detected. Unsure what field to plot.');
    mainField = tempFieldNames{1};
    tempDataStructure = tempLoad.(mainField);

    searchFields = fieldnames(searchIdentifiers);
    flag_thisIsGoodMatFile = 1;
    for ith_searchfield = 1:length(searchFields)
        searchFieldName = searchFields{ith_searchfield};
        if ~isempty(searchIdentifiers.(searchFieldName))
            if ~strcmp(searchIdentifiers.(searchFieldName),tempDataStructure.Identifiers.(searchFieldName))
                flag_thisIsGoodMatFile = 0;
            end
        end
    end

    if 1==flag_thisIsGoodMatFile
        if fid
            fprintf(fid,'Loading file %.0d of %.0d: %s\n', ith_folder, NdataSets, matName);
        end
        NgoodDataSets = NgoodDataSets + 1;
        matDataCellArray{NgoodDataSets,1} = tempLoad;
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
if (1==flag_do_plots)

    %% Plot all of them together?
    if ~isempty(plotFlags.fig_num_plotAllMatTogether) && (0<NgoodDataSets)
        fig_num_plotAllMatTogether = plotFlags.fig_num_plotAllMatTogether;
        figure(fig_num_plotAllMatTogether);
        clf;

        % Test the function
        clear plotFormat
        plotFormat.LineStyle = '-';
        plotFormat.LineWidth = 2;
        plotFormat.Marker = 'none';
        plotFormat.MarkerSize = 5;

        legend_entries = cell(length(matDataCellArray)+1,1);
        for ith_matData = 1:length(matDataCellArray)
            matName = only_directory_filelist(ith_matData).name;
            plotFormat.Color = fcn_geometry_fillColorFromNumberOrName(ith_matData);
            colorMap = plotFormat.Color;
            tempFieldNames = fieldnames(matDataCellArray{ith_matData});
            assert(length(tempFieldNames)==1,'No main field detected. Unsure what field to plot.');
            mainField = tempFieldNames{1};
            tempDataStructure = matDataCellArray{ith_matData}.(mainField);
            fcn_DataClean_plotRawData(tempDataStructure, (matName), (plotFormat), (colorMap), (fig_num_plotAllMatTogether))
            legend_entries{ith_matData} = matName;

        end

        % Plot the base station
        fcn_plotRoad_plotLL([],[],fig_num_plotAllMatTogether);
        legend_entries{end} = 'Base Station';

        h_legend = legend(legend_entries);
        set(h_legend,'Interpreter','none','FontSize',6)
    
        % Force the plot to fit
        geolimits('auto');

        title(searchIdentifiers.WorkZoneScenario,'interpreter','none','FontSize',12)

    end




    %% Plot all individually?
    if ~isempty(plotFlags.fig_num_plotAllMatIndividually)  && (0<NgoodDataSets)
        fig_num_plotAllMatIndividually = plotFlags.fig_num_plotAllMatIndividually;


        for ith_matData = 1:length(matDataCellArray)
            fig_num = fig_num_plotAllMatIndividually -1 +ith_matData;
            figure(fig_num);
            clf;

            % Plot the base station
            fcn_plotRoad_plotLL([],[],fig_num);

            % Plot the data
            matName = only_directory_filelist(ith_matData).name;
            tempFieldNames = fieldnames(matDataCellArray{ith_matData});
            assert(length(tempFieldNames)==1,'No main field detected. Unsure what field to plot.');
            mainField = tempFieldNames{1};
            tempDataStructure = matDataCellArray{ith_matData}.(mainField);
            fcn_DataClean_plotRawData(tempDataStructure, (matName), ([]), ([]), (fig_num))

            pause(0.02);

        end
    end


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

