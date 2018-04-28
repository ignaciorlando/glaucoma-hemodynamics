function [ vFAIs, Q_1_vFAI, Q_2_vFAI ] = compute_vFAI_forall( Sols, Q_in, P_in )
%COMPUTE_VFAI_FORALL Calculates the vFAI for all simulations.
% Generates a cell array with the vFAI for each simulation in the Sols
% array.
%
% Parameters:
% Sols: The results of the simulations for each patient.
% Q_in:     The different values of the total blood flow used in the 
%           simulation scenarios.
% P_in:     The different values of the inlet blood pressure used in the 
%           simulation scenarios.
%
% Return:
% vFAIs:    The vFAI value for each outlet of each simulation in Sols.
% Q_1_vFAI: The list of totla flow for the Step 1 of the vFAI index.
% Q_2_vFAI: The list of totla flow for the Step 2 of the vFAI index.
%

K=0;
KK=0;
Q_1_vFAI = [];
Q_2_vFAI = [];
for scqi = 1 : 1;
%for scqi = 1 : numel(Q_in)-1;
    %for scqj = scqi+1 : numel(Q_in);
    for scqj = numel(Q_in)-KK : numel(Q_in);
        K=K+1;
        Q_1_vFAI(end+1) = Q_in(scqi);
        Q_2_vFAI(end+1) = Q_in(scqj);
    end;
end;

vFAIs = cell(size(Sols));
for p = 1 : numel(Sols);
    vfais = cell(1, numel(P_in));
    for scp = 1 : numel(P_in);
        k=0;
        for scqi = 1 : 1;
        %for scqi = 1 : numel(Q_in)-1;
            %for scqj = scqi+1 : numel(Q_in);
            for scqj = numel(Q_in)-KK : numel(Q_in);
                k    = k + 1;
                % Computes the vFAI value for the current simulation
                n    = size(Sols{p}{1,1},1);
                vfai = vFAI( P_in(scp)*ones(n,1), Sols{p}{scqi,scp}(:,3),...
                             Sols{p}{scqj,scp}(:,3), Sols{p}{scqi,scp}(:,2),...
                             Sols{p}{scqj,scp}(:,2), [] );
                vfais(k,scp) = {vfai};
            end;
        end;
    end;
    vFAIs(p) = {vfais};
end;

end
