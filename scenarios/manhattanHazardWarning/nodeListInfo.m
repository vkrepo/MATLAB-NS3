classdef nodeListInfo < handle
    % For each node, persistent arrays in each function store node related
    % information which can be get/set when required. The index in the arrays
    % defines the node id. For example: if TX count of vehicles is
    % stored in 'txCount' array, txCount(5) holds TX count of 5th
    % node.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    methods(Static)

         % Set/Get route object of vehicle
        function route = routeObj(vehicleId, routeObj)
            
            persistent routeObjs;
            if(isempty(routeObjs))
                routeObjs = vehicularRoute;
            end
            if(nargin >= 2)  % Using as a set function for adding route obj
                routeObjs(vehicleId) = routeObj;
            end
            route = routeObjs(vehicleId);
            
        end
        % Set/Get TX count of vehicle
        function txCount = nodeTxCount(vehicleId, pktCount)
            persistent txCountList;
            if(nargin >= 2)  % Using as a set function.
                if(pktCount>0)
                    txCountList(vehicleId) = txCountList(vehicleId) + pktCount;
                else
                    txCountList(vehicleId) =0;
                end
                
            end
       
            txCount = txCountList(vehicleId);
        end
        
        % Set/Get rx count of vehicle
        function rxCount = nodeRxCount(vehicleId, pktCount)
            persistent rxCountList;
            if(nargin >= 2)  % Using as a set function
                if(pktCount>0)
                    rxCountList(vehicleId) = rxCountList(vehicleId) + pktCount;
                else
                    rxCountList(vehicleId) = 0;
                end
            end
            
            rxCount = rxCountList(vehicleId);
        end
        
        % Set/Get hazard warning rx count of vehicle
        function rxCount = nodeHazardWarningRxCount(vehicleId, pktCount)
            persistent rxCountList;
            if(nargin >= 2)  % Using as a set function
                if(pktCount>0)
                    rxCountList(vehicleId) = rxCountList(vehicleId) + pktCount;
                else
                    rxCountList(vehicleId) = 0;
                end
            end
            
            rxCount = rxCountList(vehicleId);
        end
        % Set/Get hazard warning tx count of vehicle
        function txCount = nodeHazardWarningTxCount(vehicleId, pktCount)
            persistent txCountList;
            if(nargin >= 2)  % Using as a set function
                if(pktCount>0)
                    txCountList(vehicleId) = txCountList(vehicleId) + pktCount;
                else
                    txCountList(vehicleId) = 0;
                end
            end
            
            txCount = txCountList(vehicleId);
        end
         % Set/Get event Id for timer started toreach end of the road 
        function eventId = nodeTimerList(vehicleId, id)
            persistent eventIdList;
            if(nargin >= 2)  % Using as a set function
                    eventIdList(vehicleId) = id;
            end
            eventId = eventIdList(vehicleId);
        end
         % Set/Get flag for a vehicle stopped due to hazard. If the flag is
         % set, it means vehicle has stopped on the road with hazard and
         % waiting for hazard to be removed.
        function stopFlag = hazardStopFlag(vehicleId, flag)
            persistent hazardStopFlagList;
            if(nargin == 2)  % Using as a set function
                    hazardStopFlagList(vehicleId) = flag;
            end
            stopFlag = hazardStopFlagList(vehicleId);
        end
        
         function topologyObj = getSetTopology(topology)
            persistent topologyVar;
            if(isempty(topologyVar))
                topologyVar = 0;
            end
            if(nargin == 1)  % Using as a set function
                    topologyVar= topology;
            end
            topologyObj = topologyVar;
         end
        
         % Get/Update hazard avoidance count.
         function hazardAvoidance = hazardAvoidanceCount(count )
            persistent hazardAvoidanceCount;
            if(nargin == 1)  % Using as a set function
              if(count > 0)   
                    hazardAvoidanceCount =  hazardAvoidanceCount + count;
                                                       
              else
                    hazardAvoidanceCount = 0; 
              end
            end
             hazardAvoidance = hazardAvoidanceCount;
         end
         
          % Get/Update hazard stoppage count. It is the count of cases
          % where vehicle stopped to avoid hazard.
         function hazardStoppage = hazardStoppageCount(count )
            persistent hazardStoppageCount;
            if(nargin == 1)  % Using as a set function
              if(count > 0)   
                    hazardStoppageCount =  hazardStoppageCount + count;
              else
                    hazardStoppageCount = 0; 
              end
            end
             hazardStoppage = hazardStoppageCount;
         end
         
          % Get/Set hazard collision count. It is the count of failure
          % case where vehicle collided with hazard
         function hazardCollision = hazardCollisionCount(count )
            persistent hazardCollisionCount;
            if(nargin == 1)  % Using as a set function
              if(count > 0)   
                    hazardCollisionCount =  hazardCollisionCount + count;
                                                       
              else
                    hazardCollisionCount = 0; 
              end
            end
             hazardCollision = hazardCollisionCount;
         end
    end
end

