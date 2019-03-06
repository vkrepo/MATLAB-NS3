function txPPDU = mlWifiGenerator(packet, cfgNHT, txGain)
% mlWifiGenerator WLAN packet encoder for 802.11a

%
% Copyright (C) Vamsi.  2017-19 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

% Set the configuration object's PSDU length
cfgNHT.PSDULength = length(packet)/8;

% Generate waveform using non-HT configuration for the given data
txPPDU = wlanWaveformGenerator(packet,cfgNHT);
end
