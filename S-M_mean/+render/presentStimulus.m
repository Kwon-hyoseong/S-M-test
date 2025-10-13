function abort = presentStimulus(dp, stim, isMoving, motionParams, stimDurationMs, kb)
%PRESENTSTIMULUS Draw the dot stimulus for a specified duration.

abort = false;
numFrames = max(1, round((stimDurationMs/1000) / dp.ifi));

Screen('FillRect', dp.wPtr, dp.bkColor);
vbl = Screen('Flip', dp.wPtr);

for frameIdx = 1:numFrames
    if isMoving && frameIdx > 1
        [stim.xPosDeg, stim.yPosDeg] = render.updatePositions(stim.xPosDeg, stim.yPosDeg, motionParams, stim, dp);
    end

    Screen('FillRect', dp.wPtr, dp.bkColor);

    xyPix = geom.convertCentersToPixels(stim.xPosDeg, stim.yPosDeg, dp);
    sizePix = stim.dotSizeDeg * dp.ppd;

    Screen('DrawDots', dp.wPtr, xyPix, sizePix, [1 1 1], [0 0], 2);

    vbl = Screen('Flip', dp.wPtr, vbl + 0.5 * dp.ifi);

    if input.shouldAbort(kb)
        abort = true;
        break;
    end
end
end