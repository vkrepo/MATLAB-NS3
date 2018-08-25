classdef Ipv4GlobalRoutingHelper < MlWrapper
    % Ipv4GlobalRoutingHelper This object adds global routing protocol to internet stack of a node.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_ipv4_global_routing_helper.html
    
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
        
        function delete(obj)
            mexIpv4GlobalRoutingHelper('delete', obj.cppHandle);
        end
        
        function obj = Ipv4GlobalRoutingHelper(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexIpv4GlobalRoutingHelper('new');
                case 1
                    obj.cppHandle = mexIpv4GlobalRoutingHelper('new', varargin{1}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
    
    methods (Static)
        function RecomputeRoutingTables()
            mexIpv4GlobalRoutingHelper('RecomputeRoutingTables');
        end
        
        function PopulateRoutingTables()
            mexIpv4GlobalRoutingHelper('PopulateRoutingTables');
        end
    end
end
