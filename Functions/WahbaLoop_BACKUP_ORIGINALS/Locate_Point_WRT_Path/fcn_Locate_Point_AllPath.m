% function [location] = fcn_Locate_Point_AllPath(query, ENU)
% Find the position of point wrt every point on the path - Left/Right
% query - Point for which location needs to be determined
% ENU - ENU coordinates of the path
%
% Author: Srivenkata Satya Prasad Maddipatla
% Date: 16th Oct, 2019

function [location] = fcn_Locate_Point_AllPath(query, ENU)
    
    n = size(ENU, 1);                         % Length of the path
    
    % Vector in the path
    s_vector = diff(ENU);
    % Vector pointing towards the point, from the nearest point on the path
    p_vector = [query(1)-ENU(1:n-1,1), query(2)-ENU(1:n-1,2), query(3)-ENU(1:n-1,3)];
    
    % cross product between both the vectors
    c = cross(s_vector, p_vector);
    % Upward pointing component of the vectors
    up = c(:,3);
    
    % '0' - on the path; '-1' - Left of the path; '1' - Right of the path
    % Intuitively similar to number line
    location = sign(-up);
    
end