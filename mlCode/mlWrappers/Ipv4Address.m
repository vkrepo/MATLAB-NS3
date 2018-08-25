classdef Ipv4Address < MlWrapper
    % Ipv4Address This object holds Ipv4 addresses in the host-byte order.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_ipv4_address.html
    
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
            mexIpv4Address('delete', obj.cppHandle);
        end
        
        function obj = Ipv4Address(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexIpv4Address('new');
                case 1
                    obj.cppHandle = mexIpv4Address('new', varargin{1});
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function Set(obj, varargin)
            switch(length(varargin))
                case 1
                    mexIpv4Address('Set', obj.get(), varargin{1});
                otherwise
            end
        end
        
        function objND = IsSubnetDirectedBroadcast(obj, mask)
            objND = mexIpv4Address('IsSubnetDirectedBroadcast', obj.get(), mask.get());
        end
        
        function objND = Get(obj)
            objND = mexIpv4Address('Get', obj.get());
        end
        
        function objND = IsMulticast(obj)
            objND = mexIpv4Address('IsMulticast', obj.get());
        end
        
        function objND = IsBroadcast(obj)
            objND = mexIpv4Address('IsBroadcast', obj.get());
        end
        
        function objND = IsAny(obj)
            objND = mexIpv4Address('IsAny', obj.get());
        end
        
        function objND = IsLocalhost(obj)
            objND = mexIpv4Address('IsLocalhost', obj.get());
        end
        
        function objND = GetSubnetDirectedBroadcast(obj, mask)
            objND = mexIpv4Address('GetSubnetDirectedBroadcast', obj.get(), mask.get());
            objND = Ipv4Address.ip4addrCreationFromUint64(objND);
        end
        
        function objND = GetAddressOperator(obj)
            % Returns an address object which represents the Ipv4Address object.
            
            objND = mexIpv4Address('GetAddressOperator', obj.get());
            objND = Address.addrCreationFromUint64(objND);
        end
    end
    
    methods (Static)
        function objND = GetLoopback()
            objND = mexIpv4Address('GetLoopback');
            objND = Ipv4Address.ip4addrCreationFromUint64(objND);
        end
        
        function objND = GetBroadcast()
            objND = mexIpv4Address('GetBroadcast');
            objND = Ipv4Address.ip4addrCreationFromUint64(objND);
        end
        
        function objND = GetAny()
            objND = mexIpv4Address('GetAny');
            objND = Ipv4Address.ip4addrCreationFromUint64(objND);
        end
        
        function objND = GetZero()
            objND = mexIpv4Address('GetZero');
            objND = Ipv4Address.ip4addrCreationFromUint64(objND);
        end
        
        function objND = ip4addrCreationFromUint64 (val)
            objND = Ipv4Address(0, 0);
            objND.cppHandle = val;
        end
    end
end
