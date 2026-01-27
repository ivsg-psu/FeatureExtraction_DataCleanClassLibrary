% script_test_fcn_DebugTools_replaceStringInDirectory

% Revision history
% 2025_09_29 - sbrennan@psu.edu
% -- wrote the code originally using
%    % script_test_fcn_LoadRawDataToMATLAB_determineDataType as a starter

%% Set up the workspace
close all

%% Code demos start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____                              ____   __    _____          _
%  |  __ \                            / __ \ / _|  / ____|        | |
%  | |  | | ___ _ __ ___   ___  ___  | |  | | |_  | |     ___   __| | ___
%  | |  | |/ _ \ '_ ` _ \ / _ \/ __| | |  | |  _| | |    / _ \ / _` |/ _ \
%  | |__| |  __/ | | | | | (_) \__ \ | |__| | |   | |___| (_) | (_| |  __/
%  |_____/ \___|_| |_| |_|\___/|___/  \____/|_|    \_____\___/ \__,_|\___|
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Demos%20Of%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 1

close all;
fprintf(1,'Figure: 1XXXXXX: DEMO cases\n');

%% DEMO case: Single directory query
figNum = 10001;
titleString = sprintf('Single directory query');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Define your directory path, old string, and new string
directoryPath = fullfile(cd,'Functions');

oldString = '_DataClean_';
newString = '_LoadRawDataToMATLAB_';
flagSkipComments = []; % Use defaults

% Call the function to perform the replacement
fcn_DebugTools_replaceStringInDirectory(directoryPath, oldString, newString, (flagSkipComments), (fig_num));

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
% assert(ischar(datatype));

% Check variable sizes
% assert(length(datatype)>1);

% Check variable values
% assert(strcmp(datatype,'gps'));

% Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));



%% DEMO case: Multiple directory query
figNum = 10002;
titleString = sprintf('Multiple directory query');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Define the function inputs
directoryPath = {...
    % fullfile(cd);
    % fullfile(cd,'Functions');
    fullfile(cd,'Functions','DEPRECATED_TO_TIMECLEAN');
    fullfile(cd,'Functions','DEPRECATED_TO_TIMECLEAN_UNUSED');
    fullfile(cd,'Functions','DEPRECATED_TO_TIMECLEAN_ROOT');    
 };

oldString = '_DataClean_';
newString = '_TimeClean_';
flagSkipComments = []; % Use defaults

% Call the function to perform the replacement
fcn_DebugTools_replaceStringInDirectory(directoryPath, oldString, newString, (flagSkipComments), (figNum));

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
% assert(ischar(datatype));

% Check variable sizes
% assert(length(datatype)>1);

% Check variable values
% assert(strcmp(datatype,'gps'));

% Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Test cases start here. These are very simple, usually trivial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _______ ______  _____ _______ _____
% |__   __|  ____|/ ____|__   __/ ____|
%    | |  | |__  | (___    | | | (___
%    | |  |  __|  \___ \   | |  \___ \
%    | |  | |____ ____) |  | |  ____) |
%    |_|  |______|_____/   |_| |_____/
%
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 2

close all;
fprintf(1,'Figure: 2XXXXXX: TEST mode cases\n');
% 
% %% TEST case: simple crossing at origin
% fig_num = 20001;
% titleString = sprintf('TEST case: simple crossing at origin');
% fprintf(1,'Figure %.0f: %s\n',fig_num, titleString);
% figure(fig_num); clf;


%% Fast Mode Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ______        _     __  __           _        _______        _
% |  ____|      | |   |  \/  |         | |      |__   __|      | |
% | |__ __ _ ___| |_  | \  / | ___   __| | ___     | | ___  ___| |_ ___
% |  __/ _` / __| __| | |\/| |/ _ \ / _` |/ _ \    | |/ _ \/ __| __/ __|
% | | | (_| \__ \ |_  | |  | | (_) | (_| |  __/    | |  __/\__ \ |_\__ \
% |_|  \__,_|___/\__| |_|  |_|\___/ \__,_|\___|    |_|\___||___/\__|___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Fast%20Mode%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 8

close all;
fprintf(1,'Figure: 8XXXXXX: FAST mode cases\n');

%% Basic example - NO FIGURE
figNum = 80001;
fprintf(1,'Figure: %.0f: FAST mode, empty fig_num\n',figNum);
figure(figNum); close(figNum);

% Define the function inputs
directoryPath = fullfile(cd,'Functions');
queryString = 'fcn_DataClean_determineDataType';
directoryQuery = [];

% Call the function
fcn_DebugTools_findStringInDirectory(directoryPath, queryString, directoryQuery, []);

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
% assert(ischar(datatype));

% Check variable sizes
% assert(length(datatype)>1);

% Check variable values
% assert(strcmp(datatype,'gps'));

% Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, fig_num=-1\n',figNum);
figure(figNum); close(figNum);

% Define the function inputs
directoryPath = fullfile(cd,'Functions');
queryString = 'fcn_DataClean_determineDataType';
directoryQuery = [];

% Call the function
fcn_DebugTools_findStringInDirectory(directoryPath, queryString, directoryQuery, -1);

% sgtitle(titleString, 'Interpreter','none');

% Check variable types
% assert(ischar(datatype));

% Check variable sizes
% assert(length(datatype)>1);

% Check variable values
% assert(strcmp(datatype,'gps'));

% Make sure plot opened up
% assert(isequal(get(gcf,'Number'),figNum));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);

% Define the function inputs
directoryPath = fullfile(cd,'Functions');
queryString = 'fcn_DataClean_determineDataType';
directoryQuery = [];

Niterations = 10;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations
    % Call the function
    fcn_DebugTools_findStringInDirectory(directoryPath, queryString, directoryQuery, []);

end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;
for ith_test = 1:Niterations
    % Call the function
    fcn_DebugTools_findStringInDirectory(directoryPath, queryString, directoryQuery, -1);

end
fast_method = toc;

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

% Plot results as bar chart
figure(373737);
clf;
hold on;

X = categorical({'Normal mode','Fast mode'});
X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
Y = [slow_method fast_method ]*1000/Niterations;
bar(X,Y)
ylabel('Execution time (Milliseconds)')


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% BUG cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ____  _    _  _____
% |  _ \| |  | |/ ____|
% | |_) | |  | | |  __    ___ __ _ ___  ___  ___
% |  _ <| |  | | | |_ |  / __/ _` / __|/ _ \/ __|
% | |_) | |__| | |__| | | (_| (_| \__ \  __/\__ \
% |____/ \____/ \_____|  \___\__,_|___/\___||___/
%
% See: http://patorjk.com/software/taag/#p=display&v=0&f=Big&t=BUG%20cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All bug case figures start with the number 9

% close all;

%% BUG

%% Fail conditions
if 1==0
    %

end


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


% %% fcn_INTERNAL_loadExampleData
% function [seed_points, V, C] = fcn_INTERNAL_loadExampleData
%
%
% % pull halton set
% halton_points = haltonset(2);
% points_scrambled = scramble(halton_points,'RR2'); % scramble values
%
% % pick values from halton set
% Halton_range = [1801 1901];
% low_pt = Halton_range(1,1);
% high_pt = Halton_range(1,2);
% seed_points = points_scrambled(low_pt:high_pt,:);
% [V,C] = voronoin(seed_points);
% % V = V.*stretch;
% end % Ends fcn_INTERNAL_loadExampleData
  

