function aperture = updateApertureEdges(aperture)
%UPDATEAPERTUREEDGES Populate boundary fields (deg) from center/size.
%   aperture = UPDATEAPERTUREEDGES(aperture) computes the left/right/top/
%   bottom limits in degrees for the supplied aperture structure. The
%   structure must contain fields `centerDeg`, `widthDeg`, and `heightDeg`.

halfWidth  = aperture.widthDeg / 2;
halfHeight = aperture.heightDeg / 2;

aperture.leftDeg   = aperture.centerDeg(1) - halfWidth;
aperture.rightDeg  = aperture.centerDeg(1) + halfWidth;
aperture.topDeg    = aperture.centerDeg(2) - halfHeight;
aperture.bottomDeg = aperture.centerDeg(2) + halfHeight;
end