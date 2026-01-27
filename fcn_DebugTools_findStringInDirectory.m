function flagStringWasFound = fcn_DebugTools_findStringInDirectory(directoryPath, queryString, varargin)
% fcn_DebugTools_findStringInDirectory
% Finds all instances of 'queryString' within 'directoryPath'.
%
% FORMAT:
%
%     flagStringWasFound = fcn_DebugTools_findStringInDirectory(directoryPath, queryString, (directoryQuery), (fig_num));
%
% INPUTS:
%
%     directoryPath: a string representing the directory to search. If
%     multiple directories are to be checked, can enter a cell array of
%     strings, one for each path.
%
%     queryString: the string to find
%
%     (OPTIONAL INPUTS)
%
%     directoryQuery: a string representing the type of file search to do.
%     Default is '*.*' which searches only the given directory. Other
%     options could include '**' which searches the given directory and all
%     subdirectories of that given directory, 'fcn_*' etc.
%
%     fig_num: a figure number to plot results. If set to -1, skips any
%     input checking or debugging, no figures will be generated, and sets
%     up code to maximize speed. As well, if given, this forces the
%     variable types to be displayed as output and as well makes the input
%     check process verbose
%
% OUTPUTS:
%
%     flagStringWasFound: returns true if the queryString was found, false
%     otherwise
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DebugTools_findStringInDirectory
%     for a full test suite.
%
% This function was written on 2025_09_27 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
% 2025_09_27 - sbrennan@psu.edu
% -- wrote the code originally, using breakDataIntoLaps as starter

% TO-DO
% (none)

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 4; % The largest Number of argument inputs to the function
flag_max_speed = 0; % The default. This runs code with all error checking
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_LAPS_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_LAPS_FLAG_CHECK_INPUTS");
    MATLABFLAG_LAPS_FLAG_DO_DEBUG = getenv("MATLABFLAG_LAPS_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_LAPS_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_LAPS_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_LAPS_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_LAPS_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug % If debugging is on, print on entry/exit to the function
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_fig_num = 999978; %#ok<NASGU>
else
    debug_fig_num = []; %#ok<NASGU>
end

%% check input arguments?
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
if 0==flag_max_speed
    if flag_check_inputs
        % Are there the right number of inputs?
        narginchk(2,MAX_NARGIN);

        % % Check the input_path to be sure it has 2 or 3 columns, minimum 2 rows
        % % or more
        % fcn_DebugTools_checkInputsToFunctions(input_path, '2or3column_of_numbers',[2 3]);
    end
end


% Does user want to specify directoryQuery?
directoryQuery = '*.*'; % Default is search only current directory
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp) % Did the user NOT give an empty value?
       directoryQuery = temp;
    end
end

% Does user want to show the plots?
flag_do_plots = 0; % Default is to NOT show plots
if (0==flag_max_speed) && (MAX_NARGIN == nargin) 
    temp = varargin{end};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
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

flagStringWasFound = false;

if ~iscell(directoryPath)
    directoryPath = {directoryPath};
end

for ith_path = 1:length(directoryPath)
    foundFile = '';
    thisDirectoryPath = directoryPath{ith_path};

    % Get a list of all files in the directory
    fileList = dir(fullfile(thisDirectoryPath, directoryQuery)); % Adjust file extension as needed

    % Filter out directories from the list
    fileList = fileList(~[fileList.isdir]);

    fprintf(1,'\nChecking folder:%s \nFor string: %s\n',thisDirectoryPath, queryString);
    for i = 1:length(fileList)
        fileName = fileList(i).name;
        flag_checkThisFile = 1;
        % if ~contains(fileName,fileQueryString)
        %     flag_checkThisFile = 0;
        % end
        if flag_checkThisFile
            filePath = fullfile(thisDirectoryPath, fileName);
            try
                % Read the entire file content
                fileContent = readlines(filePath);

                % Perform line-by-line search
                for ith_line = 1:length(fileContent(:,1))
                    thisLine = fileContent(ith_line,1);
                    thisLineCharacters = char(thisLine);

                    % Print to the screen the name fo the file (and update
                    % the flag) every time the file changes, but only then
                    if contains(thisLine,queryString) 
                        if ~strcmp(foundFile,fileName)
                            foundFile = fileName;
                            fprintf(1,'Found instance in: %s\n',fileName);
                            flagStringWasFound = true;
                        end
                        fprintf(1,'\tLine %.0f: %s\n', ith_line, thisLineCharacters);
                    end
                end
            catch ME
                warning('Error processing file %s: %s\n', fileName, ME.message);
            end % Ends try
        end % Ends check if fileName contains
    end % Ends for loop through files
end % Ends for loop through directories

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


