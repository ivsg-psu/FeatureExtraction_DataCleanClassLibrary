function directory_filelist  = fcn_DataClean_listDirectoryContents(rootdirs, varargin)
% fcn_DataClean_listDirectoryContents
% Creates a list of specified root directories, including all
% subdirectories, of a given query. Allows specification whether to keep
% either files, directories, or both.
%
% FORMAT:
%
%      directory_filelist = fcn_DataClean_listDirectoryContents(rootdirs, (fileQueryString), (flag_fileOrDirectory), (fid))
%
% INPUTS:
%
%      rootdirs: either a string containing the folder name(s) where to
%      query, or a cell array of names of folder locations. NOTE: the
%      folder locations should be complete paths.
%
%      (OPTIONAL INPUTS)
%
%      fileQueryString: the prefix used to perform the query to search for
%      file or directory listings. All directories within the rootdirs, and
%      any subdirectories of these, are processed. The default
%      fileQueryString, if left empty, is: 'mapping_van_'.
%
%      flag_fileOrDirectory: a flag to specify whether files or directories
%      are returned.
% 
%         set to 0 to return only files and no directories
% 
%         set to 1 to return only directories and no files
%
%         set to 2 to return both files and directories (default)
%
%      fid: the fileID where to print. Default is 1, to print results to
%      the console. If set to -1, skips any input checking or debugging, no
%      prints will be generated, and sets up code to maximize speed.
%
% OUTPUTS:
%
%      directory_filelist: a structure array of listings, one for each
%      found match
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%      fcn_DataClean_loadMappingVanDataFromFile
%      fcn_DataClean_plotRawData
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_listDirectoryContents
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
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(2,4);

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
                warning('A directory was specified for query that does not seem to exist!?');
                warning('The missing folder is: %s',folderName);
                rethrow(ME)
            end
        end

    end
end

% Does user want to specify bagQueryString?
fileQueryString = 'mapping_van_';
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        fileQueryString = temp;
    end
end

% Does user want to specify flag_fileOrDirectory?
flag_fileOrDirectory = 2;
if 2 <= nargin
    temp = varargin{2};
    if ~isempty(temp)
        flag_fileOrDirectory = temp;
    end
end

% Does user want to specify fid?
fid = 0;
if (0 == flag_max_speed) && (4 <= nargin)
    temp = varargin{end};
    if ~isempty(temp)
        fid = temp;
    end
end


% % Does user want to specify plotFlags?
% % Set defaults
% plotFlags.fig_num_plotAllRawTogether = [];
% plotFlags.fig_num_plotAllRawIndividually = [];
% flag_do_plots = 0;
% if (0==flag_max_speed) &&  (7<=nargin)
%     temp = varargin{end};
%     if ~isempty(temp)
%         plotFlags = temp;
%         flag_do_plots = 1;
%     end
% end

flag_do_plots = 0; % Nothing to plot


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

%% Check if rootdirs is a string. If so, convert it to a cell array
if ~iscell(rootdirs) && (isstring(rootdirs) || ischar(rootdirs))
    rootdirs{1} = rootdirs;
end

%% Find all the directories that will be queried
directory_filelist = [];
if fid>0
    fprintf(fid,'\nSEARCHING DIRECTORIES, searching for: %s\n',fileQueryString);
end

for ith_rootDirectory = 1:length(rootdirs)
    rootdir = rootdirs{ith_rootDirectory};
    if  fid>0
        fprintf(fid,'Loading directory candidates from directory: %s\n',rootdir);
    end
    directoryQuery = fullfile(rootdir, '**',fileQueryString);
    filelist = dir(directoryQuery);  % gets list of files and folders in any subfolder that start with name 'mapping_van_'

    switch flag_fileOrDirectory
        case 0  
            % Files only
            fileListToAdd = filelist([filelist.isdir]==0);
        case 1
            % Directories only
            fileListToAdd = filelist(find([filelist.isdir].*[(~strcmp({filelist.name},'..'))]==1)); %#ok<FNDSB>
        case 2
            % Both
            fileListToAdd = filelist;
    end

    directory_filelist = [directory_filelist; fileListToAdd];  %#ok<AGROW> % keep only directories from list
    if fid>0
        fprintf(fid,'\tCandidates found in directory: %.0f\n',length(fileListToAdd));
    end
end

if  fid>0
    fprintf(fid,'Total candidates found: %.0f\n',length(directory_filelist));
end

if  fid>0
    fprintf(fid,'\nCONTENTS FOUND:\n');
    % Print the fields
    previousDirectory = '';
    for jth_file = 1:length(directory_filelist)
        thisFolder = directory_filelist(jth_file).folder;
        if ~strcmp(thisFolder,previousDirectory)
            previousDirectory = thisFolder;
            fprintf(fid,'Folder: %s\n',thisFolder);
        end
        if (0==flag_fileOrDirectory) || (2==flag_fileOrDirectory)
            fprintf(fid,'\t%s\n',directory_filelist(jth_file).name);
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
if (1==flag_do_plots)

    % Nothing to plot!

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

%% fcn_INTERNAL_makeDirectory
function fcn_INTERNAL_makeDirectory(targetDirectoryName)
if 7~=exist(targetDirectoryName,'dir')
    % Need to make the directory

    % Find full path
    full_path_directory_to_create = fullfile(targetDirectoryName);

    % Find part below current directory
    relativePath = extractAfter(full_path_directory_to_create,cat(2,cd(),filesep));

    [successFlag,message] = mkdir(cd,relativePath);
    if 1~=successFlag 
        warning('on','backtrace');
        warning('Unable to create directory: %s. Message given:',fullPathDirectoryToCheck,message);
        error('Image save specified that directory be created, but cannot create directory. Unable to continue.');
    end
    
    % % Split the relativePath into parts
    % pathParts = split(relativePath,filesep);
    % previousParentPath = cd();
    % for ith_directory = 1:length(pathParts)
    %     directoryToCheck = pathParts{ith_directory};
    %     fullPathDirectoryToCheck = fullfile(previousParentPath,directoryToCheck);
    % 
    %     % Does the directory exist, or do we need to make it?
    %     if 7~=exist(fullPathDirectoryToCheck,'dir')
    %         % Need to make the directory
    %         successFlag = mkdir(previousParentPath,directoryToCheck);
    %         if 1~=successFlag
    %             warning('on','backtrace');
    %             warning('Unable to create directory: %s',fullPathDirectoryToCheck)
    %             error('Image save specified that directory be created, but cannot create directory. Unable to continue.');
    %         end
    %     end
    % 
    %     previousParentPath = fullfile(previousParentPath,directoryToCheck);
    % 
    % end
end
end % Ends fcn_INTERNAL_makeDirectory

%% fcn_INTERNAL_saveImages
function fcn_INTERNAL_saveImages(imageName, saveFlags)
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

