classdef YansWifiPhyHelper < MlWrapper & WifiPhyHelper
    % YansWifiPhyHelper This object is used to create and manage PHY object for the Yans model.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_yans_wifi_phy_helper.html
    
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
            mexYansWifiPhyHelper('delete', obj.cppHandle);
        end
        
        function obj = YansWifiPhyHelper(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexYansWifiPhyHelper('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
        function SetChannel(obj, varargin)
            % Sets the channel to given channel object
            
            switch(length(varargin))
                case 1
                    mexYansWifiPhyHelper('SetChannel', obj.get(), varargin{1}.get());
                otherwise
            end
        end
    end
    
    methods (Static)
        function objND = Default()
            objND = YansWifiPhyHelper(0);
            objND.cppHandle = mexYansWifiPhyHelper('Default');
        end
    end
end