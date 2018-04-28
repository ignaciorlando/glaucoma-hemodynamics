
function X = compact_features(features)

    % initialize the matrix
    X = zeros(length(features), size(features{1}, 1));
    % compat the features inside it
    for i = 1 : length(features)
        X(i,:) = features{i};
    end

end