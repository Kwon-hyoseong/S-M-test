function abort = presentBlank(dp, durationMs, kb)
%PRESENTBLANK Show a blank screen for the requested duration.

abort = false;

Screen('FillRect', dp.wPtr, dp.bkColor);

if durationMs <= 0
    Screen('Flip', dp.wPtr);
    abort = input.shouldAbort(kb);
    return;
end

numFrames = max(1, round((durationMs/1000) / dp.ifi));
vbl = Screen('Flip', dp.wPtr);

for frameIdx = 1:numFrames %#ok<NASGU>
    Screen('FillRect', dp.wPtr, dp.bkColor);
    vbl = Screen('Flip', dp.wPtr, vbl + 0.5 * dp.ifi);

    if input.shouldAbort(kb)
        abort = true;
        break;
    end
end
end