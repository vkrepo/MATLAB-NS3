function [rxPSDU] = mlWifiRecover(rxPPDU, cfgNHT, rxPPDUGain, agcGain)
% mlWifiRecover Packet decoder

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

% Create receiver object and apply gain
% Apply rxPPDU gain and add thermal noise
rxPPDU = rxPPDU*10^(rxPPDUGain/20);

% In a real receiver we would use an AGC, but here we can just add a
% gain, based on the known loss due to FSPL (less TX and rxPPDU gains)
rxPPDU = rxPPDU*10^(agcGain/20);

ind = wlanFieldIndices(cfgNHT);
fs = wlanSampleRate(cfgNHT);

% Packet detect and determine coarse packet offset
coarsePktOffset = wlanPacketDetect(rxPPDU,cfgNHT.ChannelBandwidth);
if isempty(coarsePktOffset) % If empty no L-STF detected; packet error
    % Synchronization failed, return dummy payload
    rxPSDU = zeros(cfgNHT.PSDULength*8,1,'int8');
    return
end

% Extract L-STF and perform coarse frequency offset correction
lstf = rxPPDU(coarsePktOffset+(ind.LSTF(1):ind.LSTF(2)),:);
coarseFreqOff = wlanCoarseCFOEstimate(lstf,cfgNHT.ChannelBandwidth);
rxPPDU = helperFrequencyOffset(rxPPDU,fs,-coarseFreqOff);

% Extract the non-HT fields and determine fine packet offset
nonhtfields = rxPPDU(coarsePktOffset+(ind.LSTF(1):ind.LSIG(2)),:);
finePktOffset = wlanSymbolTimingEstimate(nonhtfields,cfgNHT.ChannelBandwidth);

% Determine final packet offset
pktOffset = coarsePktOffset+finePktOffset;

% If packet detected outwith the range of expected delays from the
% channel modeling (0 with no channel); packet error
if pktOffset>0
    % Synchronization failed, return dummy payload
    rxPSDU = zeros(cfgNHT.PSDULength*8,1,'int8');
    return
end

% Extract L-LTF and perform fine frequency offset correction
lltf = rxPPDU(pktOffset+(ind.LLTF(1):ind.LLTF(2)),:);
fineFreqOff = wlanFineCFOEstimate(lltf,cfgNHT.ChannelBandwidth);
rxPPDU = helperFrequencyOffset(rxPPDU,fs,-fineFreqOff);

% Extract L-LTF samples from the waveform, demodulate and perform
% channel estimation
lltf = rxPPDU(pktOffset+(ind.LLTF(1):ind.LLTF(2)),:);
lltfDemod = wlanLLTFDemodulate(lltf,cfgNHT);
chanEst = wlanLLTFChannelEstimate(lltfDemod,cfgNHT);
nVar = helperNoiseEstimate(lltfDemod);

% Extract Data samples from the waveform
data = rxPPDU(pktOffset+(ind.NonHTData(1):ind.NonHTData(2)),:);
% Recover the transmitted PSDU in Non-HT Data
rxPSDU = wlanNonHTDataRecover(data,chanEst,nVar,cfgNHT);

end
