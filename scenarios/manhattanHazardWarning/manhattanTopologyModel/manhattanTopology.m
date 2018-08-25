classdef manhattanTopology < handle
    % TOPOLOGY  Defines the whole topology template
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties
        gridOrigin % Coordinates of grid Origin
        horBlocks % Number of horizontal blocks
        verBlocks % Number of vertical blocks
        streetWidth % width of street. All streets are assumed to of similar width
        streets = street % All streets in manhattan grid.
        horStreetSize  % length of each horizontal streets in metres
        verStreetSize % length of each vertical street in metres
        streetCount % Total number of streets
        
    end
    
    methods
        % Creating Manhattan grid topology
        function createManhattanGrid(obj, horBlocks, verBlocks, ...
                streetWidth, streetLen)
            % Setting topology-defining parameters
            obj.gridOrigin = [0 0 0];
            obj.horBlocks = horBlocks;
            obj.verBlocks = verBlocks;
            obj.streetWidth = streetWidth;
            obj.horStreetSize = streetLen;
            obj.verStreetSize = streetLen  ;
            
            obj.streetCount=0; % Initialized to zero, incremented with every street creation
            
            
            %Topology is created by first creating all horizontal streets (+x
            %as well as -x direction) followed by all vertical streets (+y and -y directions).
            
            %  When a street is created its left-turn street, right-turn street, straight street, U-turn
            % street Ids are also set (Note: Only ids are set, the actual
            % street object may be created later in the defined order)
            
            % Create all +x and -x direction streets
            obj.createHorizontalStreets();
            
            % Create all +y and -y direction streets
            obj.createVerticalStreets();
            
            
        end
        
        
        % Get Road Id By block Index
        % Ther can be 4 types of streets: +x +y -x -y
        function streetId = getStreetIdForBlock(obj,hBlock, VBlock, str)
            if(str=='+x')
                streetId = (VBlock-1)*obj.horBlocks*2 + hBlock;
            elseif(str == '-x')
                streetId = (VBlock-1)*obj.horBlocks*2 -hBlock +1;
            elseif(str == '+y')
                totalHRoads = (obj.horBlocks*(obj.verBlocks-1)*2);
                streetId = totalHRoads + (hBlock-2)*obj.verBlocks*2 + VBlock ;
            elseif(str == '-y')
                totalHRoads = (obj.horBlocks*(obj.verBlocks-1)*2);
                streetId = totalHRoads + (hBlock)*obj.verBlocks*2 - VBlock +1;
                
            end
        end
        
        
        
        
        % Get Road Id By origin offset index
        % Ther can be 4 types of streets: +x +y -x -y
        function streetId = getStreetId(obj,hIndex, vIndex, str)
            if(str=='+x')
                streetId = (vIndex-1)*obj.horBlocks*2 + hIndex;
            elseif(str == '-x')
                streetId = (vIndex*obj.horBlocks*2 -hIndex +1);
            elseif(str == '+y')
                totalHRoads = (obj.horBlocks*(obj.verBlocks-1)*2);
                streetId = totalHRoads + (hIndex-1)*obj.verBlocks*2 + vIndex;
            elseif(str == '-y')
                totalHRoads = (obj.horBlocks*(obj.verBlocks-1)*2);
                streetId = totalHRoads + (hIndex-1)*obj.verBlocks*2 + 2*obj.verBlocks - vIndex +1;
            end
        end
        
        % Create all horizontal streets and set left-turn, right-turn ,
        % straight and U-turn streets w.r.t each of them. Streets are
        % created in pairs as each street has a corresponding opposite
        % direction street
        function createHorizontalStreets(obj)
            for vIndex=1:(obj.verBlocks-1)
                hstartPos = obj.gridOrigin + [0 ((vIndex)*obj.verStreetSize + (vIndex-1)*2*obj.streetWidth + (obj.streetWidth/2)) 0];
                for hIndex=1:(obj.horBlocks)
                    % creating +ve X-axis steet
                    newStreet = obj.createStreet(hstartPos, [1 0 0], obj.horStreetSize);
                    
                    newStreet.id = obj.getStreetId(hIndex,vIndex,'+x');
                    obj.streets(newStreet.id) = newStreet;
                    newStreet.setLeftStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '+x');
                    newStreet.setRightStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '+x');
                    newStreet.setStraightStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '+x');
                    newStreet.setUTurnStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '+x');
                    
                    
                    
                    % creating corrsponding -ve X-axis street
                    % X-coordinate of start point of -ve X-street is X-coordinate of end point of its corresponding -X
                    % while its Ycoordinate is 1 street width above Y-coordinate of corresponding +X street
                    negHstartPos = hstartPos + [obj.horStreetSize obj.streetWidth 0]; % calclating -ve X street start pos
                    
                    %Create street
                    newStreet = obj.createStreet(negHstartPos, [-1 0 0], obj.horStreetSize);
                    %calculate street Id
                    newStreet.id = obj.getStreetId(hIndex,vIndex,'-x');
                    
                    newStreet.setLeftStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '-x');
                    newStreet.setRightStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '-x');
                    newStreet.setStraightStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '-x');
                    newStreet.setUTurnStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '-x');
                    
                    obj.streets(newStreet.id) = newStreet;
                    
                    hstartPos = hstartPos + [obj.horStreetSize+2*obj.streetWidth 0  0]; % Moving to coordinate of next hor street
                    
                    
                end
            end
            
        end
        % Create all vertical streets and set left-turn, right-turn ,
        % straight and U-turn streets w.r.t each of them
        function createVerticalStreets(obj)
            for hIndex=1:(obj.horBlocks-1)
                vStartPos = obj.gridOrigin + [((hIndex)*obj.horStreetSize + ...
                    (hIndex-1)*2*obj.streetWidth + (1.5*obj.streetWidth)) 0 0];
                for vIndex=1:(obj.verBlocks)
                    % As every street has a corresponding opposite
                    % direction street, street are created in pairs
                    
                    % ******* Start: Positive y-axis street related code block *********%
                    
                    % creating a +ve Y-axis steet
                    newStreet = obj.createStreet(vStartPos, [0 1 0], obj.verStreetSize);
                    
                    % Fetching its id
                    newStreet.id = obj.getStreetId(hIndex,vIndex,'+y');
                    
                    
                    % Setting left,right,straight,u-turn streets w.r.t
                    % just created +y directional street
                    newStreet.setLeftStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '+y');
                    newStreet.setRightStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '+y');
                    newStreet.setStraightStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '+y');
                    newStreet.setUTurnStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '+y');
                    
                    
                    % ******* END: Positive y-axis street related code block *********%
                    
                    
                    
                    
                    % **************START: Corresponding -ve Y-axis street related code block**********
                    
                    obj.streets(newStreet.id) = newStreet;
                    % creating corrsponding -ve Y-axis street.
                    % Start point is end point of its corresponding -Y street
                    negVstartPos = vStartPos + [-obj.streetWidth obj.verStreetSize 0]; % calclating -ve Y street start pos
                    %negVstartPos = vStartPos + [obj.streetWidth obj.verStreetSize 0]; % calclating -ve Y street start pos
                    %Create street
                    newStreet = obj.createStreet(negVstartPos, [0 -1 0], obj.verStreetSize);
                    %calculate street Id
                    newStreet.id = obj.getStreetId(hIndex,vIndex,'-y');
                    
                    newStreet.setLeftStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '-y');
                    newStreet.setRightStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '-y');
                    newStreet.setStraightStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '-y');
                    newStreet.setUTurnStreetId(hIndex, vIndex, obj.horBlocks, obj.verBlocks, '-y');
                    
                    % add street object to array of streets
                    obj.streets(newStreet.id) = newStreet;
                    
                    % **************END: -ve Y-axis street related code block**********
                    vStartPos = vStartPos + [0 obj.verStreetSize+2*obj.streetWidth 0]; % Moving to coordinate of next hor street
                    
                end
            end
        end
        
        % Create a single directional street
        function newStreet = createStreet(obj,startPos, direction,length)
            newStreet = street; % Create a street object
            obj.streetCount = obj.streetCount+1;
            newStreet.length = length;
            newStreet.direction = direction;
            newStreet.startPosition = startPos;
            newStreet.endPosition = startPos + (direction.*[length length 0]); % Assuming direction of street is only along x or along y
        end
        
        % Get street Information
        function street = getStreetInfo(obj,streetId)
            street = obj.streets(streetId);
        end
        
        function delete(obj)
        end
    end
    
end

