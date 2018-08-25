classdef Ssid < MlWrapper
    % Ssid This object models IEEE 802.11 SSID information element.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_ssid.html
    
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
            mexSsid('delete', obj.cppHandle);
        end
        
        function objND = IsBroadcast(obj)
            objND = mexSsid('IsBroadcast', obj.get());
        end
        
        function objND = GetInformationFieldSize(obj)
            objND = mexSsid('GetInformationFieldSize', obj.get());
        end
        
        function obj = Ssid(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexSsid('new');
                case 1
                    obj.cppHandle = mexSsid('new', varargin{1});
                case 2
                    obj.cppHandle = mexSsid('new', varargin{1}, varargin{2}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function objND = IsEqual(obj, o)
            objND = mexSsid('IsEqual', obj.get(), o.get());
        end
    end
end