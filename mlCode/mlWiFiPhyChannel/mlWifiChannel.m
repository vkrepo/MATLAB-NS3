function [rxPSDU, rxPowerdBm, snrW] = mlWifiChannel(txPPDU, ...
    senderPosition, receiverPosition,powerLevel, txGain, rxGain, channelWidth)
% mlWifiChannel Models a free-space WiFi channel in MATLAB for 802.11a.
% Called from WST Callback function, while the simulation runs in NS3.
%
% Input parameters list:
% TXPPDU             - Tx waveform.
% SENDERPOSITION     - Position (x,y,z) vector of the sender as double
% values.
% RECEIVERPOSITION   - Position (x,y,z) vector of the receiver as double
% values.
% POWERLEVEL         - Transmit power level in dBm as a double value.
% TXGAIN             - Transmitter gain in Db as a double value.
% RXGAIN             - Receiver gain in Db as a double value.
% CHANNELWIDTH       - Bandwidth of channel in MHz as integer.
%
% Output parameters list
% RXPSDU             - Modified signal after passing through channel.
% RXPOWERDBM         - Received signal strength by receiver in dBm.

%
% Copyright (C) Vamsi.  2017-19 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

% Loss (dB) in the Signal-to-Noise-Ratio due to non-idealities in the
% receiver. This is "the difference in decibels (dB) between the noise
% output of the actual receiver to the noise output of an ideal receiver
% with the same overall gain and bandwidth when the receivers are connected
% to sources at the standard noise temperature T0 (usually 290 K)".
rxNoiseFigure = 7;
% Calculate distance between sender and receiver
dist = norm(senderPosition-receiverPosition);

fc = 5.1509e9; % 5 GHz signal
lambda = physconst('LightSpeed')/fc;

% Calculate free space path loss (will be returned in Db)
pathLoss = fspl(dist, lambda);
rxPowerdBm = powerLevel + txGain - pathLoss;

freeSpaceSig = txPPDU*10^((powerLevel-30-pathLoss+txGain)/20);

rxPowermW = 10^(rxPowerdBm/10); % Before any Rx gain as applied at receiver
signal = rxPowermW / 1000;

% thermal noise at 290K in J/s = W
BOLTZMANN = 1.3803e-23;

% Nt is the power of thermal noise in W at 290K
Nt = BOLTZMANN * 290 * double(channelWidth) * 1000000;

noiseFigure = 10^(rxNoiseFigure/10);
% receiver noise Floor (W) which accounts for thermal noise and non-idealities of the receiver
noiseFloor = noiseFigure * Nt;

% Ideally noiseInterference should also be added here which is not considered here;
noise = noiseFloor;
snrW = double(signal/noise);
snrDb = 10*log10(snrW);

% Create an AWGN noise channel with the calculated SNR and signal power.
chNoise = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', ...
    'SignalPower', signal, 'SNR', snrDb);
rxPSDU = chNoise(freeSpaceSig);

end
