% script_test_fcn_DataClean_listDirectoryContents.m
% tests fcn_DataClean_listDirectoryContents.m

% Revision history
% 2024_10_02 - sbrennan@psu.edu
% -- wrote the code originally, using fcn_DataClean_loadRawDataFromDirectories as starter

%% Set up the workspace
close all

%% Choose data folder and bag name, read before running the script
% The parsed the data files are saved on OneDrive
% in \IVSG\GitHubMirror\MappingVanDataCollection\ParsedData. To process the
% bag file, please copy file folder to the LargeData folder.


%% Test 1: File query
% fig_num = 1;
% figure(fig_num);
% clf;

clear rootdirs
rootdirs{1} = fullfile(cd,'Functions');

% Specify the bagQueryString
fileQueryString = '*.m'; % The more specific, the better to avoid accidental loading of wrong information

% Specify the flag_fileOrDirectory
flag_fileOrDirectory = 0; % A file

% Specify the fid
fid = 1; % 1 --> print to console

% Call the function
directory_filelist = fcn_DataClean_listDirectoryContents(rootdirs, (fileQueryString), (flag_fileOrDirectory), (fid));

% Check the results
assert(isstruct(directory_filelist));
assert(length(directory_filelist)>1);


%% Test 2: File query, specific string
% fig_num = 1;
% figure(fig_num);
% clf;

clear rootdirs
rootdirs{1} = fullfile(cd,'Functions');

% Specify the bagQueryString
fileQueryString = 'script_test_fcn_DataClean_load*.m'; % The more specific, the better to avoid accidental loading of wrong information

% Specify the flag_fileOrDirectory
flag_fileOrDirectory = 0; % A file

% Specify the fid
fid = 1; % 1 --> print to console

% Call the function
directory_filelist = fcn_DataClean_listDirectoryContents(rootdirs, (fileQueryString), (flag_fileOrDirectory), (fid));

% Check the results
assert(isstruct(directory_filelist));
assert(length(directory_filelist)>1);


%% Test 3: Directory query, specific string
% fig_num = 1;
% figure(fig_num);
% clf;

clear rootdirs
rootdirs{1} = fullfile(cd,'Utilities');

% Specify the bagQueryString
fileQueryString = 'Functions'; % The more specific, the better to avoid accidental loading of wrong information

% Specify the flag_fileOrDirectory
flag_fileOrDirectory = 1; % A directory

% Specify the fid
fid = 1; % 1 --> print to console

% Call the function
directory_filelist = fcn_DataClean_listDirectoryContents(rootdirs, (fileQueryString), (flag_fileOrDirectory), (fid));

% Check the results
assert(isstruct(directory_filelist));
assert(length(directory_filelist)>1);

%% Test 3: Directory query, specific string
% fig_num = 1;
% figure(fig_num);
% clf;

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'Utilities');
rootdirs{2} = fullfile(cd,'LargeData');
rootdirs{3} = fullfile(cd,'Data');


% Specify the bagQueryString
fileQueryString = 'Functions'; % The more specific, the better to avoid accidental loading of wrong information

% Specify the flag_fileOrDirectory
flag_fileOrDirectory = 1; % A file

% Specify the fid
fid = 1; % 1 --> print to console

% Call the function
directory_filelist = fcn_DataClean_listDirectoryContents(rootdirs, (fileQueryString), (flag_fileOrDirectory), (fid));

% Check the results
assert(isstruct(directory_filelist));
assert(length(directory_filelist)>1);

%% Test 4: File listing, all mat files in Data directory
% fig_num = 1;
% figure(fig_num);
% clf;

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = fullfile(cd,'Data');


% Specify the bagQueryString
fileQueryString = '*.mat'; % The more specific, the better to avoid accidental loading of wrong information

% Specify the flag_fileOrDirectory
flag_fileOrDirectory = 0; % A file

% Specify the fid
fid = 1; % 1 --> print to console

% Call the function
directory_filelist = fcn_DataClean_listDirectoryContents(rootdirs, (fileQueryString), (flag_fileOrDirectory), (fid));

% Check the results
assert(isstruct(directory_filelist));
assert(length(directory_filelist)>1);

%% Test 5: Find all bag files in a given directory, and sort them, then print
% fig_num = 1;
% figure(fig_num);
% clf;

% List which directory/directories need to be loaded
clear rootdirs
rootdirs{1} = 'D:\MappingVanData\RawBags\OnRoad\PA653Normalville\2024-08-22';


% Specify the bagQueryString
fileQueryString = '*.bag'; % The more specific, the better to avoid accidental loading of wrong information

% Specify the flag_fileOrDirectory
flag_fileOrDirectory = 0; % A file

% Specify the fid
fid = 1; % 1 --> print to console

% Call the function
directory_filelist = fcn_DataClean_listDirectoryContents(rootdirs, (fileQueryString), (flag_fileOrDirectory), (fid));

% Check the results
assert(isstruct(directory_filelist));
assert(length(directory_filelist)>1);

%%%%%
% Sort them
Nfiles = length(directory_filelist);
for ith_file = 1:Nfiles
    fileName = directory_filelist(ith_file).name;
    if length(fileName)>4
    end
end


%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagName, bagName);
end
