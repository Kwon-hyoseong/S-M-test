function [xCandidate, yCandidate] = sampleNonOverlappingPosition(existingX, existingY, existingSizes, currentSize, xBounds, yBounds, safetyMarginDeg)
%SAMPLENONOVERLAPPINGPOSITION Draw a candidate position avoiding overlaps.

maxAttempts = 1000;
widthDeg  = xBounds(2) - xBounds(1);
heightDeg = yBounds(2) - yBounds(1);

if widthDeg <= 0 || heightDeg <= 0
    error('Aperture is too small for the requested dot size.');
end

for attempt = 1:maxAttempts %#ok<NASGU>
    xCandidate = xBounds(1) + rand * widthDeg;
    yCandidate = yBounds(1) + rand * heightDeg;

    if isempty(existingX)
        return;
    end

    dx = existingX - xCandidate;
    dy = existingY - yCandidate;
    minDist = (existingSizes + currentSize)/2 + safetyMarginDeg;

    if all((dx.^2 + dy.^2) >= (minDist.^2))
        return;
    end
end

error('Failed to place dot without overlap after %d attempts.', maxAttempts);
end