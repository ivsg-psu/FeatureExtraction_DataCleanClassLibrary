function [checked_flags,sensors_without_Trigger_Time] = fcn_DataClean_checkAllSensorsHaveTriggerTime(dataStructure,fid,flags)


checked_flags = flags;
all_sensors_have_trigger_time = 1;
checked_flags.all_sensors_have_trigger_time = all_sensors_have_trigger_time;
fields = fieldnames(dataStructure);
sensors_without_Trigger_Time = [];
for idx_field = 1:length(fields)
    current_field_struct = dataStructure.(fields{idx_field});
    if ~isempty(current_field_struct)
        
       Trigger_Time = current_field_struct.Trigger_Time;
        
    end
    if all(isnan(Trigger_Time))
        all_sensors_have_trigger_time = 0;
        checked_flags.all_sensors_have_trigger_time = all_sensors_have_trigger_time;
        sensors_without_Trigger_Time = [sensors_without_Trigger_Time; string(fields{idx_field})];
    end

end






end