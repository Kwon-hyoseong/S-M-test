function xyPix = convertCentersToPixels(xDeg, yDeg, dp)
%CONVERTCENTERSTOPIXELS Convert deg coordinates to pixel space.
%   xyPix = CONVERTCENTERSTOPIXELS(xDeg, yDeg, dp) converts degrees of
%   visual angle into screen pixels using the display parameters in `dp`.
%   The result is a 2xN matrix suitable for Screen('DrawDots').

xyPix = [xDeg; yDeg] * dp.ppd;
xyPix(1, :) = xyPix(1, :) + dp.cx;
xyPix(2, :) = xyPix(2, :) + dp.cy;
end