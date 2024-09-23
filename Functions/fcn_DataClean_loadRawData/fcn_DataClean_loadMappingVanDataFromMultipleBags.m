function rawdata_cell = fcn_DataClean_loadMappingVanDataFromMultipleBags(dataFolder,date,Identifiers,fid,varargin)

% imports raw data from mapping van bag files
%
% FORMAT:
%
%      rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagFolderName)
%
% INPUTS:
%
%      bagFolderName: the folder name where the bag files are located as a
%      sub-directory within the LargeData subdirectory of the
%      DataCleanClass library.
%
%      (OPTIONAL INPUTS)
%
%      (none)
%
% OUTPUTS:
%
%      rawdata: a  data structure containing data fields filled for each
%      ROS topic
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_loadMappingVanDataFromFile
%     for a full test suite.
%
% This function was written on 2023_06_19 by S. Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history
% 2023_06_16 - Xinyu Cao
% -- wrote the code originally as a script, using data from
% mapping_van_2023-06-05-1Lap as starter, the main part of the code will be
% functionalized as the function fcn_DataClean_loadRawDataFromFile The
% result of the code will be a structure store raw data from bag file
% 2023_06_19 - S. Brennan
% -- first functionalization of the code
% 2023_06_22 - S. Brennan
% -- fixed fcn_DataClean_loadRawDataFromFile_SickLidar filename
% -- to correct: fcn_DataClean_loadRawDataFromFile_sickLIDAR
% 2023_06_22 - S. Brennan
% AGAIN - someone reverted the edits
% -- fixed fcn_DataClean_loadRawDataFromFile_SickLidar filename
% -- to correct: fcn_DataClean_loadRawDataFromFile_sickLIDAR
% 2023_06_26 - X. Cao
% -- modified fcn_DataClean_loadRawDataFromFile_Diagnostic
% -- The old diagnostic topics 'diagnostic_trigger' and
% 'diagnostic_encoder' are replaced with 'Trigger_diag' and 'Encoder_diag'
% -- modified fcn_DataClean_loadRawDataFromFile_SparkFun_GPS
% -- each sparkfun gps has three topics, sparkfun_gps_GGA, sparkfun_gps_VTG
% and sparkfun_gps_GST. 
% 2023_07_04 - S. Brennan
% -- added FID to fprint to allow printing to file
% -- moved loading print statements to this file, not subfiles


flag_do_debug = 1;  % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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

if isempty(fid)
    fid = 1;
end

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(4,6);
        
    % Check if dataFolder is a directory. If directory is not there, warn
    % the user.
    try
        fcn_DebugTools_checkInputsToFunctions(dataFolder, 'DoesDirectoryExist');
    catch ME
        warning(['It appears that data was not pushed into a folder: ' ...
            '\\DataCleanClassLibrary\LargeData ' ...
            'which is the folder where large data is imported for processing. ' ...
            'Note that this folder is too large to include in the code repository, ' ...
            'so it must be copied over from a data storage location. Within IVSG, ' ...
            'this storage location is the OndeDrive folder called GitHubMirror.']);
        rethrow(ME)
    end
end


if nargin <= 4
    dataFolder = fullfile(pwd, dataFolder, date); % No sub-folder
    flag_do_load_all_data = 1;
elseif nargin == 5
    Flags = varargin{1};
    dataFolder = fullfile(pwd, dataFolder, date);
    flag_do_load_all_data = Flags.flag_do_load_all_data;
    
elseif nargin == 6
    Flags = varargin{1};
    flag_do_load_all_data = Flags.flag_do_load_all_data;
    laneName = varargin{2};
    dataFolder = fullfile(pwd, dataFolder, date,laneName);
  
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
folder_list = dir(dataFolder);
bag_folder_list = folder_list(3:end);
num_folders = length(bag_folder_list);

rawdata_cell = {};
skip_count = 0;

if flag_do_load_all_data == 1
    folder_range = 1:num_folders;
else
    user_input_txt = sprintf('There are %d bag folders, please enter the folder range you want to load. [idx_start:idx_end]', num_folders);
    user_input = input(user_input_txt);
    folder_range = user_input;
end



    
for folder_idx = folder_range
    
    % Check that the list is the file. If it is a directory, the isdir flag
    % will be 1.
    bagFolderName = bag_folder_list(folder_idx).name;
    bagFolderPath = fullfile(dataFolder,bagFolderName);
    isfolder(bagFolderPath)
    if isfolder(bagFolderPath)
        % Get the file name
        % date = 'none';
      
        rawdata_temp = fcn_DataClean_loadMappingVanDataFromFile(bagFolderPath,Identifiers,[],fid,Flags);
     
        % Remove the extension
        rawdata_cell{folder_idx - skip_count} = rawdata_temp;
    else
        skip_count = skip_count + 1;
    end
end

        

end