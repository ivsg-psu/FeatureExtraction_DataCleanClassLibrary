%% Find Lane and Road Boundaries

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______ _           _   _                                        _   _____                 _   ____                        _            _           
%  |  ____(_)         | | | |                                      | | |  __ \               | | |  _ \                      | |          (_)          
%  | |__   _ _ __   __| | | |     __ _ _ __   ___    __ _ _ __   __| | | |__) |___   __ _  __| | | |_) | ___  _   _ _ __   __| | __ _ _ __ _  ___  ___ 
%  |  __| | | '_ \ / _` | | |    / _` | '_ \ / _ \  / _` | '_ \ / _` | |  _  // _ \ / _` |/ _` | |  _ < / _ \| | | | '_ \ / _` |/ _` | '__| |/ _ \/ __|
%  | |    | | | | | (_| | | |___| (_| | | | |  __/ | (_| | | | | (_| | | | \ \ (_) | (_| | (_| | | |_) | (_) | |_| | | | | (_| | (_| | |  | |  __/\__ \
%  |_|    |_|_| |_|\__,_| |______\__,_|_| |_|\___|  \__,_|_| |_|\__,_| |_|  \_\___/ \__,_|\__,_| |____/ \___/ \__,_|_| |_|\__,_|\__,_|_|  |_|\___||___/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                                                                                                     
                                                                                                                                                     
function [Lanes_Boundaries, offsets_intensity] = fcn_DataClean_findLanesandBoundaries(img,imgHeight,scan_range,Extrema_Struct,Flags)
% function Lanes_Boundaries = fcn_laneCenter_findLanesandBoundaries(img,imgHeight,I,H,...
%                   extrema_correlation_unstraightened,extrema_correlation_unstraightenedHeight,scan_range,Flags)
%%%% Script_testing_merge_intensity_and_height.m
%       Template filtering identifies lanes from LIDAR intenstity extrema data by aligning the extrema in successive LIDAR scans. The
%       lane centerline is calculated by averaging the positions of the innermost lane lines. The vehicle position is also derived. 
%
% Notes: Only works on lanes of constant width.
%
% FORMAT: 
%
%       Lanes_Boundaries = fcn_laneCenter_findLanesandBoundaries(img,scan_range);
%
% INPUTS:
%
%      img: image file containing unfiltered LIDAR intensity data.
%      imgHeight: image file containing unfiltered LIDAR height data 
%      I: LIDAR intensity extrema data
%      H: LIDAR height extrema data
%      extrema_correlation_unstraightened: correlation for each intensity extrema (strength) 
%      extrema_correlation_unstraightenedHeight: correlation for each height extrema (strength) 
%      scan_range: range of scans in the LIDAR dataset to be processed.
%
%      (OPTIONAL INPUTS)
%
%      Input_Optional: explanation.
%
% OUTPUTS:
%
%      Lanes_Boundaries: empty variable 
%
%      heightsandintensities.mat: datafile containing detected lane, road geometry,
%                                 centerline, and derived vehicle position for a range of LIDAR scans.
%
% DEPENDENCIES
%
%      fcn_check_to_template
%      interpolated_data.mat
%      extrema_data.mat
%
% EXAMPLES:
%      
%       See the script:
%       script_test_fcn (UPDATE) for a full
%       test suite.
%
% This function was written on 2022_01_29 by Vahan Kazandjian and Dr. S Brennan
% Questions or comments? sbrennan@psu.edu 

% Revision history:
%     2022_01_29
%     -- Created function

%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _       
%  |_   _|                 | |      
%    | |  _ __  _ __  _   _| |_ ___ 
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |                  
%              |_| 
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
show_plots = 1;

% scan_range = (scan_range)'; %(1819:1909)';  % The range of indices to examine
% scan_range = (1819:1909)';  % The range of indices to examine

%  % Tell user that we are within this function
%
%                 fprintf(1,'Starting FCN fcn_laneCenter_findLanesandBoundaries: Finding extrema...\n')
%
%
%             % Find the size of the image
%             N_points = size(img,1);
%             N_scans = size(img,2);
%             half_number_of_points = round(N_points/2);
%
%             % THE FOLLOWING NEEDS TO BE AN EXTREMA SUBFUNCTION
%             % Convert to grayscale - start by creating empty intensity
%             % array, and empty extrema correlation array
%             I = zeros(N_points,N_scans);
%             extrema_correlation_unstraightened = zeros(size(I));

% Check if the variables exist already in the workspace. If so, do NOT load
% them again (this takes forever).
if Flags.flag_skip_ahead_point <=5
%     if ~exist('img','var') && Flags.use_datafiles == 1 %If variable does not exist or flag is set to use datafiles
%         
%         fprintf(1,'\t Loading img variables from file.\n');
%         load('.\Data\interpolated_data.mat','one_color','one_colorHeight','XY_interp')  %if true, the interpolated data is loaded
%         % Intensity Image
%         img(:,:,1) = one_color;
%         img(:,:,2) = one_color;
%         img(:,:,3) = one_color;
%         
%         %Height Image
%         imgHeight(:,:,1) = one_colorHeight;
%         imgHeight(:,:,2) = one_colorHeight;
%         imgHeight(:,:,3) = one_colorHeight;
%         fprintf(1,'\t Done loading intensity and height image data\n');
%     end    
    
    if ~exist('H','var') && Flags.use_datafiles == 1 %If variable does not exist or flag is set to use datafiles
        fprintf(1,'Loading extrema...\n');
        load(fullfile('.','Data','extrema_data.mat'),'I','H','extrema_correlation_unstraightened', 'extrema_correlation_unstraightenedHeight')  %if true, the extrema data is loaded
        fprintf(1,'\t Done loading extrema...\n');
    end 
        extrema_correlation_unstraightened = Extrema_Struct.extrema;
        extrema_correlation_unstraightenedHeight = Extrema_Struct.extrema_height;
        H = Extrema_Struct.H;
        I = Extrema_Struct.I;
    
        %     else % if false, the extrema are computed
        %                 %if obj.verbose == 1
        %                     fprintf(1,'\t Extrema data being calculated...\n')
        %                % end
        %                 % Loop through each scan, finding the extrema
        %                 for k_scan = 1:N_scans
        %
        %                     %if obj.verbose == 1
        %                         fprintf(1,'\t\tProcessing extrema from scan %i / %i\n', k_scan, N_scans)
        %                     %end
        %
        %                     % Grab the scan data for one scan
        %                     scan_data = img(:,k_scan)';
        %
        %                     % Calculate the optimal filter
        %                     filter = obj.extrema.fcn_createOptimalExtremaFilter(scan_data, obj.filter_lengthI);
        %
        %                     % Apply the optimal filter to find extrema
        %                     [extrema_kth_scan, correlation_kth_scan] = obj.extrema.fcn_findExtrema(scan_data,filter, obj.number_of_extrema);
        %
        %                     % Save results
        %                     extrema_correlation_unstraightened(:,k_scan) = correlation_kth_scan;
        %                     I(:,k_scan) = extrema_kth_scan;
        %
        %                 end
        %
        %                 % Save the results to file
        %                 %if obj.verbose == 1
        %                     fprintf(1,'\tSaving extrema to file: extrema_data.mat in current folder...\n');
        %                 %end
        %                 save('extrema_data.mat','I', 'extrema_correlation_unstraightened')
        %                 %if obj.verbose == 1
        %                     fprintf(1,'\t\tSaving is done.');
        %                 %end
        %             end
        
        
        %% Plot the matrices (slow)
        if 1 == 0
            for current_iteration = 1:length(scan_range) %1:N_scans
                k_scan = scan_range(current_iteration);
                % Load results
                
                scan_normalizedIntensity = img(:,k_scan)'; % Intensity
                scan_Height = imgHeight(:,k_scan)'; % Height
                correlation_kth_scan = extrema_correlation_unstraightened(:,k_scan); % Intensity
                extrema_kth_scan = I(:,k_scan); % Intensity
                correlation_kth_scanHeight = extrema_correlation_unstraightenedHeight(:,k_scan); % Height
                extrema_kth_scanHeight = H(:,k_scan);  % Height
                
                
                % FOR DEBUGGING:
                %diff_scan_Height = abs([0, diff(scan_Height)]); % Absolute value of derivative of Height
                diff_scan_Height = [0, diff(scan_Height)]; % Derivative of Height
                %diff_scan_Height = scan_Height; % Height
                
                % For image, keep only the extrema with strong
                % correlations
                threshold_for_image_extrema_correlation = 200; %200 - 200 used for Vahan's Honors Thesis
                extrema_indices = find(extrema_kth_scan>0.5);
                weak_extrema_indices = find((correlation_kth_scan(extrema_indices).^2)<(threshold_for_image_extrema_correlation.^2));
                extrema_indices_to_remove = extrema_indices(weak_extrema_indices);
                extrema_kth_scan(extrema_indices_to_remove) = 0; % Shut off the weak ones
                
                % For the height, keep only terms with
                % highest or lowest correlation
                [~,min_correlationIndex_kth_scanHeight] = min(correlation_kth_scanHeight);
                [~,max_correlationIndex_kth_scanHeight] = max(correlation_kth_scanHeight);
                extrema_indicesHeight = find(extrema_kth_scanHeight>0.5);
                threshold_for_height_extrema_correlation = (5)^2; % Must be within 5 index points of peak correlation
                weak1_extremaHeight_indices = extrema_indicesHeight((extrema_indicesHeight-min_correlationIndex_kth_scanHeight).^2>threshold_for_height_extrema_correlation);
                weak2_extremaHeight_indices = extrema_indicesHeight((extrema_indicesHeight-max_correlationIndex_kth_scanHeight).^2>threshold_for_height_extrema_correlation);
                weak_extremaHeight_indices = intersect(weak1_extremaHeight_indices,weak2_extremaHeight_indices);
                
                if 1==0
                    extrema_kth_scanHeight(weak_extremaHeight_indices) = 0; % Shut off the weak height ones
                else % Keep only min and max value?
                    extrema_kth_scanHeight = zeros(size(extrema_kth_scanHeight));
                    extrema_kth_scanHeight(min_correlationIndex_kth_scanHeight) = 1;
                    extrema_kth_scanHeight(max_correlationIndex_kth_scanHeight) = 1;
                end
                
                % THIS IS NEW:
                I(:,k_scan) = extrema_kth_scan; % Intensity
                H(:,k_scan) = extrema_kth_scanHeight;  % Height
                
                % For debugging
                if 1==0
                    % Do another set of plots (either put side by side or
                    % on same) plot extrema for both (extrema_kth_scan...)
                    
                    figure(1999)
                    clf
                    
                    
                    subplot(5,1,1)
                    indices_of_extrema = find(extrema_kth_scan>0.5);
                    x_data_for_plotting = 1:length(scan_normalizedIntensity);
                    plot(x_data_for_plotting,scan_normalizedIntensity,'b');
                    hold on
                    
                    plot(x_data_for_plotting(indices_of_extrema),scan_normalizedIntensity(indices_of_extrema),'ro')
                    plot(x_data_for_plotting(extrema_indices_to_remove),scan_normalizedIntensity(extrema_indices_to_remove),'co');
                    title(sprintf('Intensity and its Extrema for scan: %d',k_scan));
                    
                    subplot(5,1,2)
                    plot(x_data_for_plotting,correlation_kth_scan,'b');
                    hold on
                    plot(x_data_for_plotting(indices_of_extrema),correlation_kth_scan(indices_of_extrema),'ro')
                    title('Correlation for Intensity');
                    
                    subplot(5,1,3)
                    indices_of_extrema = find(extrema_kth_scanHeight>0.5);
                    x_data_for_plotting = 1:length(scan_Height);
                    plot(x_data_for_plotting,scan_Height,'b');
                    hold on;
                    plot(x_data_for_plotting(indices_of_extrema),scan_Height(indices_of_extrema),'ro');
                    plot(x_data_for_plotting(weak_extremaHeight_indices),scan_Height(weak_extremaHeight_indices),'co');
                    title('Height and its Extrema')
                    
                    subplot(5,1,4)
                    x_data_for_plotting = 1:length(diff_scan_Height);
                    plot(x_data_for_plotting,diff_scan_Height,'b');
                    hold on;
                    plot(x_data_for_plotting(indices_of_extrema),diff_scan_Height(indices_of_extrema),'ro');
                    title('Derivative of height')
                    
                    subplot(5,1,5)
                    plot(x_data_for_plotting,correlation_kth_scanHeight,'b');
                    hold on
                    plot(x_data_for_plotting(indices_of_extrema),correlation_kth_scanHeight(indices_of_extrema),'ro')
                    title('Correlation for Intensity');
                    
                    drawnow;
                end % Ends if statement to plot
            end % Ends for loop
        end
        
        
        
        
        %% Check correlation plots
        
        
        % Renormalize correlation plots for intensity
        extrema_correlation_unstraightened_normalized = abs(extrema_correlation_unstraightened);
        extrema_correlation_unstraightened_normalized = extrema_correlation_unstraightened_normalized - min(extrema_correlation_unstraightened_normalized);
        extrema_correlation_unstraightened_normalized = extrema_correlation_unstraightened_normalized./max(extrema_correlation_unstraightened_normalized)*255;
        
        % Renormalize correlation plots for height
        extrema_correlation_unstraightenedHeight_normalized = abs(extrema_correlation_unstraightenedHeight);
        extrema_correlation_unstraightenedHeight_normalized = extrema_correlation_unstraightenedHeight_normalized - min(extrema_correlation_unstraightenedHeight_normalized);
        extrema_correlation_unstraightenedHeight_normalized = extrema_correlation_unstraightenedHeight_normalized./max(extrema_correlation_unstraightenedHeight_normalized)*255;
        
        % Plot the correlation results?
%         if 1 == Flags.Plot
%             %Intensity
%             figure(3874);
%             clf;
%             image(abs(extrema_correlation_unstraightened_normalized));
%             title('The results of the correlation via optimal filtering (intensity)');
%             
%             %Height
%             figure(3875);
%             clf;
%             image(abs(extrema_correlation_unstraightenedHeight_normalized)); %If using diff, then must divided extrema correlation by .0001 to see a result
%             title('The results of the correlation via optimal filtering (height)');
%         end
        
        
        
        
        %% Find offsets
        
        % Template the results
        template_intensity = [1456;1713;4777]; %find(I(:,scan_range(1))>0.5); %[1379;1634;4687];
        template_height = find(H(:,scan_range(1))>0.5);
        
        % Initialize arrays
        offsets_intensity  = zeros(length(scan_range),length(template_intensity));
        offsets_height = zeros(length(scan_range),length(template_height));
        
        
        index_distance_threshold = 75; %200;
        
%         if 1 == Flags.Plot
%             figure(4222)
%             set(gca,'ydir','reverse')
%             xlabel('Scan Number')
%             ylabel('Intensity Extrema')
%             hold on
%         end 
        
        for current_iteration = 1:length(scan_range) %1:N_scans
            k_scan = scan_range(current_iteration);
            
            extrema_kth_scan = I(:,k_scan); % Intensity
            extrema_kth_scanHeight = H(:,k_scan);  % Height
            
            indices_intensity = find(extrema_kth_scan>0.5);
            indices_height = find(extrema_kth_scanHeight>0.5);
            
            indices_intensity2 = find(extrema_kth_scan>0.5); %For testing height info without template
            offsets_intensity3{current_iteration,:} = indices_intensity2;
            
            indices_height2 = indices_height; %For testing height info without template
            
            % Check intensity to see if only 3 values
            old_indices_intensity = template_intensity;
            indices_intensity = fcn_check_to_template(template_intensity,indices_intensity, index_distance_threshold);
            
            new_indices_intensity = [0;0;0];
            average_shift = 0;
            
            for i = 1:length(indices_intensity)
                if isnan(indices_intensity(i))
                    average_shift = mean((indices_intensity - old_indices_intensity),'omitnan');
                    new_indices_intensity(i,:) = old_indices_intensity(i) + average_shift;
                else
                    new_indices_intensity(i,:) = indices_intensity(i);
                end
            end
            
            % Check height to see if only 2
            %         if k_scan == 1822
            %             disp('Enter here');
            %             temp = fcn_check_to_template(template_height,indices_height, index_distance_threshold);
            %         end
            
            % Compare height indices to the template
            if 1 == 0
                indices_height = fcn_check_to_template(template_height,indices_height, index_distance_threshold);
            end
            % Slowly move the template to real data
            forget_factor = 2/3; %2/3;
            template_intensity = forget_factor*template_intensity + (1-forget_factor)*new_indices_intensity;
            
            
            template_height = forget_factor*template_height + (1-forget_factor)*indices_height;
            
            % Save results
            offsets_intensity(current_iteration,:) = new_indices_intensity;
            offsets_height(current_iteration,:) = indices_height2; %indices_height; %For testing height info without template
            
            x_iteration = current_iteration + scan_range(1);
            
            if 1 == Flags.Plot
                plot(x_iteration, indices_intensity,'.')
                %plot(x_iteration,new_indices_intensity,'o')
                %plot(x_iteration,template_intensity,'o')
                drawnow
            end 
        end
        
        
        %% Plot results
        
        %Find centerline
        intensity_centerline = mean(offsets_intensity(:,2:3),2);
        %height_centerline = mean(offsets_height,2)
        
        if 1 == Flags.Plot
            %offsets_height = movmean(offsets_height,100) %For testing height info without template
            
            figure(27272);
            clf;
            hold on;
            
            % Plot Lanes and Road Boundaries
            
            h1 = plot(scan_range,(offsets_intensity*0.001),'r','LineWidth',3);
            %h2 = plot(scan_range,(offsets_height*0.001),'.g','MarkerSize',15); %Uncomment to plot
            %geometry
            
            %plot(range,(offsets_intensity(:,2)*0.001),'r'); % Manually plot each individual lane line
            %plot(range,(offsets_intensity(:,3)*0.001),'r');
            %plot(range,(offsets_height(:,2)*0.001),'g'); % Manually plot each individual road boundary line
            
            % Plot Centerlines
            %plot(scan_range,height_centerline,'c');
            %h3 = plot(scan_range, intensity_centerline*.001,'b','LineWidth',3);
            
            xlabel('Scan Number')
            ylabel('Lateral Feature Position [m]')
            %legend([h1(1),h2(1),h3(1)],'Lane Markers','Road Geometry','Lane Centerline')
            %legend([h1(1),h2(1)],'Lane Markers','Road Geometry') % Uncomment for geometry
            %legend([h1(1),h3(1)],'Lane Markers','Lane Centerline')
            legend([h1(1)],'Lane Markers')
            %grid on;
            %grid minor;
            set (gca, 'ydir', 'reverse')
            set(gca,'FontSize',15)
            %ylim([-.99, 7]) %Uncomment to plot height
            ylim([0, 7])
        end 
        %% Plot Offsets from First Scan
        
        if 1 == 0
            offsets_intensity1 = offsets_intensity - offsets_intensity(1,:);
            offsets_height1 = offsets_height - offsets_height(1,:);
            
            % Plot results
            
            figure(27556);
            clf;
            hold on;
            plot(scan_range,offsets_intensity1(:,1),'r');
            plot(scan_range,offsets_intensity1(:,2),'r');
            plot(scan_range,offsets_intensity1(:,3),'r');
            plot(scan_range,offsets_height1(:,1),'g');
            plot(scan_range,offsets_height1(:,2),'g');
            ylabel('Driver deviation relative to first scan [mm]');
            xlabel('Scan line');
            legend('Lane Markers','Road Geometry')
            grid on;
            grid minor;
        end
        %% Plot Offsets from Mean
        
        
        % Remove offsets in offsets (laugh)
        offsets_intensity_mean1 = offsets_intensity - mean(offsets_intensity,'omitnan');
        offsets_height_mean1 = offsets_height - mean(offsets_height);
        
        %vehicle_position =
        
        % Plot results
        if 1 == Flags.Plot
            figure(27555);
            clf;
            hold on;
            h1 = plot(scan_range,offsets_intensity_mean1*0.001,'r','LineWidth',2);
            %h2 = plot(scan_range,offsets_height_mean1*0.001,'g','LineWidth',3); %Uncomment to plot height information
            
            %     plot(range,offsets_intensity_mean1(:,1)*0.001,'r');
            %     plot(range,offsets_intensity_mean1(:,2)*0.001,'r');
            %     plot(range,offsets_intensity_mean1(:,3)*0.001,'r');
            %     plot(range,offsets_height_mean1(:,1)*0.001,'g');
            %     plot(range,offsets_height_mean1(:,2)*0.001,'g');
            %ylabel('Lateral deviation relative to features on the road [m]');
            ylabel({'Lateral deviation from'; 'mean feature position [m]'});
            xlabel('Scan line');
            %legend([h1(1),h2(1)],'Lane Markers','Road Geometry')
            legend([h1(1)],'Lane Markers')
            %grid on;
            %grid minor;
            set(gca,'FontSize',15)
        end 
        %% Take averages
        mean_image_offsets = mean(offsets_intensity_mean1,2);
        mean_height_offsets = mean(offsets_height_mean1,2);
        
        if 1 == Flags.Plot
            figure(24646);
            clf;
            hold on;
            h1 = plot(scan_range,mean_image_offsets(:,1)*0.001,'r','LineWidth',2);
            %h2 = plot(scan_range,mean_height_offsets(:,1)*0.001,'g','LineWidth',2); %Uncomment to plot height information
            %legend('Lane Markers','Road Geometry')
            %ylabel('Average lateral deviation relative to features on the road [m]');
            ylabel({'Average lateral deviation from'; 'mean feature position [m]'});
            xlabel('Scan line');
            %legend([h1(1),h2(1)],'Lane Markers','Road Geometry') %Uncomment to plot height information
            legend('Lane Markers')
            %grid on;
            %grid minor;
            set(gca,'FontSize',15)
        end 
        
        %% Plot Average Deviation of Road Geometry to Mean
        
        %mean_image_offset = mean_image_offsets - mean_height_offsets;
        mean_height_offset = offsets_height_mean1 - mean_height_offsets;
        
        std_intensity_offset_2height = std(mean_height_offset(:,1)) %standard deviation of lane marker deviation wrt mean of road boundary position [m]
        
        if 1 == Flags.Plot
            figure(24648);
            clf;
            hold on;
            %plot(range,mean_image_offset(:,1)*0.001,'r');
            plot(scan_range,mean_height_offset(:,1),'g','LineWidth',2);
            legend('Road Geometry')
            ylabel({'Deviation of geometry features'; 'relative to mean [mm]'});
            xlabel('Scan line');
            %grid on;
            %grid minor;
            set(gca,'FontSize',15)
        end 
        
        %% Plot Average Deviation of Lane Markers to Mean
        
        mean_image_offset = offsets_intensity_mean1 - mean_image_offsets;
        %mean_height_offset = offsets_height_mean1 - mean_height_offsets;
        
        std_height_offset_2intensity = std(mean_image_offset(:,1)) %standard deviation of lane marker deviation wrt mean of lane marker position [m]
        
        if 1 == Flags.Plot
            figure(24649);
            clf;
            hold on;
            plot(scan_range,mean_image_offset(:,1),'r','LineWidth',2);
            %plot(range,mean_height_offset(:,1)*0.001,'g'); %Uncomment to plot height information
            legend('Lane Markers')
            ylabel({'Deviation of lane features'; 'relative to mean [mm]'});
            xlabel('Scan line');
            %grid on;
            %grid minor;
            set(gca,'FontSize',15)
        end 
        
        %% Realign Scans
        
        offsets_intensity = offsets_intensity - mean_image_offsets;
        %offsets_height = offsets_height -  mean_height_offsets;
        
        offsets_height = offsets_height - mean_image_offsets; %For testing height info without template
        
        vehicle_position = intensity_centerline;
        
        intensity_centerline = mean(offsets_intensity(:,2:3),2);
        %height_centerline = mean(offsets_height,2); % suppressed output on 9/14/21
        
        if 1 == Flags.Plot
            figure(27273);
            clf;
            hold on;
            
            % Plot Offset Lanes and Boundaries
            
            h1 = plot(scan_range,offsets_intensity*0.001,'r','LineWidth',3);
            %h2 = plot(scan_range,offsets_height*0.001,'.g','MarkerSize',15); %Uncomment to plot height information
            %h3 = plot(scan_range, vehicle_position*.001,'k','LineWidth',3);
            
            
            %     plot(range,offsets_intensity(:,1)*0.001,'r');
            %     plot(range,offsets_intensity(:,2)*0.001,'r');
            %     plot(range,offsets_intensity(:,3)*0.001,'r');
            %     plot(range,offsets_height(:,1)*0.001,'g');
            %     plot(range,offsets_height(:,2)*0.001,'g');
            
            % Plot Centerlines

            %     %plot(range,height_centerline,'c');
            
            %h4 = plot(scan_range,intensity_centerline*.001,'b','LineWidth',3);
            
            xlabel('Scan Number')
            ylabel('Lateral Feature Position [m]')
            %legend([h1(1),h2(1),h3(1),h4(1)],'Lane Markers','Road Geometry','Vehicle Position','Lane Centerline') %Uncomment to plot height information
            %legend([h1(1),h2(1)],'Lane Markers','Road Geometry')
            legend('Lane Markers')
            %grid on;
            %grid minor;
            set ( gca, 'ydir', 'reverse' )
            set(gca,'FontSize',15)
            ylim([0, 7])
        end   
        
        intensity_centerline = mean(offsets_intensity(:,2:3),2);
        
        if 1 == Flags.Plot
            % Plot Lane Centerline and Vehicle Position
            figure(272732);
            clf;
            hold on;
            
            % Plot Offset Lanes and Boundaries
            
            h1 = plot(scan_range,offsets_intensity*0.001,'r','LineWidth',2);
            %h2 = plot(scan_range,offsets_height*0.001,'.g','MarkerSize',15); %Uncomment to plot height information
            h3 = plot(scan_range, vehicle_position*.001,'k','LineWidth',2);
            
            % Plot Centerlines
            
            h4 = plot(scan_range,intensity_centerline*.001,'b','LineWidth',2);
            
            xlabel('Scan Number')
            ylabel('Lateral Feature Position [m]')
            %legend([h1(1),h2(1),h3(1),h4(1)],'Lane Markers','Road Geometry','Vehicle Position','Lane Centerline') %Uncomment to plot height information
            %legend([h1(1),h2(1)],'Lane Markers','Road Geometry') %Uncomment to plot height information
            legend([h1(1),h3(1),h4(1)],'Lane Markers','Vehicle Position','Lane Centerline')
            %grid on;
            %grid minor;
            set ( gca, 'ydir', 'reverse' )
            set(gca,'FontSize',15)
            ylim([-.99, 7])
        end 
        % Shift Centerline to 0
        
        y_zero_point = mean(intensity_centerline*.001); %The average position of the lane centerline is where y = 0
        
        offsets_intensity_array = (offsets_intensity*0.001-y_zero_point);
        offsets_height_array = (offsets_height*0.001-y_zero_point); %Uncomment to plot height information
        vehicle_position_array = (vehicle_position*.001-y_zero_point);
        intensity_centerline_array = (mean(offsets_intensity_array(:,2:3),2)*.001);
        
        if 1==1 %1 == Flags.Plot
            % Plot Lane Centerline and Vehicle Position
            figure(272733);
            clf;
            hold on;
            
            % Plot Offset Lanes and Boundaries
            h1 = plot(scan_range,offsets_intensity_array,'r','LineWidth',2);
            %h2 = plot(scan_range,offsets_height_array,'.g','MarkerSize',15); %Uncomment to plot height information
            h3 = plot(scan_range,vehicle_position_array,'k','LineWidth',2);
            
            % Plot Centerlines
            h4 = plot(scan_range,intensity_centerline_array,'b','LineWidth',2);
            
            xlabel('Scan Number')
            ylabel('Lateral Feature Position [m]')
            %legend([h1(1),h2(1),h3(1),h4(1)],'Lane Markers','Road Geometry','Vehicle Position','Lane Centerline') %Uncomment to plot height information
            %legend([h1(1),h2(1)],'Lane Markers','Road Geometry') %Uncomment to plot height information
            %legend([h1(1),h3(1),h4(1)],'Lane Markers','Vehicle Position','Lane Centerline')
            %grid on;
            %grid minor;
            set ( gca, 'ydir', 'reverse' )
            set(gca,'FontSize',15)
            ylim([-2, 2])
            
            
            
            % Plot Lane Centerline and Vehicle Position
            figure(272743);
            clf;
            hold on;
            
%             subplot(2,1,1);
%             % Plot Offset Lanes and Boundaries
%             h1 = plot(scan_range,offsets_intensity_array,'r','LineWidth',2);
%             title('Filtered Lane Markers')
%             ylabel('Lateral Feature Position [m]')
%             set ( gca, 'ydir', 'reverse' )
%             set(gca,'FontSize',15)
%             ylim([-2, 2])
            
            subplot(2,1,2);
            %legend([h1(1)],'Lane Markers')
            h1 = plot(scan_range,offsets_intensity_array+vehicle_position_array,'r','LineWidth',2);
            title('Filtered Lane Markers')
            xlabel('Scan Number')
            ylabel('Lateral Feature Position [m]')
            set ( gca, 'ydir', 'reverse' )
            set(gca,'FontSize',15)
            ylim([-3, 3])
            box on 
            
            %figure
            subplot(2,1,1);
            hold on
            title('Unfiltered Lane Markers')
            xlabel('Scan Number')
            ylabel('Lateral Feature Position [m]')
            set ( gca, 'ydir', 'reverse' )
            set(gca,'FontSize',15)
            ylim([-3, 3])
            box on
            for q = 1:numel(offsets_intensity3)
                plot(scan_range(q),offsets_intensity3{q}*.001-3.4,'.r','LineWidth',2)
            end

        end 
        Lanes_Boundaries = fprintf(1,'\t Script Complete!\n');
end
    % Save data to file so that we don't have to recalculate again later
fprintf('\t Saving Height and Intensity points withins file: heightsandintensities.mat in current folder...\n')
save(fullfile('.','Data','heightsandintensities.mat'),'offsets_intensity','offsets_height','intensity_centerline','vehicle_position','scan_range');
fprintf('\t File save is done.\n')
    
end %End Function