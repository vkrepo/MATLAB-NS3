%        TRUCK PLATOONING EXAMPLE WITH ROUGH PATCH ON ROAD
% -------------------------------------------------------------------------
% The Scenario has a preformed platoon of trucks moving on a highway lane
% dedicated for the platoon. The other adjacent lanes in the highway have
% other vehicles moving without any  mobility intelligence but they do
% transmit packets which can create interference for platoon trucks thereby
% incurring communication losses. A rough stretch of road is modeled on the
% platoon lane which has a max-speed limit. A Road-Side-Unit is placed at
% the start of rough patch which broadcasts information about it. Platoon
% leader reads this packet and decelerates in order to adhere to the speed
% limit of rough patch and the other trailing trucks just blindly follow
% without ever knowing the reason of deceleration. After crossing rough
% patch platoon again accelerates.
% -------------------------------------------------------------------------
% The main simulation loop is run in NS-3, using mex call. The
% functionality / features implemented in MATLAB are:
% * Road topology creation
% * WSMP Traffic application installation, packet Creation
% * Mobility Intelligence based on received packets.
% * Statistics collection
% * Visualization

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

%% Adding path of Mex wrappers, bindings, highway-topology model and traces.
addpath(genpath(fullfile(pwd,'../../native/mexBindings')));
addpath(genpath(fullfile(pwd,'../../mlCode/mlWrappers')));
addpath(genpath(fullfile(pwd,'highwayTopologyModel')));
addpath(genpath(fullfile(pwd,'traces')));

%% Cleaning if at all last iteration did not exit cleanly
clc;
close all;
clear;
Simulator.Destroy();
clear functions;

%% Scenario configuration section
simTime = 80; % Simulation Run time in seconds

% Configure highway topology along with rough patch.
laneCount = 4;  % Number of lanes in the highway
laneWidth = 10; % Width of each lane in metres
highwayLength = 6000; % Metres
roughPatchStart = 500; % Metres
roughPatchLen = 200; % Metres
roughPatchSpeedLim = 5; % Metres per second

% Platoon Configuration
numTrucks = 5; % Platoon length in terms of number of trucks
minTimeHeadway = 0.1; % In seconds. A truck needs to maintain this bare minimum
% time gap with respect to its preceding platoon truck
% to avoid being in the danger zone.
maxTimeHeadway = 0.5; % In seconds. Any two trucks should be within this
% time gap of each other to limit platoon length.
maxAcceleration = 4; % in metres per second square
maxDeceleration = 8; % in metres per second square
minStandstillGap = 3; % in metres. Initially trucks at rest are this much apart.
normalAccel = 2; % Initially platoon leader starts off with this acceleration
% which eventually sets the whole platoon in motion
speedLimit = 25; % metres per second. Max speed limit for platoon.
truckLength = 10; % metres.

allowRogueVeh = 1; % Set this to 0 for no traffic in other lanes, otherwise 1.

% Add all non-platoon traffic to 2nd, 3rd and 4th lane of the highway
% at the positions specified in the below arrays. Number of vehicles in
% those lanes will be governed by respective size of these arrays. All this
% comes into effect if 'allowRogueVeh' flag set to 1.
rogueVehPosLane2 = [20 45 63 84 105 128];% 145 162 175 210 240 275 305 340 375 ...
%400 435 475 520 535 560 580 605 630 659];
rogueVehPosLane3 = [25 45 59 77 95];% 120 150 170 198 235 265 297 325 ...
%345 369 380 410 430 445 475 490 550 570 600 618];
rogueVehPosLane4 = [25 48 78 98 125 150];% 168 195 220 245 275 300 330 ...
%363 380 410 450 480 520 555 580 600 610 630];

% Set constant speed to all non-platoon vehicles.
rogueVehSpeed = 9;

%Phy configuration of platoon trucks
platoonTxGain = 1;
platoonRxGain = 1;
platoonRxNoiseFigure = 7;

%Phy configuration of Road-Side-unit
RSUTxGain = 1;
RSURxGain = 1;
RSURxNoiseFigure = 7;

%Phy configuration of non-platoon vehicles
rogueVehTxGain = 6;
rogueVehRxGain = 1;
rogueVehRxNoiseFigure = 7;

% Configuration of 'Log-distance based' channel loss model.
pathLossExponent = 2;
referenceDistance = 1; %metres
referenceLoss = 46.6777; % dB

% Scenario has 3 types of packets: (i)Platoon-beacons sent by  platoon trucks
% (ii) 'Rough patch Warning' packet sent by Road-Side-Unit.
% (iii) 'Dummy beacon' packets sent by non-platoon vehicles.
% Configure the periodicty (in milliseconds) of the defined packet types.
platoonBeaconPeriodicity = 100;
roughPatchWarningPeriodicity = 500;
rogueVehPktPeriodicity = 100;

%Define the platoon-failure condition.
platoonFailureCommGap = 500; % In milliseconds. If a platoon truck does not
% receive any platoon beacon from its preceding
% truck for this much amount of time, it stops
% and it is treated as failure of platooning.

% Platoon leader decelerates on receiving a 'rough patch' warning only if
% rough patch is within this range.
roughPatchRelevanceDist = 100; % metres

% Set periodicity of writing visualization logs. Lesser value
% makes the visulization look smooth/finer but at the cost of simulation
% run time
logPeriodicity = 150; %millisecs

%% Initialize the MATLAB-NS3 interface to maintain state of the simulation.
initNs3Interface();

%% Create highway topology with configured values
topology = highwayTopology;
createHighwayTopology(topology, laneCount, laneWidth, highwayLength);

%% Create a node(truck) container of platoon trucks.
truckContainer = scenarioSetup.createVehicles(numTrucks);
%% Create and install protocol stack including Channel on platoon trucks.
% Create Phy with configured values.
phyConfig.vehTxGain = platoonTxGain;
phyConfig.vehRxGain = platoonRxGain;
phyConfig.vehRxNoiseFigure = platoonRxNoiseFigure;
wavePhy = scenarioSetup.createPhy(phyConfig);

% Create Channel with configured values and associate it with Phy
channelConfig.pathLossExponent = pathLossExponent;
channelConfig.referenceDistance = referenceDistance;
channelConfig.referenceLoss = referenceLoss;
channel = scenarioSetup.associateChannelWithPhy(wavePhy, channelConfig);

% Create default WAVE Mac
waveMac = scenarioSetup.createDefaultWaveMac();

% Install WAVE stack on all trucks.
netDevices = scenarioSetup.installWaveStack(wavePhy, waveMac, truckContainer);


% Register Rx callback on platoon trucks
SocketInterface.RegisterRXCallback(netDevices, @WaveRXCallback);

%% Create mobility intelligence object and initialize with configured values
mobIntel =  mobilityIntelligence;
mobIntel.minTimeHeadway = minTimeHeadway;
mobIntel.maxTimeHeadway = maxTimeHeadway;
mobIntel.maxAcceleration = maxAcceleration;
mobIntel.maxDeceleration = maxDeceleration;
mobIntel.minStandstillGap = minStandstillGap;
mobIntel.normalAccel = normalAccel;
mobIntel.truckLength = truckLength;
mobIntel.roughPatchRelevanceDist = roughPatchRelevanceDist;
mobIntel.speedLimit = speedLimit;
mobilityIntelligence.getSetMobIntelObject(mobIntel);



%% Set mobilty and WSMP packet app on all platoon trucks
% -- Lane and initial position is assigned for all trucks.
% -- All the trucks except leader are given speed and acceleration as 0
% -- Platoon leader is given zero speed and initial acceleration.
% -- WSMP application which makes every truck to transmit periodic
%    'platoon beacon' is installed.
platoonConfig.numTrucks = numTrucks;
platoonLane = 1;
platoonConfig.lane = platoonLane;
platoonConfig.topology = topology;
platoonConfig.platoonBeaconFrequency = platoonBeaconPeriodicity;
platoonConfig.platoonFailureCommGap = platoonFailureCommGap;
platoonConfig.truckContainer =  truckContainer;
scenarioSetup.setMobilityAndWSMPApp(platoonConfig);


%% Create and place RSU at the start of rough patch and install warning app
RSUConfig.waveMac = waveMac;
RSUConfig.wavePhy = wavePhy;
RSUConfig.txGain = RSUTxGain;
RSUConfig.rxGain = RSURxGain;
RSUConfig.rxNoiseFigure = RSURxNoiseFigure;
RSUConfig.platoonLane = platoonLane;
RSUConfig.topology = topology;
RSUConfig.roughPatchStart = roughPatchStart;
RSUConfig.roughPatchLen = roughPatchLen;
RSUConfig.roughPatchSpeedLim = roughPatchSpeedLim;
RSUConfig.laneWidth = laneWidth;
RSUConfig.roughPatchWarningPeriodicity = roughPatchWarningPeriodicity; % In milliseconds

rsuContainer = scenarioSetup.installRSU(RSUConfig);

%% Add non-platoon traffic in other lanes, install WAVE stack on them
% For each rogue vehicle:
% ---Initial position on lanes is assigned ,Mobility is installed such that they move with
%    constant velocity
% ---WSMP packet application is installed for creating network interference.
numRogueVeh = 0; % Initialization.
if(allowRogueVeh == 1)
    rogueVConfig.rogueVehPosLane2 = rogueVehPosLane2;
    rogueVConfig.rogueVehPosLane3 = rogueVehPosLane3;
    rogueVConfig.rogueVehPosLane4 = rogueVehPosLane4;
    rogueVConfig.rogueVehSpeed = rogueVehSpeed;
    rogueVConfig.wavePhy = wavePhy;
    rogueVConfig.waveMac = waveMac;
    rogueVConfig.txGain = rogueVehTxGain;
    rogueVConfig.rxGain = rogueVehTxGain;
    rogueVConfig.rxNoiseFigure = rogueVehRxNoiseFigure;
    rogueVConfig.rogueVehPktInterval = rogueVehPktPeriodicity;
    rogueVConfig.topology = topology;
    rogueVConfig.laneCount = laneCount;
    rogueVConfig.numTrucks = numTrucks;
    
    [rogueVContainer, numRogueVeh] = scenarioSetup.installRogueVehicles(rogueVConfig);
end
%a=x;
%% Set up Visualization Logging
visualizerConfig.platoonBeaconFreq = platoonBeaconPeriodicity;
visualizerConfig.platoonFailureCommGap = platoonFailureCommGap;
visualizerConfig.rogueVehPktInterval = rogueVehPktPeriodicity;
visualizerConfig.platoonTxGain = platoonTxGain;
visualizerConfig.rogueVehTxGain = rogueVehTxGain;
visualizerConfig.roughPatchSpeedLim = roughPatchSpeedLim;
visualizerConfig.roughPatchStart = roughPatchStart;
visualizerConfig.roughPatchLen = roughPatchLen;
visualizerConfig.laneWidth = laneWidth;
visualizerConfig.laneCount = laneCount;
visualizerConfig.highwayLength = highwayLength;
visualizerConfig.numTrucks = numTrucks;
visualizerConfig.numRogueVeh = numRogueVeh;
if(numRogueVeh>0)
    visualizerConfig.rogueVehC = rogueVContainer;
end
visualizerConfig.rsuC = rsuContainer;
visualizerConfig.logPeriodicity = logPeriodicity;

scenarioSetup.setUpVisualizationAndTraces(visualizerConfig);


%% Run simulation
Simulator.Stop(simTime);
disp('Simulation Started ................');
Simulator.Run();

%% Deinitialization
visualizerTraces.deinitLogFile();
args.numTrucks = numTrucks;
args.numRogueVehicles = numRogueVeh;
args.topology = topology;
if(numRogueVeh>0)
    args.rogueVehC = rogueVContainer;
end
scenarioSetup.deleteHandleObjects(args);
Simulator.Destroy();
deinitNs3Interface();
%clear mex;
clear all;
disp('**** Simulation Completed ****');

