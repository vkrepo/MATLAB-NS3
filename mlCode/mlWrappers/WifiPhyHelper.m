classdef WifiPhyHelper < MlWrapper
    % WifiPhyHelper This object models the functionality of WiFi PHY layer.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_wifi_phy_helper.html
    
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
        
        function Set(obj, name, v)
            mexWifiPhyHelper('Set', obj.get(), name, v.get());
        end
    end
end