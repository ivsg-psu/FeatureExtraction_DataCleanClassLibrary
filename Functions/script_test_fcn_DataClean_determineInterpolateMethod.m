% script_test_fcn_DataClean_determineInterpolateMethod.m
% tests fcn_DataClean_determineInterpolateMethod.m

% Revision history
% 2024_10_08 - sbrennan@psu.edu
% -- wrote the code originally


%% Set up the workspace
close all



%% Basic test
fig_num = []; % Does nothing
field_name = 'ROS_Time';

interp_method = fcn_DataClean_determineInterpolateMethod(field_name, (fig_num));

% Check output
assert(strcmp(interp_method,'linear'));


%% Testing fast mode
% Perform the calculation in slow mode

field_name = 'ROS_Time';


fig_num = [];
REPS = 1000; minTimeSlow = Inf;
tic;
for i=1:REPS
    tstart = tic;
    interp_method = fcn_DataClean_determineInterpolateMethod(field_name, (fig_num));
    telapsed = toc(tstart);
    minTimeSlow = min(telapsed,minTimeSlow);
end
averageTimeSlow = toc/REPS;

% Perform the operation in fast mode
fig_num = -1;
REPS = 1000; minTimeFast = Inf; 
tic;
for i=1:REPS
    tstart = tic;
    interp_method = fcn_DataClean_determineInterpolateMethod(field_name, (fig_num));
    telapsed = toc(tstart);
    minTimeFast = min(telapsed,minTimeFast);
end
averageTimeFast = toc/REPS;

fprintf(1,'Comparison of fast and slow modes of fcn_DataClean_determineInterpolateMethod:\n');
fprintf(1,'N repetitions: %.0d\n',REPS);
fprintf(1,'Slow mode average speed per call (seconds): %.8f\n',averageTimeSlow);
fprintf(1,'Slow mode fastest speed over all calls (seconds): %.8f\n',minTimeSlow);
fprintf(1,'Fast mode average speed per call (seconds): %.8f\n',averageTimeFast);
fprintf(1,'Fast mode fastest speed over all calls (seconds): %.8f\n',minTimeFast);
fprintf(1,'Average ratio of fast mode to slow mode (unitless): %.3f\n',averageTimeSlow/averageTimeFast);
fprintf(1,'Fastest ratio of fast mode to slow mode (unitless): %.3f\n',minTimeSlow/minTimeFast);



%% Fail conditions
if 1==0
    %% Bad field name
    field_name = 'Bad field';

    interp_method = fcn_DataClean_determineInterpolateMethod(field_name, (fig_num));

end
