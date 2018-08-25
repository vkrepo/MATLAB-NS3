%        HAZARD WARNING EXAMPLE WITH VEHICLES AND A HAZARD
% -------------------------------------------------------------------------
%
%             |__|__|__|__|__|__|__|__|__|__|__|
%             |__|__|__|__|__|__|__|__|__|__|__|
%             |__|__2__|__|__|__|__*__|__|__|__|
%             |__|__|__|__|__|__|__|__|__6__|__|
%             |__|__|__3__|__|__4__|__|__|__|__|
%             |  |  |  |  |  |  |  |  |  |  |  1
%
% This example illustrates the hazard warning scenario on manhattan grid.
% Manhattan grid is configured with: number of horizontal and vertical
% blocks, street length and street width. In this scenario there are few
% regular vehicles with configured journeys as a [source road, destination
% road] pairs. During the simulation run, a hazard(broken down vehicle) pops
% up one of the roads. The routing algorithm assigns route to vehicles such
% that they pass through the hazard. Hazard transmits warning packets with
% a configurable periodicity. Vehicles dynamically find themselves an
% alternate route (if possible), if they receive warning packet indicating
% that the next road in their respective route has hazard. If a vehicle
% doesn't get the hazard warning in time, it might end up taking the road
% with hazard. In the worst case it might collide with the hazard if it
% does not get any warning even after it moves on the road with hazard.
% These failure situations can happen, due to high vehicle speed or low
% periodicity of hazard warning messages (or poor / busy channel, ...).
% -------------------------------------------------------------------------
% The main simulation loop is run in NS-3, using mex call. The
% functionality / features implemented in MATLAB are:
% * Manhattan grid road topology creation
% * Vehicular routing and re-routing
% * WSMP Traffic application installation, packet Creation
% * Mobility Intelligence
% * Visualization

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

%% Adding paths
% Path of Mex wrappers, bindings, manhattan-topology model and
% traces respectively
addpath(genpath(fullfile(pwd,'../../native/mexBindings')));
addpath(genpath(fullfile(pwd,'../../mlCode/mlWrappers')));
addpath(genpath(fullfile(pwd,'manhattanTopologyModel')));
addpath(genpath(fullfile(pwd,'traces')));

%% Cleaning if at all last iteration did not exit cleanly
clc;
close all;
clear;
Simulator.Destroy();
clear functions;

%% Scenario Configuration Section

% Configure simulation run time (In seconds)
simTime = 50;

% Manhattan-grid configuration
hBlocks = 4 ; % Number of horizontal blocks
vBlocks = 4 ; % number of vertical blocks
streetWidth = 8 ; % Street width
streetLen = 100 ; % Block size defines street length

% Define Journey of a regular vehicle in terms of source and destination
% roads. Each road is identified by a 3-tuple: direction, block's
% horizontal Index, block's vertical index. The horizontal index and
% vertical index uniquely identify a block while direction is required to
% identify the particular road as a block can be surrounded by 4 types of
% roads characterized by their direction: +x, -x, +y, -y. A sample journey
% could be : {'+x' 3 2} to {'+y' 1 3}. It means vehicle needs to travel
% from '+x' directional road of the 3th block in the 2nd row (from bottom)
% of grid to '+y' directional road of the 1st block in the 3rd row (from
% bottom) of the grid. The number of regular vehicles is decided by number
% of source, destination pairs in this list.

% NOTE: As our manhattan grid implementation does not have roads at the
% boundary of grid, some road identifiers are not valid. For a MxN
% manhattan grid the invalid road identifiers are:
% {'+y', 1, k}
% {'-y', M, k}
% {'+x', k, N}
% {'-x', k, 1}
% Here k can be  any number 1 to M (if it is horizontal index of block) or
% 1 to N (if it is vertical index of block).

journeyList = {
    % Source Road      % Destination Road
    { {'+x' 4 2}        {'+y' 2 4 } } %  Vehicle 1 journey
    { {'-y' 1 3}        {'+y' 4 3 } } %  Vehicle 2 journey
    { {'+y' 1 3}        {'-y' 2 1 } } %      .
    { {'+y' 2 1}        {'-y' 1 4 } } %      .
    { {'+x' 3 1}        {'-y' 3 4 } } %      .
    { {'-x' 1 2}        {'-x' 2 3 } } %      .
    { {'+x' 4 1}        {'-x' 1 4 } } %      .
    { {'-y' 2 1}        {'+x' 2 2 } } %      .
    };



% Configure speed of each regular vehicle. Vehicle moves with speed equal
% to the value at index equal to its ID in this matrix. If this matrix does
% not define speed for all, a random value between 15 to 20 is
% chosen.
speedMatrix = [19 20 22 21 21 21 20 22];


% Hazard appears on this road.
hazardLoc = {'+y' 3 3}; %Define hazrd location

hazardEntryT = 5000; % Hazard occurence timestamp in milliseconds.
hazardWarningPeriodicity = 150; % In milliseconds

% Set number of Rogue vehicles
numRogueVehicles = 40;
maxRogueVehSpeed = 20; % m/s. Every rogue vehicle is given a constant speed
%limited by this value


% Regular vehicle physical layer properties.
vehTxGain = 6;
vehRxGain = 1;
vehRxNoiseFigure = 7;

% Hazard (Broken Down vehicle) physical layer properties
hazardTxGain = 1;
hazardRxGain = 1;
hazardRxNoiseFigure = 7;

% Rogue Vehicle physical layer properties.
rogueTxGain = 6;
rogueRxGain = 1;
rogueRxNoiseFigure = 7;


%Channel Properties
pathLossExponent = 3;
referenceDistance = 1; %meters
%referenceLoss = 46.6777; % dB
referenceLoss = 49.3; % dB

% All the vehicles (Regular & Rogue) transmit with this periodicity
positionBeaconPeriodicity = 100; %millisecs


%% Create manhattan topology with configured values
topology = manhattanTopology; % Creating manhattan topology object
createManhattanGrid(topology, hBlocks, vBlocks, streetWidth, streetLen);
nodeListInfo.getSetTopology(topology);

%% Find routes based on source and destination passing through hazard
routeVector = scenarioSetup.createRoutes(journeyList, hazardLoc);

%% Initialize the NS3-Mex Interface to maintain state of the simulation.
initNs3Interface();

%% Create regular vehicle container and add vehicles to it.
% Number of vehicles equal to number of journeys provided.
numVehicles = length(routeVector);
regVehContainer = scenarioSetup.createVehicles(numVehicles);


%% Create and install protocol stack including Channel on regular vehicles.
% Create Phy with configured values.
phyConfig.vehTxGain = vehTxGain;
phyConfig.vehRxGain = vehRxGain;
phyConfig.vehRxNoiseFigure = vehRxNoiseFigure;
wavePhy = scenarioSetup.createPhy(phyConfig);

% Create Channel with configured values and associate it with Phy
channelConfig.pathLossExponent = pathLossExponent;
channelConfig.referenceDistance = referenceDistance;
channelConfig.referenceLoss = referenceLoss;
channel = scenarioSetup.associateChannelWithPhy(wavePhy, channelConfig);

% Create default WAVE Mac
waveMac = scenarioSetup.createDefaultWaveMac();

% Install WAVE stack on all regular vehicles.
netDevices = scenarioSetup.installWaveStack(wavePhy, waveMac, regVehContainer);

% Register RX callback on vehicles.
SocketInterface.RegisterRXCallback(netDevices, @WaveRXCallback);


%% Attach routes, mobility, packet application to regular vehicles.
% Install mobility on vehicles according to their respective routes. 'WSMP
% position beacon' application is installed on each of them and
% corresponding event schedule governing the periodicity of packets is also
% installed.
vehConfig.numVehicles = numVehicles;
vehConfig.regVehContainer = regVehContainer;
vehConfig.speedMatrix = speedMatrix;
vehConfig.roadOffset = 0;
vehConfig.routeVector = routeVector;
vehConfig.pktType = 'positionBeacon';
vehConfig.vehType = 'regular';
vehConfig.pktPeriodicity = positionBeaconPeriodicity;

scenarioSetup.setMobilityAndWSMPApp(vehConfig);


%% Install rogue vehicles in the scenario for creating network interference
% Rogue vehicles are created, WAVE stack is installed on them.
% For each rogue vehicle:
% ---Mobility is installed such that rogue vehicles always hover in vicinity of
% hazard.
% ---WSMP packet application is installed for creating network interference.

rogueVehConfig.numVehicles = numRogueVehicles;
rogueVehConfig.wavePhy = wavePhy;
rogueVehConfig.txGain = rogueTxGain;
rogueVehConfig.rxGain = rogueRxGain;
rogueVehConfig.rxNoiseFigure = rogueRxNoiseFigure;
rogueVehConfig.waveMac = waveMac;
rogueVehConfig.hazardLoc = hazardLoc;
rogueVehConfig.maxVehSpeed = maxRogueVehSpeed;
rogueVehConfig.pktPeriodicity = positionBeaconPeriodicity;

rVehC = scenarioSetup.installRogueVehicles(rogueVehConfig);


%% Configure hazard related parameters and schedule hazard creation
hazardConfig.warningPeriodicity = hazardWarningPeriodicity; % Periodicity of warning packet in milliseconds.
hazardConfig.offsetFromStart = 0.8*streetLen;  % Hazard location offset from start of road
hazardConfig.entryTime = hazardEntryT; % In milliseconds.
hazardRepairT = simTime*1000 - hazardEntryT; %Time required to repair the hazard in milliseconds.
%Here making sure that it stays till the end of
%simulation.
hazardConfig.repairTime = hazardRepairT; % In milliseconds
hazardConfig.location = hazardLoc;
hazardConfig.phy = wavePhy;
hazardConfig.txGain = hazardTxGain;
hazardConfig.rxGain = hazardRxGain;
hazardConfig.rxNoiseFigure = hazardRxNoiseFigure;
hazardConfig.mac = waveMac;

scenarioSetup.configureHazard(hazardConfig);


%% Set up Visualization Logging
config.hBlocks = hBlocks;
config.vBlocks = vBlocks;
config.streetWidth = streetWidth;
config.streetLen = streetLen;
config.rVehC = rVehC;
config.numVehicles = numVehicles;
config.numRogueVehicles = numRogueVehicles;
config.logPeriodicity = 500;
scenarioSetup.setUpVisualizationAndTraces(config);

%% Run simulation
Simulator.Stop(simTime);
disp('Simulation Started ................');
Simulator.Run();

%% Deinitialization
% Delete all handle objects created during simulation.
args.numVehicles = numVehicles;
args.numRogueVehicles = numRogueVehicles;
args.topology = topology;
if(numRogueVehicles>0)
    args.rogueVehC = rVehC;
end
scenarioSetup.deleteHandleObjects(args);

Simulator.Destroy();
deinitNs3Interface();
clear all;
disp('**** Simulation Completed *****');


