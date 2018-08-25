classdef nodeListInfo < handle
    % For each node, persistent arrays in each function store node related
    % information which can be get/set when required. The index in the arrays
    % defines the node id. For example: if current acceleration of vehicles is
    % stored in 'acceleration' array, acceleration(5) holds acceleration of 5th
    % node.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    methods(Static)
        
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
        
        
        % Set/Get acceleration value of node. If acceleration is passed as
        % second argument then used as set function. Returns the current
        % acceleration value
        function currentAcceleration = nodeAcceleration(vehicleId, acceleration)
            
            persistent nodeAccel;
            if(nargin >= 2)  % Using as a set function for setting accel.
                nodeAccel(vehicleId) = acceleration;
            end
            currentAcceleration = nodeAccel(vehicleId);
            
        end
        % Update tX count of vehicle
        function txCount = nodeTxCount(vehicleId, pktCount)
            persistent txCountList;
            if(nargin >= 2)  % Using as a set function.
                if(pktCount>0)
                    txCountList(vehicleId) = txCountList(vehicleId) + ...
                        pktCount;
                else
                    txCountList(vehicleId) = 0;
                end
                
            end
            
            txCount = txCountList(vehicleId);
        end
        
        % update rx count of vehicle
        function rxCount = nodeRxCount(vehicleId, pktCount)
            persistent rxCountList;
            if(nargin >= 2)  % Using as a set function
                if(pktCount>0)
                    rxCountList(vehicleId) = rxCountList(vehicleId) + ...
                        pktCount;
                else
                    rxCountList(vehicleId) = 0;
                end
            end
            
            rxCount = rxCountList(vehicleId);
        end
        
        % update rx count from preceding vehicle
        function rxCount = nodePrecedingRxCount(vehicleId, pktCount)
            persistent precedingRxCountList;
            if(nargin >= 2)  % Using as a set function
                if(pktCount>0)
                    precedingRxCountList(vehicleId) = ...
                        precedingRxCountList(vehicleId) + pktCount;
                else
                    precedingRxCountList(vehicleId) = 0;
                end
            end
            
            rxCount = precedingRxCountList(vehicleId);
        end
        
        % update last Rx time  of platoon beacon
        function lastRxT = lastRxTime(vehicleId, rxTime)
            persistent lastRxTime;
            if(nargin >= 2)  % Using as a set function
                lastRxTime(vehicleId) = rxTime;
            end
            lastRxT = lastRxTime(vehicleId);
        end
        
        
        % update worst RX time gap of platoon beacon
        function worstRxGapPB = worstPlatoonBeaconRxGap(vehicleId, gap)
            persistent worstRxGap;
            if(nargin >= 2)  % Using as a set function
                if(gap > 0)
                    if(worstRxGap(vehicleId) < gap)
                        worstRxGap(vehicleId) = gap;
                    end
                else
                    worstRxGap(vehicleId) = 0;
                end
            end
            worstRxGapPB = worstRxGap(vehicleId);
        end
        
        % update last Rx time  of platoon beacon
        function stoppedFlag = stoppedFlag(vehicleId, flag)
            persistent nodeStopFlag;
            if(nargin >= 2)  % Using as a set function
                nodeStopFlag(vehicleId) = flag;
            end
            stoppedFlag = nodeStopFlag(vehicleId);
        end
        
        % Update/Get per node communication break info
        % breakType could be consecutive 2 packets, 3 packets, 4 packets,
        % 5 packets loss
        function count = getSetCommBreak(vehicleId, breakType, count)
            persistent communicationBreakInfo;
            if(nargin >=3)
                if(count ~= 0)
                    communicationBreakInfo(vehicleId).(breakType) = ...
                        communicationBreakInfo(vehicleId).(breakType) + count;
                else
                    communicationBreakInfo(vehicleId).(breakType) = 0;
                end
            end
            count = communicationBreakInfo(vehicleId).(breakType);
        end
        
        %Set/Get Safe zone flag
        function flagVal = getSetSafeZoneFlag(vehicleId, flag)
            persistent safeFlag;
            if(nargin >= 2)  % Using as a set function
                safeFlag(vehicleId) = flag;
            end
            flagVal = safeFlag(vehicleId);
        end
        
        
    end
end

