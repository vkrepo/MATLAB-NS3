classdef vehicularRoute < handle
    % Each node has a route object of this class, which has route and
    % other related properties and functions.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
        
    properties
        vehicleId % Id of vehicle which route object belongs to
        route % Route of a vehicle. its a sequence of street ids
        currentStreetIndex % index of street on which vehicle currently is
        % w.r.t complete route. For example: %If route of a vehicle is:
        %1 4 5 6 10 and currently vehicle is on street ID 6 then
        %'currentStreetIndex' is 4
    end
    
    methods
        % set the route object attributes
        function setRoute( obj, vehicleId, route, streetIndex)
            obj.vehicleId = vehicleId;
            obj.route = route;
            if(nargin == 4)
                obj.currentStreetIndex = streetIndex;
            else
                % Initializing at street index 0 i.e vehicle is not
                % even placed at first street of route
                obj.currentStreetIndex = 0;
            end
            
        end
        
        % Increment route index by one and return it. For a vehicle it is
        % incremented when it completes a road in its route and moves to
        % next road in the route.
        function nextIndex = incrementRouteIndex(obj)
            sizeN = size(obj.route, 2); % get route length
            
            if(obj.currentStreetIndex == sizeN) % return zero if journey has ended.
                nextIndex = 0;
            else
                obj.currentStreetIndex = obj.currentStreetIndex + 1;
                nextIndex = obj.currentStreetIndex;
            end
        end
        
        % Get street Id by index in the route, if index is not passed
        % return the current street ID
        function streetId = getStreetIdByIndex(obj, index)
            switch nargin
                case 1
                    streetId = obj.route(obj.currentStreetIndex);
                case 2
                    streetId = obj.route(index);
            end
            
        end
        
        % Get index of current street with respect to all the streets in
        % the journey
        function streetIndex = getCurrentStreetIndex(obj)
            streetIndex = obj.currentStreetIndex;
        end
        
        % Set current index of street with respect to the journey.
        function setCurrentStreetIndex(obj, streetIndex)
            obj.currentStreetIndex = streetIndex;
        end
        
        
        % Return length of route
        function routeLen = getRouteLen(obj)
            routeLen = size(obj.route, 2);
        end
    end
    
    methods(Static)
        % Based on the road which hazard is on, for rogue vehicles, two
        % sets of cyclic routes are found, one which is near start point of
        % hazard road and another which is near end point of hazard road.
        % Basically these two routes are in vicinity of hazard and rogue
        % vehicles are set to move along these routes to create network
        % interference near to hazard. If the hazard road is near to
        % boundary of manhattan-grid, it may not have topology stretch in
        % both the direction. In that case only one route is returned by
        % this function and all rogue vehicles are placed there.
        function routeVector = createRogueRouteVector(args)
            % Get manhattan topology object
            topology = nodeListInfo.getSetTopology();
            street = topology.getStreetInfo(args.hazardRoadId);
            numRoute=0;
            leftId = street.leftId;
            if(leftId ~= 0) % hazard street has no left-turn.
                numRoute = numRoute + 1;
                route1(1) = leftId;
                leftStreet =  topology.getStreetInfo(leftId);
                uTurnId = leftStreet.uTurnId;
                route1(2) = uTurnId;
                uTurnStreet = topology.getStreetInfo(uTurnId);
                straightId = uTurnStreet.straightId;
                route1(3) = straightId;
                straightStreet = topology.getStreetInfo(straightId);
                uTurnId = straightStreet.uTurnId;
                route1(4) = uTurnId;
                routeVector{numRoute} = route1;
            end
            
            hazardUTurnId = street.uTurnId;
            hazardUTurn = topology.getStreetInfo(hazardUTurnId);
            leftId = hazardUTurn.leftId;
            if(leftId ~= 0) % hazard U-Turn street has no left-turn.
                numRoute = numRoute + 1;
                route2(1) = leftId;
                leftStreet =  topology.getStreetInfo(leftId);
                uTurnId = leftStreet.uTurnId;
                route2(2) = uTurnId;
                uTurnStreet = topology.getStreetInfo(uTurnId);
                straightId = uTurnStreet.straightId;
                route2(3) = straightId;
                straightStreet = topology.getStreetInfo(straightId);
                uTurnId = straightStreet.uTurnId;
                route2(4) = uTurnId;
                routeVector{numRoute} = route2;
            end
            
        end
        
        % Given source and destination road. It returns the path from start
        % of source road to end of destination road.
        function route = findRoute(sourceRoad, destRoad)
            % Get manhattan topology object
            topology = nodeListInfo.getSetTopology();
            valueSet = {
                % 4 values in each set is for +x direction, -x direction
                % +y direction, -y direction
                
                {'straight', 'uTurn', 'left', 'right'}, ...
                {'uTurn', 'straight', 'right', 'left'}, ...
                {'right', 'left', 'straight', 'uTurn'}, ...
                { 'left', 'right', 'uTurn', 'straight'}
                };
            keySet = {'+x', '-x', '+y', '-y'};
            
            %Here '+x' is mapped to  ['straight' 'uTurn' 'left' 'right']
            % It means:
            % After completing movement on a +x directional road for
            % moving along  +x direction - take straight
            % moving along -x direction - take uTurn
            % moving along +y direction - take left
            % moving along -y direction - take right
            dirVector= containers.Map(keySet,valueSet);
            
            index=1;
            route(index) = sourceRoad;
            currStreet = topology.getStreetInfo(sourceRoad);
            destStreet = topology.getStreetInfo(destRoad);
            currentPos = currStreet.endPosition;
            currentStreetDir = currStreet.direction;
            finalStartPos = destStreet.startPosition;
            currentStreetId = sourceRoad;
            
            recentTurn = cell(1);
            % Loop till current position becomes equal to start of end
            % road
            % If x-coordinate of start of destination road has been
            % matched then try to match y-coordinate
            while((abs(currentPos(1) - finalStartPos(1)) > 2*topology.streetWidth) || ...
                    (abs(currentPos(2) - finalStartPos(2)) > 2*topology.streetWidth))
                moveAlongYFlag = 1;
                avoidCycle=0;
                
                % First match x-coordinate (if possible)
                if(((finalStartPos(1) - currentPos(1)) > 2*topology.streetWidth))
                    
                    % Move in +x direction
                    if(currentStreetDir == [1 0 0])
                        mapVal = dirVector('+x');
                        nextTurn = mapVal(1);
                    elseif(currentStreetDir == [-1 0 0])
                        mapVal = dirVector('-x');
                        nextTurn = mapVal(1);
                    elseif(currentStreetDir == [0 1 0])
                        mapVal = dirVector('+y');
                        nextTurn = mapVal(1);
                    elseif(currentStreetDir == [0 -1 0])
                        mapVal = dirVector('-y');
                        nextTurn = mapVal(1);
                    end
                    
                    if(isequal(nextTurn, {'left'}))
                        currentStreetId = currStreet.leftId;
                    elseif(isequal(nextTurn, {'right'}))
                        currentStreetId = currStreet.rightId;
                    elseif(isequal(nextTurn, {'straight'}))
                        currentStreetId = currStreet.straightId;
                    elseif(isequal(nextTurn, {'uTurn'}))
                        currentStreetId = currStreet.uTurnId;
                        if(isequal(recentTurn, {'uTurn'}))
                            % Cannot take uturn after a uturn
                            avoidCycle = 1;
                        end
                    end
                    if(currentStreetId ~=0 && avoidCycle==0)
                        moveAlongYFlag = 0;
                    end
                elseif(((finalStartPos(1) -currentPos(1) ) < -2*topology.streetWidth))
                    % Move in -x  direction
                    if(currentStreetDir == [1 0 0])
                        mapVal = dirVector('+x');
                        nextTurn = mapVal(2);
                    elseif(currentStreetDir == [-1 0 0])
                        mapVal = dirVector('-x');
                        nextTurn = mapVal(2);
                    elseif(currentStreetDir == [0 1 0])
                        mapVal = dirVector('+y');
                        nextTurn = mapVal(2);
                    elseif(currentStreetDir == [0 -1 0])
                        mapVal = dirVector('-y');
                        nextTurn = mapVal(2);
                    end
                    
                    % Check if it is possible to take a street to
                    % move towards the x-coordinate of final street
                    
                    if(isequal(nextTurn, {'left'}))
                        currentStreetId = currStreet.leftId;
                    elseif(isequal(nextTurn, {'right'}))
                        currentStreetId = currStreet.rightId;
                    elseif(isequal(nextTurn, {'straight'}))
                        currentStreetId = currStreet.straightId;
                    elseif(isequal(nextTurn, {'uTurn'}))
                        currentStreetId = currStreet.uTurnId;
                    end
                    if(currentStreetId ~=0)
                        moveAlongYFlag = 0;
                    end
                end
                
                if(moveAlongYFlag == 1)
                    
                    if(((finalStartPos(2) - currentPos(2)) > 2*topology.streetWidth))
                        % Move in +y direction.depending on the
                        % current road dir. Next turn which moves
                        % towards +x is extracted from dirVector map
                        if(currentStreetDir == [1 0 0])
                            mapVal = dirVector('+x');
                            nextTurn = mapVal(3);
                        elseif(currentStreetDir == [-1 0 0])
                            mapVal = dirVector('-x');
                            nextTurn = mapVal(3);
                        elseif(currentStreetDir == [0 1 0])
                            mapVal = dirVector('+y');
                            nextTurn = mapVal(3);
                        elseif(currentStreetDir == [0 -1 0])
                            mapVal = dirVector('-y');
                            nextTurn = mapVal(3);
                        end
                        
                    elseif(((finalStartPos(2) -currentPos(2) ) < -2*topology.streetWidth))
                        % Move in -y  direction
                        if(currentStreetDir == [1 0 0])
                            mapVal = dirVector('+x');
                            nextTurn = mapVal(4);
                        elseif(currentStreetDir == [-1 0 0])
                            mapVal = dirVector('-x');
                            nextTurn = mapVal(4);
                        elseif(currentStreetDir == [0 1 0])
                            mapVal = dirVector('+y');
                            nextTurn = mapVal(4);
                        elseif(currentStreetDir == [0 -1 0])
                            mapVal = dirVector('-y');
                            nextTurn = mapVal(4);
                        end
                    end
                end
                
                % next turn direction has been identified, now get
                % start of next road.
                % nextTurn = cell2mat(nextTurn);
                
                if(isequal(nextTurn, {'left'}))
                    currentStreetId = currStreet.leftId;
                elseif(isequal(nextTurn, {'right'}))
                    currentStreetId = currStreet.rightId;
                elseif(isequal(nextTurn, {'straight'}))
                    currentStreetId = currStreet.straightId;
                elseif(isequal(nextTurn, {'uTurn'}))
                    currentStreetId = currStreet.uTurnId;
                end
                if(currentStreetId ==0)
                    nextTurn = {'uTurn'};
                    currentStreetId = currStreet.uTurnId;
                end
                currStreet = topology.getStreetInfo(currentStreetId);
                currentPos = currStreet.endPosition;
                currentStreetDir = currStreet.direction;
                index = index+1;
                route(index) = currentStreetId;
                recentTurn = nextTurn;
                
            end
            index=index+1;
            route(index) = destRoad;
        end
        
        % This function returns the routeVector containing journey of
        % all vehicles as a sequence of valid road Ids with all
        % vehicles having the road containing hazard in the journey.
        function routeVector = createRouteVector(journeyList, hazardRoadId)
            % Get manhattan topology object
            topology = nodeListInfo.getSetTopology();
            routeVector = cell(length(journeyList));
            
            % For journey of each vehicle, find a route
            for index=1:length(journeyList)
                journey = journeyList{index};
                startRoadDir = cell2mat(journey{1}(1));
                sourceHBlock = cell2mat(journey{1}(2));
                sourceVBlock = cell2mat(journey{1}(3));
                
                sourceRoadId =  topology.getStreetIdForBlock( ...
                    sourceHBlock, sourceVBlock,startRoadDir);
                
                endRoadDir = cell2mat(journey{2}(1));
                endHBlock = cell2mat(journey{2}(2));
                endVBlock = cell2mat(journey{2}(3));
                destRoadId =  topology.getStreetIdForBlock( ...
                    endHBlock, endVBlock, endRoadDir);
                
                hopRoadId = hazardRoadId;
                
                % Find route from source road to end of hop-road
                subRoute1 = vehicularRoute.findRoute(sourceRoadId, hopRoadId);
                
                % Find route from hop road to final destination
                subRoute2 = vehicularRoute.findRoute(hopRoadId, destRoadId);
                
                % Concatenate the routes to form complete route
                routeVector{index} = horzcat(subRoute1, subRoute2(2:end));
                
            end
                                               
            
        end
        
        
    end
    
end


