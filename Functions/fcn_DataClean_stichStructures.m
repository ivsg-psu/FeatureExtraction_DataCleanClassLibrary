function [stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, varargin)
% fcn_DataClean_stichStructures
% given a cell array of structures, merges all the fields that are common
% among the structures, and lists also the fields that are not common
% across all. A "merge" consists of a vertical concatenation of data, e.g.
% the data rows from structure 1 are stacked above structure 2 which are
% stacked above structure 3, etc. If the data are scalars, the scalars must
% match for all the structures - otherwise they are considered not common.
%
% To merge structures, the following must be true:
%
%      all the merged fields must have the same field names
%
%      all the field entries must all be 1x1 scalars with the same scalar
%      value, OR all the field entries must be NxM vectors where M is the
%      same across structures, but N may be different across the structures
%      and/or across fields.
%
%      if the fields are themselves substructures, then the stitching
%      process is called with the substructures also.
%
%  The function returns an empty stitchedStructure ([]) if there is no
%  merged result. If substructures exist and partially agree, the parts
%  that disagree are indicated withthin uncommonFields using the dot
%  notation, for example: fieldName.disagreedSubFieldName. This is
%  recursive so sub-sub-fields would also be checked and similarly denoted
%  with two dots, etc.
%
% FORMAT:
%
%      [stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num))
%
% INPUTS:
%
%      cellArrayOfStructures: a cell array of structures to stitch
%
%      (OPTIONAL INPUTS)
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      stitchedStructure: a single structure containing all the data from
%      all the structures, ordered in same order as the input cell array
%
%      uncommonFields: a cell array of strings containing the names of any
%      fields that were not common across all the inputs
%
% DEPENDENCIES:
%
%      (none)
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_stichStructures
%     for a full test suite.
%
% This function was written on 2024_09_11 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history
% 2024_09_11 - Sean Brennan, sbrennan@psu.edu
% -- wrote the code originally as a script


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==2 && isequal(varargin{end},-1))
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; % % % % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS");
    MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG = getenv("MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_DATACLEAN_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_DATACLEAN_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_fig_num = 999978; %#ok<NASGU>
else
    debug_fig_num = []; %#ok<NASGU>
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

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(1,2);
    end
end

% Does user want to specify fig_num?
flag_do_plots = 0;
if (0==flag_max_speed) &&  (2<=nargin)
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp; %#ok<NASGU>
        flag_do_plots = 1;
    end
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

%% Main script
% Initialize the output
stitchedStructure = cellArrayOfStructures{1};
uncommonFields = [];

% How many data sets do we have?
N_datasets = length(cellArrayOfStructures);

% Find which fields in the initial structure are also structures
% themselves. Pass in the "template" structure to ID these.
flags_initialIsStrucutre = fcn_INTERNAL_whichFieldsAreStructures(cellArrayOfStructures{1});

% Is a merge needed?
if N_datasets>1

    % Check for overlapping field names along primary fields in the initial
    % data structure, that these are all in the subsequent structures. In
    % other words, all the fields in all the merged structures must exist
    % in each of the structures. This step finds these "common" fields and
    % as well lists out the uncommon fields.
    [flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkOverlappingFieldNames(cellArrayOfStructures, flags_initialIsStrucutre);

    % Check that the data are all the same vector types. Namely: all the
    % field entries must all be 1x1 scalars with the same scalar value, OR
    % all the field entries must be NxM vectors where M is the same across
    % structures, but N may be different across the structures and/or
    % across fields.
    [flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkVectorTypes(cellArrayOfStructures, uncommonFields, flags_initialAllOverlap);

    if any(flags_initialAllOverlap)

        % Check that all the subfields that are structures actually merge-able
        % structures, and populates the stitched structure with these structures.
        % If the field is a structure that is NOT mergable or not overlapping, then
        % the field is removed.
        [stitchedStructure, flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkSubstructureMerging(cellArrayOfStructures, uncommonFields, flags_initialAllOverlap, flags_initialIsStrucutre);

        if any(flags_initialAllOverlap)
            % Merge the data for overlapping fields that are NOT structures
            stitchedStructure = fcn_INTERNAL_mergeNonStructureFields(cellArrayOfStructures, stitchedStructure, flags_initialAllOverlap, flags_initialIsStrucutre);
        else
            stitchedStructure = [];
        end
    else
        stitchedStructure = [];
    end
end


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
if (1==flag_do_plots) 
    

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

%% fcn_INTERNAL_whichFieldsAreStructures
function flags_initialIsStrucutre = fcn_INTERNAL_whichFieldsAreStructures(templateStructure)
% Find which fields in the initial structure are also structures themselves

% Pull out the fields of the template structure
sensorfields_initial= fieldnames(templateStructure);

flags_initialIsStrucutre = zeros(length(sensorfields_initial),1);
for ith_field = 1:length(sensorfields_initial)
    thisField = sensorfields_initial{ith_field};
    if isstruct(templateStructure.(thisField))
        flags_initialIsStrucutre(ith_field) = 1;
    end
end
end % Ends fcn_INTERNAL_whichFieldsAreStructures

%% fcn_INTERNAL_checkOverlappingFieldNames
function [flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkOverlappingFieldNames(cellArrayOfStructures, flags_initialIsStrucutre)
% How many data sets do we have?
N_datasets = length(cellArrayOfStructures);

% What are the fields in the first structure? This one is used as a
% template for all the others
sensorfields_initial= fieldnames(cellArrayOfStructures{1});


% Check for overlapping field names along primary fields in the initial
% data structure, that these are all in the subsequent structures
% NuncommonFields = 0;
flags_initialAllOverlap = ones(length(sensorfields_initial),1);
uncommonFields = [];
for ith_structure = 2:N_datasets
    sensorfields_subsequent = fieldnames(cellArrayOfStructures{ith_structure});

    [flags_OverlappingInitial, outlierFieldsAdded] = fcn_INTERNAL_compareFields(sensorfields_initial, sensorfields_subsequent);
    flags_initialAllOverlap = flags_initialAllOverlap.*flags_OverlappingInitial;

    % Append any non-matching field names to the list of uncommon
    % fields
    if ~isempty(outlierFieldsAdded)
        for ith_field = 1:length(outlierFieldsAdded)
            % Make sure this is not already added
            if ~any(strcmp(outlierFieldsAdded{ith_field},uncommonFields))
                % NuncommonFields = NuncommonFields+1;
                uncommonFields{end+1} = outlierFieldsAdded{ith_field}; %#ok<AGROW>
            end
        end
    end

    % Check that the fields in subsequent structure are, or are not,
    % structures. If one is a structure, but the other is not, they do
    % not match. Need to update the flag_initialAllOverlap accordingly
    % to indicate that, although they have the same names, they are not
    % actually the same
    for ith_field = 1:length(flags_initialAllOverlap)
        if 1 == flags_initialAllOverlap(ith_field,1)
            thisField = sensorfields_initial{ith_field};
            if isstruct(cellArrayOfStructures{ith_structure}.(thisField)) ~= flags_initialIsStrucutre(ith_field)
                flags_initialAllOverlap(ith_field) = 0;
            end
        end
    end

end
end % Ends fcn_INTERNAL_checkOverlappingFieldNames

%% fcn_INTERNAL_compareFields
function [flags_OverlappingInitial, outlierFieldsAdded] = fcn_INTERNAL_compareFields(sensorfields_initial, sensorfields_to_be_added)
NfieldsInitial = length(sensorfields_initial);
NfieldsAdded = length(sensorfields_to_be_added);
flags_sensorsAddedNotFound = ones(NfieldsAdded,1);

outlierFieldsAdded = [];
flags_OverlappingInitial = ones(NfieldsInitial,1);

for ith_field = 1:NfieldsInitial
    fieldToTest = sensorfields_initial{ith_field};
    agreementIndicies = find(strcmp(fieldToTest,sensorfields_to_be_added));
    if isempty(agreementIndicies)
        % The lists do NOT agree
        flags_OverlappingInitial(ith_field,1) = 0;
        outlierFieldsAdded{end+1} = fieldToTest; %#ok<AGROW>
    else
        % The lists agree
        flags_sensorsAddedNotFound(agreementIndicies) = 0;
    end
end

% Find which fields were outliers in the added
notFoundIndicies = find(1==flags_sensorsAddedNotFound);
for ith_notFound = 1:length(notFoundIndicies)
    thisNotFoundIndex = notFoundIndicies(ith_notFound);
    outlierFieldsAdded{end+1} = sensorfields_to_be_added{thisNotFoundIndex}; %#ok<AGROW>
end
end % Ends fcn_INTERNAL_compareFields


%% fcn_INTERNAL_checkVectorTypes
function [flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkVectorTypes(cellArrayOfStructures, uncommonFields, flags_initialAllOverlap)
% Check that the data are all the same vector types. Namely: all the
% field entries must all be 1x1 scalars with the same scalar value, OR
% all the field entries must be NxM vectors where M is the same across
% structures, but N may be different across the structures and/or
% across fields.

templateStructure = cellArrayOfStructures{1};

% How many data sets do we have?
N_datasets = length(cellArrayOfStructures);

% Get the initial sensorfields (this is the template)
sensorfields_initial= fieldnames(cellArrayOfStructures{1});

% Initialize the output to all zeros - these are 
fieldRowDimensions    = zeros(length(sensorfields_initial),1);
fieldColumnDimensions = zeros(length(sensorfields_initial),1);
scalarValues          = nan(length(sensorfields_initial),1);

% Fill in all the column/row dimensions, and scalar values, for the
% templateStructure
fieldsOverlappingIndicies = find(flags_initialAllOverlap);
for jth_overlappingField = 1:length(fieldsOverlappingIndicies)
    indexFieldToCheck = fieldsOverlappingIndicies(jth_overlappingField);
    fieldToCheck = sensorfields_initial{indexFieldToCheck};
    dataToCheck = templateStructure.(fieldToCheck);
    if ~isstruct(dataToCheck)
        sizeOfData = size(dataToCheck);
        fieldRowDimensions(indexFieldToCheck,1) = sizeOfData(1);
        fieldColumnDimensions(indexFieldToCheck,1) = sizeOfData(2);
        if all(sizeOfData==1)
            scalarValues(indexFieldToCheck,1) = dataToCheck;
        end
    end
end

% Check all the other structures to see if they have the correct vector
% dimensions
fieldsOverlappingIndicies = find(flags_initialAllOverlap);
for ith_structure = 2:N_datasets
    for jth_overlappingField = 1:length(fieldsOverlappingIndicies)
        indexFieldToCheck = fieldsOverlappingIndicies(jth_overlappingField);
        fieldToCheck = sensorfields_initial{indexFieldToCheck};

        % Is the field NOT a structure?
        dataToCheck = cellArrayOfStructures{ith_structure}.(fieldToCheck);
        if ~isstruct(dataToCheck)
            sizeOfData = size(dataToCheck);
            flag_thisDataIsGood = 1;

            % Does this data have right number of columns?
            if fieldColumnDimensions(indexFieldToCheck,1) ~= sizeOfData(2)
                flag_thisDataIsGood = 0;
            end

            % Is this data scalar and the template is NOT scalar?
            if isnan(scalarValues(indexFieldToCheck,1)) && all(all(sizeOfData==1))
                flag_thisDataIsGood = 0;
            end

            % Is the template a scalar and this data NOT a scalar?
            if ~isnan(scalarValues(indexFieldToCheck,1)) && ~all(all(sizeOfData==1))
                flag_thisDataIsGood = 0;
            end

            % Is the template a scalar and this data a scalar, and the values are different?
            if ~isnan(scalarValues(indexFieldToCheck,1)) && all(all(sizeOfData==1)) && ~isequal(dataToCheck,scalarValues(indexFieldToCheck,1))
                flag_thisDataIsGood = 0;
            end

            if 0==flag_thisDataIsGood
                flags_initialAllOverlap(indexFieldToCheck) = 0;
                % Make sure this is not already added
                if ~any(strcmp(fieldToCheck,uncommonFields))
                    uncommonFields{end+1} = fieldToCheck; %#ok<AGROW>
                end
            end

        end
    end
end

end % Ends fcn_INTERNAL_checkVectorTypes


%% fcn_INTERNAL_checkSubstructureMerging
function [stitchedStructure, flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkSubstructureMerging(cellArrayOfStructures, uncommonFields, flags_initialAllOverlap, flags_initialIsStrucutre)
% Check that all the subfields that are structures actually merge-able
% structures, and populates the stitched structure with these structures.
% If the field is a structure that is NOT mergable or not overlapping, then
% the field is removed.

stitchedStructure = cellArrayOfStructures{1};

% How many data sets do we have?
N_datasets = length(cellArrayOfStructures);

% Get the initial sensorfields (this is the template)
sensorfields_initial= fieldnames(cellArrayOfStructures{1});

% Initialize the output to all zeros - these are 
flag_removeFields = zeros(length(sensorfields_initial),1);

fieldsOverlappingIndicies = find(flags_initialAllOverlap);
for ith_structure = 2:N_datasets
    for jth_overlappingField = 1:length(fieldsOverlappingIndicies)
        indexFieldToMerge = fieldsOverlappingIndicies(jth_overlappingField);
        fieldToMerge = sensorfields_initial{indexFieldToMerge};

        % Is the field a structure?
        if 1==flags_initialIsStrucutre(indexFieldToMerge)
            % check that both sub-structures are merge-able
            cellArrayOfSubStructures{1} = stitchedStructure.(fieldToMerge);
            cellArrayOfSubStructures{2} = cellArrayOfStructures{ith_structure}.(fieldToMerge);
            [stitchedSubStructure, uncommonSubFields] = fcn_DataClean_stichStructures(cellArrayOfSubStructures);

            if isempty(stitchedSubStructure)
                flags_initialAllOverlap(indexFieldToMerge) = 0;
                flag_removeFields(indexFieldToMerge,1) = 1;
            else
                stitchedStructure.(fieldToMerge) = stitchedSubStructure;
            end

            % Update the uncommon field list?
            if ~isempty(uncommonSubFields)
                for ith_subfield = 1:length(uncommonSubFields)
                    nameToAdd = cat(2,fieldToMerge,'.',uncommonSubFields{ith_subfield});
                    % Make sure this is not already added
                    if ~any(strcmp(uncommonFields,nameToAdd))
                        % NuncommonFields = NuncommonFields+1;
                        uncommonFields{end+1} = nameToAdd; %#ok<AGROW>
                    end
                end
            end
        end
    end
end


% Remove any bad fields
% Remove fields that were tagged for removal
badFieldIndicies = find(flag_removeFields);
for ith_badField = 1:length(badFieldIndicies)
    badIndex = badFieldIndicies(ith_badField);
    fieldToDelete = sensorfields_initial{badIndex};
    stitchedStructure = rmfield(stitchedStructure,fieldToDelete);
end

% Remove fields that did not overlap
badFieldIndicies = find(0==flags_initialAllOverlap);
for ith_badField = 1:length(badFieldIndicies)
    badIndex = badFieldIndicies(ith_badField);
    fieldToDelete = sensorfields_initial{badIndex};
    if isfield(stitchedStructure,fieldToDelete)
        stitchedStructure = rmfield(stitchedStructure,fieldToDelete);
    end
end

% Check if all fields removed. If so, then the stitchedStructure no longer exists
if isempty(fieldnames(stitchedStructure))
    stitchedStructure = [];
end

end % Ends fcn_INTERNAL_checkSubstructureMerging


%% fcn_INTERNAL_mergeNonStructureFields
function stitchedStructure = fcn_INTERNAL_mergeNonStructureFields(cellArrayOfStructures, stitchedStructure, flags_initialAllOverlap, flags_initialIsStrucutre)

% How many data sets do we have?
N_datasets = length(cellArrayOfStructures);

% Get the initial sensorfields (this is the template)
sensorfields_initial= fieldnames(cellArrayOfStructures{1});

% Merge the data for overlapping fields that are NOT structures
fieldsOverlappingIndicies = find(flags_initialAllOverlap);

% Loop over all the subsequent data structures, pulling the fields out
% of each and merging into the stitched structure
for ith_structure = 2:N_datasets
    for jth_overlappingField = 1:length(fieldsOverlappingIndicies)
        indexFieldToMerge = fieldsOverlappingIndicies(jth_overlappingField);
        fieldToMerge = sensorfields_initial{indexFieldToMerge};

        % Is the field NOT a structure?
        if 0==flags_initialIsStrucutre(indexFieldToMerge)
            % Merge them!
            stitchedStructure.(fieldToMerge) = [stitchedStructure.(fieldToMerge); cellArrayOfStructures{ith_structure}.(fieldToMerge)];
        end
    end
end
end % Ends fcn_INTERNAL_mergeNonStructureFields


