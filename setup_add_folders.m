
% SETUP_FOLDERS
% -------------------------------------------------------------------------
% This code add folders to Matlab environment
% -------------------------------------------------------------------------

% get current root position
my_root_position = pwd;

% An ignored folder, namely configuration, will be created for you so you
% just have to edit configuration scripts there without having to commit
% every single change you made
if exist('configuration', 'file')==0
    % Create folder
    mkdir('configuration');
end
config_filenames = dir(fullfile('default-configuration', '*.m'));
config_filenames = { config_filenames.name };
for i = 1 : length(config_filenames)
    if exist(fullfile('configuration', config_filenames{i}), 'file')==0
        % Copy the default configuration file
        copyfile(fullfile('default-configuration', config_filenames{i}), fullfile('configuration', config_filenames{i}));
    end
end
    

% Install external libraries
if exist('external', 'file')==0
    mkdir('external');
end

% Skeletonization library
skeletonization_library = fullfile('external', 'skeletonization');
if exist(skeletonization_library, 'file') == 0
    % Download the library
    websave('Skeleton.zip', 'http://www.cs.smith.edu/~nhowe/research/code/Skeleton.zip');
    % unzip the code
    mkdir(skeletonization_library);
    unzip('Skeleton.zip', fullfile('external', 'skeletonization'));
    delete('Skeleton.zip')
end

% add main folders to path
addpath(genpath(fullfile(my_root_position, 'data-organization'))) ;
addpath(genpath(fullfile(my_root_position, 'fundus-util'))) ;
addpath(genpath(fullfile(my_root_position, 'configuration'))) ;
addpath(genpath(fullfile(my_root_position, 'core'))) ;
addpath(genpath(fullfile(my_root_position, 'experiments'))) ;
% add each external folder carefully
addpath(genpath(fullfile(my_root_position, 'external', 'hemodynamics-solver'))) ;
addpath(genpath(fullfile(my_root_position, 'external', 'skeletonization'))) ;
addpath('external')
run external/cnn-finetune/dependencies/vlfeat/toolbox/vl_setup.m

% compile the markSchmidt code
markSchmidt_code_path = fullfile('external', 'markSchmidt');
addpath(markSchmidt_code_path);
addpath(genpath(markSchmidt_code_path));
