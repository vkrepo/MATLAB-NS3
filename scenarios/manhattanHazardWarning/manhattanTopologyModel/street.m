classdef street < handle
    % STREET Manhattan street class
    % Each street in the manhattan grid will be an instance of this class
    % with various attributes as defined below
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties
        id % Unique street/road identifier in the whole manhattan grid.
        direction % direction vector of street.
        length % length of street.
        startPosition % starting coordinates of street.
        endPosition % ending coordinates of street.
        leftId % left-turn street id from intersection.
        rightId % right-turn street id from intersection
        straightId % the street taken if vehicle moved straight after reaching intersection
        uTurnId % U-turn street id from intersection
    end
    
    methods
        % set left-turn street ids for the passed street object
        % street for which left-turn street id is calculated could be '+x'
        % '+y' '-x' '-y' in direction. Left street id will be calculated differently for all these cases.
        function setLeftStreetId( obj,hBlockIndex, vBlockIndex, hBlocks, vBlocks, str)
            if(str=='+x') % for positve x-dir street
                if(hBlockIndex == hBlocks)
                    leftStreetId = 0 ;% Last horizontal block's +x streets have no left so filling 0
                else
                    totalHorStreets = hBlocks*(vBlocks-1)*2;  % multiplying by 2 as every street has corresponding opposite street
                    leftStreetId = totalHorStreets + (hBlockIndex-1)*vBlocks*2 +vBlockIndex +1;
                end
                obj.leftId = leftStreetId;
                
            elseif(str=='-x') % for -ve x-dir street
                if(hBlockIndex == 1)
                    leftStreetId = 0; % First horizontal block's -x streets have no left so filling 0
                else
                    totalHorStreets = hBlocks*(vBlocks-1)*2;  % multiplying by 2 as every street has corresponding opposite street
                    leftStreetId = totalHorStreets + (hBlockIndex-2)*vBlocks*2 + (vBlocks-vBlockIndex) + vBlocks +1;
                end
                obj.leftId = leftStreetId;
                
            elseif(str=='+y') % for positive y-dir street
                if(vBlockIndex == vBlocks)
                    leftStreetId = 0; % Last vertical block's +y streets have no left so filling 0
                else
                    leftStreetId = (vBlockIndex-1)*hBlocks*2 + hBlocks + (hBlocks - hBlockIndex) +1 ;
                end
                obj.leftId = leftStreetId;
                
            elseif(str=='-y') % for positive y-dir street
                if(vBlockIndex == 1)
                    leftStreetId = 0; % First vertical block's -y streets have no left so filling 0
                else
                    %totalHorStreets = hBlocks*(vBlocks-1)*2  % multiplying by 2 as every street has corresponding opposite street
                    leftStreetId = (vBlockIndex-2)*hBlocks*2 + hBlockIndex +1 ;
                end
                obj.leftId = leftStreetId;
            end
            
        end
        
        % set right-turn street ids for the passed street object
        % street for which right-turn street id is calculated could be '+x'
        % '+y' '-x' '-y'. Right street id will be calculated differently for all these cases.
        function setRightStreetId( obj,hBlockIndex, vBlockIndex, hBlocks, vBlocks, str)
            if(str=='+x') % for positve x-dir street
                if(hBlockIndex == hBlocks)
                    rightStreetId = 0; % Last horizontal block's +x streets have no right-turn so filling 0
                else
                    totalHorStreets = hBlocks*(vBlocks-1)*2;  % multiplying by 2 as every street has corresponding opposite street
                    rightStreetId = totalHorStreets + (hBlockIndex-1)*vBlocks*2 + (vBlocks - vBlockIndex) + vBlocks +1;
                end
                obj.rightId = rightStreetId;
                
            elseif(str=='-x') % for -ve x-dir street
                if(hBlockIndex == 1)
                    rightStreetId = 0; % First horizontal block's -x streets have no right-turn so filling 0
                else
                    totalHorStreets = hBlocks*(vBlocks-1)*2;  % multiplying by 2 as every street has corresponding opposite street
                    rightStreetId = totalHorStreets + (hBlockIndex-2)*vBlocks*2 + vBlockIndex +1;
                end
                obj.rightId = rightStreetId;
                
            elseif(str=='+y') % for positive y-dir street
                if(vBlockIndex == vBlocks)
                    rightStreetId = 0; % Last vertical block's +y streets have no right-turn so filling 0
                else
                    %totalHorStreets = hBlocks*(vBlocks-1)*2  % multiplying by 2 as every street has corresponding opposite street
                    rightStreetId = (vBlockIndex-1)*hBlocks*2 + hBlockIndex +1 ;
                end
                obj.rightId = rightStreetId;
                
            elseif(str=='-y') % for positive y-dir street
                if(vBlockIndex == 1)
                    rightStreetId = 0; %  Last vertical block's -y streets have no right-turn so filling 0
                else
                    %totalHorStreets = hBlocks*(vBlocks-1)*2  % multiplying by 2 as every street has corresponding opposite street
                    rightStreetId = (vBlockIndex-2)*hBlocks*2 + (hBlocks-hBlockIndex) + hBlocks +1 ;
                end
                obj.rightId = rightStreetId;
            end
            
        end
        
        
        % set id of street straight after intersection for the passed street object
        % street for which straight street id is calculated could be '+x'
        % '+y' '-x' '-y'.  'Straight' street id will be calculated differently for all these cases.
        function setStraightStreetId( obj,hBlockIndex, vBlockIndex, hBlocks, vBlocks, str)
            if(str=='+x') % for positve x-dir street
                if(hBlockIndex == hBlocks)
                    straightStreetId = 0; % Last horizontal block's +x streets do not have straight street once they end, so filling 0
                else
                    %totalHorStreets = hBlocks*(vBlocks-1)*2  % multiplying by 2 as every street has corresponding opposite street
                    straightStreetId = obj.id+1 ;
                end
                obj.straightId = straightStreetId;
                
            elseif(str=='-x') % for -ve x-dir street
                if(hBlockIndex == 1)
                    straightStreetId = 0; % First horizontal block's -x streets do not have straight street once they end, so filling 0
                else
                    straightStreetId = obj.id+1;
                end
                obj.straightId = straightStreetId;
                
            elseif(str=='+y') % for positive y-dir street
                if(vBlockIndex == vBlocks)
                    straightStreetId = 0; % Last vertical block's +y streets do not have straight street once they end, so filling 0
                else
                    straightStreetId = obj.id+1 ;
                end
                obj.straightId = straightStreetId;
                
            elseif(str=='-y') % for positive y-dir street
                if(vBlockIndex == 1)
                    straightStreetId = 0 ; % First vertical block's -y streets do not have straight street once they end, so filling 0
                else
                    straightStreetId = obj.id + 1 ;
                end
                obj.straightId = straightStreetId;
            end
            
        end
        
        % set id of u-turn road passed street object
        % street for which u-turn street id is calculated could be '+x'
        % '+y' '-x' '-y'. So it will be calculated differently for all these cases.
        function setUTurnStreetId( obj,hBlockIndex, vBlockIndex, hBlocks, vBlocks, str)
            if(str=='+x') % for positve x-dir street
                obj.uTurnId = (vBlockIndex-1)*hBlocks*2 + hBlockIndex + 2*(hBlocks -hBlockIndex) + 1;
                
            elseif(str=='-x') % for -ve x-dir street
                obj.uTurnId = (vBlockIndex-1)*hBlocks*2 + hBlockIndex   ;
            elseif(str=='+y') % for positive y-dir street
                obj.uTurnId = obj.id + 2*(vBlocks - vBlockIndex) + 1  ;
                
            elseif(str=='-y') % for positive y-dir street
                totalHorStreets = hBlocks*(vBlocks-1)*2;
                obj.uTurnId = totalHorStreets + (hBlockIndex -1)*vBlocks*2 + vBlockIndex;
            end
            
        end
        function delete(obj)
            
        end
        
    end
    
    
    
end

