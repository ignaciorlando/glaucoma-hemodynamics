
% SCRIPT_RUN_SIMULATION
% -------------------------------------------------------------------------
% This script run simulations for a series of .vtk files.
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

% Parameters for the hemodynamic simulations. -----------------------------
% The blood viscocity, in [dyn s /cm^2].
% Since the radius of the arteries are <150 µm, a variable
% viscosity depending on the segment radius will be used in the
% simulaction.
mu   = 0.04; 
% The blood density, in [g / cm^3]. Only used if the stenosis model is employed.
rho  = 1.05;
% The central retinal artery pressure at the inlet, in [mmHg].
% P_in = [57.22, 62.22, 65.22]; 
P_in = [62.22]; 
% The reference pressure at the outlet, the venous pressure, in [mmHg].
% This value is not used in the current set-up of boundary conditions,
% since the flow is strongly imposed in the terminals.
P_ref = 30.0;
% List of total inflows to be used, in [cm^3 / s]
% The values in the paper and the literature are reported in [µl/min], then
% we converted to [cm^3 / s]
% Q_in = [30.0, 40.8, 45.6, 52.9, 80.0] * (1./60.) * 0.001;
Q_in = [30.0, 45.6, 80.0] * (1./60.) * 0.001;
% Murray exponent
mExp = 2.66;
%The resistance model to be used, can be Poiseuille or PoiseuilleTapering
rModel = 'Poiseuille';

% prepare output data folder
output_data_folder = fullfile(output_folder, '/hemodynamic-simulation');
if exist(output_data_folder, 'dir') == 0
    mkdir(output_data_folder);
end

% retrieve arteries filenames
filenames = dir(fullfile(input_folder, '/input_data/vtk/*.vtk'));
filenames = {filenames.name};

%% process data

% for each .vtk file
Sols  = cell(length(filenames),1);
Times = cell(length(filenames),1);
for i = 1 : length(filenames)
    current_filename       = fullfile(input_folder, 'input_data','vtk', filenames{i});
    current_filename_roots = strcat(current_filename(1:end-4),'_roots.mat');
    fprintf('Processing %s\n', current_filename);
    load(current_filename_roots);
    countSim = 1;
    sols     = cell(numel(Q_in),numel(P_in));
    times    = cell(numel(Q_in),numel(P_in));
    % Loop over all inlet flows
    for j = 1 : numel(Q_in);
        % Loop over all inlet pressures
        for k = 1 : numel(P_in);
            output_filename = fullfile(output_data_folder, strcat(filenames{i}(1:end-4),'_SC',num2str(countSim)));
            [sol, time] = run_simulation( current_filename, roots, mu, rho, P_in(k), P_ref, Q_in(j), mExp, rModel, output_filename, imgSize(i,:), pixelSpacing(i,:), HDidx );
            countSim = countSim + 1;
            
            % Store the solution of the outlets of the patient in an array
            mask                 = sol(:,:,end);
            [iOutlets, jOutlets] = find(mask==2);
            solOutlets           = nan(numel(iOutlets),size(sol,3));
            for h = 1 : numel(iOutlets);
                solOutlets(h,:) = sol(iOutlets(h), jOutlets(h),:);
            end;
            sols(j,k)            = {solOutlets};
            times(j,k)           = {time};
        end;
    end;
    Sols(i)  = {sols};
    Times(i) = {times}; 
end
save(strcat(output_data_folder,'/SolutionsAtOutlets.mat'),'Sols','Times','P_in','Q_in');

