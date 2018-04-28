
% SCRIPT_EXPORT_VTKSIMSOL_MATLAB
% -------------------------------------------------------------------------
% This script export vtk files with simulation solution to matlab files.
% -------------------------------------------------------------------------

clc
clear
close all

% Configurate the script, the script should contain the pixel spacing and image size
config_generate_input_data_vtk;
% input folder
input_folder = fullfile(input_folder, database);
% output folder
output_folder = fullfile(output_folder, database);
% Crates HDidx, the struct containing the hemodynamic indexes in the 
% solution array.
config_hemo_var_idx

%% set up variables

% The number of central retinal artery pressures for the scenario id computation.
% nP_in = 3; 
nP_in = 1;
% The number of central retinal artery flow for the scenario id computation.
% nQ_in = 5;
nQ_in = 3;

% prepare output data folder
output_data_folder = fullfile(output_folder, '/hemodynamic-simulation');
% retrieve arteries filenames
filenames = dir(fullfile(input_folder, '/input_data/vtk/*.vtk'));
filenames = {filenames.name};

%% process data

% for each .vtk file
for i = 1 : length(filenames)
    current_filename       = fullfile(input_folder, 'input_data','vtk', filenames{i});
    current_filename_roots = strcat(current_filename(1:end-4),'_roots.mat');
    fprintf('Processing %s\n', current_filename);
    load(current_filename_roots);

    countSim = 1;
    % Loop over all inlet flows
    for j = 1 : nQ_in;
        % Loop over all inlet pressures
        for k = 1 : nP_in;
            input_filename = fullfile(output_data_folder, strcat(filenames{i}(1:end-4),'_SC',num2str(countSim),'_sol.vtk'));
            output_filename = fullfile(output_data_folder, strcat(filenames{i}(1:end-4),'_SC',num2str(countSim),'_sol.mat'));
            countSim = countSim + 1;
            
            [ sol, sol_condense ] = vtkSimulationResultImporter( input_filename, imgSize(i,:), pixelSpacing(i,:), roots, HDidx );
            
            save(output_filename,'sol','sol_condense','HDidx');
            
        end;
    end;
end;
