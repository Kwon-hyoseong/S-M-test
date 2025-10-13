function abort = shouldAbort(kb)
%SHOULDABORT Return true if the escape key is pressed.

[keyIsDown, ~, keyCode] = KbCheck(-1);
abort = keyIsDown && any(keyCode(kb.escKey));
end