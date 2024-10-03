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
% rootdirs{1} = fullfile(cd,'Data');


% Specify the bagQueryString
fileQueryString = '*.bag'; % The more specific, the better to avoid accidental loading of wrong information

% Specify the flag_fileOrDirectory
flag_fileOrDirectory = 0; % A file

% Specify the fid
fid = -1; % 1 --> print to console

% Call the function
directory_filelist = fcn_DataClean_listDirectoryContents(rootdirs, (fileQueryString), (flag_fileOrDirectory), (fid));

% Check the results
assert(isstruct(directory_filelist));
assert(length(directory_filelist)>1);

%%%%%
% Sort them by time
Nfiles = length(directory_filelist);
timeNumbers = datetime(zeros(Nfiles,1), 0, 0);
for ith_file = 1:Nfiles
    fileName = directory_filelist(ith_file).name;
    timeNumbers(ith_file,1) = fcn_INTERNAL_findTimeFromName(fileName);
end

% Sort them
[~,sortedIndex] = sort(timeNumbers);

sorted_directory_filelist = directory_filelist(sortedIndex);

fid = 1;
fprintf(fid,'\nCONTENTS FOUND:\n');
% Print the fields
previousDirectory = '';
for jth_file = 1:length(sorted_directory_filelist)
    thisFolder = sorted_directory_filelist(jth_file).folder;
    if ~strcmp(thisFolder,previousDirectory)
        previousDirectory = thisFolder;
        fprintf(fid,'Folder: %s\n',thisFolder);
    end
    if (0==flag_fileOrDirectory) || (2==flag_fileOrDirectory)
        fprintf(fid,'\t%s\n',sorted_directory_filelist(jth_file).name);
    end
end

%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_loadMappingVanDataFromFile(bagName, bagName);
end

function timeNumber = fcn_INTERNAL_findTimeFromName(fileName)

timeString = [];
if length(fileName)>4
    splitName = strsplit(fileName,{'_','.'});
    for ith_split = 1:length(splitName)
        if contains(splitName{ith_split},'-')
            timeString = splitName{ith_split};
        end
    end
end
timeNumber = datetime(timeString,'InputFormat','yyyy-MM-dd-HH-mm-ss');
end