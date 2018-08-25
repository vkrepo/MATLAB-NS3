classdef vehicularMobility < handle
    % This class has functions to set mobility model on vehicles and move
    % them along their routes.
    
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
        function setMobilityModel(nodeId, mobilityModel)
            % Get node from node id
            node = NodeList.GetNode(nodeId);
            % creates Mobility Helper object */
            mobility = MobilityHelper();
            mobility.SetMobilityModel (mobilityModel);
            % installs mobility on node */
            mobility.Install (node);
        end
        
        % Set Position and velocities of vehicles For each vehicle, this
        % function shall be called for setting initial position as well as
        % whenever it reaches end of the road.
        function setVehiclePosAndVelocity(args)
            % Get node from node id
            node = NodeList.GetNode(args.nodeId);
            % Getting the mobility model object
            mmObj = node.GetObject(args.mm);
            
            % Check whether vehicle has crashed into hazard. If not only
            % then move to next road
            collisionFlag = 0;
            % Check if hazard is present in topology
            if(hazard.getSetHazardPresenceFlag() == 1)
                % Check if vehicle has completed at least 1 road
                if(args.routeInfo.getCurrentStreetIndex() > 0)
                    % Check if vehicle is on the road having hazard
                    if(args.routeInfo.getStreetIdByIndex() == ...
                            hazard.getSetHazardRoad())
                        %Check whether vehicle collided with hazard
                        vehPos = mmObj.GetPosition();
                        velocity = mmObj.GetVelocity();
                        hazardPos = hazard.getSetHazardPos();
                        distance = norm(vehPos - hazardPos);
                        timeGap = distance/(norm(velocity));
                        timeS = Simulator.Now();
                        VehTSHazardPos = (timeS - timeGap)*1000; % In millisecs
                        
                        % Get entry and exit time of hazard
                        [hazardEntryT, hazardExitT] = hazard.getSetHazardTimeSlot();
                        
                        % Check if hazard was present when it crossed the
                        % hazard position
                        if(VehTSHazardPos >= hazardEntryT && ...
                                VehTSHazardPos <= hazardExitT)
                            collisionFlag = 1;
                            mmObj.SetVelocity([0 0 0]);
                            nodeListInfo.hazardCollisionCount(1);
                            % Logging collision event due to hazard.
                            time = Simulator.Now();
                            file = fopen('log_file.txt','a+');
                            fprintf (file,'%f %d %d %f %f %f %d %d %d\n', time, ...
                                visualizerTraces.HAZARD_COLLISION_EVENT, ...
                                args.nodeId, hazard.getSetHazardRoad(), 0, ...
                                0, -1, -1, -1);
                            fclose(file);
                        end
                        
                    end
                end
            end
            
            % If vehicle did not collide
            if(collisionFlag ~=1 )
                % increment the route index by 1 (i.e. to next street) and
                % return it,  0 is returned if destination is reached
                nextIndex = args.routeInfo.incrementRouteIndex();
                
                if(nextIndex ~= 0) % journey not ended
                    nextStreetId = args.routeInfo.getStreetIdByIndex(nextIndex);
                    streetInfo = args.topology.getStreetInfo(nextStreetId);
                    if(streetInfo.direction == [1 0 0])
                        nextPos = streetInfo.startPosition + ...
                                  [args.offset 0 0];
                    elseif(streetInfo.direction == [-1 0 0])
                        nextPos = streetInfo.startPosition + ...
                                  [-args.offset 0 0];
                    elseif(streetInfo.direction == [0 1 0])
                        nextPos = streetInfo.startPosition + ...
                                  [0 args.offset 0];
                    elseif(streetInfo.direction == [0 -1 0])
                        nextPos = streetInfo.startPosition + ...
                                  [0 -args.offset 0];
                    end
                    
                    % sets node position */
                    mmObj.SetPosition(nextPos);
                    if(strcmp(args.mm, 'ConstantVelocityMobilityModel'))
                        mmObj.SetVelocity(args.speed .* streetInfo.direction);
                        if(args.speed ~= 0)
                            timeToEndOfStreet = (streetInfo.length - ....
                                args.offset)/args.speed;
                            %eventId = Simulator.Schedule('vehicularMobility.setVehiclePosAndVelocity', ...
                            %timeToEndOfStreet*1000, args);
                            Simulator.Schedule('vehicularMobility.setVehiclePosAndVelocity', ...
                                timeToEndOfStreet*1000, args);
                            % Stroing event ID which may be used late for
                            % cancellation
                            %nodeListInfo.nodeTimerList(args.nodeId+1, eventId);
                        end
                    end
                    
                else
                    %Vehicle reached its destination,so stopping it
                    mmObj.SetVelocity([0 0 0]);
                    timeS = Simulator.Now();
                    file = fopen('log_file.txt','a+');
                    fprintf (file,'%f %d %d %f %f %f %d %d %d\n',timeS, ...
                        visualizerTraces.JOURNEY_COMPLETE_EVENT, args.nodeId, ...
                        -1, -1, -1, -1, -1, -1);
                    fclose(file);
                    
                end
            end
        end
        
        % Set initial position and velocities of rogue vehicles After that
        % this function shall be called whenever a vehicle reaches end of
        % the road.
        function setRogueVehiclePosAndVelocity(args)
            % Get node from node id
            node = NodeList.GetNode(args.nodeId);
            % Getting the mobility model object
            mmObj = node.GetObject(args.mm);
            
            
            
            % increment the route index by 1 (i.e. to next street) and
            % returns it, returns 0 if % destination is reached
            nextIndex = args.routeInfo.incrementRouteIndex();
            if(nextIndex == 0) % Completed route so traverse again
                args.routeInfo.setCurrentStreetIndex(1);
                nextIndex = 1;
            end
            nextStreetId = args.routeInfo.getStreetIdByIndex(nextIndex);
            streetInfo = args.topology.getStreetInfo(nextStreetId);
            if(streetInfo.direction == [1 0 0])
                nextPos = streetInfo.startPosition + [args.offset 0 0];
            elseif(streetInfo.direction == [-1 0 0])
                nextPos = streetInfo.startPosition + [-args.offset 0 0];
            elseif(streetInfo.direction == [0 1 0])
                nextPos = streetInfo.startPosition + [0 args.offset 0];
            elseif(streetInfo.direction == [0 -1 0])
                nextPos = streetInfo.startPosition + [0 -args.offset 0];
            end
            
            % sets node position */
            mmObj.SetPosition(nextPos);
            if(strcmp(args.mm, 'ConstantVelocityMobilityModel'))
                mmObj.SetVelocity(args.speed .* streetInfo.direction);
                if(args.speed ~= 0)
                    
                    timeToEndOfStreet = (streetInfo.length - args.offset)/args.speed;
                    if(args.offset ~=0 )
                        args.offset = 0; % Start offset is only for the first road in route.
                    end
                    Simulator.Schedule('vehicularMobility.setRogueVehiclePosAndVelocity', ...
                                       timeToEndOfStreet*1000, args);
                end
            end
            
        end
        
    end
    
end

