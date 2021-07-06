function [outputArg1,outputArg2] = fcn_DataClean_insertCleanedData(cleanedData,trips,flag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% ------------------------ CONNECT TO  DATABASE ------------------------ %
% choose different da name to connect to them 
database_name = 'mapping_van_cleaned';
%
% create a instance 
DB = Database(database_name);

%%show tables 
tables = DB.ShowTables();

%assign PRIVILEGES
if 1==0
    exec(DB.db_connection,'ALTER role ivsg_db_user LOGIN;');
    exec(DB.db_connection,['grant CONNECT ON DATABASE ' database_name ' TO ivsg_db_user;']);
    for i_table= 1:height(tables)
        sql_grant_privilege = ['grant SELECT on ' tables.Table{i_table} ' to ivsg_db_user ;'];
        exec(DB.db_connection,sql_grant_privilege);
        sql_grant_privilege = ['grant INSERT on ' tables.Table{i_table} ' to ivsg_db_user ;'];
        exec(DB.db_connection,sql_grant_privilege);
    end
%     results_trips = fetch(DB.db_connection,'SELECT * from trips;'); %query some data to check
    
end

%---
flag.basicInsert = false;
%% 1)vehicle
if flag.basicInsert
    database_name = 'mapping_van_raw';
    % create a instance
    DB_raw = Database(database_name);
    
    [result_table, ~, ~] = DB_raw.select('vehicle', {'id','name'});
    sqlwrite(DB.db_connection,'vehicle',result_table);
    
    %data = sqlread(DB.db_connection,'vehicle','MaxRows',10);%query some data to check
    
end

%% 2)base_station
if flag.basicInsert
    database_name = 'mapping_van_raw';
    % create a instance
    DB_raw = Database(database_name);
    fields = {'id','name','latitude','longitude','altitude','geography','latitude_std','longitude_std','altitude_std','timestamp'};
    [result_table, ~, ~] = DB_raw.select('base_stations', fields);
    sqlwrite(DB.db_connection,'base_stations',result_table);
    
    data = sqlread(DB.db_connection,'base_stations','MaxRows',10);%#ok<NASGU> %query some data to check
    
end

%% 3)trips
if isempty(DB.db_connection.Message) % check if the connection is successful
    % {'id','vehicle_id','base_stations_id','name','description','date','driver','passengers','notes'}
%     trips.id = trip_id_cleaned;
%     trips.vehicle_id = 1;
%     trips.base_stations_id = base_station.id;
%     trips.name = trip_name;
    
    trips_table = struct2table(trips);
    
    try
         sqlwrite(DB.db_connection,'trips',trips_table);
    catch ME
        switch ME.identifier
            case 'database:database:WriteTableDriverError'
                if strfind(ME.message,'duplicate key value violates unique constraint')
                    warning(ME.message);
                    prompt = ['Do you want to replace the trip_id: ' num2str(trips.id) ' ?[y/n]'];
                    User_input_replace = input(prompt,'s');
                    
                    if strcmpi(User_input_replace,'y')
                        fprintf(1,'Thanks. Let''s update it...\n');
                        %sql_trip_delete =[ 'delete from trips where id = ' num2str(trips.id) ';'];
                        %exec(DB.db_connection,sql_trip_delete);
                        %sqlwrite(DB.db_connection,'trips',trips_table);
                        % delete is not good, because other tables will
                        % depned on it
                        %update(DB.db_connection,tablename,colnames,data,whereclause)
                        column = {'vehicle_id','base_stations_id','name','description','date','driver','passengers','notes'};
                        data = trips_table(:,2:end);
                        update(DB.db_connection,'trips',column ,data,['WHERE id = ' num2str(trips.id) ';']);
                        
                     fprintf(1,['trip_id ' num2str(trips.id) ' has been updated!\n']);
                    else
                        fprintf(1,'insert is aborted.\n');
                        
                    end
                else
                    rethrow(ME)
                end
            otherwise
                rethrow(ME)
        end
        %
    end
%     DB.disconnect();
    data = sqlread(DB.db_connection,'trips','MaxRows',10); %#ok<NASGU>
end

%% 4)'merged_gps' table 
% %{'id','trips_id','latitude','longitude','altitude
% ','geography','xeast','xeast_sigma','ynorth','ynorth_sigma',
% 'zup','zup_sigma','velocity_magnitude','velocity_magnitude_sigma','xeast_increments','xeast_increments_sigma',
% 'ynorth_increments','ynorth_increments_sigma','yaw_deg','yaw_deg_sigma','gps_seconds','gps_week','timestamp'}


% store the cleaned data into merged_gps struct
merged_gps.latitude = cleanedData.MergedGPS.latitude;
merged_gps.longitude = cleanedData.MergedGPS.longitude;
merged_gps.altitude = cleanedData.MergedGPS.longitude;

merged_gps.trips_id = trips.id*ones(length(merged_gps.latitude),1);

merged_gps.xeast = cleanedData.MergedGPS.xEast;
merged_gps.xeast_sigma = cleanedData.MergedGPS.xEast_Sigma;
merged_gps.ynorth = cleanedData.MergedGPS.yNorth;
merged_gps.ynorth_sigma = cleanedData.MergedGPS.yNorth_Sigma;
merged_gps.zup = cleanedData.MergedGPS.zUp;
merged_gps.zup_sigma = cleanedData.MergedGPS.zUp_Sigma;
merged_gps.velocity_magnitude = cleanedData.MergedGPS.velMagnitude;
merged_gps.velocity_magnitude_sigma = cleanedData.MergedGPS.velMagnitude_Sigma;

merged_gps.xeast_increments = cleanedData.MergedGPS.xEast_increments;
merged_gps.xeast_increments_sigma = cleanedData.MergedGPS.xEast_increments_Sigma;
merged_gps.ynorth_increments = cleanedData.MergedGPS.yNorth_increments;
merged_gps.ynorth_increments_sigma = cleanedData.MergedGPS.yNorth_increments_Sigma;
merged_gps.yaw_deg = cleanedData.MergedGPS.Yaw_deg;
merged_gps.yaw_deg_sigma = cleanedData.MergedGPS.Yaw_deg_Sigma;

merged_gps.gps_seconds = cleanedData.MergedGPS.GPS_Time;
merged_gps.gps_week = cleanedData.GPS_Hemisphere.GPS_week * ones(length(cleanedData.MergedGPS.GPS_Time),1);

t_unix_start = datetime('1970-01-01','InputFormat','yyyy-MM-dd');
t_gps_start = datetime('1980-01-06','InputFormat','yyyy-MM-dd');
tick = posixtime(t_gps_start) - posixtime(t_unix_start);

unix_timestamp = cleanedData.GPS_Hemisphere.GPS_week * 604800 + cleanedData.MergedGPS.GPS_Time + tick;
time_zone = datetime(unix_timestamp, 'ConvertFrom', 'posixtime','TimeZone','America/New_York','Format','yyyy-MM-dd HH:mm:ss');
time_measured = cellstr(time_zone); %Convert to cell array of character vectors
merged_gps.timestamp = time_measured;


merged_gps_table = struct2table(merged_gps);
% insert data into road_segment_reference
if flag.DBinsert
    insert_rows = 500000;
    Split = ceil(height(merged_gps_table)/insert_rows); % insert 100,000 rows each loop,40seconds
    tic
    for i= 1:Split
        row_index_start = insert_rows*i -insert_rows+1;
        row_index_end = min(insert_rows*i,height(merged_gps_table));
        merged_gps_table_insert = merged_gps_table(row_index_start:row_index_end,:);
        fprintf(1,' Insert: trip_id %.2f , %.2f  to %.2f rows\n',trips.id,row_index_start,row_index_end);
        
        try
            sqlwrite(DB.db_connection,'merged_gps',merged_gps_table_insert);
        catch ME
            switch ME.identifier
                case 'database:database:WriteTableDriverError'
                    if strfind(ME.message,'duplicate key value violates unique constraint')
                        warning(ME.message);
                        prompt = ['Do you want to replace the merged_gps data of trip_id: ' num2str(trips.id) ' ?[y/n]'];
                        User_input_replace = input(prompt,'s');
                        
                        if strcmpi(User_input_replace,'y')
                            fprintf(1,'Thanks. Let''s update it...\n');
                            % delete old data
                            sql_trip_delete =[ 'delete from merged_gps where trips_id = ' num2str(trips.id) ';'];
                            exec(DB.db_connection,sql_trip_delete);
                            % reset the sequence id 
                            sql_max_id ='select max(id) from merged_gps;'; %
                            results_max_id = fetch(DB.db_connection,sql_max_id); %
                            
                            sql_merged_gps_id_seq_restart  = ['ALTER SEQUENCE merged_gps_id_seq RESTART WITH ' num2str(results_max_id.max+1)];
                            exec(DB.db_connection,sql_merged_gps_id_seq_restart);
                            
                            %update(DB.db_connection,tablename,colnames,data,whereclause)
                            % insert new data
                            sqlwrite(DB.db_connection,'merged_gps',merged_gps_table_insert);
                            fprintf(1,['trip_id ' num2str(trips.id) ' has been updated!\n']);
                            
                        else
                            fprintf(1,'insert is aborted.\n');
                            
                        end
                    else
                        rethrow(ME)
                    end
                otherwise
                    rethrow(ME)
            end
            %
        end
        
        toc
    end
    fprintf(1,' Insert: merged_gps data of trip_id %d completed.\n',trips.id);
    toc
end

DB.disconnect();   
end

