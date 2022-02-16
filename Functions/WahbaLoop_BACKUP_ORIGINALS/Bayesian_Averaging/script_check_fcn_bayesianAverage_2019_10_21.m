%% This is a script that checks the function: fcn_bayesianAverage
% function [bayes_avg, bayes_sigma] = fcn_bayesianAverage(value1, sigma1, value2, simgma2, varargin)
% varargin can take many arguments, arguments follow the order 
% value1, sigma1, value2, simag2 .......
% where 'value%d' is the parameter and 'sigma%d' is the corresponding std-deviation
% 'bayes_avg' is the weighted average
% 'bayes_sigma' is the weighted std-dev

% Change history:
% 2019_10_18 - Code first written by Satya
% 2019_10_19 to 2019_10_20- Brennan added more examples, including one that breaks the
% function


% Prep the workspace
clear all
close all
clc

% create random values
A = 0.5*randn(50,1);
A_s = 0.5*ones(50,1);
B = [0.02*randn(15,1); 100*randn(20,1); 0.02*randn(15,1)];
B_s = [0.02*ones(15,1); 100*ones(20,1); 0.02*ones(15,1)];
C = [1*randn(15,1); 50*randn(20,1); 1*randn(15,1)];
C_s = [1*ones(15,1); 50*ones(20,1); 1*ones(15,1)];

bayes_avg = fcn_bayesianAverage(A,A_s,B,B_s,C,C_s);

figure()
plot(A(:,1),'b');   % Similar to novatel
hold on;
plot(B(:,1),'g');   % Similar to Hemisphere
plot(C(:,1),'C');   % Similar to Hemisphere
plot(bayes_avg,'r--');  % weighted
legend('0.5','0.02 and 100','1 and 50','avg');


%% Create very simple example
A = 2;
A_s = 0.5;
B = 3;
B_s = 0.5;
C = 4;
C_s = 0.5;
[bayes_avg,bayes_sigma] = fcn_bayesianAverage(A,A_s,B,B_s,C,C_s)
% Answer should be 3, as all are equally weighted. Might think that sigma
% should be 0.5, but it's really about 0.5/sqrt(3), due to the central
% limit theorem. Each point, due to aggregation, makes the mean's variance
% less and less by the square-root of N, where N is the number of points
% used to calculate the mean.

A = 2;
A_s = 0.5;
B = 3;
B_s = 0.1;
C = 4;
C_s = 3;
[bayes_avg,bayes_sigma] = fcn_bayesianAverage(A,A_s,B,B_s,C,C_s)
% Note how the sigma value is always less than or equal to the smallest
% sigma in the range given.



%% Create vector examples
% First, create test data range, and bad indices
xvector = (1:20)';
bad_parts_of_x = (5:15);
clean_data1 = 4*ones(length(xvector),1);
clean_data2 = 6*ones(length(xvector),1);
clean_data3 = 8*ones(length(xvector),1);

% Next, add noise to each with a given sigma -
sigma1 = 0.2*ones(length(xvector),1);
sigma2 = 0.4*ones(length(xvector),1);
sigma3 = 1*ones(length(xvector),1);

% Show that the weighted average shifts toward variable of least variance
[bayes_avg,bayes_sigma] = fcn_bayesianAverage(...
    clean_data1, sigma1,...
    clean_data2, sigma2,...
    clean_data3, sigma3);

% Plot results
figure(111);
clf;
plot(...
    xvector,clean_data1,'r-',...
    xvector,clean_data1+sigma1,'r--',...
    xvector,clean_data1-sigma1,'r--',...
    xvector,clean_data2,'g-',...
    xvector,clean_data2+sigma2,'g--',...
    xvector,clean_data2-sigma2,'g--',...
    xvector,clean_data3,'b-',...
    xvector,clean_data3+sigma3,'b--',...
    xvector,clean_data3-sigma3,'b--');
hold on;
plot(xvector,bayes_avg,'k-','LineWidth',2);
plot(xvector,bayes_avg+bayes_sigma,'k--','LineWidth',1);
plot(xvector,bayes_avg-bayes_sigma,'k--','LineWidth',1);

%% Now change the variances around to show that this shifts average

% Next, add noise to each with a given sigma -
sigma1 = 1*ones(length(xvector),1);
sigma2 = 0.4*ones(length(xvector),1);
sigma3 = 0.2*ones(length(xvector),1);

% Show that the weighted average shifts toward variable of least variance
[bayes_avg,bayes_sigma] = fcn_bayesianAverage(...
    clean_data1, sigma1,...
    clean_data2, sigma2,...
    clean_data3, sigma3);

% Plot results
figure(222);
clf;
plot(...
    xvector,clean_data1,'r-',...
    xvector,clean_data1+sigma1,'r--',...
    xvector,clean_data1-sigma1,'r--',...
    xvector,clean_data2,'g-',...
    xvector,clean_data2+sigma2,'g--',...
    xvector,clean_data2-sigma2,'g--',...
    xvector,clean_data3,'b-',...
    xvector,clean_data3+sigma3,'b--',...
    xvector,clean_data3-sigma3,'b--');
hold on;
plot(xvector,bayes_avg,'k-','LineWidth',2);
plot(xvector,bayes_avg+bayes_sigma,'k--','LineWidth',1);
plot(xvector,bayes_avg-bayes_sigma,'k--','LineWidth',1);


%% Now change the variances around locally

% Next, add noise to each with a given sigma -
sigma1 = 1*ones(length(xvector),1);
sigma2 = 0.4*ones(length(xvector),1);
sigma3 = 0.2*ones(length(xvector),1);
sigma3(bad_parts_of_x,1) = 0.8;

% Show that the weighted average shifts toward variable of least variance
[bayes_avg,bayes_sigma] = fcn_bayesianAverage(...
    clean_data1, sigma1,...
    clean_data2, sigma2,...
    clean_data3, sigma3);

% Plot results
figure(333);
clf;
plot(...
    xvector,clean_data1,'r-',...
    xvector,clean_data1+sigma1,'r--',...
    xvector,clean_data1-sigma1,'r--',...
    xvector,clean_data2,'g-',...
    xvector,clean_data2+sigma2,'g--',...
    xvector,clean_data2-sigma2,'g--',...
    xvector,clean_data3,'b-',...
    xvector,clean_data3+sigma3,'b--',...
    xvector,clean_data3-sigma3,'b--');
hold on;
plot(xvector,bayes_avg,'k-','LineWidth',2);
plot(xvector,bayes_avg+bayes_sigma,'k--','LineWidth',1);
plot(xvector,bayes_avg-bayes_sigma,'k--','LineWidth',1);

%% Here's some examples that break the function 
% The following breaks the code, but not obvious why (if not inside the
% code)
A = 2:3;
A_s = 0.5;
B = 3:4;
B_s = 0.1;
C = 4;
C_s = 3;
[bayes_avg,bayes_sigma] = fcn_bayesianAverage(A,A_s,B,B_s,C,C_s)

% The following should work... but doesn't
A = [2 3];
A_s = 0.5;
B = [3 4];
B_s = 0.1;
C = [4 5];
C_s = 3;
[bayes_avg,bayes_sigma] = fcn_bayesianAverage(A,A_s,B,B_s,C,C_s)

% The following should NOT work... but does
A = [2 nan];
A_s = [0.5 0.5];
B = [3 4];
B_s = [0.5 0.5];
C = [4 5];
C_s = [0.5 0.5];
[bayes_avg,bayes_sigma] = fcn_bayesianAverage(A,A_s,B,B_s,C,C_s)

%% Test the new function
% This should work
input_data  = [2 4];
input_sigma = [3 3];
[bayes_avg,bayes_sigma] = fcn_bayesianAverageMatrixForm(input_data,input_sigma)

% Throw bad data at it, see if it gives error...
input_data  = [2 4];
input_sigma = [3];
[bayes_avg,bayes_sigma] = fcn_bayesianAverageMatrixForm(input_data,input_sigma)

input_data  = [2 4];
input_sigma = [3 nan];
[bayes_avg,bayes_sigma] = fcn_bayesianAverageMatrixForm(input_data,input_sigma)

%% Now test with vector examples
% First, create test data range, and bad indices
xvector = (1:20)';
bad_parts_of_x = (5:15);
clean_data1 = 4*ones(length(xvector),1);
clean_data2 = 6*ones(length(xvector),1);
clean_data3 = 8*ones(length(xvector),1);
input_data = [clean_data1, clean_data2, clean_data3];

% Next, add noise to each with a given sigma -
sigma1 = 0.2*ones(length(xvector),1);
sigma2 = 0.4*ones(length(xvector),1);
sigma3 = 1*ones(length(xvector),1);
input_sigma = [sigma1,sigma2,sigma3];

% Show that the weighted average shifts toward variable of least variance
[bayes_avg,bayes_sigma] = fcn_bayesianAverageMatrixForm(input_data,input_sigma);

% Plot results
figure(111);
clf;
plot(...
    xvector,clean_data1,'r-',...
    xvector,clean_data1+sigma1,'r--',...
    xvector,clean_data1-sigma1,'r--',...
    xvector,clean_data2,'g-',...
    xvector,clean_data2+sigma2,'g--',...
    xvector,clean_data2-sigma2,'g--',...
    xvector,clean_data3,'b-',...
    xvector,clean_data3+sigma3,'b--',...
    xvector,clean_data3-sigma3,'b--');
hold on;
plot(xvector,bayes_avg,'k-','LineWidth',2);
plot(xvector,bayes_avg + bayes_sigma,'k--','LineWidth',1);
plot(xvector,bayes_avg - bayes_sigma,'k--','LineWidth',1);
