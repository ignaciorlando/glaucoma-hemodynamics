
% SCRIPT_GENERATE_INPUT_DATA_VTK
% -------------------------------------------------------------------------
% This script generates the vtkPolyData representation for each input data 
% .mat file.
% -------------------------------------------------------------------------

% Configurate the script
config_generate_input_data_vtk;

%% set up variables

% input folder
input_folder = fullfile(input_folder, database);
% output folder
output_folder = fullfile(output_folder, database);

if exist('pixelSpacing', 'var') == 0
    pixelSpacing = [ones(40,1)*0.0025, ones(40,1)*0.0025];;
    warning(strcat('Pixel spacing undefined. Using default values:',num2str(pixelSpacing)))    
end

% prepare output data folder
output_data_folder = fullfile(output_folder, '/input_data/vtk');
if exist(output_data_folder, 'dir') == 0
    mkdir(output_data_folder);
end

% retrieve arteries filenames
filenames = dir(fullfile(output_folder, '/input_data/*.mat'));
filenames = {filenames.name};

%% process data

% for each .mat file
for i = 1 : length(filenames)

    current_filename = filenames{i};
    fprintf('Processing %s\n', current_filename);
    load( fullfile(output_folder, strcat('/input_data/',current_filename)));
    % Generates the vtkPolyData from the graph and radius information
    % stored in the .mat file.
    %display_graph(graph)
    [polydata, roots] = vtkPolyData( trees_radius, graph, pixelSpacing(i,:) );
    roots = polydata.Points(roots,:); 
    save(fullfile(output_data_folder, strcat(current_filename(1:end-4), '_roots.mat')), 'roots');
    % Saves the vtkPolyData to ascii file
    vtkPolyDataWriter(polydata, fullfile(output_data_folder, strcat(current_filename(1:end-3), 'vtk')));    
    
end