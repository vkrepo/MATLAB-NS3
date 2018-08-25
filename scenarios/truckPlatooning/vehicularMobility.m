classdef vehicularMobility < handle
    % Setting the mobility model and its properties for all the nodes.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties
        
    end
    
    methods(Static)
        % Set mobility Model
        function setMobilityModel(nodeId, mobilityModel)
            % Get node from node id
            node = NodeList.GetNode(nodeId);
            % creates Mobility Helper object */
            mobility = MobilityHelper();
            mobility.SetMobilityModel (mobilityModel);
            mobility.Install (node);
        end
        
        % Set initial position and velocities of vehicles
        function setVehiclePosAndVelocity(args)
            % Get node from node id
            node = NodeList.GetNode(args.nodeId);
            % gets constant velocity mobility model from node */
            if(strcmp(args.mm, 'ConstantVelocityMobilityModel'))
                mmObj = node.GetObject(args.mm);
            end
            % gets constant acceleration mobility model from node */
            if(strcmp(args.mm, 'ConstantAccelerationMobilityModel'))
                mmObj = node.GetObject(args.mm);
            end
            % increment the route index by 1 (i.e. to next road) and
            % returns it, ... returns 0 if % destination is reached
            nextIndex = args.routeInfo.incrementRouteIndex();
            
            if(nextIndex ~= 0) % journey not ended
                
                nextRoadId = args.routeInfo.getRoadIdByIndex(nextIndex);
                laneInfo = args.topology.getLaneInfo(nextRoadId);
                if(laneInfo.direction == [1 0 0])
                    initialPos = laneInfo.startPosition + [args.offset 0 0];
                elseif(laneInfo.direction == [-1 0 0])
                    initialPos = laneInfo.startPosition + [-args.offset 0 0];
                elseif(laneInfo.direction == [0 1 0])
                    initialPos = laneInfo.startPosition + [0 args.offset 0];
                elseif(laneInfo.direction == [0 -1 0])
                    initialPos = laneInfotInfo.startPosition + [0 -args.offset 0];
                end
                
                % sets node position to the start of road
                mmObj.SetPosition(initialPos);
                
                if(strcmp(args.mm, 'ConstantVelocityMobilityModel'))
                    mmObj.SetVelocity(args.speed .* roadInfo.direction);
                elseif(strcmp(args.mm, 'ConstantAccelerationMobilityModel'))
                    mmObj.SetVelocityAndAcceleration( ...
                        args.speed .* laneInfo.direction, ...
                        args.acceleration.* laneInfo.direction);
                    
                    nodeListInfo.nodeAcceleration(args.nodeId+1,args.acceleration);
                end
            else
                %vehicle reached its destination,so stopping it
                mmObj.SetVelocity([0 0 0]); % Wrapper required
                if(strcmp(args.mm, 'ConstantAccelerationMobilityModel'))
                    %TODO: set acceleration zero or set some deceleration
                    %for graceful
                    % stopping. In that case, deceleration should start
                    % ahead of time such that vehicle completely stops at
                    % the end of road/road/lane
                end
                
            end
            
        end
        
        function stopAccelerating(args)
            node = NodeList.GetNode(args.nodeId);
            mmObj = node.GetObject(args.mm);
            
            currentVelocity = mmObj.GetVelocity ();
            deceleration = 0;
            mmObj.SetVelocityAndAcceleration(currentVelocity, [deceleration 0 0]);
            
            nodeListInfo.nodeAcceleration(args.nodeId+1, deceleration);
            timeToStartDecel = 10;
            Simulator.Schedule('vehicularMobility.startDecelerating', ...
                timeToStartDecel*1000, args);
            
        end
        
        function timeToStop = startDecelerating(args)
            node = NodeList.GetNode(args.nodeId);
            mmObj = node.GetObject(args.mm);
            
            currentVelocity = mmObj.GetVelocity ();
            deceleration = 3;
            mmObj.SetVelocityAndAcceleration(currentVelocity, [-deceleration 0 0]);
            
            nodeListInfo.nodeAcceleration(args.nodeId+1,-deceleration);
            timeToStop = norm(currentVelocity)/deceleration;
            Simulator.Schedule('vehicularMobility.stopVehicle', ...
                timeToStop*1000, args);
            
        end
        
        
        function stopVehicle(args)
            node = NodeList.GetNode(args.nodeId);
            mmObj = node.GetObject(args.mm);
            mmObj.SetVelocityAndAcceleration([0 0 0], [0 0 0]);
            
            Simulator.Schedule('vehicularMobility.startAccelerating', 5*1000, args);
            nodeListInfo.nodeAcceleration(args.nodeId+1,0);
        end
        
        function startAccelerating(args)
            node = NodeList.GetNode(args.nodeId);
            mmObj = node.GetObject(args.mm);
            mmObj.SetVelocityAndAcceleration([0 0 0], [2 0 0]);
            Simulator.Schedule('vehicularMobility.stopAccelerating', ...
                10*1000, args);
            nodeListInfo.nodeAcceleration(args.nodeId+1,2);
        end
        
    end
    
end

