function features = extract_bag_of_hemodynamic_features( root_folder, feature_maps_filenames, centroids, output_path, pois, verbosity, use_only_radius )
%EXTRACT_BAG_OF_HEMODYNAMIC_FEATURES Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 6
        use_only_radius = false;
    end

    % call to config_hemo_var_idx to get the ids of the masks
    config_hemo_var_idx;

    if exist('verbosity', 'var') == 0
        verbosity = false;
    end

    % identify the number of hemodynamic features
    size_centroids = size(centroids);
    k = size_centroids(1);
    n_features = size_centroids(2);
    
    % initialize the cell array of features
    features = cell(size(feature_maps_filenames));
    
    % extract features for each of the feature maps
    for j = 1 : length(feature_maps_filenames)
        
        % load the feature map
        current_feature_map = load(fullfile(root_folder, feature_maps_filenames{j}), 'sol_condense', 'HDidx');
        % prepare an array of the useful features
        if use_only_radius
            to_preserve = zeros(size(current_feature_map.sol_condense, 2), 1);
            to_preserve(HDidx.r) = 1;
        else
            to_preserve = ones(size(current_feature_map.sol_condense, 2), 1);
            to_preserve(HDidx.mask) = 0;
            to_preserve(HDidx.r) = 0;
        end
        to_preserve = logical(to_preserve);
        
        % get the parameters in the pois
        sol_c_mean = extract_statistic_from_sol_condense(current_feature_map.sol_condense, current_feature_map.HDidx, 'mean');
        X = [];
        for p = 1 : length(pois)
            if pois(p)==-1
                current_sol = sol_c_mean(sol_c_mean(:,8)<0,:);
            else
                current_sol = sol_c_mean(sol_c_mean(:,8) == pois(p),:);
            end
            current_sol = current_sol(:,to_preserve);
            X = cat(1, X, current_sol);
        end
        % normalize by mean and standard deviation
        current_mean = mean(X);
        current_std = std(X);
        X = bsxfun(@rdivide, bsxfun(@minus, X, current_mean), current_std  + eps);
        
        % compute the distances between each feature and the centroid
        distances = zeros(size(X,1), k);
        for kk = 1 : k
            % compute the euclidean distance
            distances(:,kk) = sqrt(sum((X - repmat(centroids(kk,:), size(X,1), 1)).^2, 2));
        end
        % identify the activated word
        [~, activated_word] = min(distances,[],2);
        % count the number of repetitions
        X = histc(activated_word,1:k);
        % assign to the array of features
        features{j} = X;
        
        if ~strcmp(output_path, '')
            % output filename
            output_filename = feature_maps_filenames{j};
            output_filename = strcat(output_filename(1:end-8), '.mat');
            % save it
            save(fullfile(output_path, output_filename), 'X');
        end
        
    end

end

