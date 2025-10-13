clear all;
clc;
AssertOpenGL;
KbName('UnifyKeyNames');

kb = struct();
kb.useKbQueueCheck = 0;
kb = init_keyboard(kb);

% %%
% % 학번 입력 및 실험 종류 선택
% studentID = input('참가자 번호를 입력해주세요: ', 's');
% 
% validGender = false;
% while ~validGender
%     gender = input('성별을 입력해주세요 (M/F): ', 's');
%     if strcmpi(gender, 'M') || strcmpi(gender, 'F')
%         validGender = true;
%     else
%         disp('Invalid input. Please enter M for Male or F for Female.');
%     end
% end
% 
% age = input('만나이를 입력해주세요: ');
% 
% validHand = false;
% while ~validHand
%     hand = input('주로 사용하는 손은 무엇인가요? (R/L): ', 's');
%     if strcmpi(hand, 'R') || strcmpi(hand, 'L')
%         validHand = true;
%     else
%         disp('Invalid input. Please enter R for Right hand or L for Left hand.');
%     end
% end
% 
% validcolor = false;
% while  ~validcolor
%     color = input('시력이상 또는 색약이 없으신가요?(Y/N): ','s');
%     if strcmpi(color,'Y') || strcmpi(color,'N')
%         validcolor = true;
%     else
%         disp('Invalid input. Please enter Y for normal or N.')
%     end
% end
% 
% saveFileName = ['results_Exp_' studentID '_S-M_mean.mat'];
% 
% result.info = struct('gender', gender, 'age', age, 'hand', hand, 'color', color); % gender와 age와 hand를 하나의 필드로 저장

%% Display settings
dp.screenNum = max(Screen('Screens'));

dp.dist   = 55;
dp.width  = 60;
dp.bkColor   = [0.5 0.5 0.5];
dp.textColor = [0 0 0];
dp.textFont  = 'Arial';
dp.textSize  = 32;
dp.responseInstructions = {
    '응답하세요!';
    '왼쪽 방향키: T1 평균이 더 큽니다';
    '오른쪽 방향키: T2 평균이 더 큽니다'
};
dp.responseTimerFormat = '남은 시간: %d ms';
dp.skipChecks = 1;

try
    dp = OpenWindow(dp);
    HideCursor;
    ListenChar(2); 
    %% Dot configuration
    dotParams.smallSizeDeg = 0.7;
    dotParams.largeSizeDeg = 1.3;
    dotParams.targetMeanDeg     = 1.0;
    dotParams.meanJitterDeg     = 0.05;
    dotParams.minSizeDeg        = 0.4;
    dotParams.maxSizeDeg        = 1.8;
    dotParams.gToleranceDeg     = 0.001;
    dotParams.jitterStdRatio    = 0.15;
    dotParams.perceptualExponent = 0.76;
    dotParams.meanDiffLevels    = [0.06 0.12 0.18 0.24 0.30 0.36];
    dotParams.safetyMarginDeg   = 0.05;

    ratioAssignments = {
        struct('label','S6L2_vs_S2L6','t1Counts',[6 2],'t2Counts',[2 6]);
        struct('label','S5L3_vs_S3L5','t1Counts',[5 3],'t2Counts',[3 5]);
        struct('label','S3L5_vs_S5L3','t1Counts',[3 5],'t2Counts',[5 3]);
        struct('label','S2L6_vs_S6L2','t1Counts',[2 6],'t2Counts',[6 2])
    };

    numDots = sum(ratioAssignments{1}.t1Counts);

    %% Motion configuration
    motionParams.direction        = 'up';
    motionParams.speedDegPerSec   = 1.5;

    %% Timing configuration (ms)
    timingParams.fixationMs     = 300;
    timingParams.stimDurationMs = 500;
    timingParams.isiDurationMs  = 200;
    timingParams.postTrialMs    = 500;

    comboRepeats = 1;
    stimCombos = {'MM','SM','MS','SS'};

    apertureConfig.outer.centerDeg = [0 0];
    apertureConfig.outer.widthDeg  = 12;
    apertureConfig.outer.heightDeg = 9;
    apertureConfig.outer = geom.updateApertureEdges(apertureConfig.outer);

    apertureConfig.paddingDeg = 1.0;
    apertureConfig.inner = geom.shrinkAperture(apertureConfig.outer, apertureConfig.paddingDeg);

    epsDeg = 1 / dp.ppd;
    fprintf('Estimated pixel pitch: %.4f°/pixel.\n', epsDeg);
    if dotParams.gToleranceDeg < 0.5 * epsDeg
        fprintf(['[경고] gTolerance가 디스플레이 해상도(%.4f°)보다 매우 작습니다. ' ...
                 '계산상 문제는 없으나 물리적으로 구분이 어려울 수 있습니다.\n'], epsDeg);
    end

    Screen('FillRect', dp.wPtr, dp.bkColor);
    Screen('Flip', dp.wPtr);

    condList = design.buildTrialConditions(stimCombos, ratioAssignments, dotParams.meanDiffLevels, comboRepeats);
    order = randperm(numel(condList));

    result.trials(numel(order), 1) = struct( ...
        'condIdx', [], ...
        'comboLabel', '', ...
        'ratioIdx', [], ...
        'diffLevel', [], ...
        't1TargetMeanDeg', [], ...
        't2TargetMeanDeg', [], ...
        'responseKey', '', ...
        'responseChoice', '', ...
        'responseRtMs', NaN, ...
        'didRespond', false, ...
        'correct', NaN);

    abortExperiment = false;
    trialCounter = 1;

    for idx = order
        cond = condList(idx);

        if abortExperiment
            break;
        end

        comboLabel = cond.comboLabel;
        t1IsMoving = comboLabel(1) == 'M';
        t2IsMoving = comboLabel(2) == 'M';

        [t1TargetMeanDeg, t2TargetMeanDeg, t1Counts, t2Counts] = ...
            design.computeTargetMeans(dotParams, ratioAssignments{cond.ratioIdx}, cond.diffLevel);

        t1TargetMeanDeg = design.jitterMean(t1TargetMeanDeg, dotParams);
        t2TargetMeanDeg = design.jitterMean(t2TargetMeanDeg, dotParams);

        % Fixation screen before T1 onset
        if timingParams.fixationMs > 0
            numFixFrames = max(1, round((timingParams.fixationMs/1000) / dp.ifi));
            firstFixationFrame = true;
            for frameIdx = 1:numFixFrames
                Screen('FillRect', dp.wPtr, dp.bkColor);
                make_fixation(dp);
                if firstFixationFrame
                    vbl = Screen('Flip', dp.wPtr);
                    firstFixationFrame = false;
                else
                    vbl = Screen('Flip', dp.wPtr, vbl + 0.5 * dp.ifi);
                end
                if input.shouldAbort(kb)
                    abortExperiment = true;
                    break;
                end
            end
            if abortExperiment
                break;
            end
        end

        stim1 = stim.createStimulusStruct(numDots, t1TargetMeanDeg, dotParams, apertureConfig.outer, apertureConfig.inner, t1Counts);
        abortExperiment = render.presentStimulus(dp, stim1, t1IsMoving, motionParams, timingParams.stimDurationMs, kb);
        if abortExperiment
            break;
        end

        abortExperiment = render.presentBlank(dp, timingParams.isiDurationMs, kb);
        if abortExperiment
            break;
        end

        stim2 = stim.createStimulusStruct(numDots, t2TargetMeanDeg, dotParams, apertureConfig.outer, apertureConfig.inner, t2Counts);
        abortExperiment = render.presentStimulus(dp, stim2, t2IsMoving, motionParams, timingParams.stimDurationMs, kb);
        if abortExperiment
            break;
        end

        response = input.collectResponse(dp, kb, timingParams.postTrialMs);
        if response.wasAborted
            abortExperiment = true;
            break;
        end

        trialResult = struct();
        trialResult.condIdx = idx;
        trialResult.comboLabel = cond.comboLabel;
        trialResult.ratioIdx = cond.ratioIdx;
        trialResult.diffLevel = cond.diffLevel;
        trialResult.t1TargetMeanDeg = t1TargetMeanDeg;
        trialResult.t2TargetMeanDeg = t2TargetMeanDeg;
        trialResult.responseKey = response.keyName;
        trialResult.didRespond = response.didRespond;
        trialResult.responseRtMs = response.rt * 1000;

        if response.didRespond
            if strcmpi(response.keyName, 'LeftArrow')
                trialResult.responseChoice = 'T1';
            elseif strcmpi(response.keyName, 'RightArrow')
                trialResult.responseChoice = 'T2';
            else
                trialResult.responseChoice = '';
            end
        else
            trialResult.responseChoice = '';
        end

        if response.didRespond
            if strcmp(trialResult.responseChoice, 'T1')
                trialResult.correct = t1TargetMeanDeg > t2TargetMeanDeg;
            elseif strcmp(trialResult.responseChoice, 'T2')
                trialResult.correct = t2TargetMeanDeg > t1TargetMeanDeg;
            else
                trialResult.correct = NaN;
            end
        else
            trialResult.correct = NaN;
        end

        result.trials(trialCounter) = trialResult;
        trialCounter = trialCounter + 1;
    end

    result.trials = result.trials(1:trialCounter-1);

    render.presentBlank(dp, 0, kb);

    Screen('CloseAll');
    ListenChar(0);
    ShowCursor;
    if kb.useKbQueueCheck
        KbQueueRelease;
    end
    RestrictKeysForKbCheck([]);
    save(saveFileName, 'result');
catch ME
    Screen('CloseAll');
    ListenChar(0);
    ShowCursor;
    if exist('kb','var') && isfield(kb,'useKbQueueCheck') && kb.useKbQueueCheck
        KbQueueRelease;
    end
    RestrictKeysForKbCheck([]);
    rethrow(ME);
end