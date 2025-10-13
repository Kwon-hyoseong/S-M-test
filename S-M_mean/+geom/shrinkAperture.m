function innerAperture = shrinkAperture(baseAperture, paddingDeg)
%SHRINKAPERTURE Reduce an aperture by a symmetric padding (deg).
%   innerAperture = SHRINKAPERTURE(baseAperture, paddingDeg) returns an
%   aperture whose width/height are reduced by twice the padding. The
%   resulting aperture inherits the center coordinates from baseAperture.

innerAperture = baseAperture;
innerAperture.widthDeg  = baseAperture.widthDeg  - 2 * paddingDeg;
innerAperture.heightDeg = baseAperture.heightDeg - 2 * paddingDeg;

if innerAperture.widthDeg <= 0 || innerAperture.heightDeg <= 0
    error('Inner aperture became non-positive. Adjust padding or base size.');
end

innerAperture = geom.updateApertureEdges(innerAperture);
end