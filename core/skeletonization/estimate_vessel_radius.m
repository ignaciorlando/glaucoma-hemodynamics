function [ vessel_radius ] = estimate_vessel_radius( vessel_segm, centerline )
%ESTIMATE_VESSEL_RADIUS Compute the vessel radius using the Euclidean
%transform

    % We approximate the vessel radius using the Euclidean transform
    vessel_radius = bwdist(imcomplement(vessel_segm)) .* centerline;

    % Identify problematic pixels with radius 0
    problematic_pixels = centerline .* (vessel_radius==0) > 0;
    vessel_radius(problematic_pixels) = 0.5;

end

