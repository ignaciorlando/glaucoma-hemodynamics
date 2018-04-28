function [ sol_c ] = extract_statistic_from_sol_condense( sol_condense, HDidx, statid )
%EXTRACT_STATISTIC_FROM_SOL_CONDENSE Retrieves an array with the statistic.
% Retrieves an array of the desire size in the first dimension, one second 
% dimension and the number of variables (HDidx.mask) in the third dimension
% containing the specified variables statistic.
%
% Parameters:
% sol_condense: The condense solution.
% HDidx:        The indexes of the variables.
% statid:       The statistic identifier to be extracted from the condense
%               solution argument
% Return:
% An array of the desire size in the first dimension, one second 
% dimension and the number of variables (HDidx.mask) in the third dimension
% containing the specified variables statistic.
%

if (~isfield(sol_condense{1,1},statid))
    error('The specified statid is not a fieldname of the staitsitc structures stored in sol_condense. Can not continue.')
end

sol_c = nan(size(sol_condense,1),HDidx.mask);

for i = 1 : size(sol_condense,1)
    for var = 1 : HDidx.mask
        sol_c(i,var) = getfield(sol_condense{i,var}, statid);
    end
end

end
