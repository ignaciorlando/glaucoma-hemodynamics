
% SCRIPT_TRAIN_HEMODYNAMIC_FEATURE_EXTRACTION
% -------------------------------------------------------------------------
% Use this script to train the hemodynamic feature extraction.
% -------------------------------------------------------------------------

clc
config_train_hemodynamic_feature_extraction

%% prepare input variables

% retrieve labels
load(fullfile(root_folder, 'labels.mat'));

% update root_folder to include hemodynamic-simulation
root_folder = fullfile(root_folder, 'hemodynamic-simulation');

% retrieve the image names
feature_map_filenames = dir(fullfile(root_folder, strcat('*_', scenario, '_sol.mat')));
feature_map_filenames = {feature_map_filenames.name};

%% get the centroids

% get the centroids
centroids = get_hemodynamic_centroids( root_folder, feature_map_filenames, labels, k );

%% save the output

% prepare filename
output_filename = strcat('centroids_k=', num2str(k), '_trained-on-', database, '_', scenario, '.mat');

% save the file
if exist(output_folder, 'dir')==0
    mkdir(output_folder);
end
save(fullfile(output_folder, output_filename), 'centroids');