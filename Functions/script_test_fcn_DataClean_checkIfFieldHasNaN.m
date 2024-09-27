% script_test_fcn_DataClean_checkIfFieldHasNaN.m
% tests fcn_DataClean_checkIfFieldHasNaN.m

% Revision history
% 2023_07_02 - sbrennan@psu.edu
% -- wrote the code originally using INTERNAL function from
% checkTimeConsistency

%      [flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(...
%          dataStructure,field_name,...
%          (flags),(string_any_or_all),(sensors_to_check),(fid))

%% Prep the workspace
close all;

%% CASE 1: basic example - no inputs, not verbose
% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.sound  = nan;

flags = []; 
string_any_or_all = '';
sensors_to_check = '';
fid = 0;

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_sensors,0));
assert(strcmp(offending_sensor,'quiet_pig'));

modified_test_structure = initial_test_structure;
modified_test_structure.quiet_pig.sound  = 'whisper';

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(modified_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_sensors,1));
assert(isequal(offending_sensor,''));

%% CASE 2: basic example - no inputs, verbose
% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.sound  = nan;

flags = []; 
string_any_or_all = '';
sensors_to_check = '';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_sensors,0));
assert(strcmp(offending_sensor,'quiet_pig'));

modified_test_structure = initial_test_structure;
modified_test_structure.quiet_pig.sound  = 'oink oink';

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(modified_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_sensors,1));
assert(isequal(offending_sensor,''));

%% CASE 3: show that empty matricies, empty strings, and nan do not work
% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.sound  = nan;

flags = []; 
string_any_or_all = '';
sensors_to_check = '';
fid = 1;

% empty matrix field
modified_test_structure = initial_test_structure;
modified_test_structure.quiet_pig.sound  = [];

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(modified_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_sensors,1));
assert(strcmp(offending_sensor,''));

% empty string field
modified_test_structure = initial_test_structure;
modified_test_structure.quiet_pig.sound  = '';

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(modified_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_sensors,1));
assert(strcmp(offending_sensor,''));

% nan field
modified_test_structure = initial_test_structure;
modified_test_structure.quiet_pig.sound  = nan;

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(modified_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_sensors,0));
assert(strcmp(offending_sensor,'quiet_pig'));

%% CASE 4: basic example - string_any_or_all changed, verbose
% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.sound  = nan;

flags = []; 
string_any_or_all = 'any';
sensors_to_check = '';
fid = 1;

% Run with 'any' option - it changes the flag name, and shows at least one
% sensor passes
[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);
assert(isequal(flags.sound_has_no_nan_in_any_sensors,0));
assert(strcmp(offending_sensor,'quiet_pig'));

modified_test_structure = initial_test_structure;
modified_test_structure.quiet_pig.sound  = 'oink oink';
[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(modified_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);
assert(isequal(flags.sound_has_no_nan_in_any_sensors,1));
assert(isequal(offending_sensor,''));

% Run same thing with 'all' option - it changes the flag name, and does not
% pass the first case
string_any_or_all = 'all';
sensors_to_check = '';
fid = 1;

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);
assert(isequal(flags.sound_is_not_filled_with_nan_in_every_sensor,1));
assert(strcmp(offending_sensor,''));


%% CASE 5: basic example - sensors_to_check changed, verbose
% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.sound  = nan;

flags = []; 
fid = 1;
sensors_to_check = 'cow';
string_any_or_all = 'any';

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_cow_sensors,1));
assert(strcmp(offending_sensor,''));

sensors_to_check = 'cow';
string_any_or_all = 'all';

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_is_not_filled_with_nan_in_every_cow_sensor,1));
assert(strcmp(offending_sensor,''));


sensors_to_check = 'pig';
string_any_or_all = 'any';

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_has_no_nan_in_any_pig_sensors,0));
assert(isequal(offending_sensor,'quiet_pig'));

sensors_to_check = 'pig';
string_any_or_all = 'all';

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_is_not_filled_with_nan_in_every_pig_sensor,1));
assert(isequal(offending_sensor,''));

sensors_to_check = 'quiet';
string_any_or_all = 'all';

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'sound',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.sound_is_not_filled_with_nan_in_every_quiet_sensor,0));
assert(isequal(offending_sensor,'quiet_pig'));



%% CASE 1: basic example - bad input. 
% Note that it throws an output of offending sensor for the first sensor it
% encounters, because the sensor does not have that field

% Fill in some silly test data
initial_test_structure = struct;
initial_test_structure.cow1.sound = 'moo';
initial_test_structure.cow2.sound = 'moo moo';
initial_test_structure.cow3.sound = 'moo moo moo';
initial_test_structure.pig1.sound  = 'oink';
initial_test_structure.quiet_pig.sound  = nan;

flags = []; 
string_any_or_all = '';
sensors_to_check = '';
fid = 0;

[flags,offending_sensor] = fcn_DataClean_checkIfFieldHasNaN(initial_test_structure,'garbage',flags, string_any_or_all, sensors_to_check,fid);

assert(isequal(flags.garbage_has_no_nan_in_any_sensors,0));
assert(strcmp(offending_sensor,'cow1'));

