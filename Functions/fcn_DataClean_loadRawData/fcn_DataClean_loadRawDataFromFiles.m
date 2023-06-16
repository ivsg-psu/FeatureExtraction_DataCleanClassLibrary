function rawdata = fcn_DataClean_loadRawDataFromFiles(bagname, basestation)


folder_path = bagname + "/"
addpath(folder_path)
file_list = dir(folder_path);
num_files = length(file_list);

for file_idx = 3:num_files
    file_name = file_list(file_idx).name;
    file_name_noext = extractBefore(file_name,'.'); 
    file_name_noslash = extractAfter(file_name_noext,'_slash_');
    topic_name = strrep(file_name_noext,'_slash_','/');
    datatype = fcn_DataClean_determineDataType(topic_name);
    topic_name_noslash = extractAfter(topic_name,'/');
    file_path = folder_path + file_name;
    opts = detectImportOptions(file_path);
    if contains(topic_name,'sick_lms500/scan')
        table = readmatrix(file_path, opts)
    else
        opts = detectImportOptions(file_path);
        opts.PreserveVariableNames = true;
        table = readtable(file_path,opts);
    end
end