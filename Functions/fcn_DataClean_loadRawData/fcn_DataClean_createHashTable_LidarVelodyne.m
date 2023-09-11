function fcn_DataClean_createHashTable_LidarVelodyne(velodyne_struct, target_folder)

if ~isstring(target_folder)
    target_folder = string(target_folder);

end

if ~exist(target_folder,'dir')
    mkdir(target_folder)
else
    fprintf("Folder: " + target_folder + " is already exist")
end

hashtags = velodyne_struct.MD5Hash;
N_scans = length(hashtags);
for idx_scan = 1:N_scans
    hashtag = hashtags{idx_scan};
    sub_folder = string(hashtag(1:2)) + "/" + string(hashtag(3:4));
    file_folder = target_folder + "/" + sub_folder;
    if ~exist(file_folder,'dir')
        mkdir file_folder
    else
        fprintf("Folder: " + file_folder + " is already exist")
    end
end
