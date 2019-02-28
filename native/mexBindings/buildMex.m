function buildMex(varargin)
% This function will help in building the mex files.

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

cmd ='';
if length(varargin) == 0
    cmd = 'default';
elseif length(varargin) == 1
    cmd = varargin{1};
else
    error('Makefile error');
end

if strcmp(cmd, 'default')
    CFLAGS = '-DMANUAL_CHANGE=1 -I./ -I../../ns-allinone-3.29/ns-3.29/build/ -I../mlPhy';
    LDFLAGS = '-L. -L../../ns-allinone-3.29/ns-3.29/build/lib/ -lmexNs3State -lns3.29-internet-debug -lns3.29-internet-apps-debug -lns3.29-point-to-point-layout-debug -lns3.29-wifi-debug -lns3.29-csma-debug -lns3.29-lte-debug -lns3.29-propagation-debug -lns3.29-wimax-debug -lns3.29-csma-layout-debug -lns3.29-mesh-debug -lns3.29-spectrum-debug -lns3.29-dsdv-debug -lns3.29-mobility-debug -lns3.29-stats-debug -lns3.29-antenna-debug -lns3.29-dsr-debug -lns3.29-mpi-debug -lns3.29-aodv-debug -lns3.29-netanim-debug -lns3.29-tap-bridge-debug -lns3.29-applications-debug -lns3.29-energy-debug -lns3.29-network-debug -lns3.29-test-debug -lns3.29-bridge-debug -lns3.29-nix-vector-routing-debug -lns3.29-topology-read-debug -lns3.29-buildings-debug -lns3.29-fd-net-device-debug -lns3.29-olsr-debug -lns3.29-uan-debug -lns3.29-config-store-debug -lns3.29-flow-monitor-debug -lns3.29-point-to-point-debug -lns3.29-virtual-net-device-debug -lns3.29-netanim-debug -lns3.29-core-debug -lstdc++ -lns3.29-wave-debug -lns3.29-lr-wpan-debug -lns3.29-sixlowpan-debug -lns3.29-traffic-control-debug -lmatlabphy';
    
    MEXFILES = {'initNs3Interface.cpp', 'deinitNs3Interface.cpp', 'mexWifiPhyHelper.cpp', 'mexMobilityModel.cpp', 'mexSsidValue.cpp',...
        'mexBooleanValue.cpp', 'mexEventId.cpp', 'mexUintegerValue.cpp', 'mexNodeContainer.cpp', 'mexYansWifiChannel.cpp', 'mexMatlabWifiChannel.cpp',...
        'mexSimulator.cpp', 'mexNode.cpp', 'mexMobilityHelper.cpp', 'mexConstantPositionMobilityModel.cpp', 'mexAddress.cpp', 'mexAddressValue.cpp',...
        'mexConstantAccelerationMobilityModel.cpp', 'mexConstantVelocityMobilityModel.cpp', 'mexNodeList.cpp', 'mexYansWifiPhyHelper.cpp', 'mexRngSeedManager.cpp', 'mexWifiMacHelper.cpp',...
        'mexYansWifiChannelHelper.cpp', 'mexSsid.cpp', 'mexWifiHelper.cpp', 'mexNetDeviceContainer.cpp', 'mexPacketSocketHelper.cpp', 'mexPacketSocketAddress.cpp', 'mexOnOffHelper.cpp',...
        'mexDoubleValue.cpp', 'mexStringValue.cpp', 'mexDoubleValue.cpp', 'mexEmptyAttributeValue.cpp', 'mexApplicationContainer.cpp', 'mexConfig.cpp', 'mexYansWavePhyHelper.cpp',...
        'mexWaveHelper.cpp', 'mexNqosWaveMacHelper.cpp', 'mexQosWaveMacHelper.cpp', 'mexSocketInterface.cpp', 'mexMatlabWifiChannelHelper.cpp', 'mexMatlabWifiPhyHelper.cpp',...
        'mexUdpEchoServerHelper.cpp', 'mexUdpEchoClientHelper.cpp', 'mexInternetStackHelper.cpp', 'mexIpv4InterfaceContainer.cpp', 'mexIpv4AddressHelper.cpp',...
        'mexUdpServerHelper.cpp', 'mexUdpClientHelper.cpp', 'mexTimeValue.cpp', 'mexIpv4Address.cpp', 'mexInetSocketAddress.cpp', 'mexPacketSinkHelper.cpp',...
        'mexDataRateValue.cpp', 'mexIpv4GlobalRoutingHelper.cpp', 'mexAttributeDumper.cpp'
        };
    
    MEX = 'mex';
    for idx = 1:numel(MEXFILES)
        stmt = [MEX ' ' MEXFILES{idx} ' ' CFLAGS ' ' LDFLAGS];
        eval(stmt)
    end
elseif strcmp(cmd, 'clean')
    eval('delete *.mexa64');
else
    error('Not valid command');
end
end
