
% SCRIPT_GENERATE_INPUT_DATA
% -------------------------------------------------------------------------
% This script generates the input data for the simulation process.
% -------------------------------------------------------------------------

% Configurate the script
config_generate_input_data;

%% set up variables

% prepare arteries folder
arteries_folder = fullfile(input_folder, 'arteries');
% prepare od folder
od_folder = fullfile(input_folder, 'od-masks');


% prepare output data folder
output_data_folder = fullfile(output_folder, 'input_data');
if exist(output_data_folder, 'dir') == 0
    mkdir(output_data_folder);
end

% retrieve arteries filenames
filenames = dir(fullfile(arteries_folder, '*.png'));
filenames = {filenames.name};

%% process data

% for each arteries file
for i = 1 : length(filenames)

    % get current filename
    current_filename = filenames{i};
    
    % open the segmentation of the arteries
    arteries_segm = imread(fullfile(arteries_folder, current_filename));
    % open the segmentation of the od
    od_segm = imread(fullfile(od_folder, current_filename));
    
    fprintf('Processing %s\n', current_filename);
    
    % process the segmentation to recover the skeleton with trees ids 
    [trees_ids, root_pixels] = skeletonize_vascular_tree(arteries_segm, od_segm);
    % and process the skeletonization to recover the vessel radius
    trees_radius = estimate_vessel_radius(arteries_segm, trees_ids > 0);
    % generate graph
    graph = initialize_graph_from_skeleton(trees_ids, root_pixels);
    
    % save the mat file in the output folder
    save(fullfile(output_data_folder, strcat(current_filename(1:end-3), 'mat')), ...
        'trees_ids', 'trees_radius', 'graph');
    
end