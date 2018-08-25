classdef stats
    % Update packet statsfor nodes/vehicles and also allow to retrieve them
    
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
        % This function acts as a get/set function for statistics. If there
        % are 3 params then it becomes a set function to update 'value' of
        % the stats type 'name' otherwise it gets the 'value' of type
        % 'name'
        function val = getSetStats(nodeId, name, value)
            % Persistent variable to store stats of all nodes indexed by
            % their id's and type of statistics
            persistent nodeStats;
            if(nargin == 3)
                if(value>0) % Increment the count by value
                    nodeStats(nodeId).name = nodeStats(nodeId).name + value;
                else % set the value to 0, use while initialization
                    nodeStats(nodeId).name = 0;
                end
            end
            val = nodeStats(nodeId).name;
        end
        
    end
end

