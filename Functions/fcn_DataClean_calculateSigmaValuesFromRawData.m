function dataStructureWithSigmas = fcn_DataClean_calculateSigmaValuesFromRawData(dataStructure, varargin)
% fcn_DataClean_calculateSigmaValuesFromRawData
% Calculates standard deviations on key variables if they are left empty
% during the data loading process.
%
% FORMAT:
%
%      RawDataWithSigmas = fcn_DataClean_loadSigmaValuesFromRawData(dataStructure, (fid))
%
% INPUTS:
%
%      dataStructure: a data structure with fields for each sensor input
% 
%      (OPTIONAL INPUTS)
%
%      fid: 
%
% OUTPUTS:
%
%      dataStructureWithSigmas: the data structure with standard deviations added
%
% DEPENDENCIES:
%
%      (none)
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_loadSigmaValuesFromRawData
%     for a full test suite.
%
% This function was written on 2019_10_10 by S. Brennan
% Questions or comments? sbrennan@psu.edu 


% Revision history:
% 2019_10_10 
% -- first write of function by sbrennan@psu.edu
% 2019_11_27 
% -- added more comments, function header.
% 2020_11_10 
% -- changed file name in prep for DataClean class
% 2023_06_12 - sbrennan@psu.edu
% -- Fixed nanmean and nanstd which is not supported in new MATLAB installs
% -- Major reformat of function to IVSG style
% -- Renamed internal function to clearly be an INTERNAL, not external call
% 2024_11_20 - xfc5113@psu.edu
% -- Rename the function from fcn_DataClean_loadSigmaValuesFromRawData to 
%   fcn_DataClean_calculateSigmaValuesFromRawData, the original function
%   was still in the Functions folder, need to be removed after review
% -- Fixed a bug in line 152 to prevent calculated sigma field to overwrite
%    by the copy


% TO DO
% 

flag_do_debug = 1; % Flag to show the results for debugging
flag_do_plots = 0; % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


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

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(1,2);
        
    % NOTE: data structure SHOULD be checked!

end


%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% An old code can be found here that calculates sigmas based on standard deviations
% rawDataWithSigmas = fcn_DataClean_estimateStatesFromIncrementedStatesViaCumsum(rawDataWithSigmasAndMedianFiltered);


%% Define which fields to calculate sigmas for
fields_to_calculate_sigmas_for = [...
    {'velNorth'},...
    {'velEast'},...
    {'velUp'},...
    {'velMagnitude'},...
    {'Roll_deg'},...
    {'Pitch_deg'},...
    {'Yaw_deg'},...
    {'Yaw_deg_from_position'},... % Confirmed
    {'Yaw_deg_from_velocity'},... % Confirmed
    {'xy_increments'}... % Confirmed
    {'XAccel'},...
    {'YAccel'},...
    {'ZAccel'},...
    {'XGyro'},...
    {'YGyro'},...
    {'ZGyro'},...
    {'xEast_increments'},...
    {'yNorth_increments'},...
    {'xEast'},...
    {'yNorth'},...
    {'zUp'},...
    ];


names = fieldnames(dataStructure); % Grab all the fields that are in rawData structure
dataStructureWithSigmas = dataStructure;
for i_data = 1:length(names)
    % Grab the data subfield name
    data_name = names{i_data};
    % d = eval(data_name);
    d = eval(cat(2,'dataStructure.',data_name));
    
    if flag_do_debug
        fprintf(1,'\n Sensor %d of %d: ',i_data,length(names));
        fprintf(1,'Calculating rawData sigmas for sensor: %s\n',data_name);
    end
    
    subfieldNames = fieldnames(d); % Grab all the subfields
    clear dout; % Initialize this structure
    dout = d;
    for i_subField = 1:length(subfieldNames)
        % Grab the name of the ith subfield
        subFieldName = subfieldNames{i_subField};

        if flag_do_debug
            fprintf(1,'\tProcessing subfield: %s ',subFieldName);
        end
        
        % % Copy over the field itself first
        % dout.(subFieldName) = d.(subFieldName);
        
        % Check to see if this subField is in the list
        if any(strcmp(subFieldName,fields_to_calculate_sigmas_for))

            % Check if Sigma field exists - if it does, do NOT overwrite it
            subFieldNameSigma = cat(2,subFieldName,'_Sigma');
            if any(strcmp(subFieldNameSigma,subfieldNames))&&(all(~isnan(d.(subFieldNameSigma))))
                % The Sigma field already exists and it is not NaN, just copy it over then
                dout.(subFieldNameSigma) = d.(subFieldNameSigma);
                if flag_do_debug
                    fprintf(1,' <-- skipped this sigma, already defined\n');
                end
            else
                % The Sigma field does not exist - need to calculate it.
                % Some of the dat may have NaN values, so we need to
                % consider this.
                data = d.(subFieldName);
                if ~isnan(data)&&~isempty(data)
                    real_sigma = fcn_INTERNAL_calcSigmaNoOutliers(data);
                    dout.(subFieldNameSigma) = real_sigma;
                else
                   warning('Sigma cannot be calculated on field %s of %s since field %s is NaN or empty', subFieldName, data_name, subFieldName) 
                end
                if isnan(real_sigma)
                    error('Sigma calculation produced an NaN value on field %s of sensor %s. Exiting.',subFieldName,data_name);
                end
                
                
                if flag_do_debug
                    % fprintf(1,' <-- calculated a sigma, has length: %d\n',length(real_sigma(:,1)));
                    fprintf(1,' <-- calculated a sigma\n'); 
                end
            end % Ends the if on whether the subfield already exists
        else 
            % If enter here, then we have a field that does NOT need a
            % sigma calculation. So we can do nothing...
            
            if flag_do_debug
                fprintf(1,'\n');
            end
        end % Ends the if statement to check if subfield is on list
    end % Ends for loop through the subfields

    dataStructureWithSigmas.(data_name) = dout; % Save results to main structure
    
     
    
end  % Ends for loop through all sensor names in rawData

%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots
    
    % Nothing to plot        
    
end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function



%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§



%% fcn_INTERNAL_calcSigmaNoOutliers
function real_sigma = fcn_INTERNAL_calcSigmaNoOutliers(data)
% Some of the data may contain NaN values, hence the use of nanmean and
% nanstd below.

differences = diff(data);
deviations = differences - mean(differences,'omitnan');
outlier_sigma = std(deviations,'omitnan');

% Reject outliers
deviations_with_no_outliers = deviations(abs(deviations)<(3*outlier_sigma));
real_sigma = std(deviations_with_no_outliers,'omitnan');

%real_sigma_vector = real_sigma*
end % Ends fcn_INTERNAL_calcSigmaNoOutliers
