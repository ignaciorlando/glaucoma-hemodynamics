
% CONFIG_BOHF_CROSS_VALIDATION
% -------------------------------------------------------------------------
% This script is called by script_bohf_cross_validation to setup the 
% variables required for running a full evaluation of the BOHF model on a 
% given set.
% -------------------------------------------------------------------------

% database used for the experiments
database = 'LeuvenEyeStudy';

% input folder
input_data_path = fullfile(pwd, 'data');

% output folder
output_data_path = fullfile(pwd, 'results');

% validation metric
%validation_metric = 'auc';
validation_metric = 'acc';

% points of interest (pois)
%pois = [-1]; % only segments
%pois = [2]; % only terminals
%pois = [3]; % only bifurcations
%pois = [-1, 2, 3]; % segments, terminals and bifurcations
pois = [2, 3]; % terminals and bifurcations

% indicate whether you want to only use the radius or not
%use_only_radius = false;
use_only_radius = true;

% feature extraction -----------

% number of centroids to learn for each of the classes
ks = 2:15;
% simulation scenario
simulation_scenario = 'SC2';