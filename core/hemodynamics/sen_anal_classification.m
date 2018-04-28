function [ statsFP, statsFQ ] = sen_anal_classification( Sols, Q_in, P_in, idxVar, flagSubP )
%SEN_ANAL_CLASSIFICATION Perform classification of ficticius classes using global averages.
% Performs classification of the patients according to the mean value of
% the variable (idxVar). Then computes how many consecutive changes of
% classes accour for the scenarios with the same inlet pressure and for
% those with the same total blood flow.
% Return statistics conserning the changes of classes of the patients.
%
% Parameters:
% Sols: 
% Q_in:     The different values of the total blood flow used in the 
%           simulation scenarios.
% P_in:     The different values of the inlet blood pressure used in the 
%           simulation scenarios.
% idxVar:   The index of the variable (column) of the solutions at each
%           scenario that will be used. In the default implementation 1 is 
%           radius, 2 is flow, 3 is Pressure, 4 is velocity and 5 is mask. 
% flagSubP: If true, the pressure drop (relative to inlet) is computed
%           instead of pressure statistics. The flag true should be used 
%           with pressure (idxVar=4) only.
%
% Return:
% statsFP: Statistics for fixed pressure scenarios.
% statsFQ: Statistics for fixed flow scenarios.
%

% Computes the mean of the variable over all the scenarios
stats_outlets_allSC = compute_stats( Sols, [0,0], idxVar, [1.,0.] );
if (flagSubP);
    PDrops=[];
    for scj = 1 : numel(P_in);
        aux = compute_stats( Sols, [0,scj], idxVar, [-1., P_in(scj)] );
        PDrops = [PDrops; aux.Data];
    end;
    stats_outlets_allSC = statistics(PDrops);
end;

changesForFixedQ = cell(numel(Sols),1);
changesForFixedP = cell(numel(Sols),1);
% For each patient
for p = 1 : numel(Sols);
    class = false(numel(Q_in), numel(P_in), size(Sols{p}{1,1},1));
    % For each scenario
    for sci = 1 : numel(Q_in);
        for scj = 1 : numel(P_in);
            outlets = Sols{p}{sci,scj};
            if (flagSubP);
                class(sci,scj,:) = (P_in(scj)-outlets(:,idxVar)) < stats_outlets_allSC.mean;
            else
                class(sci,scj,:) = outlets(:,idxVar) < stats_outlets_allSC.mean;    
            end;            
        end;
    end;
    
    % Changes in outlets when the scenarios represent fixed total flow
    sumXor = zeros(numel(Q_in), size(Sols{p}{1,1},1));
    for scj = 1 : numel(P_in)-1;
        sumXor = sumXor + reshape(xor(class(:,scj,:), class(:,scj+1,:)), size(sumXor));        
    end;
    changesForFixedQ(p) = {sumXor};        

    % Changes in outlets when the scenarios represent fixed inlet pressure
    sumXor = zeros(numel(P_in), size(Sols{p}{1,1},1));
    for sci = 1 : numel(Q_in)-1;
        sumXor = sumXor + reshape(xor(class(sci,:,:), class(sci+1,:,:)), size(sumXor));
    end;
    changesForFixedP(p) = {sumXor};
end;

% Now that the count of changes for fixed pressure or flow scenarios is
% ready for each outlet of each patient, the average and std deviation
% of that count over all outlets is computed.
ChangesForFixedP = [];
ChangesForFixedQ = [];
for p = 1 : numel(Sols);
    ChangesForFixedP = [ChangesForFixedP; sum(changesForFixedP{p}',2)];
    ChangesForFixedQ = [ChangesForFixedQ; sum(changesForFixedQ{p}',2)];    
end;
statsFP = statistics(ChangesForFixedP);
statsFQ = statistics(ChangesForFixedQ);

end

