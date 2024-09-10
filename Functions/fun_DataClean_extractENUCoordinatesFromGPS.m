function [GPS_SparkFun_Front_ENU, GPS_SparkFun_LeftRear_ENU, GPS_SparkFun_RightRear_ENU,vehicleDGPS_mode] = fun_DataClean_extractENUCoordinatesFromGPS(dataStructure)

[cell_array_xEast,GPS_Units_names] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'xEast','GPS');

[cell_array_yNorth,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'yNorth','GPS');

[cell_array_zUp,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'zUp','GPS');

N_GPS_units = length(GPS_Units_names);

GPS_SparkFun_Front_ENU = [];
GPS_SparkFun_LeftRear_ENU = [];
GPS_SparkFun_RightRear_ENU = [];

for idx_GPS_unit = 1:N_GPS_units
    GPS_Units_name = GPS_Units_names{idx_GPS_unit};
    array_xEast = cell_array_xEast{idx_GPS_unit};
    array_yNorth = cell_array_yNorth{idx_GPS_unit};
    array_zUp = cell_array_zUp{idx_GPS_unit};
    if strcmp(GPS_Units_name,"GPS_SparkFun_Front")
        GPS_SparkFun_Front_ENU = [array_xEast, array_yNorth, array_zUp];

    elseif strcmp(GPS_Units_name,"GPS_SparkFun_LeftRear")
        GPS_SparkFun_LeftRear_ENU = [array_xEast, array_yNorth, array_zUp];
    elseif strcmp(GPS_Units_name,"GPS_SparkFun_RightRear")
        GPS_SparkFun_RightRear_ENU = [array_xEast, array_yNorth, array_zUp];

    end

end

[cell_array_DGPS,~] = fcn_DataClean_pullDataFromFieldAcrossAllSensors(dataStructure, 'DGPS_mode','GPS');
array_DGPS = cell2mat(cell_array_DGPS);
vehicleDGPS_mode = min(array_DGPS,[],2);









end