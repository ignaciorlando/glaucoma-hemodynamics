% SCRIPT_EVALUATE_CLASSIFICATION
% -------------------------------------------------------------------------
% Use this script to evaluate the performance of different classifiers
% -------------------------------------------------------------------------

config_evaluate_classification;

%% setup the environment

% set the classifier
classifier = 'logistic-regression';

% load the labels
load(fullfile(root_path, 'labels.mat'));

% first tag is the features used
input_folder_name = 'bohf';
features_tag = 'BOHF ';

% construct the input folder
switch classifier
    case 'logistic-regression'
        input_folder_name = strcat(input_folder_name, '-logistic-regression');
        classifier_tag = [features_tag];
end

% initialize the input score path
input_scores_path = fullfile(results_path, input_folder_name);

% get filenames of the scores
scores_filenames = dir(fullfile(input_scores_path, '*.mat'));
scores_filenames = { scores_filenames.name };

%% plot ROC curve

% get all the scores
all_scores = zeros(length(scores_filenames), 1);
y_hat = zeros(length(scores_filenames), 1);
for i = 1 : length(scores_filenames)
    % load this scores
    load(fullfile(input_scores_path, scores_filenames{i}));
    % attach them to all_scores
    all_scores(i) = scores;
    % assign the class
    y_hat(i) = scores > 0.5;
end

% get the ROC curve
[TPR,TNR,info] = vl_roc( 2*labels-1, all_scores);

% plot it
if ~exist('h', 'var')
    h = figure;
    my_legends = { [classifier_tag, ' - AUC=', num2str(info.auc)] };
else
    hold on;
    my_legends = cat(1, my_legends, { [classifier_tag, ' - AUC=', num2str(info.auc)] });
end
plot(1-TNR, TPR, 'LineWidth', 2)
legend(my_legends, 'Location', 'southeast');
xlabel('FPR (1 - Specificity)')
ylabel('TPR (Sensitivity)')
xticks(0:0.1:1);
grid on
box on

accuracy = sum(labels==y_hat) / length(labels);

% print accuracy and auc
disp(['AUC = ', num2str(info.auc)]);
disp(['Acc = ', num2str(accuracy)]);