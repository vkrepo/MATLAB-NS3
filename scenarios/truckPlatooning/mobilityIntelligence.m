classdef mobilityIntelligence    
    % The class has the functions to take actions based on the received
    % packets. For example, defining reaction if a 'rough patch ahead'
    % warning is received or a 'position beacon' is received from the
    % preceding truck. Reactive action could be deceleration or acceleration.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties
        minTimeHeadway
        maxTimeHeadway
        maxAcceleration
        maxDeceleration
        minStandstillGap
        initialAccel 
        normalAccel 
        truckLength 
        roughPatchRelevanceDist
        speedLimit
    end
    
    methods (Static)
        % Reaction based on platoon beacon reception
        function handlePlatoonBeacon(nodeId, pkt, len)
            % Check if node is not disconnected
            if(nodeListInfo.stoppedFlag(nodeId+1) == 0)
                % Check if packet sent from preceding node
                if( mobilityIntelligence.isPacketAccepted(nodeId, pkt) == 1)
                    rxTime = Simulator.Now();
                    % Update last RX time
                    nodeListInfo.lastRxTime(nodeId+1, rxTime);
                    % Update Plaoon beacon received count (from preceding node)
                    nodeListInfo.nodePrecedingRxCount(nodeId+1, 1);
                    
                    instantSafeGap = mobilityIntelligence.calculateInstantSafeGap(nodeId, pkt);
                    [instantGap, dir] = mobilityIntelligence.calculateInstantGap(nodeId, pkt) ;
                    mobIntel = mobilityIntelligence.getSetMobIntelObject();
                    if(instantSafeGap > instantGap) % Unsafe zone
                        % Safe gap is breached so need to decelerate by max
                        % capability
                        accelVal = -mobIntel.maxDeceleration;
                        
                        mobilityIntelligence.adjustAcceleration(nodeId, accelVal, dir);
                        % Update acceleration in node list info
                        nodeListInfo.nodeAcceleration(nodeId+1, accelVal);
                        
                        
                    else % Safe Zone
                        
                        % Check for acceleration/deceleration if vehicle is in
                        % safe zone
                        [accelVal, dir] = mobilityIntelligence.checkForAccelChange(nodeId, pkt);
                        
                        % Limit acceleration/deceleration to maximum allowed.
                        if(accelVal > mobIntel.maxAcceleration)
                            accelVal = mobIntel.maxAcceleration;
                            
                        elseif(accelVal < -mobIntel.maxDeceleration)
                            accelVal = -mobIntel.maxDeceleration;
                        end
                        % Set the node's acceleration/deceleration to the
                        %calculated value
                        mobilityIntelligence.adjustAcceleration(nodeId, ...
                            accelVal, dir);
                        % Update acceleration in node list info
                        nodeListInfo.nodeAcceleration(nodeId+1, accelVal);
                        
                    end
                end
            end
            % end
            
        end
        % Reaction based on 'rough patch' warning reception. Only platoon leader
        % reacts to this warning and decelerate if required. The other
        % trucks just follow.
        function handleRoughPatchWarning(nodeId, payload, len)
            
            if( nodeId == 0) % Only platoon leader to accept this packet
                % Check if platoon leader is already reacting(decelerating)
                % to some previously received 'rough patch' warning. In
                % that case no need to react now
                if(mobilityIntelligence.roughPatchAwareness() == 0)
                    % ***********  payload format **********************
                    %  pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
                    %  roadId(2 bytes), xPos(2 bytes), yPos (2 bytes),
                    %  zPos(2 bytes), speed limit (1 byte)
                    laneId = typecast([payload(5) payload(6)], 'uint16');
                    route = nodeListInfo.routeObj(nodeId+1);
                    currentLaneId = route.getRoadIdByIndex();
                    % Vehicle should be on same lane as the RSU sending the
                    %warning
                    if(laneId == currentLaneId)
                        rsuPosX= double(typecast([payload(7) payload(8)], 'uint16'));
                        %rsuPosY= double(typecast([payload(9) payload(10)], 'uint16'));
                        %rsuPosZ= double(typecast([payload(11) payload(12)], 'uint16'));
                        
                        % Reading own position
                        node = NodeList.GetNode(nodeId);
                        mmObj = node.GetObject('ConstantAccelerationMobilityModel');
                        ownPos = mmObj.GetPosition();
                        
                        % Checking whether platoon leader is not already past
                        % the start of rough patch. Take action only if truck
                        % is yet to reach rough patch.
                        distanceToRoughPatch = rsuPosX - ownPos(1);
                        mobIntel = mobilityIntelligence.getSetMobIntelObject();
                        if(distanceToRoughPatch <= mobIntel.roughPatchRelevanceDist ...
                                && distanceToRoughPatch > 0 )
                            gap = rsuPosX - ownPos(1);
                            speedLimit =  double(payload(13));
                            
                            node = NodeList.GetNode(nodeId);
                            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
                            ownSpeed = norm(mmObj.GetVelocity());
                            % Check if its already moving at lesser pace
                            % than required at rough patch, in that case no
                            % need to react
                            if(ownSpeed > speedLimit)
                                requiredDecel = ((speedLimit.*speedLimit) ...
                                    - (ownSpeed.*ownSpeed))/(2.*gap);
                                requiredDecel = floor(requiredDecel);
                                if(requiredDecel < -mobIntel.maxDeceleration)
                                    requiredDecel = -mobIntel.maxDeceleration;
                                end
                                timeToSpeedLimit = (speedLimit - ownSpeed)/(requiredDecel);
                                
                                % Set the node's acceleration/deceleration to the
                                %calculated value
                                mobilityIntelligence.adjustAcceleration(nodeId, ...
                                    requiredDecel, [1 0 0]);
                                % Update acceleration in node list info
                                nodeListInfo.nodeAcceleration(nodeId+1, requiredDecel);
                                mobilityIntelligence.roughPatchAwareness(1);
                                
                                args.roughPatchLen = double(typecast([payload(14) payload(15)], 'uint16'));
                                args.roughPatchStart = rsuPosX;
                                args.nodeId = nodeId;
                                
                                % Start  a timer for platoon leader to
                                % reach the start of the rough patch
                                Simulator.Schedule('mobilityIntelligence.roughPatchMovement',...
                                    timeToSpeedLimit*1000, args);
                                
                            end
                            
                            
                            
                        end
                        
                    end
                end
            end
        end
        
        
        
        
        % Calculate instaneous safe gap between the vehicle and its
        % preceding one by taking into account their respective pos,
        % velocity and acceleration.
        function instantSafeGap = calculateInstantSafeGap(nodeId, payload)
            mobIntel = mobilityIntelligence.getSetMobIntelObject();
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            ownSpeed = norm(mmObj.GetVelocity());
            
            % Preceeding vehicle speed not considered.
            %preceedVehicleSpeed =  double(payload(13));
            %ownStopDistance = ((ownSpeed.*ownSpeed)./(2.*mobilityIntelligence.maxDeceleration));
            %preceedVehStopDist = ((preceedVehicleSpeed.*preceedVehicleSpeed)./(2.*mobilityIntelligence.maxDeceleration));
            instantSafeGap =  mobIntel.minStandstillGap + ownSpeed.*mobIntel.minTimeHeadway;% ...
            %+ ownStopDistance  - preceedVehStopDist;
        end
        
        % Based on the received platoon beacon, calculate instantaneous safe gap
        % between the vehicle and preceding one.
        function [gap, dir] = calculateInstantGap(nodeId, payload)
            mobIntel = mobilityIntelligence.getSetMobIntelObject();
            % reading X,Y,Z location of sending truck
            preceedPosX= double(typecast([payload(7) payload(8)], 'uint16'));
            preceedPosY= double(typecast([payload(9) payload(10)], 'uint16'));
            preceedPosZ= double(typecast([payload(11) payload(12)], 'uint16'));
            
            % Reading own position
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            ownPos = mmObj.GetPosition();
            
            % In calculation of gap adjusting for truck length as well.
            % This is assuming that all trucks have same length.
            gapVector = [((preceedPosX-mobIntel.truckLength) ...
                - ownPos(1)) (preceedPosY - ownPos(2)) ...
                (preceedPosZ - ownPos(3))];
            gap = norm(gapVector);
            dir = (gapVector)./(gap);
        end
        
        
        % Check the need of acceleration/deceleration based on the received
        %platoon beacon from the preceding vehicle in the platoon.
        function [reqAcceleration, dir]  = checkForAccelChange(nodeId, payload)
            mobIntel = mobilityIntelligence.getSetMobIntelObject();
            %preceedVehicleAccel =  double(utils.twos2dec(double(payload(14))));
            preceedVehicleAccel =  double(payload(14));
            if(preceedVehicleAccel>127) % If value is negative
                preceedVehicleAccel = preceedVehicleAccel - 256;
            end
            preceedVehicleSpeed =  double(payload(13));
            if(preceedVehicleSpeed>127) % If value is negative
                preceedVehicleSpeed = preceedVehicleSpeed - 256;
            end
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            ownVelocity = mmObj.GetVelocity();
            ownSpeed = norm(ownVelocity);
            %velocityVector = ownVelocity./ownSpeed;
            
            % reading X,Y,Z location of sending truck
            preceedPosX= double(typecast([payload(7) payload(8)], ...
                'uint16'));
            preceedPosY= double(typecast([payload(9) payload(10)], ...
                'uint16'));
            preceedPosZ= double(typecast([payload(11) payload(12)], ...
                'uint16'));
            
            % Reading own position
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            ownPos = mmObj.GetPosition();
            
            gapVector = [((preceedPosX -mobIntel.truckLength)...
                - ownPos(1)) (preceedPosY - ownPos(2)) ...
                (preceedPosZ - ownPos(3))];
            
            gap = norm(gapVector);
            
            accelerationConstant = 1;
            velocityPropConstant = 1;
            positionPropConstant = 1;

%             accelerationConstant = .66;
%             velocityPropConstant = 1;
%             positionPropConstant = 4;
            
            
            % Calculate Required acceleration/deceleration
            reqAcceleration = ...
                (accelerationConstant .* preceedVehicleAccel) + ...
                velocityPropConstant.*(preceedVehicleSpeed - ownSpeed)+ ...
                + positionPropConstant.*(gap- ...
                (mobIntel.minStandstillGap + ...
                (ownSpeed.*mobIntel.maxTimeHeadway)));
            
            reqAcceleration = floor(reqAcceleration);
            dir = (gapVector)./(gap);
            if(ownVelocity(1)<=0 && (reqAcceleration < 0) )
                reqAcceleration = 0;
            end
        end
        
        
        % Make the vehicle accelerate or decelerate
        function adjustAcceleration(nodeId, acceleration, dir)
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            velocity = mmObj.GetVelocity();
            mmObj.SetVelocityAndAcceleration(velocity, acceleration .* dir);
            
        end
        
        %Check whether position beacon to be accepted for processing
        function isAccepted = isPacketAccepted(nodeId, payload)
            sendingTruckId = double(typecast([payload(3) payload(4)], ...
                'uint16'));
            if((sendingTruckId+1) == nodeId) % Accept only if preceding ...
                % truck sent the packet
                isAccepted = 1;
            else
                isAccepted = 0;
            end
            
        end
        
        % Get/Set rough patch awareness flag;
        function awarenessFlag = roughPatchAwareness(flag)
            persistent awareness;
            if(isempty(awareness))
                awareness = 0;
            end
            if(nargin == 1)
                awareness =flag;
            end
            awarenessFlag = awareness;
        end
        
        % Movement on Rough Patch
        function roughPatchMovement(args)
            node = NodeList.GetNode(args.nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            velocity = mmObj.GetVelocity();
            position = mmObj.GetPosition();
            roughPatchEndPos = args.roughPatchStart + args.roughPatchLen;
            roughPatchDistance = roughPatchEndPos -position(1);
            if(roughPatchDistance > 0)
                timeToRoughpatchEnd = roughPatchDistance/velocity(1);
            else % Already crossed the rough patch
                timeToRoughpatchEnd = 0;
            end
            % Stop accelerating
            mmObj.SetVelocityAndAcceleration(velocity,[0 0 0]);
            Simulator.Schedule('mobilityIntelligence.roughPatchEnd',...
                timeToRoughpatchEnd*1000, args);
            % Update acceleration in node list info
            nodeListInfo.nodeAcceleration(args.nodeId+1, 0);
            
        end
        
        % Movement after Rough Patch. Accelerate again
        function roughPatchEnd(args)
            mobIntel = mobilityIntelligence.getSetMobIntelObject();
            node = NodeList.GetNode(args.nodeId);
            mmObj = node.GetObject('ConstantAccelerationMobilityModel');
            velocity = mmObj.GetVelocity();
            
            mmObj.SetVelocityAndAcceleration(velocity,[mobIntel.normalAccel 0 0]);
            % Update acceleration in node list info
            nodeListInfo.nodeAcceleration(args.nodeId+1, mobIntel.normalAccel);
            mobilityIntelligence.roughPatchAwareness(0);
            
        end
        
        % Check for communication failure as well as update consecutive
        % packet loss statistics.
        function checkPlatoonCommLoss(args)
            mobIntel = mobilityIntelligence.getSetMobIntelObject();
            if(nodeListInfo.stoppedFlag(args.nodeId+1) == 0)
                time = Simulator.Now();
                lastRxTime = nodeListInfo.lastRxTime(args.nodeId + 1);
                if(lastRxTime > 0)
                    rxGap = time - lastRxTime;
                else % No Platoon beacon received packet yet
                    rxGap = 0;
                end
                % Update Worst platoon gap. It will be updated only if this
                % gap is less than current worst update gap.
                nodeListInfo.worstPlatoonBeaconRxGap(args.nodeId+1, rxGap);
                % Check whether communication failure occured
                if(rxGap*1000 >= args.platoonFailureCommGap)
                    file = visualizerTraces.getSetLogFileHandle();
                    fprintf (file,'%f %d %d %f %f %f %f %f %d\n',time, ...
                        visualizerTraces.COMMUNICATION_FAILURE_EVENT, ...
                        args.nodeId, rxGap, -1, -1, -1, -1, -1) ;
                    %fclose(file);
                    node = NodeList.GetNode(args.nodeId);
                    mmObj = node.GetObject('ConstantAccelerationMobilityModel');
                    velocity = mmObj.GetVelocity();
                    speed = norm(velocity);
                    if(speed > 0) % If vehicle is moving.
                        
                        % Due to communication failure making the
                        % truck stop with maximum possible
                        % deceleration.
                        mobilityIntelligence.adjustAcceleration( ...
                            args.nodeId, -mobIntel.maxDeceleration, [1 0 0]);
                        % Update acceleration in node list info
                        nodeListInfo.nodeAcceleration(args.nodeId+1,...
                            -mobIntel.maxDeceleration);
                    end
                    % Communication failed on this node, setting flag
                    nodeListInfo.stoppedFlag(args.nodeId+1, 1);
                end
                
                % Update communication break statistics
                if((rxGap*1000 >= args.periodicity*5) && ...
                                         (rxGap*1000 < args.periodicity*6))
                    nodeListInfo.getSetCommBreak(args.nodeId+1, ...
                                                'fivePacketLoss', 1);
                    nodeListInfo.getSetCommBreak(args.nodeId+1, ....
                                                'fourPacketLoss', -1);
                elseif((rxGap*1000 >= args.periodicity*4) && ...
                                         (rxGap*1000 < args.periodicity*5))
                    nodeListInfo.getSetCommBreak(args.nodeId+1, ...
                                                'fourPacketLoss', 1);
                    nodeListInfo.getSetCommBreak(args.nodeId+1, ...
                                                'threePacketLoss', -1);
                elseif((rxGap*1000 >= args.periodicity*3) && ...
                                         (rxGap*1000 < args.periodicity*4))
                    nodeListInfo.getSetCommBreak(args.nodeId+1, ...
                                                'threePacketLoss', 1);
                    nodeListInfo.getSetCommBreak(args.nodeId+1, ...
                                                 'twoPacketLoss', -1);
                elseif((rxGap*1000 >= args.periodicity*2) && ...
                                         (rxGap*1000 < args.periodicity*3))
                    nodeListInfo.getSetCommBreak(args.nodeId+1, ...
                                                'twoPacketLoss', 1);
                end
            end
            
        end
        
        % Get/Set mobility intelligence object 
         function mobObject = getSetMobIntelObject(mobIntelObj)
            persistent mobIntel;
            if(nargin == 1)  % Using as a set function for adding route obj
                mobIntel = mobIntelObj;
            end
           mobObject = mobIntel;           
        end
    end
    
end

