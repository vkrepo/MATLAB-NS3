classdef visualizerTraces
    % Functions for logging the events and statistics (which will later be
    % displayed during visulaization)
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties(Constant)
        VEHICLE_ENTRY_EVENT = 1
        MOBILITY_EVENT = 2
        UPADTE_MOBILITY_TABLE = 3
        PACKET_TRACE = 4
        RSU_INSTALLATION_EVENT = 5
        COMMUNICATION_FAILURE_EVENT = 6
        COMMMUNICATION_GAP_COUNT = 7
        VEHICLE_IN_UNSAFE_ZONE = 8
        VEHICLE_IN_SAFE_ZONE = 9
    end
    
    methods(Static)
        % Peridically record events and statistics for purpose of
        % visualization
        function logEventsAndStats (args)
            timeS = Simulator.Now();
            preceedVehiclePos = [];
            persistent initPktCountFlag;
            if(isempty(initPktCountFlag))
                for i=0:(args.numTrucks-1)
                    nodeListInfo.nodeTxCount(i+1, 0);
                    nodeListInfo.nodeRxCount(i+1, 0);
                    nodeListInfo.nodePrecedingRxCount(i+1, 0);
                    nodeListInfo.worstPlatoonBeaconRxGap(i+1, 0);
                    nodeListInfo.lastRxTime(i+1, 0);
                    nodeListInfo.stoppedFlag(i+1, 0);
                    stats.getSetStats(i+1, 'RxError', 0);
                    nodeListInfo.getSetCommBreak(i+1, 'twoPacketLoss', 0);
                    nodeListInfo.getSetCommBreak(i+1, 'threePacketLoss', 0);
                    nodeListInfo.getSetCommBreak(i+1, 'fourPacketLoss', 0);
                    nodeListInfo.getSetCommBreak(i+1, 'fivePacketLoss', 0);
                    nodeListInfo.getSetSafeZoneFlag(i+1, 0);
                end
                for i=0:(args.rogueVehCount-1)
                    nodeListInfo.nodeTxCount(args.rogueVehId+i+1, 0);
                    nodeListInfo.nodeRxCount(args.rogueVehId+i+1, 0);
                    nodeListInfo.nodePrecedingRxCount(args.rogueVehId+i+1, 0);
                    nodeListInfo.worstPlatoonBeaconRxGap(args.rogueVehId+i+1, 0);
                    nodeListInfo.lastRxTime(args.rogueVehId+i+1, 0);
                    stats.getSetStats(args.rogueVehId+i+1, 'RxError', 0);
                end
                nodeListInfo.nodeTxCount(args.rsuId+1, 0);
                nodeListInfo.nodeRxCount(args.rsuId+1, 0);
                nodeListInfo.nodePrecedingRxCount(args.rsuId+1, 0);
                nodeListInfo.worstPlatoonBeaconRxGap(args.rsuId+1, 0);
                nodeListInfo.lastRxTime(args.rsuId+1, 0);
                stats.getSetStats(args.rsuId+1, 'RxError', 0);
                initPktCountFlag = 1;
            end
            file = visualizerTraces.getSetLogFileHandle();
            for i=0:(args.numTrucks-1)
                node = NodeList.GetNode(i);
                mmObj = node.GetObject('ConstantAccelerationMobilityModel');
                currentPosition = mmObj.GetPosition();
                currentVelocity = mmObj.GetVelocity();
                currentSpeed = norm(currentVelocity);
                currentAcceleration = nodeListInfo.nodeAcceleration(i+1);
                if(currentVelocity(1)<0)
                    mmObj.SetVelocityAndAcceleration([0 0 0], [0 0 0]);
                    nodeListInfo.nodeAcceleration(i+1,0);
                end
                
                if(isempty(preceedVehiclePos))
                    gap=0;
                else
                    mobIntel = mobilityIntelligence.getSetMobIntelObject();
                    gapVector = (preceedVehiclePos -  ...
                        [mobIntel.truckLength 0 0]) - currentPosition;
                    gap = norm(gapVector);
                end
                txCount = nodeListInfo.nodeTxCount(i+1);
                rxCount = nodeListInfo.nodeRxCount(i+1);
                precedingRxCount = nodeListInfo.nodePrecedingRxCount(i+1);
                if(i>0)
                    %Preceding node's platoon beacon tx count - own
                    %platoon beacon Rx count
                    platoonBeaconLossCount = nodeListInfo.nodeTxCount(i) ...
                        - nodeListInfo.nodePrecedingRxCount(i+1);
                    
                else
                    platoonBeaconLossCount = 0;
                end
                worstPlatoonBeaconRxGap = nodeListInfo.worstPlatoonBeaconRxGap(i+1);
                phyRxErrorCount = stats.getSetStats(i+1, 'RxError');
                packetLossCount2 = nodeListInfo.getSetCommBreak(i+1, ...
                                                          'twoPacketLoss');
                packetLossCount3 = nodeListInfo.getSetCommBreak(i+1, ...
                                                        'threePacketLoss');
                packetLossCount4 = nodeListInfo.getSetCommBreak(i+1, ...
                                                        'fourPacketLoss');
                packetLossCount5 = nodeListInfo.getSetCommBreak(i+1, ...
                                                       'fivePacketLoss');
                
                fprintf (file,'%f %d %d %f %f %f %f %f %d\n',timeS, ...
                        visualizerTraces.UPADTE_MOBILITY_TABLE, i, gap, ...
                        currentSpeed, currentAcceleration, -1, -1, -1) ;
                fprintf (file,'%f %d %d %f %f %f %f %f %d\n',timeS, ...
                         visualizerTraces.MOBILITY_EVENT, i, ...
                         currentPosition(1), currentPosition(2), ...
                         currentPosition(3), -1, -1, -1);
                fprintf (file,'%f %d %d %f %f %f %f %f %d\n',timeS, ...
                         visualizerTraces.PACKET_TRACE, i, txCount, ...
                         rxCount, precedingRxCount, ...
                          platoonBeaconLossCount, worstPlatoonBeaconRxGap, ...
                          phyRxErrorCount);
                fprintf (file,'%f %d %d %f %f %f %f %f %d\n',timeS, ...
                         visualizerTraces.COMMMUNICATION_GAP_COUNT ...
                         , i, packetLossCount2, packetLossCount3, ...
                         packetLossCount4, packetLossCount5, -1, -1) ;
                %fclose(file);
                preceedVehiclePos = currentPosition;
            end
            
            for i=0:(args.rogueVehCount-1)
                %node = args.rogueVeh.Get(i);
                node = NodeList.GetNode(args.rogueVehId + i);
                mmObj = node.GetObject('ConstantAccelerationMobilityModel');
                currentPosition = mmObj.GetPosition();
                
                %file = visualizerTraces.getSetLogFileHandle();
                fprintf (file,'%f %d %d %f %f %f %f %f %d\n',timeS, ...
                visualizerTraces.MOBILITY_EVENT, args.rogueVehId + i, ...
                currentPosition(1), currentPosition(2), currentPosition(3), ...
                -1, -1, -1);
                %fclose(file);
                
            end
            %Again rescheduling to itself
            Simulator.Schedule('visualizerTraces.logEventsAndStats', ...
                              args.logPeriodicity, args);
        end
        
        % Logging Highway config in log file to be later read by
        % visualizer
        function logHighwayConfig(laneCount, laneWidth, highwayLength, ...
                roughPatchStart, roughPatchLen)
            
            file = fopen('scenarioInfo.txt','a+');
            fprintf (file,'%f %f %f %f %f ',laneCount, laneWidth, ...
                     highwayLength, roughPatchStart, roughPatchLen);
            fclose(file);
        end
        
        
        % Logging all the objects present in the scenario: trucks, other
        % vehicles, RSU
        function logScenarioObjects(args)
            file = fopen('scenarioInfo.txt','a+');
            fprintf(file,'%f %f %f', args.numTrucks, args.rogueVehCount, ...
                    args.truckLen);
            fclose(file);
            timeS = Simulator.Now();
            
            % Logging initial position of vehicles and hazards
            
            mobilityModel = 'ConstantAccelerationMobilityModel';
            file = visualizerTraces.getSetLogFileHandle();
            for i=0:(args.numTrucks-1)
                node = NodeList.GetNode(i);
                mmObj = node.GetObject(mobilityModel);
                currentPosition = mmObj.GetPosition ();
                
                
                fprintf (file,'%f %d %d %f %f %f %f %f %d\n', timeS, ...
                visualizerTraces.VEHICLE_ENTRY_EVENT, i, currentPosition(1), ...
                currentPosition(2),currentPosition(3),-1,-1, -1);
                %fclose(file);
            end
            for i=0:(args.rogueVehCount-1)
                %node = args.rogueVeh.Get(i);
                node = NodeList.GetNode(args.rogueVehId + i);
                mmObj = node.GetObject(mobilityModel);
                currentPosition = mmObj.GetPosition();
                
                %file = visualizerTraces.getSetLogFileHandle();
                fprintf (file,'%f %d %d %f %f %f %f %f %d\n',timeS, ...
                visualizerTraces.VEHICLE_ENTRY_EVENT, args.rogueVehId+i, ...
                currentPosition(1), currentPosition(2), currentPosition(3), ...
                -1, -1, -1);
                %fclose(file);
                
            end
            rsu = NodeList.GetNode(args.rsuId);
            mmObj = rsu.GetObject('ConstantPositionMobilityModel');
            currentPosition = mmObj.GetPosition();
            
            %file = visualizerTraces.getSetLogFileHandle();
            fprintf (file,'%f %d %d %f %f %f %f %f %d\n',timeS, ...
                 visualizerTraces.RSU_INSTALLATION_EVENT, args.rsuId, ...
                 currentPosition(1), currentPosition(2), currentPosition(3), ...
                 -1, -1, -1);
            %fclose(file);
            
        end
        
        % Log config parameters for showing up in visualizer    
        function logConfigParams(args)
            file = fopen('configInfo.txt','a+');
            fprintf (file,'%f %f %f %f %f %f %f\n', ... 
                     args.platoonBeaconFreq, args.platoonFailureCommGap, ...
                     args.rogueVPktFreq, args.txGainPlatoon, ...
                     args.txGainRogueV, args.roughPatchSpeedLim, ...
                     args.maxSpeedLim);
                     
            fclose(file);
        end
        % Open fresh log files,  deleting any existing ones
        function initLog()
            
            file1 = fopen('log_file.txt','w');
            file2 = fopen('scenarioInfo.txt','w');            
            file3 = fopen('configInfo.txt','w');
           
            fclose(file1);
            fclose(file2);
            fclose(file3);
            file1 = fopen('log_file.txt','a+');
             % Storing file handle so that it does not need to be opened 
            % again for each write
            visualizerTraces.getSetLogFileHandle(file1);
            
        end
        
        % Close log file
        function deinitLogFile()
            fileH = visualizerTraces.getSetLogFileHandle();
            fclose(fileH);   
        end
        
        
        % Check whether a truck is in safe zone with respect to its
        % preceeding truck using the global information.
        function checkTruckInSafeZone(args)
            node = NodeList.GetNode(args.nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            ownSpeed = norm(mmObj.GetVelocity());
            mobIntel = mobilityIntelligence.getSetMobIntelObject();
            % Preceeding vehicle speed not considered.
            %preceedVehicleSpeed =  double(payload(13));
            %ownStopDistance = ((ownSpeed.*ownSpeed)./(2.*mobilityIntelligence.maxDeceleration));
            %preceedVehStopDist = ((preceedVehicleSpeed.*preceedVehicleSpeed)./(2.*mobilityIntelligence.maxDeceleration));
            instantSafeGap =  mobIntel.minStandstillGap +  ...
                        ownSpeed.*mobIntel.minTimeHeadway;% ...
            %+ ownStopDistance  - preceedVehStopDist;
            
            % Preceding Truck position
            node = NodeList.GetNode(args.nodeId -1);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            preceedPos = mmObj.GetPosition();
            
            % Reading own position
            node = NodeList.GetNode(args.nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            ownPos = mmObj.GetPosition();
            
            
            % In calculation of gap adjusting for truck length as well.
            % This is assuming that all trucks have same length.
            gapVector = [((preceedPos(1)-mobIntel.truckLength) ...
                - ownPos(1)) (preceedPos(2) - ownPos(2)) ...
                (preceedPos(3) - ownPos(3))];
            gap = norm(gapVector);
            
            
            if(instantSafeGap > gap) % Unsafe zone
                if(nodeListInfo.getSetSafeZoneFlag(args.nodeId+1) == 0)
                    % mark vehicle in unsafe zone for visualization
                    nodeListInfo.getSetSafeZoneFlag(args.nodeId+1, 1);
                    time = Simulator.Now();
                    file = visualizerTraces.getSetLogFileHandle();
                    fprintf (file,'%f %d %d %f %f %f %f %f %d\n', time, ...
                            visualizerTraces.VEHICLE_IN_UNSAFE_ZONE ...
                           , args.nodeId, -1, -1, -1, -1, -1, -1) ;
                    %fclose(file);
                    
                end
            else % Safe Zone
                if(nodeListInfo.getSetSafeZoneFlag(args.nodeId+1) == 1)
                    % If vehicle was in unsafe zone, mark vehicle
                    % in safe zone now.
                    nodeListInfo.getSetSafeZoneFlag(args.nodeId+1, 0);
                    time = Simulator.Now();
                    file = visualizerTraces.getSetLogFileHandle();
                    fprintf (file,'%f %d %d %f %f %f %f %f %d\n', ...
                            time, visualizerTraces.VEHICLE_IN_SAFE_ZONE ...
                        , args.nodeId, -1, -1, -1, -1, -1, -1) ;
                    %fclose(file);
                    
                end
            end                      
        end
        
        %Get/Set log file handle
        function fileHandle = getSetLogFileHandle(handle)
            persistent logFileHandle;
            if(nargin>=1)
                logFileHandle = handle;
            end
            fileHandle = logFileHandle;             
        end
        
    end
end

