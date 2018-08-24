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
    CFLAGS = '-DMANUAL_CHANGE=1 -I./ -I../../ns-allinone-3.26/ns-3.26/build/ -I../mlPhy';
    LDFLAGS = '-L. -L../../ns-allinone-3.26/ns-3.26/build/ -lmexNs3State -lns3.26-internet-debug -lns3.26-internet-apps-debug -lns3.26-point-to-point-layout-debug -lns3.26-wifi-debug -lns3.26-csma-debug -lns3.26-lte-debug -lns3.26-propagation-debug -lns3.26-wimax-debug -lns3.26-csma-layout-debug -lns3.26-mesh-debug -lns3.26-spectrum-debug -lns3.26-dsdv-debug -lns3.26-mobility-debug -lns3.26-stats-debug -lns3.26-antenna-debug -lns3.26-dsr-debug -lns3.26-mpi-debug -lns3.26-aodv-debug -lns3.26-netanim-debug -lns3.26-tap-bridge-debug -lns3.26-applications-debug -lns3.26-energy-debug -lns3.26-network-debug -lns3.26-test-debug -lns3.26-bridge-debug -lns3.26-nix-vector-routing-debug -lns3.26-topology-read-debug -lns3.26-buildings-debug -lns3.26-fd-net-device-debug -lns3.26-olsr-debug -lns3.26-uan-debug -lns3.26-config-store-debug -lns3.26-flow-monitor-debug -lns3.26-point-to-point-debug -lns3.26-virtual-net-device-debug -lns3.26-netanim-debug -lns3.26-core-debug -lstdc++ -lns3.26-wave-debug -lns3.26-lr-wpan-debug -lns3.26-sixlowpan-debug -lns3.26-traffic-control-debug -lmatlabphy';
    
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
