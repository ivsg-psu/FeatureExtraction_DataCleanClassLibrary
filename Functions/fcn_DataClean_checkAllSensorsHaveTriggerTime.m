function [checked_flags,sensors_without_Trigger_Time] = fcn_DataClean_checkAllSensorsHaveTriggerTime(dataStructure,flags,varargin)

% fcn_DataClean_checkAllSensorsHaveTriggerTime
% Check whether all sensors have Trigger Time
%
% FORMAT:
%
%      [checked_flags,sensors_without_Trigger_Time] = fcn_DataClean_checkAllSensorsHaveTriggerTime(dataStructure,fid,flags)
%
% INPUTS:
%
%      dataStructure: a data structure to be analyzed that includes the following
%      fields:
%
%      flags: A structure 'flags' with subfield flags which are set so
%      that the flag = 1 condition represents data that passes that particular
%      consistency test.
%
%      (OPTIONAL INPUTS)
%
%      fid: a file ID to print results of analysis. If not entered, the
%      console (FID = 1) is used.
%
% OUTPUTS:
%
%      checked_flags: A structure 'flags' with field
%      all_sensors_have_trigger_time added
%
%      sensors_without_Trigger_Time: A string array containing sensor neams
%      without Trigger_Time
%
% DEPENDENCIES:
%
%
% EXAMPLES:
%
%     See the script: script_test_fcn_DataClean_checkAllSensorsHaveTriggerTime
%     for a full test suite.
%
% This function was written on 2024_09_03 by X.Cao
% Questions or comments? xfc5113@psu.edu

% Revision history:
%     
% 2024_09_03: xfc5113@psu.edu
% -- wrote the code originally 
% 2024_09_27: xfc5113@psu.edu
% -- add comments for the function

% TO DO:
%


% Set default fid (file ID) first:
flag_do_debug = 1;  %#ok<NASGU> % Flag to show the results for debugging
flag_do_plots = 0;  % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking


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
    if nargin < 2 || nargin > 3
        error('Incorrect number of input arguments')
    end
        
end

        

% Does the user want to specify the fid?
% Check for user input
fid = 0; % Default case is to NOT print to the console
if 3 == nargin
    temp = varargin{1};
    if ~isempty(temp)
        % Check that the FID works
        try
            temp_msg = ferror(temp); %#ok<NASGU>
            % Set the fid value, if the above ferror didn't fail
            fid = temp;
        catch ME
            warning('on','backtrace');
            warning('User-specified FID does not correspond to a file. Unable to continue.');
            throwAsCaller(ME);
        end
    end
end

if fid == 1
    st = dbstack; %#ok<*UNRCH>
    fprintf(fid,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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

checked_flags = flags;
all_sensors_have_trigger_time = 1;
checked_flags.all_sensors_have_trigger_time = all_sensors_have_trigger_time;
fields = fieldnames(dataStructure);
sensors_without_Trigger_Time = [];
for idx_field = 1:length(fields)
    current_field_struct = dataStructure.(fields{idx_field});
    if ~isempty(current_field_struct)
        try
            Trigger_Time = current_field_struct.Trigger_Time;
    
        catch
            warning_mesg = sprintf("%s does not have Trigger_Time field", fields{idx_field});
            warning(warning_mesg)
            all_sensors_have_trigger_time = 0;
        end
  
      
    end
    if all(isnan(Trigger_Time))
        all_sensors_have_trigger_time = 0;
        checked_flags.all_sensors_have_trigger_time = all_sensors_have_trigger_time;
        sensors_without_Trigger_Time = [sensors_without_Trigger_Time; string(fields{idx_field})];
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
if flag_do_plots
    
    % Nothing to plot        
    
end

if flag_do_debug
   
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function

