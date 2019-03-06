%    WLAN INFRASTRUCTURE NETWORK EXAMPLE WITH MULTIPLE STATIONS AND APS
% -------------------------------------------------------------------------
% This example models a WLAN network with multiple APs and Stations.
% In a simple scenario, a network is modeled with an AP and two STAs.
% In a complex scenario, 4 APs and 36 STAs are included in the model. The
% Stations are arranged in a 6*6 grid, with configurable distance between
% them. APs are in a separate 2x2 grid overlaid on the stations grid.
% -------------------------------------------------------------------------
% The main simulation loop is run in NS-3, using mex call. The
% functionality / features implemented in MATLAB are:
% * Network topology creation
% * Configuration Parameters:
%    1. Type of Phy-Statistical PHY/WST PHY
%    2. Topology parameters (position, distance, count and type of nodes)
%    3. Wifi standard (802.11a/802.11b/802.11g/802.11n-2.4GHz/802.11n-5GHz/802.11ac)
%    4. Tx Gain, Rx Gain
% * Visualization

%
% Copyright (C) Vamsi.  2017-19 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

%% Adding path of Mex wrappers, bindings, wst phy model and traces.
addpath(genpath(fullfile(pwd,'../../native/mexBindings')));
addpath(genpath(fullfile(pwd,'../../mlCode/mlWrappers')));
addpath(genpath(fullfile(pwd, '../../mlCode/mlWiFiPhyChannel/')));

%% Cleaning if at all last iteration did not exit cleanly
clc;
close all;
clear;
Simulator.Destroy();
clear functions;


%% Scenario configuration section
% Simulation duration in seconds (in terms of simulation clock)
simTime = 5;

% Flag indicates whether to use MATLAB WST PHY+Channel models or NS3
% statistical models.
useWST = 0;

% Scenario can be 'simple' or 'complex'.
scenarioComplexity = 'complex';

% Configure WLAN standard to one of these: '802.11a' / '802.11b' /
% '802.11g' / '802.11n-2.4GHz' / '802.11-5GHz' / '802.11ac'.
% Applicable only if 'useWST' is 0 (using NS3 statistical PHY & Channel).
% While using WST PHY and Channel, this has to be taken care of by the PHY
% encoder-decoder implementation in MATLAB.
standard = '802.11a';

% Check the standard. If the standard is other than 802.11a and 
% useWST flag is set to 1, stop.
if ((useWST == 1) && ~strcmp(standard, '802.11a'))
    error("Currently WST callback supports only Non-HT. Remove this check if you modify the callback.")
end

% Configure APs and STAs for the scenarioComplexity
if (strcmp(scenarioComplexity,'simple'))
    numStations = 2;
    numAPs = 1;
    interStationDistance = 100;
    noOfApplications = 2;
elseif (strcmp(scenarioComplexity, 'complex'))
    numStations = 36;
    numAPs = 4;
    interStationDistance = 50;
    noOfApplications = 4;
end

% Configure station manager for stations and AP
staManager = 'MinstrelHtWifiManager';
apManager  = 'MinstrelHtWifiManager';

% Using constant position (no mobility) for all the devices
mobilityModel = 'ConstantPositionMobilityModel';

% Tx gain and Rx gain for each device
txGain = 3.0;
rxGain = 3.0;

% Initialize the binding manager to maintain state of the simulation.
initNs3Interface();

stationGridWidth = ceil(sqrt(numStations));
apGridWidth = ceil(sqrt(numAPs));

% Write configuration parameters into a file for visualization purpose.
fp = fopen('config.txt', 'w');
fprintf(fp, '%f\n', interStationDistance);
fprintf(fp, '%f\n', txGain);
fprintf(fp, '%f\n', rxGain);
fprintf(fp, '%d\n', numStations);
fprintf(fp, '%d\n', numAPs);
fclose(fp);

%% Create Nodes and install mobility on them.
% Create Node Containers for AP and Stations
accessPointC = NodeContainer();
stationC = NodeContainer();

% Create Nodes and attach to respective node containers.
stationC.Create(numStations);
accessPointC.Create(numAPs);

%% Create protocol stack, including Channel
if (useWST)
    % Create PHY Matlab model instance in NS3 to interface with MATLAB WST
    wifiPhy = MatlabWifiPhyHelper.Default();
    wifiChannel = MatlabWifiChannelHelper.Default();
    % Register WST callback that performs encoding and decoding of signals in matlab
    wifiChannel.CallBackRegistration(func2str(@WSTCallback));
    % Any channel propagation loss and delay models have to be done in MATLAB.
    % Parameters passed to WST callback from NS3:
    % - Sender and receiver identifiers, their current positions, velocities,
    % - Transmitted Packet, Tx power level, Tx gain of sender, Rx gain of receiver
    
else
    % Use NS3 PHY statistical model
    wifiPhy = YansWifiPhyHelper.Default();
    wifiChannel =  YansWifiChannelHelper();
    wifiChannel.SetPropagationDelay('ConstantSpeedPropagationDelayModel');
    
    % Enable any of the propagation loss models below.
    %wifiChannel.AddPropagationLoss('LogDistancePropagationLossModel');
    wifiChannel.AddPropagationLoss('FriisPropagationLossModel');
end

% Set Tx & Rx gains on all the devices
wifiPhy.Set('TxGain', DoubleValue(txGain));
wifiPhy.Set('RxGain', DoubleValue(rxGain));
wifiPhy.SetChannel(wifiChannel.Create());

% Create WifimacHelper
wifiHelper = WifiHelper();

standardValue = WifiPhyStandard.getStandard(standard);
wifiHelper.SetStandard(standardValue);

% Create WifiMacHelper
wifiMac = WifiMacHelper();
staDevs = NetDeviceContainer();
apDevs = NetDeviceContainer();

if(strcmp(scenarioComplexity,'complex'))
    ssid1 = Ssid('DemoSSID1');
    ssid2 = Ssid('DemoSSID2');
    ssid3 = Ssid('DemoSSID3');
    ssid4 = Ssid('DemoSSID4');
    % Install PHY and MAC over all the stations & APs
    wifiHelper.SetRemoteStationManager(staManager);
    wifiMac.SetType ('StaWifiMac', 'Ssid', SsidValue(ssid1));
    for id = 0:((numStations/2)-1)
        if(mod(id,stationGridWidth) < stationGridWidth/2 )
            wifiMac.SetType ('StaWifiMac', 'Ssid', SsidValue(ssid1));
            staDevs.Add(wifiHelper.Install(wifiPhy, wifiMac, stationC.Get(id)));
        else
            wifiMac.SetType ('StaWifiMac', 'Ssid', SsidValue(ssid2));
            staDevs.Add(wifiHelper.Install(wifiPhy, wifiMac, stationC.Get(id)));
        end
    end
    for id = (numStations/2):(numStations-1)
        if(mod(id,stationGridWidth) < stationGridWidth/2 )
            wifiMac.SetType ('StaWifiMac', 'Ssid', SsidValue(ssid3));
            staDevs.Add(wifiHelper.Install(wifiPhy, wifiMac, stationC.Get(id)));
        else
            wifiMac.SetType ('StaWifiMac', 'Ssid', SsidValue(ssid4));
            staDevs.Add(wifiHelper.Install(wifiPhy, wifiMac, stationC.Get(id)));
        end
    end
    
    wifiHelper.SetRemoteStationManager(apManager);
    wifiMac.SetType('ApWifiMac', 'Ssid', SsidValue(ssid1), 'EnableBeaconJitter', BooleanValue(true));
    apDevs.Add(wifiHelper.Install(wifiPhy, wifiMac, accessPointC.Get(0)));
    wifiMac.SetType('ApWifiMac', 'Ssid', SsidValue(ssid2), 'EnableBeaconJitter', BooleanValue(true));
    apDevs.Add(wifiHelper.Install(wifiPhy, wifiMac, accessPointC.Get(1)));
    wifiMac.SetType('ApWifiMac', 'Ssid', SsidValue(ssid3), 'EnableBeaconJitter', BooleanValue(true));
    apDevs.Add(wifiHelper.Install(wifiPhy, wifiMac, accessPointC.Get(2)));
    wifiMac.SetType('ApWifiMac', 'Ssid', SsidValue(ssid4), 'EnableBeaconJitter', BooleanValue(true));
    apDevs.Add(wifiHelper.Install(wifiPhy, wifiMac, accessPointC.Get(3)));
end

if(strcmp(scenarioComplexity,'simple'))
    ssid = Ssid('DemoSSID');
    wifiHelper.SetRemoteStationManager(staManager);
    % Install PHY and MAC over all the stations & APs
    wifiMac.SetType ('StaWifiMac', 'Ssid', SsidValue(ssid));
    staDevs = wifiHelper.Install(wifiPhy, wifiMac, stationC);
    
    wifiHelper.SetRemoteStationManager(apManager);
    wifiMac.SetType('ApWifiMac', 'Ssid', SsidValue(ssid), 'EnableBeaconJitter', BooleanValue(true));
    apDevs = wifiHelper.Install(wifiPhy, wifiMac, accessPointC);
end

% Set location and Install mobility model (no mobility)
mobility1 = MobilityHelper();
mobility2 = MobilityHelper();

% Set location and mobility for Stations
mobility1.SetPositionAllocator ('GridPositionAllocator',...
    'MinX', DoubleValue(0),...
    'MinY', DoubleValue(0),...
    'DeltaX', DoubleValue(interStationDistance),...
    'DeltaY', DoubleValue(interStationDistance),...
    'GridWidth', UintegerValue(stationGridWidth),...
    'LayoutType', StringValue('RowFirst'));

% Set location and mobility for AP
mobility2.SetPositionAllocator ('GridPositionAllocator',...
    'MinX', DoubleValue(interStationDistance/2),...
    'MinY', DoubleValue(interStationDistance/2),...
    'DeltaX', DoubleValue((stationGridWidth-2)*interStationDistance),...
    'DeltaY', DoubleValue((stationGridWidth-2)*interStationDistance),...
    'GridWidth', UintegerValue(apGridWidth),...
    'LayoutType', StringValue('RowFirst'));

mobility1.SetMobilityModel (mobilityModel);
mobility2.SetMobilityModel (mobilityModel);
mobility1.Install (stationC);
mobility2.Install (accessPointC);
% plots the STA nodes positions
plotNodePositions(0, 0, interStationDistance, interStationDistance,...
    stationGridWidth, 'RowFirst', numStations, 'STA');
hold on;
% plots the AP nodes positions
plotNodePositions(interStationDistance/2, interStationDistance/2, (stationGridWidth-2)*interStationDistance,...
    (stationGridWidth-2)*interStationDistance,...
    apGridWidth, 'RowFirst', numAPs, 'AP');
hold off;

%% Install Raw socket applications between nodes.
packetSocket = PacketSocketHelper();
packetSocket.Install(stationC);
packetSocket.Install(accessPointC);

startTimes = randi([1 5],4,5);
stopTimes = randi([6 10],6,7);

if (strcmp(scenarioComplexity,'complex'))
    srcId = [0 9 18 27];
    dstId = [8 4 31 29];
    startTime = [2 1 1 3];
    stopTime  = [4 3 2 4];
    for i = 1:noOfApplications
        installApplications(stationC,staDevs,srcId(i),dstId(i),startTime(i),stopTime(i));
    end
    
elseif (strcmp(scenarioComplexity,'simple'))
    srcId = [0 1];
    dstId = [1 0];
    startTime = [2 3];
    stopTime  = [3 4];
    for i = 1:noOfApplications
        installApplications(stationC,staDevs,srcId(i),dstId(i),startTime(i),stopTime(i));
    end
end

%% Connect Traces for collecting statistics

Config.Connect('WifiMac', 'MacTx', @statsCallback);
Config.Connect('WifiMac', 'MacRx', @statsCallback);
Config.Connect('WifiMac', 'MacRxDrop', @statsCallback);
Config.Connect('WifiPhy', 'Tx', @statsCallback);
Config.Connect('WifiPhy', 'RxOk', @statsCallback);
Config.Connect('WifiPhy', 'RxError', @statsCallback);

for i=1:numStations + numAPs
    stats.getSetStats(i, 'MacTx', 0);
    stats.getSetStats(i, 'MacRx', 0);
    stats.getSetStats(i, 'MacRxDrop', 0);
    stats.getSetStats(i, 'PhyTx', 0);
    stats.getSetStats(i, 'PhyRxOk', 0);
    stats.getSetStats(i, 'RxError', 0);
end

% Set the Simulation run time. The simulation stops at this time.
Simulator.Stop(simTime);
mexAttributeDumper('output6.xml');
disp('Simulation Started ................');
% Run the Simulation
Simulator.Run();

% Dump statistics to a file for all the stations and then APs
fileID  = fopen('stats_file.txt', 'w');
for i=1:numStations+numAPs
    fprintf(fileID, '%d %d %d %d %d %d\n', stats.getSetStats(i, 'MacTx'), ...
        stats.getSetStats(i, 'MacRx'), stats.getSetStats(i,'MacRxDrop'), ...
        stats.getSetStats(i, 'PhyTx'), stats.getSetStats(i, 'PhyRxOk'),...
        stats.getSetStats(i, 'RxError'));
end

%% Deinitialization
Simulator.Destroy();
deinitNs3Interface();
clear all;
disp('**** Simulation Completed *****');


%% Function for installing Raw socket applications between nodes
% Function to install Applications between given stations(srcId to dstId)
% at given time(from startTime to endTime).
function installApplications(stationC,staDevs,srcId,dstId,startTime,endTime)

socket = PacketSocketAddress();
% Configure source and destination address for first socket
socket.SetSingleDevice(staDevs, srcId); % Set source address
socket.SetPhysicalAddress(staDevs, dstId); % Set destination address
socket.SetProtocol(1);

% create on/off application for sockets.
onoff = OnOffHelper('PacketSocketFactory', GetAddressOperator(socket));
onoff.SetConstantRate ('1Mb/s');

% TODO: Abstract the strings.
onoff.SetAttribute('OnTime', StringValue('ns3::ConstantRandomVariable[Constant=0.7]'));
onoff.SetAttribute('OffTime', StringValue('ns3::ConstantRandomVariable[Constant=0.3]'));

% Install on/off applications over node-0 and node-1
app = onoff.Install(stationC.Get(srcId));
% Configure time at which  on/off applications have to start & stop
app.Start(startTime);
app.Stop(endTime);

end
