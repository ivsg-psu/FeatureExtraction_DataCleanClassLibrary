% script_test_fcn_DataClean_stichStructures.m
% tests fcn_DataClean_stichStructures.m

% Revision history
% 2024_09_11 - sbrennan@psu.edu
% -- wrote the code originally

%% Set up the workspace
close all


%% Test 1: Basic example - merging level 1 fields that partially agree
fig_num = [];

clear s1 s2 s3 cellArrayOfStructures

s1.a = 1*ones(3,1);
s1.b = 1*ones(3,1);
s1.c = 1*ones(3,1);
s1.e = 1*ones(3,1);

s2.a = 2*ones(3,1);
s2.c = 2*ones(3,1);
s2.d = 2*ones(3,1);

s3.a = 3*ones(3,1);
s3.c = 3*ones(3,1);
s3.e = 3*ones(3,1);
s3.f = 3*ones(3,1);


% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
cellArrayOfStructures{3} = s3;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isstruct(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
temp = fieldnames(stitchedStructure);
assert(strcmp(temp{1},'a'));
assert(strcmp(temp{2},'c'));
assert(strcmp(uncommonFields{1},'b'));
assert(strcmp(uncommonFields{2},'e'));
assert(strcmp(uncommonFields{3},'d'));
assert(strcmp(uncommonFields{4},'f'));

% Check field values
assert(isequal(stitchedStructure.a,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))
assert(isequal(stitchedStructure.c,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))

%% Test 2: Basic example - merging level 1 fields that have no overlap in field names
fig_num = [];

clear s1 s2 s3 cellArrayOfStructures

s1.a = 1*ones(3,1);
s1.b = 1*ones(3,1);
s1.e = 1*ones(3,1);

s2.c = 2*ones(3,1);
s2.d = 2*ones(3,1);
s2.e = 2*ones(3,1);

s3.a = 3*ones(3,1);
s3.c = 3*ones(3,1);
s3.d = 3*ones(3,1);

% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
cellArrayOfStructures{3} = s3;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isempty(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
assert(strcmp(uncommonFields{1},'a'));
assert(strcmp(uncommonFields{2},'b'));
assert(strcmp(uncommonFields{3},'c'));
assert(strcmp(uncommonFields{4},'d'));
assert(strcmp(uncommonFields{5},'e'));

%% Test 3: Basic example - merging level 1 fields that completely agree
fig_num = [];

clear s1 s2 s3 cellArrayOfStructures

s1.a = 1*ones(3,1);
s1.b = 1*ones(3,1);
s1.c = 1*ones(3,1);
s1.d = 1*ones(3,1);

s2.a = 2*ones(3,1);
s2.b = 2*ones(3,1);
s2.c = 2*ones(3,1);
s2.d = 2*ones(3,1);

s3.a = 3*ones(3,1);
s3.b = 3*ones(3,1);
s3.c = 3*ones(3,1);
s3.d = 3*ones(3,1);


% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
cellArrayOfStructures{3} = s3;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isstruct(stitchedStructure))
assert(isempty(uncommonFields))

% Check their fields
temp = fieldnames(stitchedStructure);
assert(strcmp(temp{1},'a'));
assert(strcmp(temp{2},'b'));
assert(strcmp(temp{3},'c'));
assert(strcmp(temp{4},'d'));

% Check field values
assert(isequal(stitchedStructure.a,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))
assert(isequal(stitchedStructure.b,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))
assert(isequal(stitchedStructure.c,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))
assert(isequal(stitchedStructure.d,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))

%% Test 4: Basic example - merging level 1 fields that have no overlap in vector types
% Structure 1 is scalar, 2 is vector
fig_num = [];

clear s1 s2 s3 cellArrayOfStructures

s1.a = 1;
s1.b = 1;
s1.c = 1;

s2.a = [2; 2];
s2.b = [2; 2];
s2.c = [2; 2];

% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isempty(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
assert(strcmp(uncommonFields{1},'a'));
assert(strcmp(uncommonFields{2},'b'));
assert(strcmp(uncommonFields{3},'c'));

%% Test 5: Basic example - merging level 1 fields that have no overlap in vector types
% Structure 1 is vector, 2 is scalar
fig_num = [];

clear s1 s2 s3 cellArrayOfStructures

s1.a = [1; 1];
s1.b = [1; 1];
s1.c = [1; 1];

s2.a = 2;
s2.b = 2;
s2.c = 2;

% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isempty(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
assert(strcmp(uncommonFields{1},'a'));
assert(strcmp(uncommonFields{2},'b'));
assert(strcmp(uncommonFields{3},'c'));

%% Test 6: Basic example - merging level 1 fields that have no overlap in vector types
% Structure 1 is vector with 1 columns, 2 is vector with 2 columns
fig_num = [];

clear s1 s2 s3 cellArrayOfStructures

s1.a = [1; 1];
s1.b = [1; 1];
s1.c = [1; 1];

s2.a = [2 2; 2 2];
s2.b = [2 2; 2 2];
s2.c = [2 2; 2 2];

% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isempty(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
assert(strcmp(uncommonFields{1},'a'));
assert(strcmp(uncommonFields{2},'b'));
assert(strcmp(uncommonFields{3},'c'));

%% Test 7: Basic example - merging level 1 and 2 fields that partially agree on each level
fig_num = [];

clear s1 s2 s3 cellArrayOfStructures

s1.a = 1*ones(3,1);
s1.b = 1*ones(3,1);
s1.c = 1*ones(3,1);
s1.sub1.a = 1*ones(3,1);

s2.a = 2*ones(3,1);
s2.c = 2*ones(3,1);
s2.d = 2*ones(3,1);
s2.sub1.a = 2*ones(3,1);
s2.sub1.b = 2*ones(3,1);

s3.a = 3*ones(3,1);
s3.c = 3*ones(3,1);
s3.e = 3*ones(3,1);
s3.f = 3*ones(3,1);
s3.sub1.a = 3*ones(3,1);
s3.sub1.c = 3*ones(3,1);
s3.sub2.a = 3*ones(3,1);

% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
cellArrayOfStructures{3} = s3;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isstruct(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
temp = fieldnames(stitchedStructure);
assert(strcmp(temp{1},'a'));
assert(strcmp(temp{2},'c'));
assert(strcmp(temp{3},'sub1'));
temp2 = fieldnames(stitchedStructure.sub1);
assert(strcmp(temp2{1},'a'));

assert(strcmp(uncommonFields{1},'b'));
assert(strcmp(uncommonFields{2},'d'));
assert(strcmp(uncommonFields{3},'e'));
assert(strcmp(uncommonFields{4},'f'));
assert(strcmp(uncommonFields{5},'sub2'));
assert(strcmp(uncommonFields{6},'sub1.b'));
assert(strcmp(uncommonFields{7},'sub1.c'));

% Check field values
assert(isequal(stitchedStructure.a,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))
assert(isequal(stitchedStructure.c,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))
assert(isequal(stitchedStructure.sub1.a,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))

%% Test 7: Basic example - merging level 1 and 2 fields that do not agree
fig_num = [];

clear s1 s2 s3 cellArrayOfStructures

s1.a = 1*ones(3,1);
s1.b = 1*ones(3,1);
s1.c = 1*ones(3,1);
s1.sub1.a = 1*ones(3,1);

s2.a = 2*ones(3,1);
s2.c = 2*ones(3,1);
s2.d = 2*ones(3,1);
s2.sub1.b = 2*ones(3,1);
s2.sub1.c = 2*ones(3,1);

s3.a = 3*ones(3,1);
s3.c = 3*ones(3,1);
s3.e = 3*ones(3,1);
s3.f = 3*ones(3,1);
s3.sub1.b = 3*ones(3,1);
s3.sub1.c = 3*ones(3,1);
s3.sub2.a = 3*ones(3,1);

% Call the function
cellArrayOfStructures{1} = s1;
cellArrayOfStructures{2} = s2;
cellArrayOfStructures{3} = s3;
[stitchedStructure, uncommonFields] = fcn_DataClean_stichStructures(cellArrayOfStructures, (fig_num));

% Check the output types
assert(isstruct(stitchedStructure))
assert(iscell(uncommonFields))

% Check their fields
temp = fieldnames(stitchedStructure);
assert(strcmp(temp{1},'a'));
assert(strcmp(temp{2},'c'));

assert(strcmp(uncommonFields{1},'b'));
assert(strcmp(uncommonFields{2},'d'));
assert(strcmp(uncommonFields{3},'e'));
assert(strcmp(uncommonFields{4},'f'));
assert(strcmp(uncommonFields{5},'sub2'));
assert(strcmp(uncommonFields{6},'sub1.a'));
assert(strcmp(uncommonFields{7},'sub1.b'));
assert(strcmp(uncommonFields{8},'sub1.c'));


% Check field values
assert(isequal(stitchedStructure.a,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))
assert(isequal(stitchedStructure.c,[1*ones(1,3) 2*ones(1,3) 3*ones(1,3)]'))

%% Fail conditions
if 1==0
    %% ERROR for bad data folder
    bagName = "badData";
    rawdata = fcn_DataClean_stichStructures(bagName, bagName);
end
