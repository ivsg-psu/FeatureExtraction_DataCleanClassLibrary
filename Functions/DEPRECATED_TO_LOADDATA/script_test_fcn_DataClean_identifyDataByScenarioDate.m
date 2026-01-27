% script_test_fcn_DataClean_identifyDataByScenarioDate.m
% tests fcn_DataClean_identifyDataByScenarioDate.m

% Revision history
% 2024_11_07 - sbrennan@psu.edu
% -- wrote the code originally by copying out of
% script_mainDataClean_loadAndSaveAllSitesRawData



%% Set up the workspace
close all


%% CASE 1: Basic call - NOT verbose
testingConditions = {
    % '2024-02-01','4.2'; % NOT parsed - bad data
    '2024-02-06','4.3';
    % '2024-04-19','2.3'; % NOT parsed
    '2024-06-24','I376ParkwayPitt'; 
    % '2024-06-28','4.1b'; % NOT parsed
    '2024-07-10','I376ParkwayPitt'; 
    '2024-07-11','I376ParkwayPitt'; 
    '2024-08-05','BaseMap';
    '2024-08-12','BaseMap';
    '2024-08-13','BaseMap';
    '2024-08-14','4.1a';
    '2024-08-15','4.1a';
    '2024-08-15','4.3'; % NOT done
    '2024-08-22','PA653Normalville';
    '2024-09-04','5.1a';
    '2024-09-13','5.2';
    '2024-09-17','1.6';
    '2024-09-19','PA51Aliquippa';
    '2024-09-20','PA51Aliquippa';
    '2024-10-16','I376ParkwayPitt'; 
    '2024-10-24','4.1b'; 
    '2024-10-31','6.1'; 
    };

fid = 0;
for ith_test = 1:length(testingConditions(:,1))

    fig_num = ith_test;
    if ~isempty(findobj('Number',fig_num))
        figure(fig_num);
        clf;
    end

    scenarioString = testingConditions{ith_test,2};
    dateString     = testingConditions{ith_test,1};   
    Identifiers = fcn_DataClean_identifyDataByScenarioDate(scenarioString, dateString, fid, fig_num);

    % Check output
    assert(isstruct(Identifiers));

    % Put a dot at the base station
    fcn_plotRoad_plotLL(([]), ([]), (fig_num));
    title(scenarioString);
    subtitle(dateString);
end

%% CASE 2: Basic call - verbose mode
testingConditions = {
    % '2024-02-01','4.2'; % NOT parsed - bad data
    '2024-02-06','4.3';
    % '2024-04-19','2.3'; % NOT parsed
    '2024-06-24','I376ParkwayPitt'; 
    % '2024-06-28','4.1b'; % NOT parsed
    '2024-07-10','I376ParkwayPitt'; 
    '2024-07-11','I376ParkwayPitt'; 
    '2024-08-05','BaseMap';
    '2024-08-12','BaseMap';
    '2024-08-13','BaseMap';
    '2024-08-14','4.1a';
    '2024-08-15','4.1a';
    '2024-08-15','4.3'; % NOT done
    '2024-08-22','PA653Normalville';
    '2024-09-04','5.1a';
    '2024-09-13','5.2';
    '2024-09-17','1.6';
    '2024-09-19','PA51Aliquippa';
    '2024-09-20','PA51Aliquippa';
    '2024-10-16','I376ParkwayPitt'; 
    '2024-10-24','4.1b'; 
    '2024-10-31','6.1'; 
    };

fid = 1;
for ith_test = 1:length(testingConditions(:,1))

    fig_num = ith_test;
    if ~isempty(findobj('Number',fig_num))
        figure(fig_num);
        clf;
    end

    scenarioString = testingConditions{ith_test,2};
    dateString     = testingConditions{ith_test,1};   
    Identifiers = fcn_DataClean_identifyDataByScenarioDate(scenarioString, dateString, fid, fig_num);

    % Check output
    assert(isstruct(Identifiers));

    % Put a dot at the base station
    fcn_plotRoad_plotLL(([]), ([]), (fig_num));
    title(scenarioString);
    subtitle(dateString);
end



%% Fail conditions
if 1==0
    
end
