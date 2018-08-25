classdef vehicularRoute < handle
    % For each node, object of this class has its route,
    % and other related properties and functions.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties
        vehicleId % ID of vehicle which route belongs to
        route % route of a vehicle. its a sequence of road ids
        currentRoadIndex % index of road on which vehicle currently is.
        % In this scenario vehicle remains on a single lane
        % all thoughout so it remains 1 after
        % journey starts and 0 before starting off.
    end
    
    methods
        % Setting up the route attributes
        % set the route object attributes
        function setRoute( obj, vehicleId, route, roadIndex)
            obj.vehicleId = vehicleId;
            obj.route = route;
            if(nargin == 4)
                obj.currentRoadIndex = roadIndex;
            else
                % Initializing at street index 0
                obj.currentRoadIndex = 0;
            end
            
        end
        
        % Increment route index indicating that vehicle is moving to next
        % road
        function nextIndex = incrementRouteIndex(obj)
            sizeN = size(obj.route, 2);
            
            if(obj.currentRoadIndex == sizeN) % return zero if journey has
                % ended.
                nextIndex = 0;
            else
                obj.currentRoadIndex = obj.currentRoadIndex + 1;
                nextIndex = obj.currentRoadIndex;
            end
        end
        
        
        % get road id from the index in the complete route.
        function roadId = getRoadIdByIndex(obj, index)
            switch nargin
                case 1
                    % if no index is specified then returning current
                    % road on which node is present/moving.
                    roadId = obj.route(obj.currentRoadIndex);
                case 2
                    roadId = obj.route(index);
            end
        end
        
        % Get current index of road with respect to all the roads
        % along the journey
        function roadIndex = getCurrentRoadIndex(obj)
            roadIndex = obj.currentRoadIndex;
        end
        
        % Set current road index.
        function setCurrentRoadIndex(obj, roadIndex)
            obj.currentRoadIndex = roadIndex;
        end
        
        
        % Return route len.
        function routeLen = getRouteLen(obj)
            routeLen = size(obj.route, 2);
        end
        
        function delete(obj)
            delete(obj);
        end
    end
end

