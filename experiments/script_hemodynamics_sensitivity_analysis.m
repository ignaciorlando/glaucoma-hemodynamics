
% SCRIPT_HEMODYNAMICS_SENSITIVITY_ANALYSIS
% -------------------------------------------------------------------------
% This script performs a sensitivity analysis of the simulations ran and
% stored in the data/RITE-*/hemodynamic-simulation/ folders and in the 
% data/RITE-*/hemodynamic-simulationSolutionsAtOutlets file.
% -------------------------------------------------------------------------

clc
clear

output_data_folder = 'data-analysis';
if (exist(output_data_folder, 'dir') == 0)
    mkdir(output_data_folder)
end;

statSig = 0.05;

%% Loads the result at the outlets
load('data/RITE-training/hemodynamic-simulation/SolutionsAtOutlets')
Sols_training  = Sols;
Times_training = Times;
load('data/RITE-test/hemodynamic-simulation/SolutionsAtOutlets')
Sols_test      = Sols;
Times_test     = Times;

Sols           = [Sols_training; Sols_test];
Times          = [Times_training; Times_test];

%% Computes the vFAI values for all the patients
[vFAIs,Q_1_vFAI] = compute_vFAI_forall( Sols, Q_in, P_in );

%% Time statistics
% Simulation pre-processing time statistics
stats_time_prep = compute_stats( Times, [0,0], 1, [1,0] );
% Simulation time statistics
stats_time_simu = compute_stats( Times, [0,0], 1, [1,0] );
% Simulation post-processing time statistics
stats_time_post = compute_stats( Times, [0,0], 1, [1,0] );

%% Statistics at the outlets for all patients, at each scenario
stats_outlets_r = {};
stats_outlets_Q = {};
stats_outlets_P = {};
for sci = 1 : numel(Q_in);
    string = '';
    for scj = 1 : numel(P_in);
        % Radius statistics
        stats_outlets_r(sci,scj)    = {compute_stats( Sols, [sci,scj], 1, [1.,           0.] )};
        % Flow percentage statistics
        stats_outlets_Q(sci,scj)    = {compute_stats( Sols, [sci,scj], 2, [1./Q_in(sci), 0.] )};
        % Pressure drop from inlet statistics
        stats_outlets_P(sci,scj)    = {compute_stats( Sols, [sci,scj], 3, [-1.,   P_in(scj)] )};
        % Blood velocity statistics
        stats_outlets_V(sci,scj)    = {compute_stats( Sols, [sci,scj], 4, [1.,           0.] )};
        % vFAI statistics
        stats_outlets_vFAI(sci,scj) = {compute_stats( vFAIs, [1,scj],1, [1.,           0.] )};      
        
        %string = strcat(string, sprintf('%1.2f$\\pm$%1.2f',stats_outlets_V{sci,scj}.mean,stats_outlets_V{sci,scj}.std),{' & '});
        string = strcat(string, sprintf('%1.2E$\\pm$%1.2E',stats_outlets_vFAI{1,scj}.mean,stats_outlets_vFAI{1,scj}.std),{' & '});
    end;
    strcat(string,'\\')
end;

%% Perform statistical analysis of difference among scenarios.
UTestsP    = sen_anal_statdiff( Sols, Q_in, P_in, 3, 1 );
UTestsV    = sen_anal_statdiff( Sols, Q_in, P_in, 4, 0 );
UTestsvFAI = sen_anal_statdiff( vFAIs, Q_1_vFAI, P_in, 1, 0 );

%% Perform classification and sensitivity analysis of ficticius classes.
[statsFPP, statsFQP]       = sen_anal_classification( Sols, Q_in, P_in, 3, 1);
[statsFPV, statsFQV]       = sen_anal_classification( Sols, Q_in, P_in, 4, 0);
[statsFPvFAI, statsFQvFAI] = sen_anal_classification( vFAIs, Q_1_vFAI, P_in, 1, 0);

%% Performs the same analysis for each patient, and see if there is some patients with "zero sensitivity"
countZSUT_P = 0;
countZSUT_Q = 0;
countZSUT_vFAI = 0;
for p = 1 : numel(Sols);
    if (isempty(find(sen_anal_statdiff( Sols(p), Q_in, P_in, 3, 1 ) <= statSig)));
        countZSUT_P   = countZSUT_P + 1;
    end;
    if (isempty(find(sen_anal_statdiff( Sols(p), Q_in, P_in, 4, 0 ) <= statSig)));
        countZSUT_Q   = countZSUT_Q + 1;
    end;
    if (isempty(find(sen_anal_statdiff( vFAIs(p), Q_1_vFAI, P_in, 1, 0 ) <= statSig)));
        countZUT_vFAI = countZSUT_vFAI + 1;
    end;    
end;


%%
%save(strcat(output_data_folder,'/stats.mat'),'stats_time_prep','stats_time_simu','stats_time_post',...
%                                             'stats_outlets_r','stats_outlets_Q','stats_outlets_P','stats_outlets_V');

