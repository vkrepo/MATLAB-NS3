classdef YansWifiChannel < MlWrapper
    % YansWifiChannel This object models the functionality of a shared wireless channel for yans PHY model.
    % More details at https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_yans_wifi_channel.html
    
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
            mexYansWifiChannel('delete', obj.cppHandle);
        end
        
        function obj = YansWifiChannel(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexYansWifiChannel('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
    
    methods (Static)
        function objND = ywcCreationFromUint64 (val)
            objND = YansWifiChannel(0);
            objND.cppHandle = val;
        end
    end
end