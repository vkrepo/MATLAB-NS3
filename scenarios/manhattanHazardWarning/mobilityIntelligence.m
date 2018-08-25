classdef mobilityIntelligence
    % This class has functions which defines reaction based on a received packet
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties
        
    end
    
    methods (Static)
        % Take action based on 'hazard-warning' reception
        function handleHazardWarning(nodeId, payload, len)
            
            % Code to handle reception of hazard warning packet
            % ***********  Hazard Warning payload format *****************%
            %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
            %      streetId(2 bytes), xPos(2 bytes), yPos (2 bytes), zPos(2
            %      bytes)%
            
            hazardStreetId = typecast([payload(5) payload(6)], 'uint16');
            route = nodeListInfo.routeObj(nodeId+1);
            currStreetIndex = route.getCurrentStreetIndex();
            currentStreetId = route.getStreetIdByIndex;
            % Check if this is not the last street in the route
            if(route.getRouteLen() >= currStreetIndex+1)
                nextStreetId =  route.getStreetIdByIndex(currStreetIndex+1);
                %% Handle the case where next street in the journey has the hazard
                if(nextStreetId == hazardStreetId)
                    % Get manhattan topology object
                    topology = nodeListInfo.getSetTopology();
                    currStreet = topology.getStreetInfo(currentStreetId);
                    destStreetId = route.getStreetIdByIndex(route.getRouteLen());
                    altRouteFound=0;
                    % Now the vehicle need to find an alternate route to
                    % destination, it does so by checking possible routes
                    % in all 4 possible directions (left, right, straight,
                    % uTurn) where hazard can be avoided.
                    if(currStreet.leftId ~= nextStreetId && currStreet.leftId ~= 0 )
                        % Find a route through left
                        altRoute = vehicularRoute.findRoute(currStreet.leftId, ...
                            destStreetId) ;
                        if(~ismember(nextStreetId, altRoute))
                            altRouteFound = 1;
                        end
                    end
                    if(altRouteFound ==0)
                        if(currStreet.rightId ~= nextStreetId && ...
                                currStreet.rightId ~= 0 )
                            % Find a route through right
                            altRoute = vehicularRoute.findRoute(...
                                currStreet.rightId, destStreetId) ;
                            if(~ismember(nextStreetId, altRoute))
                                altRouteFound = 1;
                            end
                        end
                    end
                    if(altRouteFound ==0)
                        if(currStreet.straightId ~= nextStreetId && ...
                                currStreet.straightId ~=0)
                            % Find a route through straight
                            altRoute = vehicularRoute.findRoute(currStreet.straightId, ...
                                destStreetId) ;
                            if(~ismember(nextStreetId, altRoute))
                                altRouteFound = 1;
                            end
                        end
                    end
                    if(altRouteFound ==0)
                        if(currStreet.uTurnId ~= nextStreetId && currStreet.uTurnId ~=0)
                            % Find a route through uTurn
                            altRoute = vehicularRoute.findRoute(currStreet.uTurnId, destStreetId) ;
                            if(~ismember(nextStreetId, altRoute))
                                altRouteFound = 1;
                            end
                        end
                    end
                    
                    if( altRouteFound ==1)
                        % Taking alternate route by overwriting original
                        % route with alternate route (with first street in
                        % the route being the next street. so setting
                        % correct street index as 0).
                        route.setRoute(nodeId+1, altRoute, 0 );
                        %alternateRouteIndex(1)
                        newStreetId = route.getStreetIdByIndex(1);
                        
                        % Logging re-routing event due to hazard.
                        time = Simulator.Now();
                        file = fopen('log_file.txt','a+');
                        fprintf (file,'%f %d %d %f %f %f %d %d %d\n', time, ...
                            visualizerTraces.ALTERNATE_ROUTE_EVENT, nodeId, 0, 0, ...
                            0, nextStreetId, newStreetId, -1);
                        fclose(file);
                        % Increment the count of success by 1
                        nodeListInfo.hazardAvoidanceCount(1);
                    end
                    
                    
                    
                    
                end
                %% Handle the case where vehicle is already on the hazard street
                % The vehicle needs to stop.
                if(currentStreetId == hazardStreetId)
                    % If already vehicle is not stationary due to hazard ahead.
                    if(nodeListInfo.hazardStopFlag(nodeId+1) == 0)
                        
                        node = NodeList.GetNode(nodeId);
                        mmObj = node.GetObject('ConstantVelocityMobilityModel');
                        velocity = mmObj.GetVelocity();
                        vehicleVelDir = velocity/norm(velocity);
                        posVehicle = mmObj.GetPosition();
                        
                        hazardX = double(typecast([payload(7) payload(8)], 'uint16'));
                        hazardY = double(typecast([payload(9) payload(10)], 'uint16'));
                        hazardZ = double(typecast([payload(11) payload(12)], 'uint16'));
                        
                        vectorToHazard = [hazardX hazardY hazardZ] - ...
                            [posVehicle(1) posVehicle(2) posVehicle(3)];
                        dirToHazard = vectorToHazard/norm(vectorToHazard);
                        
                        % Check whether vehicle is approaching the hazard.
                        % Beacause it need not stop even if it is on the same
                        % road as hazard but has already gone past the hazard
                        % before it popped up.
                        if(vehicleVelDir == dirToHazard)
                            mmObj.SetVelocity([0 0 0]);
                            %{
                    eventId = nodeListInfo.nodeTimerList(nodeId+1);
                    Simulator.cancel(eventId);
                            %}
                            nodeListInfo.hazardStopFlag(nodeId+1, 1);
                            route.setCurrentStreetIndex(route.getRouteLen()); %Setting
                            % current street index to final so that when end of road
                            % timer expires the node will not have next road. Basically
                            % this is to make node stop. TODO: cancel timer which was
                            % started at the start of road
                            
                            % Logging Vehicle STOP event.
                            time = Simulator.Now();
                            file = fopen('log_file.txt', 'a+');
                            fprintf (file, '%f %d %d %f %f %f %d %d %d\n',time, ...
                                visualizerTraces.VEHICLE_STOP_EVENT, nodeId, ...
                                -1, -1, -1, currentStreetId, -1, -1);
                            fclose(file);
                            % Increment the count of stoppages by 1
                            nodeListInfo.hazardStoppageCount(1);
                            
                        end
                    end
                end
                
            end
        end
        
        function handleHazardRemovedPkt(nodeId, payload, len)
            
            if(nodeListInfo.hazardStopFlag(nodeId+1) == 1)
                % Code to handle reception of 'hazard removed' packet
                % ***********  'Hazard removed'payload format *******************************%
                %      pktType(1 byte), time-to-live(1 byte), nodeId(2 bytes)
                %      streetId(2 bytes)
                
                hazardStreetId = typecast([payload(5) payload(6)], 'uint16');
                route = nodeListInfo.routeObj(nodeId+1)
                currentStreetId = route.getStreetIdByIndex();
                % Vehicle is stopped due hazard. Make it move along its
                % journey now.
                if(currentStreetId == hazardStreetId)
                    node = NodeList.GetNode(nodeId);
                    mmObj = node.GetObject('ConstantVelocityMobilityModel');
                    position = mmObj.GetPosition();
                    topology = getSetTopology();
                    streetInfo = topology.getStreetInfo(nextStreetId);
                    endOfStreetVec = (streetInfo.endPosition - position);
                    endOfstreet = norm(endOfStreetVec);
                    speed = 10;
                    mmObj.SetVelocity(speed .* streetInfo.direction);
                    timeToEndOfStreet = endOfstreet/speed;
                    % Setting mobility parmaters for all vehicles .
                    args.topology = topology;
                    args.nodeId = nodeId;
                    args.routeInfo =  nodeListInfo.routeObj(nodeId+1);
                    args.mm = 'ConstantPositionMobilityModel';
                    args.acceleration = 0;
                    
                    args.offset = 0; % Vehicle to be placed at start of road.
                    eventId = Simulator.Schedule('vehicularMobility.setVehiclePosAndVelocity', ...
                        timeToEndOfStreet*1000, args);
                    nodelistInfo.hazardStopFlag(nodeId+1, 0);
                    % Stroing event ID which may be used late for
                    % cancellation
                    nodeListInfo.nodeTimerList(nodeId+1, eventId);
                    
                end
            end
            
        end
        
    end
    
end

