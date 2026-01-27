function fcn_DebugTools_replaceStringInDirectory(directoryPath, oldString, newString, varargin)
% fcn_DebugTools_replaceStringInDirectory
% Replaces 'oldString' with 'newString' in all files within
% 'directoryPath'. If the fileName itself in the directory path contains
% the old string, writes to that new file also (does not modify the old
% file).
%
% FORMAT:
%
%      fcn_DebugTools_replaceStringInDirectory(directoryPath, oldString, newString, (flagSkipComments), (fig_num));
%
% INPUTS:
%
%      directoryPath: a string representing the directory to search. If
%      multiple directories are to be checked, can enter a cell array of
%      strings, one for each path.
%
%      oldString: the string to replace
%
%      newString: the string that will be substituted into oldString
%
%      (OPTIONAL INPUTS)
%
%     flagSkipComments: Set to:
%         0 or [] (default) to change all instances 
%         1 to skip any lines that start with a comment ('%')
%         2 to skip only lines that start with '% As:' 
%
%     fig_num: a figure number to plot results. If set to -1, skips any
%     input checking or debugging, no figures will be generated, and sets
%     up code to maximize speed. As well, if given, this forces the
%     variable types to be displayed as output and as well makes the input
%     check process verbose
%
% OUTPUTS:
%
%      (none)

%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DebugTools_replaceStringInDirectory
%     for a full test suite.
%
% This function was written on 2025_09_26 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
% 2025_09_26 - sbrennan@psu.edu
% -- wrote the code originally, using breakDataIntoLaps as starter

% TO-DO
% (none)

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 5; % The largest Number of argument inputs to the function
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
        narginchk(3,MAX_NARGIN);

        % % Check the input_path to be sure it has 2 or 3 columns, minimum 2 rows
        % % or more
        % fcn_DebugTools_checkInputsToFunctions(input_path, '2or3column_of_numbers',[2 3]);
    end
end

% Does user want to specify flagSkipComments?
flagSkipComments = 0; % Default is to change all comments
if 4 <= nargin
    temp = varargin{1};
    if ~isempty(temp) % Did the user NOT give an empty value?
       flagSkipComments = temp;
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

if ~iscell(directoryPath)
    directoryPath = {directoryPath};
end

for ith_path = 1:length(directoryPath)
    thisDirectoryPath = directoryPath{ith_path};

    % Get a list of all files in the directory
    fileList = dir(fullfile(thisDirectoryPath, '*.*')); % Adjust file extension as needed

    % Filter out directories from the list
    fileList = fileList(~[fileList.isdir]);

    fprintf(1,'Checking %0.f files in directory: %s\n',length(fileList), thisDirectoryPath)

    for i = 1:length(fileList)
        fileName = fileList(i).name;

        sourceFilePath = fullfile(thisDirectoryPath, fileName);

        numChanged = 0;
        numSkipped = 0;
        try
            % Read the entire file content
            fileContent = readlines(sourceFilePath);

            if any(contains(fileContent,oldString))
                fprintf(1,'Modifying file: %s\n',fileName)


                modifiedContent = fileContent;
                for ith_line = 1:length(fileContent(:,1))
                    thisLine = fileContent(ith_line,1);
                    thisLineCharacters = char(thisLine);
                    if contains(thisLine,oldString)
                        if 0==flagSkipComments || ...
                                (1==flagSkipComments && thisLineCharacters(1)~='%') || ...
                                (2==flagSkipComments && length(thisLineCharacters)>5 && ~strcmp(thisLineCharacters(1:5),'% As:'))

                            modifiedContent(ith_line,1) = replace(thisLine, oldString, newString);
                            numChanged = numChanged+1;
                        else
                            numSkipped = numSkipped+1;
                        end
                    end
                end

                % Write the modified content back to the file
                writelines(modifiedContent, sourceFilePath);

 
            end % Ends if contains on file contents
            fprintf('Changed %.0f instances, skipped %.0f comments in %s\n', numChanged, numSkipped, fileName);
            % Perform the string replacement
            if contains(fileName,oldString)
                newFileName = replace(fileName,oldString, newString);
                destinationFilePath = fullfile(thisDirectoryPath, newFileName);
                fprintf(1,'\tChanging name from: %s\n',fileName)
                fprintf(1,'\tChanging name to:  %s\n',newFileName)
                [moveStatus,moveMessage,moveMessageID] = movefile(sourceFilePath, destinationFilePath);
                if 1~=moveStatus
                    warning('Unexpected result encountered in file move.\nMessage: %s\n MessageID: %.0f',moveMessage, moveMessageID);
                end

                % For debugging - use the line below to put a breakpoint
                if numChanged~=0
                    temp = 2; %#ok<NASGU>
                end
            end % Ends if contains on file name, then move
        catch ME
            warning('Error processing file %s: %s\n', fileName, ME.message);
        end % Ends try

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


