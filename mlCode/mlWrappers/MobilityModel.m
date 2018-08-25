classdef MobilityModel < MlWrapper
    % MobilityModel This object keeps track of current position and velocity of a node.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_mobility_model.html
    
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
        
        function SetPosition(obj, position)
            % Sets the given position to the node
            mexMobilityModel('SetPosition', obj.get(), position);
        end
        
        function objND = GetVelocity(obj)
            % Returns the current velocity of the node
            objND = mexMobilityModel('GetVelocity', obj.get());
        end
        
        function objND = GetPosition(obj)
            % Returns the current position of the node
            objND = mexMobilityModel('GetPosition', obj.get());
        end
    end
end