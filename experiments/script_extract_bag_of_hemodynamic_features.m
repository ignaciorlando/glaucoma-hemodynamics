
% SCRIPT_EXTRACT_BAG_OF_HEMODYNAMIC_FEATURES
% -------------------------------------------------------------------------
% Use this script to extract hemodynamic features (it assumes that you have
% already trained the centroids).
% -------------------------------------------------------------------------

clc
config_extract_bag_of_hemodynamic_features

%% prepare input variables

% load the centroids
load(centroid_filename);

% update root_folder to include hemodynamic-simulation
root_folder = fullfile(root_folder, 'hemodynamic-simulation');

% retrieve the image names
feature_map_filenames = dir(fullfile(root_folder, strcat('*_', scenario, '_sol.mat')));
feature_map_filenames = {feature_map_filenames.name};

%% extract features

% check if the folder doesnt exist
if exist(output_path, 'dir')==0
    mkdir(output_path);
end

% extract the hemodynamic features and save them
features = extract_bag_of_hemodynamic_features( root_folder, feature_map_filenames, centroids, output_path, true );