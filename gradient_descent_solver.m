function [est] = gradient_descent_solver(BeaconPos, Data_In)
% This function performs gradient descent
%   minimizing the function sum(true_dist^2 - measured_dist^2)
%   where sum is over all beacons
%   and true_dist = sqrt([Xi-x]^2 + [Yi-y]^2 + [Zi-z]^2)
%   where Xi, Yi, Zi are 3D coordinates of beacon i
% Input to solver:
%   BeaconPos   : Nbx3 matrix where Nb is number of beacons
%   Data_In     : Nrx2 matrix where Nr is the number of beacons in range
%                   First column is index of beacons in range. Index is
%                   from 1 to Nb
%                   Second column is measured range
% Output from solver:
%   EstPos      : 1x3 matrix with estimated position

BeacInd       = Data_In(:,1);
r         = Data_In(:,2);

alpha = 0.2; % Step size
MaxIter = 1000; % maximum iterations
MaxChange = 1e-4; % To check for convergence
change(1) = inf;
i=1;
B = BeaconPos(BeacInd,:)
Nb = size(B,1);
est = mean(B);

while i < MaxIter & change(end)>MaxChange
    s = pdist2(B,est);
    g = s-r;
    f = sum(g.^2);
    J = -sum(repmat(s-r,1,3).*(B-repmat(est,Nb,1))./repmat(s,1,3));
    est = est-alpha*J;
    change(i) = sum((alpha*J).^2);
    i=i+1;
end
%est
%figure;plot(change);




