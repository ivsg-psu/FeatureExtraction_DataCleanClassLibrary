%% Find Extrema 
function Extrema_Struct = fcn_DataClean_findExtrema(img,imgHeight,scan_range,Flags)
%
% Notes
%
% FORMAT: 
%
%       Extrema2 = fcn_laneCenter_findExtrema(img,imgHeight,scan_range,Flags);
%
% INPUTS:
%
%      img: image matrix of compiled LIDAR intensity scans 
%
%      imgHeight: image matrix of compiled LIDAR intensity scans
%
%      scan_range: number of scans to analyze  
%
%      Flags.make_extrema_movie: When set to 1, a movie is made for the extrema (siginificantly increases runtime)
%
%      (OPTIONAL INPUTS)
%
%      Input_Optional: explanation.
%
% OUTPUTS:
%
%      Extrema2: Empty variable
%      extrema_data.mat: data file containing intensity and height extrema
%                        for all scans in the dataset and corresponding correlation values 
%
% DEPENDENCIES
%
%      (none)
%
% EXAMPLES:
%      
%       See the script:
%       script_test_fcn (UPDATE) for a full
%       test suite.
%
% This function was written on 2022_01_29 by S. Brennan, Liming Gao, Vahan
% Kazandjian, Bobby Leary
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

    % Default decimation and lane marker size
    laser_decimation = 0.001; % units are meters
    lane_marker_size = 5 * 0.0254; % Lane markers or 5 inches, this converts it to meters

    % Extrema calculations
    filter_lengthI = 100; % 100 if 0.001 decimation, 11 if 0.01 - Looking for lane markers roughly 10 cm "wide"
    filter_lengthH = 200; % 1000 if 0.001 decimation, 100 if 0.01 - Looking for objects roughly 1 meter "wide"
    number_of_extremaI = 10; % 100
    number_of_extremaH = 10; % 100
    longitudinal_window_size = 5; % 5
    lateral_window_size = 5; % 5
    minimum_vote_for_extrema_in_longitudinal_window = 2; % 2
    minimum_vote_for_extrema_in_lateral_window = 0.5; % 0.5
    lane_marker_intensity_threshold = 0.8; % 0.85 0.9

    % Other classes that are used
    utilities = Utilities();
    extrema = Extrema();

    % Find the size of the image (uses intensity image, but
    % intensity and height images are of same size)
    N_points = size(img,1);
    N_scans = size(img,2);
    half_number_of_points = round(N_points/2);  
    
    % Initialize Extrema_Struct
    Extrema_Struct = struct;
    % Convert to grayscale - start by creating empty intensity
    % array, and empty extrema correlation array
    I = zeros(N_points,N_scans);
    H = zeros(N_points,N_scans);
    extrema_correlation_unstraightened = zeros(size(I));
    extrema_correlation_unstraightenedHeight = zeros(size(H));

    % Check to see if extrema file exists (force it to 5 now to force
    % extrema calculation
    if isfile(fullfile('.','Data','extrema_data.mat')) %&& (1==obj.flag_use_datafiles) 
        %if obj.verbose == 1
            fprintf(1,'\t Extrema data found locally! Loading extrema...\n')
       % end
        load(fullfile('.','Data','extrema_data.mat'),'I','H','extrema_correlation_unstraightened', 'extrema_correlation_unstraightenedHeight')  %if true, the extrema data is loaded 
        %if obj.verbose == 1                
            fprintf(1,'\t Done loading extrema...\n');
        %end
    else % if false, the extrema are computed

        %if obj.verbose == 1
            fprintf(1,'\t Extrema data being calculated...\n')
        %end
        if Flags.make_extrema_movie == 1
            extremavideo = VideoWriter('Extrema.avi');
            extremavideo.FrameRate = 10;
            open(extremavideo);
        end
        
        % Loop through each scan, finding the extrema
        % for k_scan = 1774:1933 %1:N_scans
        for k_scan =   scan_range %1819:1933 %1:N_scans

            %if obj.verbose == 1
                fprintf(1,'\t\tProcessing extrema from scan %i / %i  ...', k_scan, N_scans)
            %end

            % Grab the scan data for one scan
            scan_normalizedIntensity = img(:,k_scan)'; % Intensity
            scan_Height = imgHeight(:,k_scan)'; % Height
            scan_Height = movmean(scan_Height,100); %Moving average of height

            %Debugging: Plot each scan
            if 1==0
                figure(2534);
                clf
                plot(1:length(scan_normalizedIntensity),scan_normalizedIntensity,'b');
                hold on
                plot(1:length(scan_Height),scan_Height,'r');
            end

            % FOR DEBUGGING:
            %diff_scan_Height = abs([0, diff(scan_Height)]); % Absolute value of derivative of Height
            diff_scan_Height = [0, diff(scan_Height)]; % Derivative of Height
            %diff_scan_Height = scan_Height; % Height

            % Calculate the optimal filter 
            filter = extrema.fcn_createOptimalExtremaFilter(scan_normalizedIntensity, filter_lengthI); % Intensity
            filterHeight = extrema.fcn_createOptimalExtremaFilter(diff_scan_Height, filter_lengthH); % Height

            % Apply the optimal filter to find extrema
            [extrema_kth_scan, correlation_kth_scan] = extrema.fcn_findExtrema(scan_normalizedIntensity,filter, number_of_extremaI); % Intensity
            [extrema_kth_scanHeight, correlation_kth_scanHeight] = extrema.fcn_findExtrema(diff_scan_Height,filterHeight, number_of_extremaH); % Height

            % Save the correlations into matrices
            extrema_correlation_unstraightened(:,k_scan) = correlation_kth_scan; % Intensity
            extrema_correlation_unstraightenedHeight(:,k_scan) = correlation_kth_scanHeight; % Height
            
            % Now - need to fix (and save) the extrema to only give
            % a few output values.-

            % For image, keep only the extrema with strong
            % correlations
            threshold_for_image_extrema_correlation = 150; %trial and error % 200 for VK's Honors Thesis 
                                                           %Need some sort of filter to check if there are multiple extrema within a threshold next to eachother                                                   
            extrema_indices = find(extrema_kth_scan>0.5);
            weak_extrema_indices = find((correlation_kth_scan(extrema_indices).^2)<(threshold_for_image_extrema_correlation.^2)); 
            extrema_indices_to_remove = extrema_indices(weak_extrema_indices); %#ok<FNDSB>
            extrema_kth_scan(extrema_indices_to_remove) = 0; % Shut off the weak ones
            extrema_indices = find(extrema_kth_scan>0.5);
            
            %This step for the intensity scans will be to filer out the
            %extrema that aren't at the peaks of the image. Might be a
            %better way to do this...
            if 1 == 1
                width_threshold = 400; % Size of window around each extrema to check for other extrema
                strong_extrema_indices = [];
                for i = 1:length(extrema_indices)
                    current_extrema = extrema_indices(i); %Look at one extrema in the scan at a time
                    window_up = current_extrema + (width_threshold/2);
                    window_low = current_extrema - (width_threshold/2);
                    extrema_in_window = find(extrema_indices < window_up & extrema_indices > window_low);
                    correlation_values = [];
                    for j = 1:length(extrema_in_window)
                        correlation_values(j) = abs(correlation_kth_scan(extrema_indices(extrema_in_window(j))));
                    end
                    [max1,index1] = max(correlation_values);
                    strong_extrema_indices(i) = extrema_indices(extrema_in_window(index1));
                end
                
                strong_extrema_indices = unique(strong_extrema_indices);
                index_of_weak_extrema = [strong_extrema_indices,extrema_indices];
                index_of_weak_extrema = index_of_weak_extrema(sum(bsxfun(@eq, index_of_weak_extrema(:), index_of_weak_extrema(:).'))==1);
                extrema_kth_scan(index_of_weak_extrema) = 0;
            end 
            
            if 1 == 0 
                extrema_indices_strong = islocalmax(abs(correlation_kth_scan));     % Find local maximums in each scan
                extrema_indices_strong = find(extrema_indices_strong>.5);
                [index_of_strong_extrema, ~] = intersect(extrema_indices_strong,extrema_indices);    % Save only extrema that are local maximums
                extrema_kth_scan = zeros(size(extrema_kth_scan));
                extrema_kth_scan(index_of_strong_extrema) = 1;
                [index_of_weak_extrema, ~] = intersect(extrema_indices_strong,extrema_indices_to_remove);
                extrema_kth_scan(index_of_weak_extrema) = 0;
            end
            
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
                extrema_kth_scanHeight(weak_extremaHeight_indices) = 0; % Shut off the weak ones
            else % Keep only min and max value?
                extrema_kth_scanHeight = zeros(size(extrema_kth_scanHeight));
                extrema_kth_scanHeight(min_correlationIndex_kth_scanHeight) = 1;
                extrema_kth_scanHeight(max_correlationIndex_kth_scanHeight) = 1;
                P(:,k_scan) = extrema_kth_scanHeight;
            end


            % Save results
            I(:,k_scan) = extrema_kth_scan; % Intensity                   
            H(:,k_scan) = extrema_kth_scanHeight; % Height
            
            Extrema_Struct.extrema = extrema_correlation_unstraightened;
            Extrema_Struct.extrema_height = extrema_correlation_unstraightenedHeight;
            Extrema_Struct.I = I;
            Extrema_Struct.H = H;
            % For debugging
            if Flags.make_extrema_movie == 1
                % Do another set of plots (either put side by side or
                % on same) plot extrema for both (extrema_kth_scan...)

                figure(1999)
                clf


                subplot(5,1,1)
                indices_of_extrema = find(extrema_kth_scan>0.5);
                x_data_for_plotting = 1:length(scan_normalizedIntensity);
                plot(x_data_for_plotting,scan_normalizedIntensity,'b','LineWidth',2);
                set(gca,'FontSize',15)
                hold on

                plot(x_data_for_plotting(indices_of_extrema),scan_normalizedIntensity(indices_of_extrema),'ro','LineWidth',2)
                plot(x_data_for_plotting(extrema_indices_to_remove),scan_normalizedIntensity(extrema_indices_to_remove),'co','LineWidth',2);
                title(sprintf('Intensity and its Extrema for scan: %d',k_scan));
                set(gca,'FontSize',15)

                subplot(5,1,2)
                plot(x_data_for_plotting,correlation_kth_scan,'b','LineWidth',2);
                hold on
                plot(x_data_for_plotting(indices_of_extrema),correlation_kth_scan(indices_of_extrema),'ro','LineWidth',2)
                title('Correlation for Intensity');
                set(gca,'FontSize',15)

                subplot(5,1,3)
                indices_of_extrema = find(extrema_kth_scanHeight>0.5);
                x_data_for_plotting = 1:length(scan_Height);
                plot(x_data_for_plotting,scan_Height,'b','LineWidth',2);
                hold on;
                plot(x_data_for_plotting(indices_of_extrema),scan_Height(indices_of_extrema),'ro','LineWidth',2);
                plot(x_data_for_plotting(weak_extremaHeight_indices),scan_Height(weak_extremaHeight_indices),'co','LineWidth',2);
                title('Height and its Extrema')
                set(gca,'FontSize',15)

                subplot(5,1,4)
                x_data_for_plotting = 1:length(diff_scan_Height);
                plot(x_data_for_plotting,diff_scan_Height,'b','LineWidth',2);
                hold on;
                plot(x_data_for_plotting(indices_of_extrema),diff_scan_Height(indices_of_extrema),'ro','LineWidth',2);
                title('Derivative of Height')
                set(gca,'FontSize',15)

                subplot(5,1,5)
                plot(x_data_for_plotting,correlation_kth_scanHeight,'b','LineWidth',2);
                hold on
                plot(x_data_for_plotting(indices_of_extrema),correlation_kth_scanHeight(indices_of_extrema),'ro','LineWidth',2)
                title('Correlation for Height');
                set(gca,'FontSize',15)
                xlabel('Index')

                drawnow;
                frame = getframe(gcf); %Get frame from plot
                writeVideo(extremavideo,frame);   %Write frame to video
            end
            %if obj.verbose == 1
                fprintf(1,'\t\t Done.\n');
            %end


        end
        



        % Do another set of plots (either put side by side or
        % on same) plot extrema for both (extrema_kth_scan...)


        % Save the results to file?
        %if obj.verbose == 1
            fprintf(1,'\tSaving extrema to file: extrema_data.mat in current folder...\n');
        %end                
        save(fullfile('.','Data','extrema_data.mat'),'I', 'H', 'extrema_correlation_unstraightened', 'extrema_correlation_unstraightenedHeight')
        %if obj.verbose == 1
            fprintf(1,'\t\tSaving is done.');
        %end
    end % Ends check to see if data file is there

        %Plot raw intensity data for debugging (
        if 1 == 0
            for i = 1:length(scan_range)
                plot(img(:,i),'LineWidth',2)
                title(num2str(i))
                ylabel('Normalized Intensity');
                xlabel('Scan Index');
                set(gca,'FontSize',15)
                drawnow
            end
            
            figure()
            plot(img(:,3084),'LineWidth',2)
            ylabel('Normalized Intensity');
            xlabel('Scan Index');
            set(gca,'FontSize',15)
            %title('Normalized Intensity, Scan 3084, Lap 1')
            
            figure()
            plot(imgHeight(:,3084),'LineWidth',2)
            ylabel('Normalized Height');
            xlabel('Scan Index');
            set(gca,'FontSize',15)
            %title('Normalized Height, Scan 3084, Lap 1')
        end
    
    % Renormalize correlation plots for intensity
    extrema_correlation_unstraightened_normalized = abs(extrema_correlation_unstraightened);
    extrema_correlation_unstraightened_normalized = extrema_correlation_unstraightened_normalized - min(extrema_correlation_unstraightened_normalized);
    extrema_correlation_unstraightened_normalized = extrema_correlation_unstraightened_normalized./max(extrema_correlation_unstraightened_normalized)*255;

    % Renormalize correlation plots for height
    extrema_correlation_unstraightenedHeight_normalized = abs(extrema_correlation_unstraightenedHeight);
    extrema_correlation_unstraightenedHeight_normalized = extrema_correlation_unstraightenedHeight_normalized - min(extrema_correlation_unstraightenedHeight_normalized);
    extrema_correlation_unstraightenedHeight_normalized = extrema_correlation_unstraightenedHeight_normalized./max(extrema_correlation_unstraightenedHeight_normalized)*255;

    % Plot the correlation results?
%     if obj.show_plots
%         %Intensity
%         figure(3874);
%         clf; 
%         image(abs(extrema_correlation_unstraightened_normalized));  
%         title('The results of the correlation via optimal filtering (intensity)');
% 
%         %Height
%         figure(3875);
%         clf; 
%         image(abs(extrema_correlation_unstraightenedHeight_normalized)); %If using diff, then must divided extrema correlation by .0001 to see a result 
%         title('The results of the correlation via optimal filtering (height)');
%     end

Extrema2 = 1; %Dummy output
end