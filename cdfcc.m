function [ yCDF, xCDF ] = cdfcc( rate )
[yy, xx, ~, ~, ~] = cdfcalc(rate);
k = length(xx);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF = [-Inf; xx(n); Inf];
yCDF = [0; 0; yy(1+n)];
end