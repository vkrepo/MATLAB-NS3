classdef NodeList < MlWrapper
    % NodeList This object maintains the list of nodes in the simulation.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_node_list.html
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties ( Access = private, Hidden = true)
        cppHandle
    end
    
    methods
        function set(obj, val)
            obj.cppHandle = val;
        end
        
        function val = get(obj)
            val = obj.cppHandle;
        end
    end
    
    methods (Static)
        function objND = GetNNodes()
            objND = mexNodeList('GetNNodes');
        end
        
        function objND = GetNode(n)
            objND = mexNodeList('GetNode', n);
            objND = Node.nodeCreationFromUint64(objND);
        end
    end
end