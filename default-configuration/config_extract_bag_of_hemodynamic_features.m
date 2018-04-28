
% CONFIG_EXTRACT_BAG_OF_HEMODYNAMIC_FEATURES
% -------------------------------------------------------------------------
% This script is called by script_extract_bag_of_hemodynamic_features
% to setup parameters for extracting the BoHF vector.
% -------------------------------------------------------------------------

% database
database = 'LeuvenEyeStudy';

% folder where the data is stored
root_folder = fullfile(pwd, 'data', database);

% pre-trained centroids filename (including path)
centroid_filename = fullfile(pwd, 'feature-extraction-models', ...
    'centroids_k=10_trained-on-LeuvenEyeStudy_SC2.mat');

% output feature path
output_path = fullfile(root_folder, 'bag-of-hemodynamic-features');