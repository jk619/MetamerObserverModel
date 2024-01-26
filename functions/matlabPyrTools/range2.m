% [MIN, MAX] = range2(MTX)
%
% Compute minimum and maximum values of MTX, returning them as a 2-vector.

% Eero Simoncelli, 3/97.

function [mn mx] = range2(mtx)

%% NOTE: THIS CODE IS NOT ACTUALLY USED! (MEX FILE IS CALLED INSTEAD)

if (~isreal(mtx))
  error('MTX must be real-valued');  
end

mn = min(min(mtx));
mx = max(max(mtx));
