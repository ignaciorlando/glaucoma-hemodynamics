function [ stats ] = statistics( Data )
%STATISTICS Computes statistics of the data array.
%

stats.n         = numel(Data);
stats.mean      = mean(Data);
stats.std       = std(Data);
stats.coefOfVar = abs(stats.std / stats.mean);
stats.min       = min(Data);
stats.max       = max(Data);
stats.median    = median(Data);
stats.quantilesV= [0.00 0.05 0.15 0.25 0.50 0.75 0.85 0.95];
stats.quantiles = quantile(Data, stats.quantilesV);
stats.Data      = Data;

end

