Screen('Preference','SkipSyncTests',1) 

PsychDefaultSetup(2);         % 0~1 색 범위, 키맵 통일
AssertOpenGL;                 % PTB OpenGL 경로/드라이버 체크

%% Display settings (params)
dp.screenNum = max(Screen('Screens'));

dp.dist   = 55;   % 관찰 거리 (cm)
dp.width  = 60;   % 화면 가로 물리폭 (cm)
dp.bkColor   = 0.5;            % 배경색 (회색)
dp.textColor = [0 0 0];        % 텍스트 색 (검정)

% 해상도/주사율/비율/ppd 미리 계산(창 열기 없이 가능)
d = Screen('Resolution', dp.screenNum);
dp.resolution  = [d.width, d.height];        % [W H] px
dp.frameRate   = d.hz;                        % Hz
dp.aspectRatio = dp.resolution(2)/dp.resolution(1);

% 픽셀-각도 변환(ppd, pixels per degree)
dp.ppd = dp.resolution(1) / ((2*atan(dp.width/(2*dp.dist)))*180/pi);


% rect = []; if want FullScreen
rect = [0 0 800 600];
[dp.wPtr, dp.wRect] = PsychImaging('OpenWindow', dp.screenNum, dp.bkColor, rect, [], [], 0);

% --- after openwindow : real params 값 update ---
Screen('BlendFunction', dp.wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
dp.ifi        = Screen('GetFlipInterval', dp.wPtr);
dp.frameRate  = round(1/dp.ifi);        % 실제 주사율
dp.resolution = dp.wRect([3 4]);        % 실제 창 크기
[dp.cx, dp.cy]= RectCenter(dp.wRect);

%%
numDots = 8;

% 점 크기 (스칼라 또는 1xN)
dotSize = randi([5, 20], 1, numDots);

% 창 크기
W = dp.resolution(1);
H = dp.resolution(2);

% 화면 안쪽에 무작위 좌표 생성(절대좌표, 좌상단 원점)
margin = max(dotSize)/2;
xPos = margin + (W - 2*margin) * rand(1, numDots);
yPos = margin + (H - 2*margin) * rand(1, numDots);

% DrawDots는 2xN 행렬을 받는다
xy = [xPos; yPos]

% 색: 전체 동일 (0~1 범위, PsychDefaultSetup(2) 기준)
dotColor = [1 0 0];

% 좌표 원점(center)을 좌상단으로 지정해서 절대좌표를 그대로 사용
Screen('DrawDots', dp.wPtr, xy, dotSize, dotColor, [0 0], 2);
Screen('Flip', dp.wPtr);
