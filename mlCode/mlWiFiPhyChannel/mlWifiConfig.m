function genConfig = mlWifiConfig(dataRate)
% mlWifiConfig Non-HT Waveform Configuration object initialization

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

% Create non-HT configuration object
genConfig = wlanNonHTConfig;
% Configure the bandwidth to 20MHz
genConfig.ChannelBandwidth = 'CBW20';
% Configure modulation & coding scheme
switch (dataRate)
    case 6
        genConfig.MCS = 0;
    case 9
        genConfig.MCS = 1;
    case 12
        genConfig.MCS = 2;
    case 18
        genConfig.MCS = 3;
    case 24
        genConfig.MCS = 4;
    case 36
        genConfig.MCS = 5;
    case 48
        genConfig.MCS = 6;
    case 54
        genConfig.MCS = 7;
    case default
        disp('Rate not found to configure MCS');
end

end
