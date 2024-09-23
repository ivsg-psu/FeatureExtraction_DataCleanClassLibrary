function [stitchedStructure, uncommonFields] = fcn_DataClean_stitchStructures(cellArrayOfStructures, varargin)
% fcn_DataClean_stitchStructures
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
%      [stitchedStructure, uncommonFields] = fcn_DataClean_stitchStructures(cellArrayOfStructures, (fid), (fig_num))
%
% INPUTS:
%
%      cellArrayOfStructures: a cell array of structures to stitch
%
%      (OPTIONAL INPUTS)
%
%      fid: the fileID where to print. Default is 1, to print results to
%      the console.
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed. When used recursively, fig_num can be a
%      string to specify the "parent" input.
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
%      fcn_DebugTools_cprintf
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_stitchStructures
%     for a full test suite.
%
% This function was written on 2024_09_11 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history
% 2024_09_11 - Sean Brennan, sbrennan@psu.edu
% -- wrote the code originally as a script
% 2024_09_15 - Sean Brennan, sbrennan@psu.edu
% -- added fid input for debugging

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the fig_num variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
flag_max_speed = 0;
if (nargin==3 && isequal(varargin{end},-1))
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
        narginchk(1,3);
    end
end

% Does user want to specify fid?
fid = 0;
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        fid = temp;
    end
end

% Does user want to specify fig_num?
flag_do_plots = 0;
parentString = '(root)';
if (0==flag_max_speed) &&  (3<=nargin)
    temp = varargin{end};
    if ~isempty(temp) && (~isstring(temp)||~ischar(temp))
        fig_num = temp; %#ok<NASGU>
        flag_do_plots = 1;
    end    

    if (isstring(temp)|| ischar(temp))
        parentString = temp;
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
flags_initialIsStructure = fcn_INTERNAL_whichFieldsAreStructures(cellArrayOfStructures{1});

% Is a merge needed?
if N_datasets>1

    % Check for overlapping field names along primary fields in the initial
    % data structure, that these are all in the subsequent structures. In
    % other words, all the fields in all the merged structures must exist
    % in each of the structures. This step finds these "common" fields and
    % as well lists out the uncommon fields.
    [flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkOverlappingFieldNames(parentString, cellArrayOfStructures, flags_initialIsStructure, fid);

    % Check that the data are all the same vector types. Namely: all the
    % field entries must all be 1x1 scalars with the same scalar value, OR
    % all the field entries must be NxM vectors where M is the same across
    % structures, but N may be different across the structures and/or
    % across fields.
    [flags_initialAllOverlap, uncommonFields, flags_sameScalars] = fcn_INTERNAL_checkVectorTypes(parentString, cellArrayOfStructures, uncommonFields, flags_initialAllOverlap, fid);

    if any(flags_initialAllOverlap)

        % Check that all the subfields that are structures actually merge-able
        % structures, and populates the stitched structure with these structures.
        % If the field is a structure that is NOT mergable or not overlapping, then
        % the field is removed.
        [stitchedStructure, flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkSubstructureMerging(parentString, cellArrayOfStructures, uncommonFields, flags_initialAllOverlap, flags_initialIsStructure, fid);

        if any(flags_initialAllOverlap)
            % Merge the data for overlapping fields that are NOT structures
            stitchedStructure = fcn_INTERNAL_mergeNonStructureFields(cellArrayOfStructures, stitchedStructure, flags_initialAllOverlap, flags_initialIsStructure, flags_sameScalars);
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
function [flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkOverlappingFieldNames(parentString, cellArrayOfStructures, ~, fid)
% How many data sets do we have?
N_datasets = length(cellArrayOfStructures);

% What are the fields in the first structure? This one is used as a
% template for all the others
sensorfields_initial= fieldnames(cellArrayOfStructures{1});

%% Make a list of ALL the fields in all the structures.
% This is useful for
% debugging as well.
sensorfields_allStructures = sensorfields_initial;
for ith_structure = 2:N_datasets
    sensorfields_subsequent = fieldnames(cellArrayOfStructures{ith_structure});

    % Append any non-matching field names to the list of common
    % fields
    for ith_field = 1:length(sensorfields_subsequent)
        % Make sure this is not already added
        if ~any(strcmp(sensorfields_subsequent{ith_field},sensorfields_allStructures))
            % NuncommonFields = NuncommonFields+1;
            sensorfields_allStructures{end+1} = sensorfields_subsequent{ith_field}; %#ok<AGROW>
        end
    end
end

%% Check which structures share fields
NallFields = length(sensorfields_allStructures);
flags_overlapMatrix = zeros(NallFields,N_datasets);
flags_allShared = ones(NallFields,1);

for ith_structure = 1:N_datasets
    sensorfields_subsequent = fieldnames(cellArrayOfStructures{ith_structure});    

    % Flag each structure that appears
    for ith_field = 1:length(sensorfields_allStructures)
        if any(strcmp(sensorfields_allStructures{ith_field},sensorfields_subsequent))
            flags_overlapMatrix(ith_field,ith_structure) = 1;
        end
    end

    % Update the shared flags
    flags_allShared = flags_allShared.*flags_overlapMatrix(:,ith_structure);
end


%% Check for overlapping field names along primary fields in the initial
% data structure; these are the "initial overlap" flags

flags_initialAllOverlap = flags_allShared(1:length(sensorfields_initial),:);

fieldsNotCommon = find(0==flags_allShared);


%% Print out failures?
if fid && ~isempty(fieldsNotCommon)
    Nheader = 20;
    Nfields = 30;

    try
        fprintf(fid,'\nTESTING %s\n',parentString);
    catch
        error('stop here');
    end
    fprintf(fid,'CHECKING FIELD NAME AGREEMENT:\n');
    fcn_INTERNAL_printSummary(fid, 'Fields shared',flags_overlapMatrix,flags_allShared, sensorfields_allStructures,(1:length(sensorfields_allStructures)),Nheader,Nfields,N_datasets,length(sensorfields_allStructures));

end

%% Fill in the uncommon fields
uncommonFields = cell(length(fieldsNotCommon),1);
for ith_field = 1:length(fieldsNotCommon)
    uncommonFields{ith_field} = sensorfields_allStructures{fieldsNotCommon(ith_field)};
    if fid
        if 1==fid
            fcn_DebugTools_cprintf('*Red','\tThe field %s is marked for deletion because it does not exist across all structures.\n',uncommonFields{ith_field});
        else
            fprintf(fid,'\tThe field %s is marked for deletion because it does not exist across all structures.\n',uncommonFields{ith_field});
        end
        % Print carriage return?
        if ith_field == length(fieldsNotCommon)
            fprintf(fid,'\n');
        end
    end
end


end % Ends fcn_INTERNAL_checkOverlappingFieldNames


%% fcn_INTERNAL_checkVectorTypes
function [flags_initialAllOverlap, uncommonFields, flags_sameScalars] = fcn_INTERNAL_checkVectorTypes(parentString, cellArrayOfStructures, uncommonFields, input_flags_initialAllOverlap, fid)
% Check that the data are all the same vector types. Namely: all the
% field entries must all be 1x1 scalars with the same scalar value, OR
% all the field entries must be NxM vectors where M is the same across
% structures, but N may be different across the structures and/or
% across fields.

% How many data sets do we have?
N_datasets = length(cellArrayOfStructures);

% Get the initial sensorfields (this is the template)
sensorfields_initial= fieldnames(cellArrayOfStructures{1});

% Initialize the matricies
NfieldsInitial            = length(sensorfields_initial);
fieldRowDimensions        = zeros(NfieldsInitial,N_datasets);
fieldColumnDimensions     = zeros(NfieldsInitial,N_datasets);
scalarValues              = nan(NfieldsInitial,N_datasets);
matrixFlags_isScalars     = zeros(NfieldsInitial,N_datasets);
matrixFlags_isString      = zeros(NfieldsInitial,N_datasets);
matrixFlags_stringsSame   = ones(NfieldsInitial,N_datasets);
matrixFlags_isCell        = zeros(NfieldsInitial,N_datasets);
matrixFlags_cellsSame     = ones(NfieldsInitial,N_datasets);
referenceStrings          = cell(NfieldsInitial,1);
referenceCells            = cell(NfieldsInitial,1);

%% Fill in all the column/row dimensions, and scalar values
% Do this for each structure, using only the overlapping fields

fieldsOverlappingIndicies = find(input_flags_initialAllOverlap);
NoverlappingFields        = length(fieldsOverlappingIndicies);
equality_Rows             = ones(NoverlappingFields,1);
equality_Columns          = ones(NoverlappingFields,1);
equality_Scalars          = ones(NoverlappingFields,1);
equality_Strings          = ones(NoverlappingFields,1);
equality_Cells            = ones(NoverlappingFields,1);

for ith_structure = 1:N_datasets
    for jth_overlappingField = 1:NoverlappingFields
        indexFieldToCheck = fieldsOverlappingIndicies(jth_overlappingField);
        fieldToCheck = sensorfields_initial{indexFieldToCheck};
        dataToCheck = cellArrayOfStructures{ith_structure}.(fieldToCheck);

        % Is reference NOT a structure?
        if ~isstruct(dataToCheck)
            if iscell(dataToCheck) 
                % This is a cell array, usually of strings
                matrixFlags_isCell(indexFieldToCheck,ith_structure) = 1;
                sizeOfData = size(dataToCheck);
                if all(sizeOfData==1)
                    if 1==ith_structure
                        referenceCells{indexFieldToCheck,1} = dataToCheck;
                    else
                        if ~isequal(dataToCheck,referenceCells{indexFieldToCheck,1})
                            matrixFlags_cellsSame(indexFieldToCheck,ith_structure) = 0;
                        end
                    end
                end
 
            elseif isstring(dataToCheck) || ischar(dataToCheck)
                % This is a string
                sizeOfData = [1 1]; % Force this into a scalar type
                
                % Is it only a single row of strings?
                if 1==length(dataToCheck(:,1))
                    matrixFlags_isString(indexFieldToCheck,ith_structure) = 1;
                    if 1==ith_structure
                        referenceStrings{indexFieldToCheck,1} = char(dataToCheck);
                    else
                        if ~strcmp(char(dataToCheck),referenceStrings{indexFieldToCheck,1})
                            matrixFlags_stringsSame(indexFieldToCheck,ith_structure) = 0;
                        end
                    end
                end
                matrixFlags_isScalars(indexFieldToCheck,ith_structure) = 1;
            else
                % This is a number
                sizeOfData = size(dataToCheck);
                if all(sizeOfData==1)
                    scalarValues(indexFieldToCheck,ith_structure) = dataToCheck;
                    matrixFlags_isScalars(indexFieldToCheck,ith_structure) = 1;
                end
            end
            fieldRowDimensions(indexFieldToCheck,ith_structure) = sizeOfData(1)>1;
            fieldColumnDimensions(indexFieldToCheck,ith_structure) = sizeOfData(2);


        end
    end
    temp_equality_Rows        = fieldRowDimensions(:,1)==fieldRowDimensions(:,ith_structure);
    temp_equality_Columns     = fieldColumnDimensions(:,1)==fieldColumnDimensions(:,ith_structure);
    temp_equality_Scalars     = 1.0*(scalarValues(:,1)==scalarValues(:,ith_structure)) + 1.0*all(isnan([scalarValues(:,1) scalarValues(:,ith_structure)]),2);
    temp_equality_Strings     = matrixFlags_stringsSame(:,1)==matrixFlags_stringsSame(:,ith_structure);
    temp_equality_Cells       = matrixFlags_cellsSame(:,1)==matrixFlags_cellsSame(:,ith_structure);

    equality_Rows             = equality_Rows.*temp_equality_Rows(fieldsOverlappingIndicies,1);
    equality_Columns          = equality_Columns.*temp_equality_Columns(fieldsOverlappingIndicies,1);
    equality_Scalars          = equality_Scalars.*temp_equality_Scalars(fieldsOverlappingIndicies,1);
    equality_Strings          = equality_Strings.*temp_equality_Strings(fieldsOverlappingIndicies,1);
    equality_Cells            = equality_Cells.*temp_equality_Cells(fieldsOverlappingIndicies,1);
end

% Check that all columns are the same in designation
% flags_allScalarsAgree= all(matrixFlags_isScalars(:,1)==matrixFlags_isScalars,2);
indexFieldsThatAreScalars = all(matrixFlags_isScalars==1,2);
flags_sameScalars = 0*input_flags_initialAllOverlap;
flags_sameScalars(fieldsOverlappingIndicies) = 1;
flags_sameScalars = flags_sameScalars.*indexFieldsThatAreScalars;

%% Compare equalities to find if any are zero
overallEquality = equality_Rows .* equality_Columns .* equality_Scalars .* equality_Strings .* equality_Cells;


%% Print out results?
if fid && any(0==overallEquality)
    fprintf(fid,'\nTESTING %s\n',parentString);    
    fprintf(fid,'CHECKING VECTOR DIMENSION AGREEMENT:\n');
    Nheader = 20;
    Nfields = 30;

    % Print row results
    fcn_INTERNAL_printSummary(fid, 'Row dimension test results', fieldRowDimensions, equality_Rows, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

    % Print column results
    fcn_INTERNAL_printSummary(fid, 'Column dimension test results', fieldColumnDimensions, equality_Columns, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

    % Print if scalar
    fcn_INTERNAL_printSummary(fid, 'Scalar present? ', matrixFlags_isScalars, equality_Scalars, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

    % Print the scalar results
    fcn_INTERNAL_printSummary(fid, 'Scalar equivalence test results', scalarValues, equality_Scalars, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

    % Print if a string
    fcn_INTERNAL_printSummary(fid, 'String present? ', matrixFlags_isString, equality_Strings, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

    % Print the string results
    fcn_INTERNAL_printSummary(fid, 'String equivalence test results', matrixFlags_stringsSame, equality_Strings, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

    % Print if a cell
    fcn_INTERNAL_printSummary(fid, 'Cell present? ', matrixFlags_isCell, equality_Cells, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

    % Print the cell results
    fcn_INTERNAL_printSummary(fid, 'Cell equivalence test results', matrixFlags_cellsSame, equality_Cells, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

    % Print the overall results
    fcn_INTERNAL_printSummary(fid, 'Overall equality?', [], overallEquality, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields);

end



%% Remove fields that are not type equal
flags_initialAllOverlap = input_flags_initialAllOverlap;

if any(0==overallEquality)
    badEqualities = find(0==overallEquality);
    for ith_badEquality = 1:length(badEqualities)
        indexFieldToCheck = fieldsOverlappingIndicies(badEqualities(ith_badEquality));
        fieldToCheck = sensorfields_initial{indexFieldToCheck};
        flags_initialAllOverlap(indexFieldToCheck) = 0;
        % Make sure this is not already added
        if ~any(strcmp(fieldToCheck,uncommonFields))
            uncommonFields{end+1} = fieldToCheck; %#ok<AGROW>
            if fid
                if 1==fid
                    fcn_DebugTools_cprintf('*Red','\tThe field %s is marked for deletion because its vector size does not agree across structures.\n',uncommonFields{end});
                else
                    fprintf(fid,'\tThe field %s is marked for deletion because its vector size does not agree across structures.\n',uncommonFields{end});
                end
            end
        end
    end
end



end % Ends fcn_INTERNAL_checkVectorTypes


%% fcn_INTERNAL_checkSubstructureMerging
function [stitchedStructure, flags_initialAllOverlap, uncommonFields] = fcn_INTERNAL_checkSubstructureMerging(parentString, cellArrayOfStructures, uncommonFields, flags_initialAllOverlap, flags_initialIsStrucutre, fid)
% Check that all the subfields that are structures actually merge-able
% structures, and populates the stitched structure with these structures.
% If the field is a structure that is NOT mergable or not overlapping, then
% the field is removed.

stitchedStructure = cellArrayOfStructures{1};

% How many data sets do we have?
N_datasets = length(cellArrayOfStructures);

% Get the initial sensorfields (this is the template)
sensorfields_initial= fieldnames(cellArrayOfStructures{1});

% Initialize the output to all zeros
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

            % Perform stitch
            [stitchedSubStructure, uncommonSubFields] = fcn_DataClean_stitchStructures(cellArrayOfSubStructures,fid, cat(2,parentString,'.',fieldToMerge));

            if isempty(stitchedSubStructure)
                flags_initialAllOverlap(indexFieldToMerge) = 0;
                flag_removeFields(indexFieldToMerge,1) = 1;
            else
                stitchedStructure.(fieldToMerge) = stitchedSubStructure;
            end

            % Update the uncommon field list?
            if ~isempty(uncommonSubFields)              
                flag_printStructureInfo = 0;
                for ith_subfield = 1:length(uncommonSubFields)
                    nameToAdd = cat(2,fieldToMerge,'.',uncommonSubFields{ith_subfield});
                    % Make sure this is not already added
                    if ~any(strcmp(uncommonFields,nameToAdd))
                        % NuncommonFields = NuncommonFields+1;
                        uncommonFields{end+1} = nameToAdd; %#ok<AGROW>
                        if fid
                            flag_printStructureInfo = 1;
                            if 1==fid
                                fcn_DebugTools_cprintf('*Red','\tThe field %s is marked as uncommon as all its subfields in the first structure do not match the subfields in the %.0d structure.\n',uncommonFields{end},ith_structure);
                            else
                                fprintf(fid,'\tThe field %s is marked as uncommon as all its subfields in the first structure do not match the subfields in the %.0d structure.\n',uncommonFields{end},ith_structure);
                            end
                        end
                    end
                end
                if flag_printStructureInfo
                    if fid
                        fprintf(fid,'THE ABOVE OCCURRED WHEN TESTING %s\n',parentString);
                        fprintf(fid,'DURING SUBSTRUCTURE MERGING OF FIELD %s BETWEEN 1 AND %.0d\n',fieldToMerge, ith_structure);
                    end
    
                end
            end % Ends if not empty
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
function stitchedStructure = fcn_INTERNAL_mergeNonStructureFields(cellArrayOfStructures, stitchedStructure, flags_initialAllOverlap, flags_initialIsStrucutre, flags_sameScalars)

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
            if ~flags_sameScalars(indexFieldToMerge,1)
                % Merge them by concatenation
                stitchedStructure.(fieldToMerge) = [stitchedStructure.(fieldToMerge); cellArrayOfStructures{ith_structure}.(fieldToMerge)];
            end
        end
    end
end
end % Ends fcn_INTERNAL_mergeNonStructureFields


%% fcn_INTERNAL_printFields
function fcn_INTERNAL_printFields(fid, leadString,fieldStrings,fieldsOverlappingIndicies,Nheader,Nfields)
% Print the fields
fprintf(fid,'%s ',fcn_DebugTools_debugPrintStringToNCharacters(leadString,Nheader));
for jth_overlappingField = 1:length(fieldsOverlappingIndicies)
    indexFieldToCheck = fieldsOverlappingIndicies(jth_overlappingField);
    fieldToCheck = fieldStrings{indexFieldToCheck};
    fprintf(fid,'%s ',fcn_DebugTools_debugPrintStringToNCharacters(fieldToCheck,Nfields));
end
fprintf(fid,'\n');

end % Ends fcn_INTERNAL_printFields


%% fcn_INTERNAL_printSummary
function fcn_INTERNAL_printSummary(fid, summaryTitleString,matrixToPrint,equality_result, sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields,N_datasets,NoverlappingFields)


fprintf(fid,'%s: \n',summaryTitleString);
fcn_INTERNAL_printFields(fid, sprintf('\tCommonField:'),sensorfields_initial,fieldsOverlappingIndicies,Nheader,Nfields)

% Print structure results
if ~isempty(matrixToPrint)
    for ith_structure = 1:N_datasets
        stringHeader = sprintf('\tStructure %.0d:',ith_structure);
        fprintf(fid,'%s ',fcn_DebugTools_debugPrintStringToNCharacters(stringHeader,Nheader));
        for jth_overlappingField = 1:NoverlappingFields
            indexFieldToCheck = fieldsOverlappingIndicies(jth_overlappingField);
            stringField = sprintf('%.0f',matrixToPrint(indexFieldToCheck,ith_structure));
            fprintf(fid,'%s ',fcn_DebugTools_debugPrintStringToNCharacters(stringField,Nfields));
        end
        fprintf(fid,'\n');
    end
end

% Print equality results
stringHeader = sprintf('\tEquality?');
fprintf(fid,'%s ',fcn_DebugTools_debugPrintStringToNCharacters(stringHeader,Nheader));
for jth_overlappingField = 1:NoverlappingFields
    stringField = sprintf('%.0f',equality_result(jth_overlappingField,1));
    fprintf(fid,'%s ',fcn_DebugTools_debugPrintStringToNCharacters(stringField,Nfields));
end
fprintf(fid,'\n');
end % Ends fcn_INTERNAL_printSummary
