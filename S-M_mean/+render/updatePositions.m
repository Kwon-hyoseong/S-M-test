function [xPosDeg, yPosDeg] = updatePositions(xPosDeg, yPosDeg, motionParams, stim, dp)
%UPDATEPOSITIONS Advance dot positions with wrap-around.

stepDeg = motionParams.speedDegPerSec / dp.frameRate;

direction = lower(motionParams.direction);
switch direction
    case 'up'
        yPosDeg = yPosDeg - stepDeg;
        yPosDeg = stim.topEdgesDeg + mod(yPosDeg - stim.topEdgesDeg, stim.verticalSpanDeg);
    case 'down'
        yPosDeg = yPosDeg + stepDeg;
        yPosDeg = stim.topEdgesDeg + mod(yPosDeg - stim.topEdgesDeg, stim.verticalSpanDeg);
    case 'left'
        xPosDeg = xPosDeg - stepDeg;
        xPosDeg = stim.leftEdgesDeg + mod(xPosDeg - stim.leftEdgesDeg, stim.horizontalSpanDeg);
    case 'right'
        xPosDeg = xPosDeg + stepDeg;
        xPosDeg = stim.leftEdgesDeg + mod(xPosDeg - stim.leftEdgesDeg, stim.horizontalSpanDeg);
    otherwise
        error('Unknown motion direction: %s', motionParams.direction);
end
end