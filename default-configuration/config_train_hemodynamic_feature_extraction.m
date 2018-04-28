
% CONFIG_TRAIN_HEMODYNAMIC_FEATURE_EXTRACTION
% -------------------------------------------------------------------------
% This script is called by script_train_hemodynamic_feature_extraction
% to setup the parameters to train the hemodynamic feature extraction.
% -------------------------------------------------------------------------

% number of centroids to learn for each of the classes
k = 10;

% training database
database = 'RITE-training';

% folder where the training data is stored
root_folder = fullfile(pwd, 'data', database);

% output folder
output_folder = fullfile(pwd, 'feature-extraction-models');

% scenario to test (use the exact ID)
scenario = 'SC1';