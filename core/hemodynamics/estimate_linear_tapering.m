function [ lin_tap, length ] = estimate_linear_tapering( points, radius )
%ESTIMATE_LINEAR_TAPERING Estimate the linear tapering function for a vessel.
% Compute and return an array with the values of a linear tapering function
% for the given vessel array.
%
% Parameters:
% points: Array of (n,3) with the points coordinates of the vessle in the
%         order inlet to outlet.
% radius: Contains the cross sectional radius for each point.
%
% Returns:
% lin_tap: An array of the same length of radius, with the linear tapering
% approximation for the radius.
% length: The length of the vesel.
%

length = 0;
for p = 2 : numel(radius);
    length = length + norm(points(p-1,:)-points(p,:));    
end;
a = 0;
b = length;
r_a= radius(1);
r_b= radius(end);
lin_tap = nan(size(radius));
x = 0;
for p = 1 : numel(radius)-1;
    lin_tap(p) = (1/length) * ((r_b - r_a) * x + b*r_a - a*r_b );    
    x = x + norm(points(p,:)-points(p+1,:));    
end;
lin_tap(end) = radius(end);    


end

