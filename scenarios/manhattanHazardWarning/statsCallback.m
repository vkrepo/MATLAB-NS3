function statsCallback(nodeId, param, value)
%  This function is used to connect the traces of NS-3 With MATLAB.

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

stats.getSetStats(nodeId, param, 1);
end
