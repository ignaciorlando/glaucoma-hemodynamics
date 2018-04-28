function [ UTests ] = sen_anal_statdiff( Sols, Q_in, P_in, idxVar, flagSubP )
%SEN_ANAL_STATDIFF Perform U-Test to detect statistical difference in mean values among the scenarios.
% 
%
% Parameters:
% Sols:     The simulation results for each paient.
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
% UTests: The p-value of the U-Tests among all patients. Testing Each
%         scenario to all scenarios.
%

outlets = cell(numel(Q_in),numel(P_in),numel(Q_in),numel(P_in));
% For each patient
for p = 1 : numel(Sols);
    % For each scenario
    for scqi = 1 : numel(Q_in);
        for scpi = 1 : numel(P_in);
            outletsI = Sols{p}{scqi,scpi}(:,idxVar);
            if (flagSubP); outletsI = P_in(scpi)-outletsI; end;
            for scqj = 1 : numel(Q_in);
                for scpj = 1 : numel(P_in);
                    outletsJ = Sols{p}{scqj,scpj}(:,idxVar);
                    if (flagSubP); outletsJ = P_in(scpj)-outletsJ; end;
                    outlets(scqi,scpi,scqj,scpj) = {[outlets{scqi,scpi,scqj,scpj}; outletsI-outletsJ ]};
                end;
            end;
        end;
    end;
end;

% Perform the two tailed paired U-Test.
UTests = nan(numel(Q_in),numel(P_in),numel(Q_in),numel(P_in));
for scqi = 1 : numel(Q_in);
    for scpi = 1 : numel(P_in);
        for scqj = 1 : numel(Q_in);
            for scpj = 1 : numel(P_in);
                UTests(scqi,scpi,scqj,scpj) = signrank(outlets{scqi,scpi,scqj,scpj},0,'tail','both','method','exact');
            end;
        end;
    end;
end;

end
