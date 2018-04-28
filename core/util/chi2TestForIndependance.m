function [ pval, M ] = chi2TestForIndependance( data )
%CHI2TESTFORINDEPENDANCE 
% The Chi-Square test of Independence is used to determine if there is a 
% significant relationship between two nominal (categorical) variables.  
% The frequency of one nominal variable is compared with different values 
% of the second nominal variable.  The data can be displayed in an R*C 
% contingency table, where R is the row and C is the column.  For example, 
% a researcher wants to examine the relationship between gender 
% (male vs. female) and empathy (high vs. low).  The chi-square test of 
% independence can be used to examine this relationship.  If the null
% hypothesis is accepted there would be no relationship between gender 
% and empathy.  If the null hypotheses is rejected the implication would 
% be that there is a relationship between gender and empathy (e.g. females 
% tend to score higher on empathy and males tend to score lower on empathy).
% 
% data: The input data containing 2 columns (variables) and n rows 
% (observations).
%

v1 = unique(data(:,1));
v2 = unique(data(:,2));
v1 = v1(~isnan(v1));
v2 = v2(~isnan(v2));

n = size(data,1);
r = numel(v1);
c = numel(v2);
dof = (r-1)*(c-1);

%% Computes the contigency table-------------------------------------------
M = zeros(r,c);
for i = 1 : r;
    for j = 1 : c;        
        M(i,j) = 0;
        for k = 1 : n;
            if (data(k,1) == v1(i) && data(k,2) == v2(j))
                M(i,j) = M(i,j) + 1;
            end;
        end;
    end;
end;
%% Computes the expected values--------------------------------------------
RSum = sum(M,2);
CSum = sum(M,1);
E = nan(r,c);
for i = 1 : r;
    for j = 1 : c;        
        E(i,j) = RSum(i)*CSum(j) / n;
    end;
end;
%% Computes the Chi-Square value-------------------------------------------
chi2 = sum(sum((M - E).^2 ./ E));

pval = 1 - chi2cdf(chi2, dof);

end

