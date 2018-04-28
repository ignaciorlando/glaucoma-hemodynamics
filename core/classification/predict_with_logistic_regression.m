
function [scores, y_hat] = predict_with_logistic_regression(X, model)

    % add a bias term
    X = cat(2, ones(size(X,1), 1), X);
    % classify given data set
    scores = (model.w' * X')';
    % threshold it
    y_hat = scores > 0;

end