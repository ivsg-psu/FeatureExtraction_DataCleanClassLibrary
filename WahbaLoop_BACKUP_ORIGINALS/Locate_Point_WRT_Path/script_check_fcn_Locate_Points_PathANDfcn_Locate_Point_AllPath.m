close all
clear all
clc

%% To check fcn_Locate_Points_Path
% Path
x = -10:0.001:10;
y = x.^2;
z = x.^3;
ENU = [x.', y.', z.'];
ENU2 = flipud(ENU);

% Points
queryArray(:,1) = -10:1:10;
queryArray(:,2) = -queryArray(:, 1) + 7;
queryArray(:,3) = queryArray(:, 1);
% i_Laps = 3;
%         east_gps_interp = aligned_Data_ByStation.traversal{i_Laps}.X;
%         north_gps_interp = aligned_Data_ByStation.traversal{i_Laps}.Y;
%         
% ENU = [mean_Data.mean_xEast'  mean_Data.mean_yNorth' zeros(length(mean_Data.mean_xEast),1)];
% queryArray = [east_gps_interp' north_gps_interp' zeros(length(mean_Data.mean_xEast),1)];
location = fcn_Locate_Points_Path(queryArray, ENU);

A = queryArray(:, 1);
B = queryArray(:, 2);

figure()
% Points on the left side
plot(A(find(location == -1)), B(find(location == -1)), 'g*');
hold on;
% Point on the right side
plot(A(find(location == 1)), B(find(location == 1)), 'bo');
% Path
plot(x,y,'g');

%plot(mean_Data.mean_xEast,mean_Data.mean_yNorth,'r.')


grid on
legend('Left','Right','Path');

%% To check fcn_Locate_Point_AllPath
% Path
x = -10:0.01:10;
y = x.^2;
z = x.^3;
ENU = [x.', y.', z.'];
ENU2 = flipud(ENU);
% Point
query = [-6, 10, 0];

% Change ENU - ENU2 nd viceversa in the below three lines
location = fcn_Locate_Point_AllPath(query, ENU2);
A = ENU2(:,1);
B = ENU2(:,2);

figure()
% Points on the left side
plot(A(find(location == -1)), B(find(location == -1)), '*');
hold on;
% Points on the right side
plot(A(find(location == 1)), B(find(location == 1)), 'o');
% Query
plot(query(1), query(2), '*');
legend('Left','Right','Query');