
% SCRIPT_SETUP_LES_AV
% -------------------------------------------------------------------------
% This script organizes the Leuven Eye Study
% -------------------------------------------------------------------------

%% set up variables

% set up main variables
config_setup_les_av;

%% unzip the file

zip_filename = fullfile(input_folder, 'LES-AV.zip');

if exist(zip_filename, 'file') == 0
    error('Couldnt find the file LES-AV.zip. Please, download it and put it in input_folder.');
else
    % unzip the file
    fprintf('Unzipping LES-AV file...\n');
    % unzip on output_folder/tmp
    unzip(zip_filename, fullfile(output_folder));
end

%% prepare the input data set and the output folders

% prepare input folder
leuven_eye_study_folder = fullfile(output_folder, 'LES-AV');

% check if the file exists
if exist(leuven_eye_study_folder, 'file') == 0
    error('Houston, we have a problem!');
end

% copy the od-masks from the precomputed data
copyfile(fullfile('precomputed-data', 'LES-AV'), fullfile(leuven_eye_study_folder));

%% read the labels file

% get image filenames
image_filenames = dir(fullfile(leuven_eye_study_input_image_folder, '*.png'));
image_filenames = { image_filenames.name };

% read the xlsx file
[num,txt,~] = xlsread(fullfile(leuven_eye_study_folder, 'Data.xlsx'));
% remove the headers
image_num = num(:,1);
diagnosis = txt(2:end, 1);

% encode the labels
binary_labels = ~strcmp(diagnosis, 'normal');
labels = zeros(size(binary_labels));
for i = 1 : length(image_filenames)
    current_image_filename = image_filenames{i};
    labels(i) = binary_labels(str2double(current_image_filename(1:end-4)) == image_num);
end

% save the labels file
filenames = image_filenames;
save(fullfile(leuven_eye_study_folder, 'labels.mat'), 'labels', 'filenames');
