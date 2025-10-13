function response = collectResponse(dp, kb, durationMs)
%COLLECTRESPONSE Display the response screen and collect participant input.

response = struct('didRespond', false, ...
                  'keyCode', NaN, ...
                  'keyName', '', ...
                  'rt', NaN, ...
                  'wasAborted', false);

if durationMs <= 0
    return;
end

startTime = GetSecs;
deadline = startTime + durationMs / 1000;

if kb.useKbQueueCheck
    KbQueueFlush;
else
    KbReleaseWait;
end

firstFrame = true;
vbl = 0;

while GetSecs < deadline && ~response.wasAborted && ~response.didRespond
    remaining = max(0, deadline - GetSecs);
    remainingMs = ceil(remaining * 1000);

    Screen('FillRect', dp.wPtr, dp.bkColor);

    instruction = sprintf('응답하세요!\n←: T1 평균이 더 큽니다\n→: T2 평균이 더 큽니다');
    DrawFormattedText(dp.wPtr, instruction, 'center', dp.cy - dp.ppd, dp.textColor, [], [], [], 1.5);

    timerText = sprintf('남은 시간: %d ms', remainingMs);
    DrawFormattedText(dp.wPtr, timerText, 'center', dp.cy + dp.ppd, dp.textColor);

    if firstFrame
        vbl = Screen('Flip', dp.wPtr);
        firstFrame = false;
    else
        vbl = Screen('Flip', dp.wPtr, vbl + 0.5 * dp.ifi);
    end

    if kb.useKbQueueCheck
        [pressed, firstPress] = KbQueueCheck;
        if pressed
            if any(firstPress(kb.escKey))
                response.wasAborted = true;
                break;
            elseif firstPress(kb.leftKey) > 0
                response = finalizeResponse(response, kb.leftKey, 'LeftArrow', firstPress(kb.leftKey), startTime);
            elseif firstPress(kb.rightKey) > 0
                response = finalizeResponse(response, kb.rightKey, 'RightArrow', firstPress(kb.rightKey), startTime);
            end
        end
    else
        [keyIsDown, keyTime, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(kb.escKey)
                response.wasAborted = true;
                break;
            elseif keyCode(kb.leftKey)
                response = finalizeResponse(response, kb.leftKey, 'LeftArrow', keyTime, startTime);
            elseif keyCode(kb.rightKey)
                response = finalizeResponse(response, kb.rightKey, 'RightArrow', keyTime, startTime);
            end
        end
    end
end

if ~firstFrame
    Screen('FillRect', dp.wPtr, dp.bkColor);
    Screen('Flip', dp.wPtr, vbl + 0.5 * dp.ifi);
end

end

function response = finalizeResponse(response, keyCode, keyName, pressTime, startTime)
response.didRespond = true;
response.keyCode = keyCode;
response.keyName = keyName;
response.rt = pressTime - startTime;
end