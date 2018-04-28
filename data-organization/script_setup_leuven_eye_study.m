
% SCRIPT_SETUP_LEUVEN_EYE_STUDY
% -------------------------------------------------------------------------
% This script organizes the Leuven Eye Study
% -------------------------------------------------------------------------

%% set up variables

% set up main variables
config_setup_leuven_eye_study;

%% unzip the file

zip_filename = fullfile(input_folder, 'LeuvenEyeStudy.zip');

if exist(zip_filename, 'file') == 0
    error('Couldnt find the file LeuvenEyeStudy.zip. Please, download it and put it in input_folder.');
else
    % unzip the file
    fprintf('Unzipping LeuvenEyeStudy file...\n');
    % unzip on output_folder/tmp
    unzip(zip_filename, fullfile(output_folder));
end

%% prepare the input data set and the output folders

% prepare input folder
leuven_eye_study_folder = fullfile(output_folder, 'LeuvenEyeStudy');

% check if the file exists
if exist(leuven_eye_study_folder, 'file') == 0
    error('Houston, we have a problem!');
end

% prepare images and masks folders
leuven_eye_study_input_image_folder = fullfile(leuven_eye_study_folder, 'images');
leuven_eye_study_input_optic_disc_folder = fullfile(leuven_eye_study_folder, 'od-masks');
leuven_eye_study_output_image_folder = fullfile(leuven_eye_study_folder, 'images');
leuven_eye_study_output_image_onh_folder = fullfile(leuven_eye_study_folder, 'images-onh');
leuven_eye_study_output_image_fov_folder = fullfile(leuven_eye_study_folder, 'images-fov');
leuven_eye_study_output_image_fov_wo_onh_folder = fullfile(leuven_eye_study_folder, 'images-fov-wo-onh');

% copy the od-masks from the precomputed data
copyfile(fullfile('precomputed-data', 'LeuvenEyeStudy'), fullfile(leuven_eye_study_folder));

%% crop the images around the FOV and resize

% get image filenames
image_filenames = dir(fullfile(leuven_eye_study_input_image_folder, '*.png'));
image_filenames = { image_filenames.name };

% get manual markings of the optic disc
manual_markings_filenames = dir(fullfile(leuven_eye_study_input_optic_disc_folder, '*.png'));
manual_markings_filenames = { manual_markings_filenames.name };

% create the output folder
mkdir(leuven_eye_study_output_image_folder);
mkdir(leuven_eye_study_output_image_onh_folder);
mkdir(leuven_eye_study_output_image_fov_folder);
mkdir(leuven_eye_study_output_image_fov_wo_onh_folder);

% iterate for each image
fprintf('Cropping and resizing images...\n');
for i = 1 : length(image_filenames)
    
    fprintf(['Processing image ', image_filenames{i}, ' (', num2str(i), '/', num2str(length(image_filenames)), ')\n']);
    
    % prepare input/output image filenames
    current_input_image_name = image_filenames{i};
    current_output_image_name = strcat(current_input_image_name(1:end-3), 'png');
    
    % prepare the image as it is
    
    % open the image
    image = imread(fullfile(leuven_eye_study_input_image_folder, current_input_image_name));    
    % save the image
    imwrite(image, fullfile(leuven_eye_study_output_image_folder, current_input_image_name));
    
    % prepare the image cropped around the FOV
    fov_mask = get_fov_mask(image, 0.001);
    % crop the image
    cropped_image_fov = crop_fov(image, fov_mask); 
    % resize the image
    resized_image = imresize(cropped_image_fov, [224, NaN]);
    % save 
    imwrite(resized_image, fullfile(leuven_eye_study_output_image_fov_folder, current_input_image_name));
    
    % prepare the image cropped around the OD
    
    % load the OD mask
    od_mask = imread(fullfile(leuven_eye_study_input_optic_disc_folder, manual_markings_filenames{i}));    
    % dilate the mask to capture part of the tissue around the optic disc
    dilated_mask = imdilate(od_mask > 0, strel('disk', round(size(image, 1) * 0.05), 8));
    % crop the image
    [ cropped_image, cropped_dilated_mask ] = crop_fov(image, dilated_mask);    
    % resize the image
    resized_image = imresize(cropped_image, [224, NaN]);
    % save 
    imwrite(resized_image, fullfile(leuven_eye_study_output_image_onh_folder, current_input_image_name));
    
    % prepare the image cropped around the FOV and without the OD
    
    % crop the od mask around the fov mask
    mask = crop_fov(od_mask, fov_mask);
    % remove the optic disc
    image_without_onh = cropped_image_fov;
    for j = 1 : size(cropped_image_fov, 3)
        image_without_onh(:,:,j) = uint8(double(cropped_image_fov(:,:,j)) .* double(imcomplement(mask > 0)));
    end
    % resize the image
    resized_image = imresize(image_without_onh, [224, NaN]);
    % save 
    imwrite(resized_image, fullfile(leuven_eye_study_output_image_fov_wo_onh_folder, current_input_image_name));
    
end

%% read the labels file

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
