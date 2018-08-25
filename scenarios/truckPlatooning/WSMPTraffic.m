classdef WSMPTraffic
    %WSMP TRAFFIC construction, sending and reception of various types
    %(which are applicable for the scenario)
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties(Constant)
        platoonBeacon=1 % pkt type
        hazardWarning=2  % pkt type
        dummyBeacon=3 %pkt type
        roughPatchWarning=4 % pkt type
        headerSize=12; % WSMP HEADER Size
    end
    
    methods(Static)
        % Packe is constructed and sent, also a timer is scheduled for next
        % packet transmission
        function runWSMPApp(args)
            CCH = 178;
            channel = CCH;
            switch(args.pType)
                case 'platoonBeacon'
                    [payloadBuf, payloadSize]= WSMPTraffic.constructPlatoonBeacon( ...
                        args.nodeId, args.rInfo, args.mm);
                    % re-scheduling according to periodicity
                    Simulator.Schedule('WSMPTraffic.runWSMPApp', args.periodicity, args);
                    
                    if(args.nodeId > 0) % Not applicable for platoon leader
                        
                        % Check for platoon beacon communication loss
                        mobilityIntelligence.checkPlatoonCommLoss(args);
                        
                        % This function internally assumes availabilty of
                        % global information about all nodes to all nodes
                        % but only for visualization purpose so no mobility
                        % intelligence happening in it.
                        visualizerTraces.checkTruckInSafeZone(args);
                    end
                    
                case 'dummyBeacon'
                    [payloadBuf, payloadSize]= WSMPTraffic.constructDummyBeacon( ...
                        args.nodeId, args.rInfo, args.mm);
                    % re-scheduling with some randomness.
                    Simulator.Schedule('WSMPTraffic.runWSMPApp', ...
                        randi([args.periodicity args.periodicity+10]), args);
                case 'roughPatchWarning'
                    [payloadBuf, payloadSize]= WSMPTraffic.constructRoughPatchWarning( ...
                        args.nodeId, args.rInfo, args.mm, ...
                        args.roughPatchLen, args.speedLim);
                    % re-scheduling according to periodicity
                    Simulator.Schedule('WSMPTraffic.runWSMPApp', args.periodicity ...
                        + randi(10), args);
            end
            WSMPTraffic.sendWSMPPkt(payloadBuf, payloadSize, args.nodeId, channel);
        end
        
        
        
        % Construct a platoon beacon packet
        function [payloadBuf, payloadSize] = constructPlatoonBeacon( ...
                nodeId, routeInfo, mobilityModel)
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject(mobilityModel);
            currentPosition = mmObj.GetPosition ();
            velocity = norm(mmObj.GetVelocity ());
            mobIntel = mobilityIntelligence.getSetMobIntelObject();
            % If speed limit breached
            if(velocity > mobIntel.speedLimit)
                acceleration = nodeListInfo.nodeAcceleration(nodeId+1);
                % If accelerating then set acceleration to zero
                if(acceleration > 0)
                    mmObj.SetVelocityAndAcceleration(...
                        [mobIntel.speedLimit 0 0], [0 0 0]);
                    nodeListInfo.nodeAcceleration( ...
                        (nodeId+1), 0);
                end
            end
            
            currentPosition(1) = ceil(currentPosition(1));
            currentPosition(2) = ceil(currentPosition(2));
            currentPosition(3) = ceil(currentPosition(3));
            
            currentRoadId = routeInfo.getRoadIdByIndex();
            
            
            % ***********  Position beacon payload format ***************
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      laneId(2 bytes), xPos(2 bytes), yPos (2 bytes),
            %      zPos(2 bytes), velocity (1 bytes), acceleration(1 byte),
            %      timestamp(4 bytes) in microseconds
            
            % Filling packet: Filling of packet fields must be in the same
            % order as they are in the packet.
            payload.pktType = uint8(WSMPTraffic.platoonBeacon); %Set pkt type
            payload.ttl = uint8(1); % fill TTL */
            payload.nodeId = uint16(nodeId); % Fill Sending Node
            payload.roadId = uint16(currentRoadId); % fill lane Id id  */
            
            % As coordinates can be negative too, converting into 2's
            % complement form,then converting to decimal (so negative
            % integers will be sent as huge positive numbers)
            % value of x,y,z coordinates assumed to be 2
            % bytes size each
            payload.xpos = uint16(bin2dec(utils.dec2twos( ...
                currentPosition(1), 16)));
            payload.ypos = uint16(bin2dec(utils.dec2twos( ...
                currentPosition(2), 16)));
            payload.zpos = uint16(bin2dec(utils.dec2twos( ...
                currentPosition(3), 16)));
            
            payload.velocity = uint8(velocity);
            
            % Read acceleration
            acceleration = nodeListInfo.nodeAcceleration(nodeId+1);
            
            % As acceleration can be negative too, converting to 2's
            % complement form
            payload.acceleration = uint8(bin2dec(utils.dec2twos(...
                acceleration,8)));
            payload.timestamp = uint32(Simulator.Now());
            
            % As MATLAB structure size be much more than the sum of the
            % fields, so packing it.
            [payloadBuf, payloadSize] = WSMPTraffic.packStruct(payload);
        end
        
        % Construct rough patch warning packet
        function [payloadBuf, payloadSize] = constructRoughPatchWarning(...
                nodeId, routeInfo, mobilityModel, roughPatchLen, speedLim)
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject(mobilityModel);
            
            currentPosition = mmObj.GetPosition (); % wrapper required
            currentPosition(1) = ceil(currentPosition(1));
            currentPosition(2) = ceil(currentPosition(2));
            currentPosition(3) = ceil(currentPosition(3));
            
            currentRoadId = routeInfo;
            % ***********  Payload format *******************************%
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      roadId(2 bytes), xPos(2 bytes), yPos (2 bytes), zPos(2
            %      bytes), speed limit (1 byte) rough patch length (2 bytes)%
            
            
            % Filling packet: Filling of packet fields must be in the same
            % order as desired in the packet.
            
            payload.pktType = uint8(WSMPTraffic.roughPatchWarning); % filling packet type
            payload.ttl = uint8(2); % filling TTL */
            payload.nodeId = uint16(nodeId); % Filling Sending Node
            payload.roadId = uint16(currentRoadId); % filling road id  */
            
            
            % As coordinates can be negative too, converting into 2's
            % complement form,then converting to decimal (so negative
            % integers will be sent huge positive numbers) value of x,y,z
            % coordinates assumed to be 2 bytes size each
            payload.xpos = uint16(bin2dec(utils.dec2twos(currentPosition(1), 16)));
            payload.ypos = uint16(bin2dec(utils.dec2twos(currentPosition(2), 16)));
            payload.zpos = uint16(bin2dec(utils.dec2twos(currentPosition(3), 16)));
            
            payload.speedLimit = uint8(speedLim);
            payload.roughPatchLen = uint16(roughPatchLen);
            
            [payloadBuf, payloadSize] = WSMPTraffic.packStruct(payload);
        end
        
        % Construct a dummy packet
        function [payloadBuf, payloadSize] = constructDummyBeacon(nodeId,...
                routeInfo, mobilityModel)
            node = NodeList.GetNode(nodeId);
            mmObj = node.GetObject(mobilityModel);
            
            currentPosition = mmObj.GetPosition ();
            currentPosition(1) = ceil(currentPosition(1));
            currentPosition(2) = ceil(currentPosition(2));
            currentPosition(3) = ceil(currentPosition(3));
            currentRoadId = routeInfo.getRoadIdByIndex();
            
            
            % ***********  Position beacon payload format ****************%
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      roadId(2 bytes), xPos(2 bytes), yPos (2 bytes), zPos(2
            %      bytes), velocity (2 bytes), acceleration (2 bytes) %
            
            % Filling packet: Filling of packet fields must be in the same
            % order as desired in the packet.
            
            payload.pktType = uint8(WSMPTraffic.dummyBeacon); %Set pkt type
            payload.ttl = uint8(2); % Set TTL */
            payload.nodeId = uint16(nodeId); % Set Sending Node
            payload.roadId = uint16(currentRoadId); % Set lane id*/
            
            
            % As coordinates can be negative too, converting into 2's
            % complement form,then converting to decimal (so negative
            % integers will be sent huge positive numbers) value of x,y,z
            % coordinates assumed to be 2 bytes size each
            payload.xpos = uint16(bin2dec(utils.dec2twos(currentPosition(1), 16)));
            payload.ypos = uint16(bin2dec(utils.dec2twos(currentPosition(2), 16)));
            payload.zpos = uint16(bin2dec(utils.dec2twos(currentPosition(3), 16)));
            
            [payloadBuf, payloadSize] = WSMPTraffic.packStruct(payload);
        end
        
        
        
        
        
        % Send the WSMP packet via mex-Interface
        function sendWSMPPkt(payloadBuf, payloadSize,nodeId, channel)
            bssWildcard = 'FF:FF:FF:FF:FF:FF';
            WSMP_PROT_NUMBER = '0x88DC';
            SocketInterface.Send(payloadBuf, payloadSize, nodeId, channel, ...
                WSMP_PROT_NUMBER, bssWildcard);
            nodeListInfo.nodeTxCount(nodeId+1, 1);
        end
        
        
        
        % Call the respective packet handler for the received packet based
        % on the packet type
        function receivePkt(nodeId, pkt, length)
            payload = pkt(WSMPTraffic.headerSize+1:end);
            nodeListInfo.nodeRxCount(nodeId+1, 1); % Upading rx pkt count
            switch(payload(1)) % first byte in payload in pkt type
                case WSMPTraffic.platoonBeacon
                    mobilityIntelligence.handlePlatoonBeacon(nodeId, ...
                        payload, length - WSMPTraffic.headerSize);
                case WSMPTraffic.dummyBeacon
                    % Do nothing
                case WSMPTraffic.roughPatchWarning
                    mobilityIntelligence.handleRoughPatchWarning(nodeId, ...
                        payload, length-WSMPTraffic.headerSize);
            end
        end
        
        
        % Returns a packet packed with info read from payload structure
        % fields.
        function [packedPayload, payloadSize] = packStruct(payload)
            pktFields = fieldnames(payload); % Reading all fields
            numFields = size(pktFields,1); % Reading number of fields
            i=1;
            pktIndex=1;
            while(i<=numFields)
                fieldName = char(pktFields(i));
                fieldVal = payload.(char(fieldName));
                fieldInt8 = typecast(fieldVal, 'uint8');
                memObj = whos('fieldVal');
                sizeInBytes = memObj.bytes;
                packedPayload(pktIndex:(pktIndex+sizeInBytes-1)) = fieldInt8;
                pktIndex = pktIndex + sizeInBytes;
                i= i+1;
                
            end
            payloadSize = pktIndex-1;
        end
    end
end
