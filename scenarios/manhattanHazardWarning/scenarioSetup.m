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
        % Returns route for each vehicle based on respective source and
        % destination
        function routeVector = createRoutes(journeyList, hazardLoc)
            topology = nodeListInfo.getSetTopology();
            hazardRoadId = topology.getStreetIdForBlock(cell2mat(hazardLoc(2)), ...
                cell2mat(hazardLoc(3)), ...
                cell2mat(hazardLoc(1)));
            routeVector = vehicularRoute.createRouteVector(journeyList, hazardRoadId);
        end
        
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
        
        % Set-up mobility and WSMP Packet application on vehicles
        function setMobilityAndWSMPApp( vehConfig )
            mobilityModel = 'ConstantVelocityMobilityModel';
            for index = 1:vehConfig.numVehicles
                node = vehConfig.regVehContainer.Get(index-1);
                nodeId = node.GetId();
                routeInfo = vehicularRoute; % Instantiate route object
                
                % Set route for the vehicle.
                routeInfo.setRoute(index, vehConfig.routeVector{index});
                
                %Storing route object for vehicle at index defined by vehicle Id in an
                %array of route objects. As node id starts from 0 (and index in MATLAB
                %starts from 1), adding 1 to nodeId.
                nodeListInfo.routeObj(nodeId+1, routeInfo);
                vehicularMobility.setMobilityModel(nodeId, mobilityModel);
                
                % Setting mobility parmaters for all vehicles .
                mobConfig.topology = nodeListInfo.getSetTopology();
                mobConfig.nodeId = nodeId;
                mobConfig.routeInfo = routeInfo;
                mobConfig.mm = mobilityModel;
                mobConfig.acceleration = 0;
                
                %Assign speed to vehicle as initialized in speed matrix. If speed is
                %not assigned for a particular vehicle, give a random speed.
                if(size(vehConfig.speedMatrix, 2) >= (nodeId + 1))
                    mobConfig.speed = vehConfig.speedMatrix(nodeId + 1);
                else
                    mobConfig.speed = randi([15 20]);
                end
                mobConfig.offset = vehConfig.roadOffset; % Vehicle to be placed at start of road.
                vehicularMobility.setVehiclePosAndVelocity(mobConfig);
                
                
                % Configure and run WSMP(Wave short message protocol) app for sending
                % position beacons.
                WSMPArgs.pType = vehConfig.pktType;
                WSMPArgs.nodeId = nodeId;
                WSMPArgs.rInfo = routeInfo;
                WSMPArgs.mm = mobilityModel;
                WSMPArgs.periodicity = vehConfig.pktPeriodicity;
                WSMPArgs.hazardId = nodeId;
                if(vehConfig.vehType == 'regular')
                    Simulator.Schedule('WSMPTraffic.runWSMPApp', ...
                        (WSMPArgs.periodicity*(nodeId+1))/1.5, WSMPArgs);
                elseif(vehConfig.vehType == 'rogue')
                    Simulator.Schedule('WSMPTraffic.runWSMPApp', ...
                        (WSMPArgs.periodicity*(nodeId+1))/1.5, WSMPArgs);
                end
                
                
            end
        end
        
        
        function rVehC = installRogueVehicles(vehConfig)
            rVehC = 0;
            if(vehConfig.numVehicles > 0)
                rVehC = NodeContainer();
                rVehC.Create(vehConfig.numVehicles);
                
                %% Install protocol stack including Channel on regular vehicles
                % Set Phy parameters for rogue vehicles
                wavePhy = vehConfig.wavePhy;
                wavePhy.Set('TxGain', DoubleValue(vehConfig.txGain));
                wavePhy.Set('RxGain', DoubleValue(vehConfig.rxGain));
                wavePhy.Set('RxNoiseFigure', DoubleValue(vehConfig.rxNoiseFigure));
                waveHelper = WaveHelper.Default();
                % Install wave stack on rogue vehicles
                netDevices = waveHelper.Install(vehConfig.wavePhy, vehConfig.waveMac, rVehC);
                
                %% Find suitable routes for rogue vehicle around the hazard
                % All the rogue vehicle shall be placed surrounding the hazard on both
                % sides (but not on the same road as hazard) to model the packet
                % interference for hazard node and they are given circular routes such that they are
                % always moving close to hazard.
                topology = nodeListInfo.getSetTopology();
                hazardLoc = vehConfig.hazardLoc;
                hazardRoadId = topology.getStreetIdForBlock(cell2mat(hazardLoc(2)), ...
                    cell2mat(hazardLoc(3)), cell2mat(hazardLoc(1)));
                rogueRouteArgs.hazardRoadId = hazardRoadId;
                rogueRouteArgs.numVehicles = vehConfig.numVehicles;
                
                % Find the possible circular routes surrounding the hazard.
                rogueRouteVector = vehicularRoute.createRogueRouteVector(rogueRouteArgs);
                
                side1RogueNum = 0;
                side2RogueNum = 0;
                
                if(length(rogueRouteVector) == 2)  %if topology stretch is on both sides.
                    side1RogueNum = vehConfig.numVehicles/2;
                    side2RogueNum =  vehConfig.numVehicles -side1RogueNum;
                else % Topology stretch only on one side
                    side1RogueNum = vehConfig.numVehicles;
                end
                
                %% Attach routes, mobility,packet application to regular vehicles.
                
                % Adding vehicles to side-1 of hazard and installing WSMP app on them
                mobilityModel = 'ConstantVelocityMobilityModel';
                for index = 1:side1RogueNum
                    node = rVehC.Get(index-1);
                    
                    nodeId = node.GetId();
                    
                    routeInfo = vehicularRoute; % Instantiate route object
                    
                    % Set route for the vehicle.
                    routeInfo.setRoute(nodeId+1,rogueRouteVector{1});
                    
                    %Storing route object for vehicle at index defined by vehicle Id in an
                    %array of route objects. As node id starts from 0 (and index in MATLAB
                    %starts from 1), adding 1 to nodeId.
                    nodeListInfo.routeObj(nodeId+1, routeInfo);
                    vehicularMobility.setMobilityModel(nodeId, mobilityModel);
                    
                    % Setting mobility parmaters for all vehicles .
                    mobConfig.topology = topology;
                    mobConfig.nodeId = nodeId;
                    mobConfig.routeInfo = routeInfo;
                    mobConfig.mm = mobilityModel;
                    mobConfig.acceleration = 0;
                    
                    %Assign speed
                    mobConfig.speed = vehConfig.maxVehSpeed;
                    
                    mobConfig.offset = index*2; % Vehicle to be placed at start of road.
                    vehicularMobility.setRogueVehiclePosAndVelocity(mobConfig);
                    
                    
                    % Configure and run WSMP(Wave short message protocol) app for sending
                    % position beacons.
                    WSMPArgs.pType = 'positionBeacon';
                    WSMPArgs.nodeId = nodeId;
                    WSMPArgs.rInfo = routeInfo;
                    WSMPArgs.mm = mobilityModel;
                    WSMPArgs.periodicity = vehConfig.pktPeriodicity;
                    WSMPArgs.hazardId = nodeId;
                    Simulator.Schedule('WSMPTraffic.runWSMPApp', ...
                        (WSMPArgs.periodicity*(nodeId+1))/1.5, WSMPArgs);
                    
                end
                
                % Adding vehicles to other side of hazard  and installing WSMP app on them
                for index = 1:side2RogueNum
                    node = rVehC.Get(side1RogueNum + index -1);
                    
                    nodeId = node.GetId();
                    
                    routeInfo = vehicularRoute; % Instantiate route object
                    
                    % Set route for the vehicle.
                    routeInfo.setRoute(nodeId+1,rogueRouteVector{2});
                    
                    %Storing route object for vehicle at index defined by vehicle Id in an
                    %array of route objects. As node id starts from 0 (and index in MATLAB
                    %starts from 1), adding 1 to nodeId.
                    nodeListInfo.routeObj(nodeId+1, routeInfo);
                    vehicularMobility.setMobilityModel(nodeId, mobilityModel);
                    
                    % Setting mobility parmaters for all vehicles .
                    mobConfig.topology = topology;
                    mobConfig.nodeId = nodeId;
                    mobConfig.routeInfo = routeInfo;
                    mobConfig.mm = mobilityModel;
                    mobConfig.acceleration = 0;
                    
                    %Assign speed
                    mobConfig.speed = vehConfig.maxVehSpeed/2;
                    
                    mobConfig.offset = index*2; % Vehicle to be placed at start of road.
                    vehicularMobility.setRogueVehiclePosAndVelocity(mobConfig);
                    
                    
                    % Configure and run WSMP(Wave short message protocol) app for sending
                    % position beacons.
                    WSMPArgs.pType = 'positionBeacon';
                    WSMPArgs.nodeId = nodeId;
                    WSMPArgs.rInfo = routeInfo;
                    WSMPArgs.mm = mobilityModel;
                    WSMPArgs.periodicity = vehConfig.pktPeriodicity;
                    WSMPArgs.hazardId = nodeId;
                    Simulator.Schedule('WSMPTraffic.runWSMPApp', ...
                        (WSMPArgs.periodicity*(nodeId+1))/1.5, WSMPArgs);
                    
                end
            end
        end
        
        % Configure hazard and schedule its creation time
        function configureHazard(config)
            topology = nodeListInfo.getSetTopology();
            config.topology = topology;
            hazardRoadId = topology.getStreetIdForBlock(cell2mat(config.location(2)), ...
                cell2mat(config.location(3)), cell2mat(config.location(1)));
            config.roadId = hazardRoadId;
            
            config.phy.Set('TxGain', DoubleValue(config.txGain));
            config.phy.Set('RxGain', DoubleValue(config.rxGain));
            config.phy.Set('RxNoiseFigure', DoubleValue(config.rxNoiseFigure));
            waveHelper = WaveHelper.Default();
            config.waveHelper = waveHelper;
            Simulator.Schedule('hazard.createHazard', config.entryTime, config);
            
        end
        
        % Set up visualization
        function setUpVisualizationAndTraces(config)
            visualizerTraces.initLog(); % Create log files
            
            % Log  manhattan  grid configuration in log files.
            visualizerTraces.logManhattanGridConfig(config.hBlocks, config.vBlocks, ...
                config.streetWidth, config.streetLen);
            
            % Log all vehicles including rogue ones
            firstRogueVehId = -1;
            if(config.numRogueVehicles > 0)
                firstRogueVeh = config.rVehC.Get(0);
                firstRogueVehId = firstRogueVeh.GetId();
            end
            visualizerTraces.logVehicles(config.numVehicles, config.numRogueVehicles, ...
                firstRogueVehId);
            
            % Position of vehicles is logged in log files with this  periodicity (in
            % millisecs). Smaller value facilitates smoothness in movement during
            % visualization but at the cost of simulation running time.
            traceArgs.logPeriodicity = config.logPeriodicity;
            
            traceArgs.numVehicles = config.numVehicles;
            traceArgs.numRogueVehicles =  config.numRogueVehicles;
            traceArgs.mm = 'ConstantVelocityMobilityModel';
            traceArgs.firstRogueVehId = firstRogueVehId;
            %traceArgs.hazardId = hazardId;
            
            % Log mobility of vehicles
            visualizerTraces.logVehicularPositionAndStats(traceArgs);
            
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
            % Delete all streets
            for i=1:args.topology.streetCount
                delete(args.topology.streets(i));
            end
            
            % Delete manhattan topology
            delete(args.topology);
            
            % Delete route objects for all regular vehicles
            for i=1:args.numVehicles
                delete(nodeListInfo.routeObj(i));
            end
            
            if(args.numRogueVehicles>0)
                firstRogueVeh = args.rogueVehC.Get(0);
                firstRogueVehId = firstRogueVeh.GetId();
            end
            % Deltete route objects for rogue vehicles
            for i=1:args.numRogueVehicles
                index = firstRogueVehId+i;
                delete(nodeListInfo.routeObj(index));
            end
            % Delete hazard route object. Assuming hazard is created after
            % all regular vehicles and rogue ones (TODO: Remove this
            % assumption)
            delete(nodeListInfo.routeObj(args.numVehicles+args.numRogueVehicles+1));
        end
    end
end