function stim = createStimulusStruct(numDots, targetMeanDeg, params, outerAperture, innerAperture, ratioCounts)
%CREATESTIMULUSSTRUCT Build dot stimulus positions and sizes.
%   Bundles dot sizes and spatial bounds for rendering routines.

dotSizeDeg = generateDotSizes(numDots, targetMeanDeg, params, ratioCounts);
[xPosDeg, yPosDeg] = initializeNonOverlappingPositions(numDots, dotSizeDeg, innerAperture, params.safetyMarginDeg);

stim.dotSizeDeg = dotSizeDeg;
stim.xPosDeg = xPosDeg;
stim.yPosDeg = yPosDeg;
stim.outerAperture = outerAperture;
stim.innerAperture = innerAperture;
stim.halfSizeDeg = dotSizeDeg / 2;

stim.topEdgesDeg    = outerAperture.topDeg    + stim.halfSizeDeg;
stim.bottomEdgesDeg = outerAperture.bottomDeg - stim.halfSizeDeg;
stim.leftEdgesDeg   = outerAperture.leftDeg   + stim.halfSizeDeg;
stim.rightEdgesDeg  = outerAperture.rightDeg  - stim.halfSizeDeg;

stim.innerTopEdgesDeg    = innerAperture.topDeg    + stim.halfSizeDeg;
stim.innerBottomEdgesDeg = innerAperture.bottomDeg - stim.halfSizeDeg;
stim.innerLeftEdgesDeg   = innerAperture.leftDeg   + stim.halfSizeDeg;
stim.innerRightEdgesDeg  = innerAperture.rightDeg  - stim.halfSizeDeg;

stim.verticalSpanDeg   = stim.bottomEdgesDeg - stim.topEdgesDeg;
stim.horizontalSpanDeg = stim.rightEdgesDeg - stim.leftEdgesDeg;
stim.innerVerticalSpanDeg   = stim.innerBottomEdgesDeg - stim.innerTopEdgesDeg;
stim.innerHorizontalSpanDeg = stim.innerRightEdgesDeg - stim.innerLeftEdgesDeg;

if any(stim.innerBottomEdgesDeg <= stim.innerTopEdgesDeg) || any(stim.innerRightEdgesDeg <= stim.innerLeftEdgesDeg)
    error('Inner aperture must be larger than dot diameters.');
end

if any(stim.verticalSpanDeg <= 0) || any(stim.horizontalSpanDeg <= 0)
    error('Aperture size must exceed the diameter of every dot.');
end
end

%% Local helpers ---------------------------------------------------------
function sizesDeg = generateDotSizes(numDots, targetMeanDeg, params, ratioCounts)
maxAttempts = 1000;
baseSizes = [repmat(params.smallSizeDeg,1,ratioCounts(1)), repmat(params.largeSizeDeg,1,ratioCounts(2))];

if numel(baseSizes) ~= numDots
    error('Ratio counts must sum to %d dots.', numDots);
end

scaleToTarget = targetMeanDeg / mean(baseSizes);
baseSizes = baseSizes * scaleToTarget;

jitterStdDeg = params.jitterStdRatio * targetMeanDeg;

for attempt = 1:maxAttempts %#ok<NASGU>
    noise = jitterStdDeg .* randn(1, numDots);
    noise = noise - mean(noise);

    sizesDeg = baseSizes + noise;
    sizesDeg = min(max(sizesDeg, params.minSizeDeg), params.maxSizeDeg);

    currentMean = mean(sizesDeg);
    delta = targetMeanDeg - currentMean;
    sizesDeg = sizesDeg + delta/numDots;

    if any(sizesDeg < params.minSizeDeg) || any(sizesDeg > params.maxSizeDeg)
        continue;
    end

    if abs(mean(sizesDeg) - targetMeanDeg) <= params.gToleranceDeg
        return;
    end
end

error('Could not generate dot sizes within tolerance. Adjust parameters.');
end

function [xPosDeg, yPosDeg] = initializeNonOverlappingPositions(numDots, dotSizeDeg, aperture, safetyMarginDeg)
xPosDeg = zeros(1, numDots);
yPosDeg = zeros(1, numDots);

for ii = 1:numDots
    currentSize = dotSizeDeg(ii);
    halfSize = currentSize / 2;

    xBounds = [aperture.leftDeg + halfSize, aperture.rightDeg - halfSize];
    yBounds = [aperture.topDeg + halfSize,  aperture.bottomDeg - halfSize];

    [xPosDeg(ii), yPosDeg(ii)] = sampleNonOverlappingPosition( ...
        xPosDeg(1:ii-1), yPosDeg(1:ii-1), dotSizeDeg(1:ii-1), currentSize, xBounds, yBounds, safetyMarginDeg);
end
end