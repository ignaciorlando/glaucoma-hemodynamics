function [ preprocessed_segm ] = preprocess_vessel_segmentation( vessel_segm )
%PREPROCESS_VESSEL_SEGMENTATION Preprocess the segmentation to improve its
%skeletonization.

    % fill holes
    preprocessed_segm = imfill(vessel_segm, 'holes');

end

