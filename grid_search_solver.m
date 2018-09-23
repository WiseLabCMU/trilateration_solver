function [EstPos, MinErr] = grid_search_solver(BeaconPos, Range, GridRes, BoundingBox)
% This function performs grid seach
% Input to solver:
%   BeaconPos   : Nbx3 matrix where Nb is number of beacons
%   Range       : Nbx1 matrix
%   GridRes     : 1x1 matrix
%   BoundingBox : 2x3 matrix with [Xmin Ymin Zmin; Xmax Ymax Zmax]
% Output from solver:
%   EstPos      : 1x3 matrix with estimated position
%   Residue     : 1x1 matrix with residue error - this is an approx indication of
%                   confidence of measurement


% Generate all the points in the grid
[AllPts_x, AllPts_y, AllPts_z] = meshgrid(BoundingBox(1,1):GridRes:BoundingBox(2,1),...
    BoundingBox(1,2):GridRes:BoundingBox(2,2),...
    BoundingBox(1,3):GridRes:BoundingBox(2,3));

All_xyz = [AllPts_x(:) AllPts_y(:) AllPts_z(:)];

% Compute distance to beacons for all points
TrueDist = pdist2(All_xyz,BeaconPos);

% Compute error between true and meaured distance
Err_TrueEstDist = sum(abs(bsxfun(@minus, TrueDist,Range')),2);

% Estimated location is location with minimum of (sum of absolute error to
% all beacons)
[MinErr, MinErrInd] = min(Err_TrueEstDist);
MinErr = MinErr/size(BeaconPos,1);

EstPos = All_xyz(MinErrInd,:);

end

