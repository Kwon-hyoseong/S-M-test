function meanDeg = jitterMean(baseMeanDeg, params)
%JITTERMEAN Apply bounded random jitter to a target mean size (deg).
%   meanDeg = JITTERMEAN(baseMeanDeg, params) perturbs the supplied mean by
%   +/- params.meanJitterDeg while clamping to min/max size limits.

meanDeg = baseMeanDeg + params.meanJitterDeg * (2 * rand - 1);
meanDeg = min(max(meanDeg, params.minSizeDeg), params.maxSizeDeg);
end