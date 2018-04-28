
root_folder = '/home/ignaciorlando/Documents/LeuvenEyeStudy';

% input folders
images_folder = fullfile(root_folder, 'images');
fov_masks_folder = fullfile(root_folder, 'masks');
artery_veins_folder = fullfile(root_folder, 'arteries-and-veins');

% output folders
segmentations_folder = fullfile(root_folder, 'vessel-segmentations');
mkdir(segmentations_folder);
arteries_folder = fullfile(root_folder, 'arteries');
mkdir(arteries_folder);
veins_folder = fullfile(root_folder, 'veins');
mkdir(veins_folder);

% image filenames
image_filenames = dir(fullfile(images_folder, '*.png'));
image_filenames = { image_filenames.name };
% fov masks filenames
mask_filenames = dir(fullfile(fov_masks_folder, '*.gif'));
mask_filenames = { mask_filenames.name };

for i = 1 : length(image_filenames)
    
    img = imread(fullfile(images_folder, image_filenames{i}));
    fov_mask = imread(fullfile(fov_masks_folder, mask_filenames{i})) > 0;
    arteries_and_veins = imread(fullfile(artery_veins_folder, image_filenames{i}));
    
    % prepare the segmentation
    segmentation = (sum(arteries_and_veins, 3) > 0) .* fov_mask;
    imwrite(segmentation, fullfile(segmentations_folder, image_filenames{i}));
    
    % update the arteries and veins
    for j = 1 : size(arteries_and_veins, 3)
        arteries_and_veins(:,:,j) = double((arteries_and_veins(:,:,j) > 150) * 255) .* double(fov_mask);
    end
    arteries_and_veins = uint8(arteries_and_veins);
    imwrite(arteries_and_veins, fullfile(artery_veins_folder, image_filenames{i}));
    
    % now get only arteries
    arteries = (arteries_and_veins(:,:,1) + arteries_and_veins(:,:,2)) > 0;
    arteries(arteries_and_veins(:,:,3) > 0) = false;
    arteries = bwareaopen(arteries, 20);
    imwrite(arteries, fullfile(arteries_folder, image_filenames{i}));
    
    % and only veins
    veins = (arteries_and_veins(:,:,2) + arteries_and_veins(:,:,3)) > 0;
    veins(arteries_and_veins(:,:,1) > 0) = false;
    veins = bwareaopen(veins, 20);
    imwrite(veins, fullfile(veins_folder, image_filenames{i}));
    
end