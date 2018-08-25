classdef MatlabWifiPhyHelper < MlWrapper & WifiPhyHelper
    % MaltabWifiPhyHelper This object is used to create and manage the PHY objects for the MATLAB PHY model.
    
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
            mexMatlabWifiPhyHelper('delete', obj.cppHandle)
        end
        function obj = MatlabWifiPhyHelper()
            obj.cppHandle = mexMatlabWifiPhyHelper('new');
        end
        
        
        function SetChannel(obj, varargin)
            % Sets channel on PHY with channel object as input argument.
            
            switch(length(varargin))
                case 1
                    mexMatlabWifiPhyHelper('SetChannel', obj.get(), varargin{1}.get());
                otherwise
            end
        end
    end
    
    methods (Static)
        function objND = Default()
            % Creates a PHY with default attributes.
            
            objND = MatlabWifiPhyHelper();
            mexMatlabWifiPhyHelper('delete', objND.cppHandle);
            objND.cppHandle = mexMatlabWifiPhyHelper('Default');
        end
        
    end
end
