
% CONFIG_GENERATE_INPUT_DATA_VTK
% -------------------------------------------------------------------------
% This script is called by script_generate_input_data for setting up the
% generation of the data needed for the simulations.
% -------------------------------------------------------------------------

% input folder
input_folder = fullfile(pwd, 'data');

% output folder
output_folder = fullfile(pwd, 'data');

% database
% database = 'RITE-test';
% database = 'RITE-training';
database = 'LES-AV';
% pixel spacing, in [cm]
% pixelSpacing = [ones(40,1)*0.0025, ones(40,1)*0.0025]; % RITE database
pixelSpacing = [ones(22,1)*0.0006, ones(22,1)*0.0006];   % LES-AV
% The image size
% imgSize      = [ones(40,1)*565, ones(40,1)*584];  % RITE database
imgSize       = [ones(22,1)*1444, ones(22,1)*1620]; % LES-AV
imgSize(12,:) = [1958, 2196];