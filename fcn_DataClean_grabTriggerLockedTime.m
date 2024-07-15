function locked_ROS_Time = fcn_DataClean_grabTriggerLockedTime(rawDataStructure)



rawTriggerMode = rawDataStructure.Trigger_Raw.mode;
ROSTime_TriggerBox = rawDataStructure.Trigger_Raw.ROS_Time;
rawTriggerModeCount = rawDataStructure.Trigger_Raw.modeCount;
tf_lock_mode =  strcmp(rawTriggerMode,"L");
locked_ROS_Time = ROSTime_TriggerBox(tf_lock_mode);
% rawTriggerTime = trimedDataStructure.Trigger_Raw.Trigger_Time;
% N_time_to_be_filled = size(rawTriggerTime,1);
% for idx_row = 1:N_time_to_be_filled
%     currentTriggerMode = rawTriggerMode(idx_row);
%     currentTriggerModeCount = rawTriggerModeCount(idx_row);
%     if strcmp(currentTriggerMode,"L")
%         rawTriggerTime(idx_row,:) = currentTriggerModeCount;
%     end
% end
% rawTriggerTimeNonNan = rawTriggerTime(~isnan(rawTriggerTime));
% ROSTime_TriggerBox_NonNan = ROSTime_TriggerBox(~isnan(rawTriggerTime));