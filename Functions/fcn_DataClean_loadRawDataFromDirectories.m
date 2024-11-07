function rawDataCellArray  = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, varargin)
% fcn_DataClean_loadRawDataFromDirectories
% imports raw data from bag files contained in a list of specified root
% directories, including all subdirectories. Stores each result into a cell
% array, one for each raw data directory. Produces plots of the data and
% mat files of the data, and can save results to user-chosen directories.
%
% FORMAT:
%
%      rawDataCellArray = fcn_DataClean_loadRawDataFromDirectories(rootdirs, Identifiers, (bagQueryString), (fid), (Flags), (saveFlags), (plotFlags))
%
% INPUTS:
%
%      rootdirs: either a string containing the folder name where the bag
%      files are located, or a cell array of names of folder locations.
%      NOTE: the folder locations should be complete paths.
%
%      Identifiers: a required structure indicating the labels to attach to
%      the files that are being loaded. The structure has the following
%      format:
% 
%             clear Identifiers
%             Identifiers.Project = 'PennDOT ADS Workzones'; % This is the project sponsoring the data collection
%             Identifiers.ProjectStage = 'OnRoad'; % Can be 'Simulation', 'TestTrack', or 'OnRoad'
%             Identifiers.WorkZoneScenario = 'I376ParkwayPitt'; % Can be one of the ~20 scenarios, see key
%             Identifiers.WorkZoneDescriptor = 'WorkInRightLaneOfUndividedHighway'; % Can be one of the 20 descriptors, see key
%             Identifiers.Treatment = 'BaseMap'; % Can be one of 9 options, see key
%             Identifiers.DataSource = 'MappingVan'; % Can be 'MappingVan', 'AV', 'CV2X', etc. see key
%             Identifiers.AggregationType = 'PreRun'; % Can be 'PreCalibration', 'PreRun', 'Run', 'PostRun', or 'PostCalibration'
%             Identifiers.SourceBagFileName =''; % This is filled in automatically for each file
%
%      For a list of allowable Identifiers, see:
%      https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_LoadWorkZone
%
%      (OPTIONAL INPUTS)
%
%      bagQueryString: the prefix used to perform the query to search for
%      bag file directories. All directories within the rootdirectors, and
%      any subdirectories of these, are processed. The default
%      bagQueryString, if left empty, is: 'mapping_van_'.
%
%      fid: the fileID where to print. Default is 1, to print results to
%      the console.
%
%      Flags: a structure containing key flags for the individual bag file
%      loading process. The defaults, and explanation of each, are below:
%
%           Flags.flag_do_load_sick = 0; % Loads the SICK LIDAR data
%           Flags.flag_do_load_velodyne = 0; % Loads the Velodyne LIDAR
%           Flags.flag_do_load_cameras = 0; % Loads camera images
%           Flags.flag_select_scan_duration = 0; % Lets user specify scans from Velodyne
%           Flags.flag_do_load_GST = 0; % Loads the GST field from Sparkfun GPS Units          
%           Flags.flag_do_load_VTG = 0; % Loads the VTG field from Sparkfun GPS Units
%
%      saveFlags: a structure of flags to determine how/where/if the
%      results are saved. The defaults are below
%
%         saveFlags.flag_saveMatFile = 0; % Set to 1 to save each rawData
%         file into the directory
%
%         saveFlags.flag_saveMatFile_directory = ''; % String with full
%         path to the directory where to save mat files
%
%         saveFlags.flag_saveImages = 0; % Set to 1 to save each image
%         file into the directory
%
%         saveFlags.flag_saveImages_directory = ''; % String with full
%         path to the directory where to save image files
%
%      plotFlags: a structure of figure numbers to plot results. If set to
%      -1, skips any input checking or debugging, no figures will be
%      generated, and sets up code to maximize speed. The structure has the
%      following format:
%
%         plotFlags.fig_num_plotAllRawTogether = 1111; % This is the figure
%         where all the bag files are plotted together
%
%         plotFlags.fig_num_plotAllRawIndividually = 2222; % This is the
%         number starting the count for all the figures that open,
%         individually, for each bag file after it is loaded.
%
%     the default is to not plot the results
%
% OUTPUTS:
%
%      rawDataCellArray: a cell array of data structures containing data
%      fields filled for each ROS topic
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%      fcn_DataClean_loadMappingVanDataFromFile
%      fcn_DataClean_plotRawData
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_loadRawDataFromDirectories
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
if (nargin==7 && isequal(varargin{end},-1))
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
        narginchk(2,7);

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
                warning('on','backtrace');
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

% Does user want to specify bagQueryString?
bagQueryString = 'mapping_van_';
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        bagQueryString = temp;
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


% Does user specify Flags?
% Set defaults
Flags.flag_do_load_SICK = 0;
Flags.flag_do_load_Velodyne = 0;
Flags.flag_do_load_cameras = 0;
Flags.flag_select_scan_duration = 0;
Flags.flag_do_load_GST = 0;
Flags.flag_do_load_VTG = 0;

if 5 <= nargin
    temp = varargin{3};
    if ~isempty(temp)
        Flags = temp;
    end
end

% Does user specify saveFlags?
% Set defaults
saveFlags.flag_saveMatFile = 0;
saveFlags.flag_saveMatFile_directory = '';
saveFlags.flag_saveImages = 0;
saveFlags.flag_saveImages_directory = '';
if 6 <= nargin
    temp = varargin{4};
    if ~isempty(temp)
        saveFlags = temp;
    end
end

% Does user want to specify plotFlags?
% Set defaults
plotFlags.fig_num_plotAllRawTogether = [];
plotFlags.fig_num_plotAllRawIndividually = [];
flag_do_plots = 0;
if (0==flag_max_speed) &&  (7<=nargin)
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

%% Make sure the image save directory is there if image save is requested.
if 1==saveFlags.flag_saveImages && 7~=exist(saveFlags.flag_saveImages_directory,'dir') && 0==saveFlags.flag_forceDirectoryCreation
    warning('on','backtrace');
    warning('Unable to find directory: %s',saveFlags.flag_saveImages_directory)
    error('Image save specified that copies image into a non-existing directory. Unable to continue.');
end

% Create the image save directory if needed
if 1==saveFlags.flag_saveImages && saveFlags.flag_forceDirectoryCreation 
    directoryName = saveFlags.flag_saveImages_directory;
    fcn_DebugTools_makeDirectory(directoryName);
end

%% Make sure the MAT save directory is there if MAT file save is requested.
if 1==saveFlags.flag_saveMatFile &&  7~=exist(saveFlags.flag_saveMatFile_directory,'dir') && 0==saveFlags.flag_forceDirectoryCreation
    warning('on','backtrace');
    warning('Unable to find directory: %s',saveFlags.flag_saveMatFile_directory)
    error('MAT file save specified that copies files into a non-existing directory. Unable to continue.');
end

% Create the image save directory if needed
if  1==saveFlags.flag_saveMatFile && saveFlags.flag_forceDirectoryCreation 
    directoryName = saveFlags.flag_saveMatFile_directory;
    fcn_DebugTools_makeDirectory(directoryName);    
end


%% Find all the directories that will be queried
only_directory_filelist  = fcn_DebugTools_listDirectoryContents(rootdirs, (bagQueryString), (1), (fid));

%% Loop through all the directories
% Initialize key storage variables
NdataSets = length(only_directory_filelist);
rawDataCellArray = cell(NdataSets,1);

% Loop through all the Bag folders in each directory
for ith_folder = 1:NdataSets

    % Load the raw data
    bagName = only_directory_filelist(ith_folder).name;
    dataFolderString = only_directory_filelist(ith_folder).folder;
    bagPath = fullfile(dataFolderString, bagName);

    if fid
        fprintf(fid,'\nLoading file %.0d of %.0d: %s\n', ith_folder, NdataSets, bagName);
    end

    rawDataCellArray{ith_folder,1} = fcn_DataClean_loadMappingVanDataFromFile(bagPath, Identifiers, (bagName), (fid), (Flags), (-1));
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

    if fid
        fprintf(fid,'\nBEGINNING PLOTTING: \n');
    end

    %% Plot all of them together?
    if ~isempty(plotFlags.fig_num_plotAllRawTogether)
        fig_num_plotAllRawTogether = plotFlags.fig_num_plotAllRawTogether;
        figure(fig_num_plotAllRawTogether);
        clf;

        % Test the function
        clear plotFormat
        plotFormat.LineStyle = '-';
        plotFormat.LineWidth = 2;
        plotFormat.Marker = 'none';
        plotFormat.MarkerSize = 5;

        legend_entries = cell(length(rawDataCellArray)+1,1);
        for ith_rawData = 1:length(rawDataCellArray)
            bagName = only_directory_filelist(ith_rawData).name;
       
            if fid
                fprintf(fid,'\tPlotting file %.0d of %.0d: %s\n', ith_rawData, length(rawDataCellArray), bagName);
            end
            plotFormat.Color = fcn_geometry_fillColorFromNumberOrName(ith_rawData);
            colorMap = plotFormat.Color;
            fcn_DataClean_plotRawData(rawDataCellArray{ith_rawData}, (bagName), (plotFormat), (colorMap), (fig_num_plotAllRawTogether))
            legend_entries{ith_rawData} = bagName;

        end

        % Plot the base station
        fcn_plotRoad_plotLL([],[],fig_num_plotAllRawTogether);
        legend_entries{end} = 'Base Station';

        h_legend = legend(legend_entries);
        set(h_legend,'Interpreter','none','FontSize',6)
    
        % Force the plot to fit
        geolimits('auto');

        title(Identifiers.WorkZoneScenario,'interpreter','none','FontSize',12)

        % Save the image to file?
        if 1==saveFlags.flag_saveImages
            fcn_INTERNAL_saveImages(cat(2,'mapping_van_',Identifiers.WorkZoneScenario), saveFlags);
        end

    end




    %% Plot all individually, and save all images and mat files
    if ~isempty(plotFlags.fig_num_plotAllRawIndividually)
        fig_num_plotAllRawIndividually = plotFlags.fig_num_plotAllRawIndividually;


        for ith_rawData = 1:length(rawDataCellArray)
            fig_num = fig_num_plotAllRawIndividually -1 +ith_rawData;
            figure(fig_num);
            clf;

            % Plot the base station
            fcn_plotRoad_plotLL([],[],fig_num);

            % Plot the data
            bagName = only_directory_filelist(ith_rawData).name;
            fcn_DataClean_plotRawData(rawDataCellArray{ith_rawData}, (bagName), ([]), ([]), (fig_num))

            pause(0.1);


            % Save the image to file?
            if 1==saveFlags.flag_saveImages

                % Make sure bagName is good
                if contains(bagName,'.')
                    bagName_clean = extractBefore(bagName,'.');
                else
                    bagName_clean = bagName;
                end

                % Save to the name
                fcn_INTERNAL_saveImages(char(bagName_clean), saveFlags);

            end

            % Save the mat file?
            if 1 == saveFlags.flag_saveMatFile
                fcn_INTERNAL_saveMATfile(rawDataCellArray{ith_rawData}, char(bagName_clean), saveFlags);
            end
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


%% fcn_INTERNAL_saveImages
function fcn_INTERNAL_saveImages(imageName, saveFlags)

pause(2); % Wait 2 seconds so that images can load

Image = getframe(gcf);
PNG_image_fname = cat(2,imageName,'.png');
PNG_imagePath = fullfile(saveFlags.flag_saveImages_directory,PNG_image_fname);
if 2~=exist(PNG_imagePath,'file') || 1==saveFlags.flag_forceImageOverwrite
    imwrite(Image.cdata, PNG_imagePath);
end

FIG_image_fname = cat(2,imageName,'.fig');
FIG_imagePath = fullfile(saveFlags.flag_saveImages_directory,FIG_image_fname);
if 2~=exist(FIG_imagePath,'file') || 1==saveFlags.flag_forceImageOverwrite
    savefig(FIG_imagePath);
end
end % Ends fcn_INTERNAL_saveImages

%% fcn_INTERNAL_saveMATfile
function  fcn_INTERNAL_saveMATfile(rawData, MATfileName, saveFlags)

MAT_fname = cat(2,MATfileName,'.mat');
MAT_fullPath = fullfile(saveFlags.flag_saveMatFile_directory,MAT_fname);
if 2~=exist(MAT_fullPath,'file') || 1==saveFlags.flag_forceMATfileOverwrite
    save(MAT_fullPath,'rawData');
end

end % Ends fcn_INTERNAL_saveMATfile

