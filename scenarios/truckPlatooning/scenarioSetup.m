classdef scenarioSetup
    % Definitions of function abstracted in scenario.m
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    methods(Static)
        % Create and returns vehicle container
        function vehContainer = createVehicles(numVehicles)
            vehContainer = NodeContainer();
            vehContainer.Create(numVehicles);
        end
        
        % Create WAVE phy with configured values
        function wavePhy = createPhy(phyConfig)
            wavePhy = YansWavePhyHelper.Default();
            wavePhy.Set('TxGain', DoubleValue(phyConfig.vehTxGain));
            wavePhy.Set('RxGain', DoubleValue(phyConfig.vehRxGain));
            wavePhy.Set('RxNoiseFigure', DoubleValue(phyConfig.vehRxNoiseFigure));
        end
        
        % Create channel and associate it with phy
        function wifiChannel = associateChannelWithPhy(wavePhy, channelConfig)
            % Create channel object, set the propagation model and its configuration.
            wifiChannel = YansWifiChannelHelper();%.Default();
            wifiChannel.SetPropagationDelay('ConstantSpeedPropagationDelayModel');
            wifiChannel.AddPropagationLoss('LogDistancePropagationLossModel', ...
                'Exponent', DoubleValue(channelConfig.pathLossExponent),...
                'ReferenceDistance', ...
                DoubleValue(channelConfig.referenceDistance), ...
                'ReferenceLoss',DoubleValue(channelConfig.referenceLoss));
            
            % Uncomment block below to add range propagation loss model on top of ....
            %  log based propagation loss model.
            %{
transmissionRange = 100;
wifiChannel.AddPropagationLoss('RangePropagationLossModel', 'MaxRange', ...
DoubleValue(transmissionRange));
            %}
            % Associate Phy and Channel
            wavePhy.SetChannel(wifiChannel.Create());
        end
        
        % Create Default Wave MAC
        function waveMac = createDefaultWaveMac()
            % Create QoS Wave MAC
            waveMac = QosWaveMacHelper.Default();
        end
        
        % Intall WAVE stack on vehicles and return the createt net-devices
        function netDevices = installWaveStack(wavePhy, waveMac, vehContainer)
            % Create Wave Helper object and set the rate adaption algorithm
            waveHelper = WaveHelper.Default();
            
            wifiMode = 'OfdmRate6MbpsBW10MHz';
            waveHelper.SetRemoteStationManager('ConstantRateWifiManager', 'DataMode',...
                StringValue(wifiMode), 'NonUnicastMode',...
                StringValue(wifiMode));
            
            % Install wave stack on vehicles
            netDevices = waveHelper.Install(wavePhy, waveMac, vehContainer);
        end
        
        % Register RX callback on vehicles
        function registerRXCallback(netDevices, funcHandle)
            SocketInterface.RegisterRXCallback(netDevices, funcHandle);
        end
        
        % Set-up mobility and WSMP Packet application on platoon trucks
        function setMobilityAndWSMPApp( platoonConfig )
            %% Assign lanes to trucks
            % Route of trucks as  lane Ids: As in this scenario truck is going to be
            % on a single lane all throughout, each route has single lane ID
            platoonLane = platoonConfig.lane;
            routeTable(1:platoonConfig.numTrucks) = platoonLane;
            
            %% Install mobility on trucks and start platoon beacon application on them.
            mobilityModel = 'ConstantAccelerationMobilityModel';
            for index = 1:platoonConfig.numTrucks
                node = platoonConfig.truckContainer.Get(index-1);
                truckId = node.GetId();
                routeInfo = vehicularRoute; % Instantiate route object
                routeInfo.setRoute(truckId+1, routeTable(index)); % create route
                
                % Storing route object for truck at index defined by vehicle Id in an
                % array of route objects. As node id starts from 0 (and index in MATLAB
                % starts from 1), adding 1 to nodeId.
                nodeListInfo.routeObj(truckId+1, routeInfo);
                
                vehicularMobility.setMobilityModel(truckId, mobilityModel);
                mobIntel = mobilityIntelligence.getSetMobIntelObject();
                % Initial distance offset of trucks from start of the lane. Truck ids
                % starts from 1 and it is given to platoon leader. Last truck is placed
                % at start of lane hence zero offset. Initially all trucks are
                % separated by minStandstill gap
                offset = (platoonConfig.numTrucks - truckId) * (mobIntel.truckLength + ...
                    mobIntel.minStandstillGap);
                
                args.topology = platoonConfig.topology;
                args.nodeId = truckId;
                args.routeInfo = routeInfo;
                args.mm = mobilityModel;
                args.speed = 0; % all platoon trucks are initially at rest.
                args.offset = offset;
                
                % Only platoon leader to be given initial acceleration.
                if(index == 1)
                    args.acceleration = mobIntel.normalAccel;
                else
                    args.acceleration = 0;
                end
                vehicularMobility.setVehiclePosAndVelocity(args);
                
                % Setting up platoon beacon application on trucks.
                args.pType = 'platoonBeacon';
                args.nodeId = truckId;
                args.rInfo = routeInfo;
                args.mm = mobilityModel;
                args.periodicity = platoonConfig.platoonBeaconFrequency;
                args.platoonFailureCommGap = platoonConfig.platoonFailureCommGap;
                
                %Making the platoon trucks start transmitting 'platoon beacons' at
                %different times by making start time a function of id of truck.
                appStartTime =  (args.periodicity*(truckId+1))/7.5;
                Simulator.Schedule('WSMPTraffic.runWSMPApp', appStartTime, args);
            end
        end
        
        
        % Create and install WAVE stack on RSU. Install WSMP app to send
        % periodic 'rough patch warning'
        function rsuContainer = installRSU(config)
            rsuContainer = NodeContainer();
            rsuContainer.Create(1);
            config.wavePhy.Set('TxGain', DoubleValue(config.txGain));
            config.wavePhy.Set('RxGain', DoubleValue(config.rxGain));
            config.wavePhy.Set('RxNoiseFigure', DoubleValue(config.rxNoiseFigure));
            waveHelper = WaveHelper.Default();
            rsuDeviceC = waveHelper.Install(config.wavePhy, config.waveMac, ...
                rsuContainer);
            rsu = rsuContainer.Get(0);
            rsuId = rsu.GetId();
            vehicularMobility.setMobilityModel(rsuId, 'ConstantPositionMobilityModel');
            laneInfo = config.topology.getLaneInfo(config.platoonLane);%Place on same lane as platoon.
            position = laneInfo.startPosition + [config.roughPatchStart (-config.laneWidth/2) 0];
            mobModelObj = rsu.GetObject('ConstantPositionMobilityModel');
            % sets RSU position
            mobModelObj.SetPosition(position);
            
            % Configure 'rough patch' warning application and install it.
            args.pType = 'roughPatchWarning';
            args.nodeId = rsuId;
            args.rInfo = config.platoonLane;
            args.mm = 'ConstantPositionMobilityModel';
            args.periodicity = config.roughPatchWarningPeriodicity; % In milliseconds
            args.roughPatchLen = config.roughPatchLen;
            args.speedLim = config.roughPatchSpeedLim;
            %Scheduling start time proportional to Id
            appStartTime =  (args.periodicity*(rsuId+1))/5.5;
            Simulator.Schedule('WSMPTraffic.runWSMPApp', appStartTime, args);
        end
        
        % Set-up mobility and WSMP Packet application on rogue vehicles
        function [rogueVehC numRogueVeh] = installRogueVehicles(config)
            % initialize counts
            lane2VehicleCount = 0;
            lane3VehicleCount = 0;
            lane4VehicleCount = 0;
            if(config.laneCount >=2) % checking if highway even has 2 lanes
                lane2VehicleCount = size(config.rogueVehPosLane2, 2);
                rogueVLane2(1:lane2VehicleCount) = 2; % Assigning lane 2
                if(config.laneCount >=3) % checking if highway even has 3 lanes
                    lane3VehicleCount = size(config.rogueVehPosLane3, 2);
                    rogueVLane3(1:lane3VehicleCount) = 3; % Assigning lane 3
                    if(config.laneCount >=4) % checking if highway even has 4 lanes
                        lane4VehicleCount = size(config.rogueVehPosLane4, 2);
                        rogueVLane4(1:lane4VehicleCount) = 4; % Assigning lane 4
                    end
                end
            end
            
            %Total non-platoon vehicle count in other lanes
            numRogueVeh = lane2VehicleCount + lane3VehicleCount + lane4VehicleCount;
            
            % Installing WAVE stack on all other non-platoon vehicles
            if(numRogueVeh > 0)
                rogueVehC = NodeContainer();
                rogueVehC.Create(numRogueVeh);
                config.wavePhy.Set('TxGain', DoubleValue(config.txGain));
                config.wavePhy.Set('RxGain', DoubleValue(config.rxGain));
                config.wavePhy.Set('RxNoiseFigure', DoubleValue(config.rxNoiseFigure));
                waveHelper = WaveHelper.Default();
                rogueVDevices = waveHelper.Install(config.wavePhy, config.waveMac, rogueVehC);
                %Register Rx callback on all non-platoon vehicles
                %SocketInterface.RegisterRXCallback(rogueVDevices, @WaveRXCallback);
            end
            
            % For all non-platoon vehicles in other lanes installing mobility ...
            % and dummy beacon application to create interference for platoon.
            mobilityModel = 'ConstantAccelerationMobilityModel';
            for index = 1:numRogueVeh
                node = rogueVehC.Get(index-1);
                vehicleId = node.GetId();
                routeInfo = vehicularRoute; % Instantiate route object
                if(index > (lane2VehicleCount + lane3VehicleCount)) %lane 4 vehicle
                    localIndex = index- (lane2VehicleCount + lane3VehicleCount);
                    routeInfo.setRoute(vehicleId + 1, rogueVLane4(localIndex));
                    % Distance from start of the lane
                    offset = config.rogueVehPosLane4(lane4VehicleCount-(localIndex-1));
                elseif(index > lane2VehicleCount) %lane 3 vehicle
                    localIndex = index - lane2VehicleCount;
                    routeInfo.setRoute(vehicleId + 1, rogueVLane3(localIndex));
                    % Distance from start of the lane
                    offset = config.rogueVehPosLane3(lane3VehicleCount-(localIndex-1));
                else  % lane 2  vehicle
                    routeInfo.setRoute(vehicleId + 1, rogueVLane2(index));
                    % Distance from start of the lane
                    offset = config.rogueVehPosLane2(lane2VehicleCount-(index-1));
                end
                nodeListInfo.routeObj(vehicleId+1, routeInfo);
                vehicularMobility.setMobilityModel(vehicleId, mobilityModel);
                
                args.topology = config.topology;
                args.nodeId = vehicleId;
                args.routeInfo = routeInfo;
                args.mm = mobilityModel;
                args.speed = config.rogueVehSpeed; % Speed of non-platoon vehicles
                args.offset = offset;
                args.acceleration = 0;
                vehicularMobility.setVehiclePosAndVelocity(args);
                
                % Configure packet application and install it.
                args.pType = 'dummyBeacon';
                args.rInfo = routeInfo;
                args.mm = mobilityModel;
                args.periodicity = config.rogueVehPktInterval;
                
                %Scheduling sending of first position beacon at different times on
                %each vehicle proportion to their ids
                appStartTime = ( args.periodicity*(vehicleId+1))/5.5;
                Simulator.Schedule('WSMPTraffic.runWSMPApp', ...
                    appStartTime, args);
            end
        end
        
        
        % Set up visualization
        function setUpVisualizationAndTraces(config)
            visualizerTraces.initLog(); % Create log files
            
            % Write config log file
            configParam.platoonBeaconFreq = config.platoonBeaconFreq;
            configParam.platoonFailureCommGap = config.platoonFailureCommGap;
            configParam.rogueVPktFreq = config.rogueVehPktInterval;
            configParam.txGainPlatoon = config.platoonTxGain;
            configParam.txGainRogueV = config.rogueVehTxGain;
            configParam.roughPatchSpeedLim = config.roughPatchSpeedLim;
            mobIntel = mobilityIntelligence.getSetMobIntelObject();
            configParam.maxSpeedLim = mobIntel.speedLimit;
            configParam.minHeadway = mobIntel.minTimeHeadway;
            configParam.maxHeadway = mobIntel.maxTimeHeadway;
            
            visualizerTraces.logConfigParams(configParam);
            
            %Log highway config
            visualizerTraces.logHighwayConfig(config.laneCount, config.laneWidth, ...
                config.highwayLength, config.roughPatchStart, config.roughPatchLen);
            
            logArgs.numTrucks= config.numTrucks;
            logArgs.truckLen = mobIntel.truckLength;
            logArgs.rogueVLength = 3;
            logArgs.rogueVehCount = config.numRogueVeh;
            
            if(config.numRogueVeh>0)
                node = config.rogueVehC.Get(0);
                logArgs.rogueVehId = node.GetId(); % Id of first non-platon vehicle
            end
            rsu = config.rsuC.Get(0);
            logArgs.rsuId  = rsu.GetId(); % Id of RSU
            
            % Log all the scenario objects: trucks , other vehicles, Road-side-unit
            visualizerTraces.logScenarioObjects(logArgs);
            
            % Log all scenario events and statistics to be later used for visualization
            logArgs.logPeriodicity = config.logPeriodicity;
            visualizerTraces.logEventsAndStats(logArgs);
            
            %% Connect Traces (callbacks) for notification
            % Other traces can be enbaled too, but at the cost of simulation run time
            %Config.Connect('WaveMac', 'MacTx', @statsCallback);
            %Config.Connect('WaveMac', 'MacRx', @statsCallback);
            %Config.Connect('WaveMac', 'MacRxDrop', @statsCallback);
            %Config.Connect('WavePhy', 'Tx', @statsCallback);
            %Config.Connect('WavePhy', 'RxOk', @statsCallback);
            Config.Connect('WavePhy', 'RxError', @statsCallback);
            
        end
        
        % Delete all handle objects created
        function deleteHandleObjects(args)
            % Delete all lanes
            for i=1:args.topology.laneCount
                delete(args.topology.lanes(i));
            end
            
            % Delete topology
            delete(args.topology);
            
            % Delete route objects for platoon
            for i=1:args.numTrucks
                delete(nodeListInfo.routeObj(i));
            end
            
            if(args.numRogueVehicles > 0)
                firstRogueVeh = args.rogueVehC.Get(0);
                firstRogueVehId = firstRogueVeh.GetId();
            end
            % Deltete route objects for rogue vehicles
            for i=1:args.numRogueVehicles
                index = firstRogueVehId+i;
                delete(nodeListInfo.routeObj(index));
            end
            
        end
    end
end