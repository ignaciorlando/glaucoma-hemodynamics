
% SCRIPT_MICCAII_STATISTICS
% -------------------------------------------------------------------------
% This script perform basic statistics and exploratory data analysis on the
% data sample for the MICCAI-2018 study.
% -------------------------------------------------------------------------

clc
clear
close all

% Configurate the script, the script should contain the pixel spacing and image size
config_generate_input_data_vtk;
% input folder
input_folder  = fullfile(input_folder, database);
% output folder
output_folder = fullfile(output_folder, database);
% Crates HDidx, the struct containing the hemodynamic indexes in the 
% solution array.
config_hemo_var_idx

%% Retrieves the patient data
load(strcat(input_folder,'/labels'));
load(strcat(input_folder,'/PatientData'));

%% Basic statistics on the patient data
statisticalSignificance = 0.05;

stat_age_pat_a = statistics(Age);
stat_age_pat_h = statistics(Age(labels==0));
stat_age_pat_g = statistics(Age(labels==1));
stat_dbp_pat_a = statistics(DBP);
stat_dbp_pat_h = statistics(DBP(labels==0));
stat_dbp_pat_g = statistics(DBP(labels==1));
stat_sbp_pat_a = statistics(SBP);
stat_sbp_pat_h = statistics(SBP(labels==0));
stat_sbp_pat_g = statistics(SBP(labels==1));
stat_iop_pat_a = statistics(IOP);
stat_iop_pat_h = statistics(IOP(labels==0));
stat_iop_pat_g = statistics(IOP(labels==1));

[h_sw_age_pat_all, p_sw_age_pat_all, sw_stat_age_pat_all] = swtest(Age, statisticalSignificance);
[h_sw_age_pat_h, p_sw_age_pat_h, sw_stat_age_pat_h] = swtest(Age(labels==0), statisticalSignificance);
[h_sw_age_pat_g, p_sw_age_pat_g, sw_stat_age_pat_g] = swtest(Age(labels==1), statisticalSignificance);
p_vart_pat_age         = vartestn(Age, labels,'TestType','LeveneQuadratic','Display','on');
p_chi2test_pat_lab_sex = chi2TestForIndependance([labels,SEX_0F_1M]);
% If both swtest were positive, then perform t-Test, if not, use a U-test.
if (~h_sw_age_pat_h && ~h_sw_age_pat_g);
    p_mdt_age_pat = ttest(Age(labels==0), Age(labels==1), 'tail','both', 'alpha',statisticalSignificance);
    p_mdt_age_pat_test = 0;
else
    p_mdt_age_pat = ranksum(Age(labels==0), Age(labels==1),'tail','both', 'alpha',statisticalSignificance);
    p_mdt_age_pat_test = 1;
end;

%% retrieve arteries filenames
scidx     = 3; % Scenario index
filenamesSCH = dir(fullfile(input_folder, strcat('/hemodynamic-simulation/*SC',num2str(scidx),'*.mat')));
filenamesSCH = {filenamesSCH.name};
scidx     = 1; % Scenario index
filenamesSCG = dir(fullfile(input_folder, strcat('/hemodynamic-simulation/*SC',num2str(scidx),'*.mat')));
filenamesSCG = {filenamesSCG.name};

%% Reads all condense simulation outputs
Labels = nan(0,1);
NSegs   = nan(0,1);
Ages   = nan(0,1);
Sexes  = nan(0,1);
Sol_c  = nan(0,HDidx.mask);
for i = 1 : length(filenames)
    if (labels(i)==0);
        current_filename       = fullfile(input_folder, '/hemodynamic-simulation/', filenamesSCH{i});    
        load(current_filename,'sol_condense');
    else
        current_filename       = fullfile(input_folder, '/hemodynamic-simulation/', filenamesSCG{i});    
        load(current_filename,'sol_condense');
    end;
    
    sol_c  = extract_statistic_from_sol_condense( sol_condense, HDidx, 'mean' );
    
    Labels = [Labels; ones(size(sol_c,1),1)*labels(i)];
    Sexes  = [Sexes; ones(size(sol_c,1),1)*SEX_0F_1M(i)];
    Ages   = [Ages; ones(size(sol_c,1),1)*Age(i)];
    Sol_c  = [Sol_c; sol_c];
    
    NSegs  = [NSegs; numel(unique( sol_c(sol_c(:, HDidx.mask) < 0 ,HDidx.mask)))];
    
end;

% stats for number of segments---------------------------------------------
stat_nseg_pat_a = statistics(NSegs);
stat_nseg_pat_h = statistics(NSegs(labels==0));
stat_nseg_pat_g = statistics(NSegs(labels==1));
p_vart_pat_nseg = vartestn(NSegs, labels,'TestType','LeveneQuadratic','Display','on');
[h_sw_nseg_pat_all, p_sw_nseg_pat_all, sw_stat_nseg_pat_all] = swtest(NSegs, statisticalSignificance);
[h_sw_nseg_pat_h, p_sw_nseg_pat_h, sw_stat_nseg_pat_h] = swtest(NSegs(labels==0), statisticalSignificance);
[h_sw_nseg_pat_g, p_sw_nseg_pat_g, sw_stat_nseg_pat_g] = swtest(NSegs(labels==1), statisticalSignificance);
% If both swtest were positive, then perform t-Test, if not, use a U-test.
if (~h_sw_nseg_pat_h && ~h_sw_nseg_pat_g);
    p_mdt_nseg_pat = ttest(NSegs(labels==0), NSegs(labels==1), 'tail','both', 'alpha',statisticalSignificance);
    p_mdt_nseg_pat_test = 0;
else
    p_mdt_nseg_pat = ranksum(NSegs(labels==0), NSegs(labels==1),'tail','both', 'alpha',statisticalSignificance);
    p_mdt_nseg_pat_test = 1;
end;
%--------------------------------------------------------------------------


% selected_samples = (Sol_c(:, HDidx.mask) == 2) & (Sol_c(:, HDidx.r) <= 40*1e-4)& (Sol_c(:, HDidx.r) >= 30*1e-4);     % Only Terminals
% selected_samples = Sol_c(:, HDidx.mask) == 2;    % Only Terminals
% selected_samples = Sol_c(:, HDidx.mask) == 3;    % Only Bifurcations
% selected_samples = Sol_c(:, HDidx.mask) < 0;     % Only Segments
% selected_samples = Sol_c(:,  HDidx.mask) > 0;    % Only Terminals And bifurcations
 selected_samples = ~isnan(Sol_c(:, HDidx.mask));  % All: terminals, bifurcations and segments
Sol_c_BT         = Sol_c(selected_samples, :);
Labels_BT        = Labels(selected_samples);
Sexes_BT         = Sexes(selected_samples);
Ages_BT          = Ages(selected_samples);

%% Basic statistics
InletP = 62.22;
stat_dp_a  = statistics(InletP - Sol_c_BT(:,HDidx.p));
stat_dp_h  = statistics(InletP - Sol_c_BT(Labels_BT==0,HDidx.p));
stat_dp_g  = statistics(InletP - Sol_c_BT(Labels_BT==1,HDidx.p));
stat_v_a   = statistics(Sol_c_BT(:,HDidx.v));
stat_v_h   = statistics(Sol_c_BT(Labels_BT==0,HDidx.v));
stat_v_g   = statistics(Sol_c_BT(Labels_BT==1,HDidx.v));
stat_age_a  = statistics(Ages_BT);
stat_age_h  = statistics(Ages_BT(Labels_BT==0));
stat_age_g  = statistics(Ages_BT(Labels_BT==1));
stat_rad_a  = statistics(Sol_c_BT(:,HDidx.r));
stat_rad_h  = statistics(Sol_c_BT(Labels_BT==0,HDidx.r));
stat_rad_g  = statistics(Sol_c_BT(Labels_BT==1,HDidx.r));

%% Now, check there are some kind
% Status, Age, Sex(0F,1M), PressureDrop, Velocitiy
data = [ Labels_BT, Ages_BT, Sexes_BT, InletP - Sol_c_BT(:,HDidx.p), Sol_c_BT(:,HDidx.v), Sol_c_BT(:,HDidx.r), Sol_c_BT(:,HDidx.q) ];
idxLab = 1;
idxAge = 2;
idxSex = 3;
idxDpr = 4;
idxVel = 5;
idxRad = 6;
idxFRQ = 7;
% Check correlation between the age and the hemodynamic variables
[r_age_dpr, p_age_dpr] = corrplot(data(:,[idxAge,idxDpr]), 'type', 'Pearson', 'tail','both', 'testR', 'on' );
[r_age_vel, p_age_vel] = corrplot(data(:,[idxAge,idxVel]), 'type', 'Pearson', 'tail','both', 'testR', 'on' );
[r_rad_frq, p_rad_frq] = corrplot(data(:,[idxRad,idxFRQ]), 'type', 'Spearman', 'tail','both', 'testR', 'on' );
[r_age_rad, p_age_rad] = corrplot(data(:,[idxAge,idxRad]), 'type', 'Pearson', 'tail','both', 'testR', 'on' );

% Check the association among Label_BT and each variable
[h_sw_age_all, p_sw_age_all, sw_stat_age_all] = swtest(data(:,idxAge), statisticalSignificance);
[h_sw_age_h, p_sw_age_h, sw_stat_age_h] = swtest(data(Labels_BT==0,idxAge), statisticalSignificance);
[h_sw_age_g, p_sw_age_g, sw_stat_age_g] = swtest(data(Labels_BT==1,idxAge), statisticalSignificance);
[h_sw_dpr_all, p_sw_dpr_all, sw_stat_dpr_all] = swtest(data(:,idxDpr), statisticalSignificance);
[h_sw_dpr_h, p_sw_dpr_h, sw_stat_dpr_h] = swtest(data(Labels_BT==0,idxDpr), statisticalSignificance);
[h_sw_dpr_g, p_sw_dpr_g, sw_stat_dpr_g] = swtest(data(Labels_BT==1,idxDpr), statisticalSignificance);
[h_sw_vel_all, p_sw_vel_all, sw_stat_vel_all] = swtest(data(:,idxVel), statisticalSignificance);
[h_sw_vel_h, p_sw_vel_h, sw_stat_vel_h] = swtest(data(Labels_BT==0,idxVel), statisticalSignificance);
[h_sw_vel_g, p_sw_vel_g, sw_stat_vel_g] = swtest(data(Labels_BT==1,idxVel), statisticalSignificance);
[h_sw_rad_all, p_sw_rad_all, sw_stat_rad_all] = swtest(data(:,idxRad), statisticalSignificance);
[h_sw_rad_h, p_sw_rad_h, sw_stat_rad_h] = swtest(data(Labels_BT==0,idxRad), statisticalSignificance);
[h_sw_rad_g, p_sw_rad_g, sw_stat_rad_g] = swtest(data(Labels_BT==1,idxRad), statisticalSignificance);

p_vart_age = vartestn(data(:,idxAge), Labels_BT,'TestType','LeveneQuadratic','Display','on');
p_vart_dpr = vartestn(data(:,idxDpr), Labels_BT,'TestType','LeveneQuadratic','Display','on');
p_vart_vel = vartestn(data(:,idxVel), Labels_BT,'TestType','LeveneQuadratic','Display','on');
p_vart_rad = vartestn(data(:,idxRad), Labels_BT,'TestType','LeveneQuadratic','Display','on');

% If both swtest were positive, then perform t-Test, if not, use a U-test.
if (~h_sw_age_h && ~h_sw_age_g);
    p_mdt_age = ttest(data(Labels_BT==0,idxAge), data(Labels_BT==1,idxAge), 'tail','both', 'alpha',statisticalSignificance);
    p_mdt_age_test = 0;
else
    p_mdt_age = ranksum(data(Labels_BT==0,idxAge), data(Labels_BT==1,idxAge),'tail','both', 'alpha',statisticalSignificance);
    p_mdt_age_test = 1;
end;
if (~h_sw_dpr_h && ~h_sw_dpr_g);
    p_mdt_dpr = ttest(data(Labels_BT==0,idxDpr), data(Labels_BT==1,idxDpr), 'tail','both', 'alpha',statisticalSignificance);
    p_mdt_dpr_test = 0;
else
    p_mdt_dpr = ranksum(data(Labels_BT==0,idxDpr), data(Labels_BT==1,idxDpr),'tail','both', 'alpha',statisticalSignificance);
    p_mdt_dpr_test = 1;
end;
if (~h_sw_vel_h && ~h_sw_vel_g);
    p_mdt_vel = ttest(data(Labels_BT==0,idxVel), data(Labels_BT==1,idxVel), 'tail','both', 'alpha',statisticalSignificance);
    p_mdt_vel_test = 0;
else
    p_mdt_vel = ranksum(data(Labels_BT==0,idxVel), data(Labels_BT==1,idxVel),'tail','both', 'alpha',statisticalSignificance);
    p_mdt_vel_test = 1;
end;
if (~h_sw_rad_h && ~h_sw_rad_g);
    p_mdt_rad = ttest(data(Labels_BT==0,idxRad), data(Labels_BT==1,idxRad), 'tail','both', 'alpha',statisticalSignificance);
    p_mdt_rad_test = 0;
else
    p_mdt_rad = ranksum(data(Labels_BT==0,idxRad), data(Labels_BT==1,idxRad),'tail','both', 'alpha',statisticalSignificance);
    p_mdt_rad_test = 1;
end;

% Perform a chi-square test of independence
p_chi2test_lab_sex                = chi2TestForIndependance(data(:,[idxLab,idxSex]));


%% Construct the matrix used in the paper:
mat = [[stat_dp_a.mean, stat_dp_a.std, stat_dp_h.mean, stat_dp_h.std, stat_dp_g.mean, stat_dp_g.std ];...
       [stat_v_a.mean, stat_v_a.std, stat_v_h.mean, stat_v_h.std, stat_v_g.mean, stat_v_g.std ];...
       [stat_age_a.mean, stat_age_a.std, stat_age_h.mean, stat_age_h.std, stat_age_g.mean, stat_age_g.std ];...
       [sum(Sexes_BT), nan, sum(Sexes_BT(Labels_BT==0)), nan, sum(Sexes_BT(Labels_BT==1)), nan];...
       [p_sw_dpr_all, nan, p_sw_dpr_h, nan, p_sw_dpr_g, nan];...
       [p_sw_vel_all, nan, p_sw_vel_h, nan, p_sw_vel_g, nan];...
       [p_sw_age_all, nan, p_sw_age_h, nan, p_sw_age_g, nan];...
       [nan, nan, p_vart_dpr, nan, nan, nan];...
       [nan, nan, p_vart_vel, nan, nan, nan];...
       [nan, nan, p_vart_age, nan, nan, nan];...
       [nan, nan, p_mdt_dpr, nan, nan, nan];...
       [nan, nan, p_mdt_vel, nan, nan, nan];...
       [nan, nan, p_mdt_age, nan, nan, nan];...       
       [nan, nan, p_chi2test_lab_sex, nan, nan, nan];...
       [r_age_dpr(1,2), p_age_dpr(1,2), nan, nan, nan, nan];...
       [r_age_vel(1,2), p_age_vel(1,2), nan, nan, nan, nan];...
       [stat_rad_a.mean, stat_rad_a.std, stat_rad_h.mean, stat_rad_h.std, stat_rad_g.mean, stat_rad_g.std ];...
       [p_sw_rad_all, nan, p_sw_rad_h, nan, p_sw_rad_g, nan];...
       [nan, nan, p_vart_rad, nan, nan, nan];...
       [nan, nan, p_mdt_rad, nan, nan, nan];...       
       [r_rad_frq(1,2), p_rad_frq(1,2), nan, nan, nan, nan];...
       ];
   
mat_pat = [[stat_nseg_pat_a.mean, stat_nseg_pat_a.std, stat_nseg_pat_h.mean, stat_nseg_pat_h.std, stat_nseg_pat_g.mean, stat_nseg_pat_g.std ];...
       [stat_age_pat_a.mean, stat_age_pat_a.std, stat_age_pat_h.mean, stat_age_pat_h.std, stat_age_pat_g.mean, stat_age_pat_g.std ];...
       [sum(SEX_0F_1M), nan, sum(SEX_0F_1M(labels==0)), nan, sum(SEX_0F_1M(labels==1)), nan];...
       [p_sw_nseg_pat_all, nan, p_sw_nseg_pat_h, nan, p_sw_nseg_pat_g, nan];...
       [p_sw_age_pat_all, nan, p_sw_age_pat_h, nan, p_sw_age_pat_g, nan];...
       [nan, nan, p_vart_pat_nseg, nan, nan, nan];...
       [nan, nan, p_vart_pat_age, nan, nan, nan];...
       [nan, nan, p_mdt_nseg_pat, nan, nan, nan];...       
       [nan, nan, p_mdt_age_pat, nan, nan, nan];...       
       [nan, nan, p_chi2test_pat_lab_sex, nan, nan, nan];...
       ];

%% Computes statistics on the radius
stat_r_a  = statistics(Sol_c_BT(:,HDidx.r));
stat_r_h  = statistics(Sol_c_BT(Labels_BT==0,HDidx.r));
stat_r_g  = statistics(Sol_c_BT(Labels_BT==1,HDidx.r));

close all