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

instructionLines = prepareInstructionLines(dp);

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
    Screen('FillRect', dp.wPtr, dp.bkColor);

    ensureTextFont(dp);
    textSize = ensureTextSize(dp);

    lineSpacingPx = max(1, round(1.2 * textSize));
    baseY = dp.cy - 1.5 * dp.ppd;

    for lineIdx = 1:numel(instructionLines)
        lineText = instructionLines{lineIdx};
        lineY = baseY + (lineIdx - 1) * lineSpacingPx;
        drawCenteredText(dp.wPtr, lineText, dp.cx, lineY, dp.textColor);
    end

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

function instructionLines = prepareInstructionLines(dp)
if isfield(dp, 'responseInstructions') && ~isempty(dp.responseInstructions)
    if iscell(dp.responseInstructions)
        rawLines = dp.responseInstructions(:);
    else
        rawLines = cellstr(dp.responseInstructions);
    end
else
    rawLines = {
        '왼쪽 방향키: T1 평균이 더 큽니다';
        '오른쪽 방향키: T2 평균이 더 큽니다'
    };
end

instructionLines = cell(size(rawLines));
for iLine = 1:numel(rawLines)
    instructionLines{iLine} = normalizeLine(rawLines{iLine});
end
end

function lineOut = normalizeLine(lineIn)
if isnumeric(lineIn)
    lineOut = lineIn;
    return;
end

if isstring(lineIn)
    lineIn = char(lineIn);
elseif iscell(lineIn)
    lineIn = char(lineIn{:});
end

if ischar(lineIn)
    lineOut = double(lineIn);
else
    lineOut = double(string(lineIn));
end
end

function textSize = ensureTextSize(dp)
if isfield(dp, 'textSize') && ~isempty(dp.textSize)
    Screen('TextSize', dp.wPtr, dp.textSize);
end

textSize = Screen('TextSize', dp.wPtr);
if textSize <= 0
    textSize = 24;
    Screen('TextSize', dp.wPtr, textSize);
end
end

function ensureTextFont(dp)
if isfield(dp, 'textFont') && ~isempty(dp.textFont)
    Screen('TextFont', dp.wPtr, dp.textFont);
end
end

function drawCenteredText(winPtr, textString, centerX, yPos, color)
bounds = Screen('TextBounds', winPtr, textString);
textX = centerX - RectWidth(bounds) / 2;
Screen('DrawText', winPtr, textString, textX, yPos, color);
end