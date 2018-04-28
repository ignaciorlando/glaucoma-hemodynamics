           

function intersecting_pts = find_skel_intersection_2(input_skeleton_image,varargin)
    
    option = 'not testing';
    if ~isempty(varargin)
        for n = 1:1:length(varargin)
            if strcmp(varargin{n},'testing') | strcmp(varargin{n},'not testing')
                option = varargin{n};
            else
                error('Error in input option');
            end
        end
    end

    % ---------------------------------------------------------------------------------------------
    input_skeleton_image = double(input_skeleton_image) ./ double(max(input_skeleton_image(:)));
    % ---------------------------------------------------------------------------------------------
    % ---------------------------------------------------------------------------------------------
    if strcmp(option,'testing')
        disp('Process the skeleton to find the intersection of the island');
    end
    kernel = [1 1 1; 1 1 1; 1 1 1];
    conv_img = conv2(input_skeleton_image,kernel,'same');
    conv_img = conv_img .* input_skeleton_image;
    intersecting_pts = find(conv_img > 3);
    [Y,X] = find(conv_img > 3);

    % ---------------------------------------------------------------------------------------------
    % If there are intersecting points, select only 1 pixel from each island of
    % intersection points
    % ---------------------------------------------------------------------------------------------
    intersecting_pts_to_plot = [];
    if ~isempty(X)
        classes = sortclasses([X,Y],1,8);
        for n = 1:1:length(classes)
            X = mean(classes{n}(:,1));
            Y = mean(classes{n}(:,2));
            temp = classes{n};
            temp(:,1) = X;
            temp(:,2) = Y;
            distance = euclidean_distance(temp,classes{n});
            temp = sortrows([distance,classes{n}]);
            intersecting_pts_to_plot = [intersecting_pts_to_plot;temp(1,[2,3])];
        end
    else
    end
    % ---------------------------------------------------------------------------------------------
    % If testing then display the skeleton image with the detected end points
    % ---------------------------------------------------------------------------------------------
    if strcmp(option,'testing')
        disp('Display the intersection ends');
        figure;
        imshow(imcomplement(input_skeleton_image));
        hold on;
        if ~isempty(intersecting_pts_to_plot)
            plot(intersecting_pts_to_plot(:,1),intersecting_pts_to_plot(:,2),'r*');
        end
        title('Red points indicated detected intersection points');
        xlabel('Test mode for "find skel ends.m" function');
    end
end