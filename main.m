% 3D trilateration code
% User has to define 
%   Boundary of the space   : Xmin, Xmax, Ymin, Ymax, Zmin, Zmax
%   Beacon Coordiantes      : BeaconPos
%   For simulation purpose, the standard deviation in ranging error
%                           : range_std 
%   Resolution of search in gird search 
%                           : GridRes
clc; clear; close all;

% Boundary of the space
Zmax = 4; 
Zmin = 0;
Xmin = 0;
Xmax = 5;
Ymin = 0;
Ymax = 8;
BoundingBox = [Xmin Ymin Zmin; Xmax Ymax Zmax];

BeaconPos = [Xmin+1 Ymin Zmax;...
    Xmax-1 Ymin Zmin;...
    Xmax Ymin+1 Zmax;...
    Xmax Ymax+1 Zmin;...
    Xmax-1 Ymax Zmax;...
    Xmin+1 Ymax Zmin;...
    Xmin Ymax-1 Zmax;...
    Xmin Ymin+1 Zmin];

% Number of beacons
Nb = size(BeaconPos,1);

% Generate random position inside the space by uniform distribution
RxPos = [Xmin + (Xmax-Xmin)*rand...
    Ymin + (Ymax-Ymin)*rand...
    Zmin + (Zmax-Zmin)*rand];

% Define standard deviation in range noise
range_std = 0.3;

% Select a subset of beacons
BeacInd = unique(randi([1 Nb],5,1)); % Selecting at most 5 beacons
BeacInRange = BeaconPos(BeacInd,:)

% Generate true range from all beacons
Range = pdist2(RxPos,BeacInRange)';
MeasuredRange = Range + range_std*randn(numel(BeacInd),1);

% Resolution of search space
GridRes = 0.05; 

% ------------- Call Solver ------------------------------------------
% Input to solver:
%   BeaconPos   : Nbx3 matrix where Nb is number of beacons. 3D position of
%                   all beacons
%   BeacInd     : Nrx1 matrix where Nr is number of beacons in range. This
%                   is the index of all beacons in range, index ranging from 1 to Nb
%   MeasuredRange : Nrx1 matrix  where Nr is number of beacons in range.
%                   This is the measured range from the beacons with index
%                   BeacInd
%   GridRes     : 1x1 matrix
%   BoundingBox : 2x3 matrix with [Xmin Ymin Zmin; Xmax Ymax Zmax]
% Output from solver:
%   EstPos      : 1x3 matrix with estimated position
%   Residue     : 1x1 matrix with residue error - this is an approx indication of
%                   confidence of measurement
[EstPos, Residue] = grid_search_solver(BeaconPos, [BeacInd MeasuredRange], GridRes, BoundingBox);
RxPos
EstPos
Residue
% -------------- Plot results ---------------------------------------
figure; hold on;
scatter3(BeaconPos(:,1),BeaconPos(:,2),BeaconPos(:,3),100,'filled','MarkerFaceColor',[0.6 0.6 0.6],'MarkerEdgeColor',[0.6 0.6 0.6]);
scatter3(BeaconPos(BeacInd,1),BeaconPos(BeacInd,2),BeaconPos(BeacInd,3),100,'filled','MarkerFaceColor','b','MarkerEdgeColor','b');
axis equal; grid on; 
xlabel('x'); ylabel('y'); zlabel('z');
scatter3(RxPos(1),RxPos(2),RxPos(3),'g');
scatter3(EstPos(1), EstPos(2), EstPos(3),'r');
legend({'Beacons not in range';'Beacons in range';'True Pos';'Est Pos'});
set(gca,'fontsize',14);
title('3D plot of true and estimated locations');



