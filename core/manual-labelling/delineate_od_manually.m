function [ final_od_roi ] = delineate_od_manually( I )
%DELINEATE_OD_MANUALLY Delineate the OD area manually using ellipses

    % first, zoom in the area around the ONH to improve the detection
    source_coordinate = floor(size(I,1) / 3);
    initial_guess = [source_coordinate, source_coordinate, ...
        size(I,1) - 2 * source_coordinate, size(I,1) - 2 * source_coordinate];
    figure, imshow(I);
    title('Select a rectangle close to the OD to zoom in');
    % maximize figure for better visualization
    set(gcf, 'Position', get(0,'Screensize')); 
    h = imrect(gca, initial_guess);
    setFixedAspectRatioMode(h, 1);
    zoom = wait(h);
    
    % crop the rectangle to zoom
    [~, rect] = imcrop(I, zoom);
    rect = round(rect);
    smallSubImage = I(rect(2) : rect(2) + rect(4), ...
        rect(1) : rect(1) + rect(3), :);
    % and show the rectangle
    close
    figure;
    the_fig = imshow(smallSubImage);
    title('Move and resize the elipse to cover the OD area');
    % maximize figure for better visualization
    set(gcf, 'Position', get(0,'Screensize')); 

    % mark the ellipse
    h = imellipse;
    wait(h);
    % generate the binary mask
    od_roi = createMask(h, the_fig);
    % assign the mask to its real position in the image
    final_od_roi = false(size(I,1),size(I,2));
    final_od_roi(rect(2) : rect(2) + rect(4), rect(1) : rect(1) + rect(3), :) = od_roi;
    close all;

end

