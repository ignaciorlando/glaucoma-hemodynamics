
% SCRIPT_DELINEATE_OD
% -------------------------------------------------------------------------
% This script allows to manually delineate the optic disc.
% -------------------------------------------------------------------------

% Configurate the script
config_delineate_od;

%% prepare variables

% prepare the input folder for the images
images_path = fullfile(input_folder, 'images');
% prepare the output folder for the optic disc masks
od_masks_path = fullfile(output_folder, 'od-masks');
if exist(od_masks_path, 'dir') == 0
    mkdir(od_masks_path);
end

% retrieve image filenames
image_filenames = dir(fullfile(images_path, '*.png'));
image_filenames = {image_filenames.name};

% count the number of images in the output folder
od_masks_filenames = dir(fullfile(od_masks_path, '*.png'));
od_masks_filenames = {od_masks_filenames.name};

% the starting image will be the one after the last image that was
% previously processed
starting_image = length(od_masks_filenames) + 1;

%% delineate the od

% for each image
for i = starting_image : length(image_filenames)
    
    % open the image
    I = imread(fullfile(images_path, image_filenames{i}));
    fprintf('Processing image %s\n', image_filenames{i});
    
    % manually delineate the OD roi
    od_roi = delineate_od_manually(I);

    % save the final_od_roi
    imwrite(od_roi, fullfile(od_masks_path, image_filenames{i}));
    
end
