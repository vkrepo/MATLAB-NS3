classdef lane < handle
    % Highway lane class
    % Each lane in the highway is an instance of this class
    % with various attributes as defined below
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties%(Access = private)
        id % Unique lane/road identifier in the highway.
        direction % direction vector of lane.
        length % length of lane.
        startPosition % starting coordinates of lane.
        endPosition % ending coordinates of lane.
        leftId % left lane id
        rightId % right lane id     
    end
    
    methods
% 	% destructor method
% 	function delete(obj)
% 	   %disp('destructor of lane object is called');
% 	end

        % Create a single directional lane
        function createLane(lane,id,startPos, direction,length)
            lane.id = id;
            lane.length = length;
            lane.direction = direction;
            lane.startPosition = startPos;
            lane.endPosition = startPos + (direction.*[length length 0]); % Assuming direction of lane is only along x or along y
        end
        
        % set left lane id for the passed lane
        function setLeftLane( lane, laneCount)
            if(isequal(lane.direction,[1 0 0]) || isequal(lane.direction,[0 -1 0])) % i.e. for +x or -y direction highways
                if(lane.id == laneCount)
                    lane.leftId = 0; % last lane does not have any left lane;
                else
                    lane.leftId = lane.id +1;
                end
            else  %-x or +y directions
                if(lane.id == 1)
                    lane.leftId = 0; % first lane does not have any left lane;
                else
                    lane.leftId = lane.id-1;
                end
            end
        end
        % set right lane id for the passed lane
        function setRightLane(lane ,laneCount)
            if(isequal(lane.direction,[1 0 0]) || isequal(lane.direction,[0 -1 0])) % i.e. +x or -y
                if(lane.id == 1)
                    lane.rightId = 0; % first lane does not have any right lane;
                else
                    lane.rightId = lane.id -1;
                end
            else
                if(lane.id == laneCount)
                    lane.rightId = 0; % last lane does not have any right lane;
                else
                    lane.rightId = lane.id +1;
                end
            end
            
        end
        
        function delete(obj)
            delete(obj);
        end
    end
end
    
