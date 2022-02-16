function [RouteStructure] = fcn_defineRouteStructure(route_name,timeFilteredData)
%FCN_DEFINESTARTPOINT Summary of this function goes here
%   Detailed explanation goes here
     %plot and define the start point by observing 
     start_index= 2400;
     %[start_longitude,start_latitude, start_xEast,start_yNorth] = fcn_plotraw_lla(timeFilteredData.GPS_Hemisphere, 1254, 'lla_raw_data', start_index);
     %fcn_googleEarth('test_track',timeFilteredData.GPS_Hemisphere)
     
  if strcmpi(route_name,'test_track') % 1 means 'test_track';  2 means wahba_loop; 
        RouteStructure.start_longitude=-77.833842140800000;  %deg
        RouteStructure.start_latitude =40.862636161300000;   %deg
        RouteStructure.start_xEast=1345.204537286125; % meters
        RouteStructure.start_yNorth=6190.884280063217; % meters
        
        RouteStructure.end_longitude=-77.833842140800000;  %deg
        RouteStructure.end_latitude =40.862636161300000;   %deg
        RouteStructure.end_xEast=1345.204537286125; % meters
        RouteStructure.end_yNorth=6190.884280063217; % meters
        
        RouteStructure.start_yaw_angle = 37.38; %deg
        RouteStructure.expectedRouteLength = 1555.5; % meters
        RouteStructure.direction = 'CCW'; % meters
  elseif strcmpi(route_name,'wahba_loop')
        RouteStructure.start_longitude=-77.87652037222755;
        RouteStructure.start_latitude =40.828390558947870;
        RouteStructure.start_xEast=-2254.319012077573;
        RouteStructure.start_yNorth=2387.887818394200;
        
        RouteStructure.end_longitude=-77.87652037222755;
        RouteStructure.end_latitude =40.828390558947870;
        RouteStructure.end_xEast=-2254.319012077573;
        RouteStructure.end_yNorth=2387.887818394200;
        
        RouteStructure.start_yaw_angle = 190;
        RouteStructure.expectedRouteLength = 11265.5;
        RouteStructure.direction = 'CCW'; % meters
       
  end
  
end

