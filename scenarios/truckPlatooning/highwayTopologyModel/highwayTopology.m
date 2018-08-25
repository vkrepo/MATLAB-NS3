classdef highwayTopology < handle
    % TOPOLOGY  Defines the whole topology template
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties %(Access = private)
        highwayOrigin % Origin
        laneCount % Number of lanes in the highway
        laneWidth % Width of each lane
        highwayLength % length of highway
        direction % Direction of highway. Such positive-x[1 0 0], negative-x[-1 0 0],positive-y[0 1 0], negative-y[0 -1 0]
        lanes = lane % All lanes in the highway.
    end
    
    methods
        % Creating Highway
        function createHighwayTopology(obj,laneCount, laneWidth, highwayLength)
            % Setting topology-defining parameters
            obj.highwayOrigin = [0 0 0];
            obj.laneCount = laneCount;
            obj.laneWidth = laneWidth;
            obj.highwayLength = highwayLength;
            obj.direction = [1 0 0];
            
            
            % Create the highway lane-by-lane 
            for laneIndex=1:laneCount
                % calculate start coordinate of each lane based on its
                % index(i.e. id) and direction
                startPos = obj.highwayOrigin + [abs(obj.direction(2)) ...
                           abs(obj.direction(1)) abs(obj.direction(3))].*[((laneIndex-1)*obj.laneWidth + ...
                           (obj.laneWidth/2)) ((laneIndex-1)*obj.laneWidth + ...
                           (obj.laneWidth/2)) 0];
                
                newLane = lane ;% Creating a new lane instance
                newLane.createLane(laneIndex,startPos, obj.direction,obj.highwayLength);
                
                % adding lane to the array of lanes in highway at index equals to id of lane  
                obj.lanes(laneIndex) = newLane;
                
                % Setting left lane Id. Set to 0 if no left lane.
                newLane.setLeftLane(obj.laneCount);
                
                % Setting right lane Id. Set to 1 if no right lane.
                newLane.setRightLane(obj.laneCount);
                
            end
        end
        % Get lane Information
        function lane = getLaneInfo(obj,laneId)
            lane = obj.lanes(laneId);
        end
        
    end
    
end


