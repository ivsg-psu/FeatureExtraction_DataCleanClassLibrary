function [mergedDataNoJumps,mergedByKFData] = fcn_DataClean_AddLocationToLidar(mergedDataNoJumps,mergedByKFData,base_station)

% Purpose :Add interpolation to Lidar data to create field in Lidar that has GPS position in ENU

% Update history
%     2021_10_15 First write of code by Liming Gao



% Use linear interpolation
% vq = interp1(x,v,xq,method)
try
        mergedDataNoJumps.Lidar.xEast = interp1(mergedDataNoJumps.MergedGPS.GPS_Time, mergedDataNoJumps.MergedGPS.xEast,...
        mergedDataNoJumps.Lidar.GPS_Time,'linear','extrap');
    mergedDataNoJumps.Lidar.yNorth = interp1(mergedDataNoJumps.MergedGPS.GPS_Time, mergedDataNoJumps.MergedGPS.yNorth,...
        mergedDataNoJumps.Lidar.GPS_Time,'linear','extrap');
    mergedDataNoJumps.Lidar.zUp = interp1(mergedDataNoJumps.MergedGPS.GPS_Time, mergedDataNoJumps.MergedGPS.zUp,...
        mergedDataNoJumps.Lidar.GPS_Time,'linear','extrap');
    
    
    mergedByKFData.Lidar.xEast = interp1(mergedByKFData.MergedGPS.GPS_Time, mergedByKFData.MergedGPS.xEast,...
        mergedByKFData.Lidar.GPS_Time,'linear','extrap');
    mergedByKFData.Lidar.yNorth = interp1(mergedByKFData.MergedGPS.GPS_Time, mergedByKFData.MergedGPS.yNorth,...
        mergedByKFData.Lidar.GPS_Time,'linear','extrap');
    mergedByKFData.Lidar.zUp = interp1(mergedByKFData.MergedGPS.GPS_Time, mergedByKFData.MergedGPS.zUp,...
        mergedByKFData.Lidar.GPS_Time,'linear','extrap');
    
catch
    disp('Debug here');
    pause;
end

% convert ENU to LLA (used for geoplot)
[mergedDataNoJumps.Lidar.latitude,mergedDataNoJumps.Lidar.longitude,mergedDataNoJumps.Lidar.altitude] ...
    = enu2geodetic(mergedDataNoJumps.Lidar.xEast,mergedDataNoJumps.Lidar.yNorth,mergedDataNoJumps.Lidar.zUp,...
    base_station.latitude,base_station.longitude, base_station.altitude,wgs84Ellipsoid);

[mergedByKFData.Lidar.latitude,mergedByKFData.Lidar.longitude,mergedByKFData.Lidar.altitude] ...
    = enu2geodetic(mergedByKFData.Lidar.xEast,mergedByKFData.Lidar.yNorth,mergedByKFData.Lidar.zUp,...
    base_station.latitude,base_station.longitude, base_station.altitude,wgs84Ellipsoid);

end
