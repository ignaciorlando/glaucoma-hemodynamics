
function model = train_logistic_regression_classifier(X, training_labels, X_val, validation_labels, validation_metric)

    % add a bias term to the training and validation sets
    X = cat(2, ones(size(X,1), 1), X);
    
    % initialize lambda values to analyze
    lambda_values = 10.^(-3:5);

    % initialize a matrix of qualities over validation
    qualities_on_validation = zeros(length(lambda_values), 1);
    % do the same for the models
    ws = cell(length(lambda_values), 1);

    % % set up the logistic loss
    funObj = @(w)LogisticLoss(w, X, 2*training_labels-1);
    new_options.Display = 0;
    new_options.useMex = 0; 
    new_options.verbose = 0;
    
    % run for each lambda value
    for lambda_idx = 1 : length(lambda_values)
        
        lambda = lambda_values(lambda_idx) * ones(size(X,2),1);
        lambda(1) = 0; % don't penalize the bias
        w = minFunc(@penalizedL2, zeros(size(X,2),1), new_options, funObj, lambda); 
        
        % save current weights
        ws{lambda_idx} = w;
        model.w = w;

        % classify the validation set
        [validation_scores, val_yhat] = predict_with_logistic_regression(X_val, model);
        % evaluate
        switch validation_metric
            case 'auc'
                % evaluate on the validation set and save current performance
                [~,~,info] = vl_roc( 2*validation_labels-1, validation_scores);
                current_performance = info.auc;
            case 'acc'
                current_performance = sum(val_yhat==validation_labels) / length(val_yhat);
        end
        % save current performance
        qualities_on_validation(lambda_idx) = current_performance;
        fprintf('    lambda=%d   %s=%d\n', lambda_values(lambda_idx), upper(validation_metric), qualities_on_validation(lambda_idx));
        
    end
    
    % retrieve the higher quality value on the validation set
    [highest_performance, ~] = max(qualities_on_validation(:));
    % get the indices of the highest performance
    idx = find(qualities_on_validation(:) == highest_performance);
    % use the last one so that we ensure the maximum regularization
    % parameter possible
    lambda_ind = idx(end);
    
    %fprintf('    HIGHEST PERFORMANCE:\n    lambda=%d   AUC=%d\n', lambda_values(lambda_ind), highest_performance);
    
    % assign to model the best that we found
    model.classifier = strcat('logistic-regression');
    model.w = ws{lambda_ind};
    model.lambda = lambda_values(lambda_ind);
    model.validation_quality = highest_performance;

end