classdef Wifi80211pHelper < MlWrapper & WifiHelper
    % Wifi80211pHelper This object creates a WiFi 802.11p network device and it installs that on a node.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_wifi80211p_helper.html
    
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
            mexWifi80211pHelper('delete', obj.cppHandle);
        end
        
        function SetStandard(obj, standard)
            % Sets the WiFi standard with the provided enumation of the WiFi standard.
            
            mexWifi80211pHelper('SetStandard', obj.get(), uint32(standard));
        end
        
        function objND = Install(obj, phy, macHelper, c)
            % Installs 802.11p Phy and MAC on the given node-container and returns the net-device container.
            objND = mexWifi80211pHelper('Install', obj.get(), phy.get(), macHelper.get(), c.get());
            objND = NetDeviceContainer.ndcCreationFromUint64(objND);
        end
        
        function obj = Wifi80211pHelper(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexWifi80211pHelper('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
    
    methods (Static)
        function objND = Default()
            objND = Wifi80211pHelper(0);
            objND.cppHandle = mexWifi80211pHelper('Default');
        end
        
        function EnableLogComponents()
            mexWifi80211pHelper('EnableLogComponents');
        end
    end
end
