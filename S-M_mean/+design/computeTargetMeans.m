function [t1TargetMeanDeg, t2TargetMeanDeg, t1Counts, t2Counts] = computeTargetMeans(params, ratioStruct, diffLevel)
%COMPUTETARGETMEANS Compute perceptually-scaled mean sizes per trial.
%   Uses the psychophysical exponent to adjust mean differences while
%   keeping individual dot sizes within bounds.

smallDeg = params.smallSizeDeg;
largeDeg = params.largeSizeDeg;
expo     = params.perceptualExponent;

t1Counts = ratioStruct.t1Counts;
t2Counts = ratioStruct.t2Counts;

baseT1 = [repmat(smallDeg,1,t1Counts(1)), repmat(largeDeg,1,t1Counts(2))];
baseT2 = [repmat(smallDeg,1,t2Counts(1)), repmat(largeDeg,1,t2Counts(2))];

meanT1deg = mean(baseT1);
meanT2deg = mean(baseT2);

meanT1ps = mean(baseT1.^expo);
meanT2ps = mean(baseT2.^expo);

diffSign = sign(meanT2ps - meanT1ps);
if diffSign == 0
    diffSign = 1;
end

t1TargetPS = meanT1ps;
t2TargetPS = t1TargetPS * (1 + diffSign * diffLevel);

scaleT1 = (t1TargetPS / meanT1ps)^(1/expo);
scaleT2 = (t2TargetPS / meanT2ps)^(1/expo);

t1TargetMeanDeg = meanT1deg * scaleT1;
t2TargetMeanDeg = meanT2deg * scaleT2;

minDeg = params.minSizeDeg;
maxDeg = params.maxSizeDeg;

t1TargetMeanDeg = min(max(t1TargetMeanDeg, minDeg), maxDeg);
t2TargetMeanDeg = min(max(t2TargetMeanDeg, minDeg), maxDeg);
end