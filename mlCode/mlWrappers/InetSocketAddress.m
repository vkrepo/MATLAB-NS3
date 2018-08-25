classdef InetSocketAddress < MlWrapper
    % InetSocketAddress This object holds Inet address.
    % This object is similar to inet_sockaddr in the BSD socket API. i.e.,
    % It holds an Ipv4Address and a port number to form an ipv4 transport endpoint.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_inet_socket_address.html
    
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
            mexInetSocketAddress('delete', obj.cppHandle);
        end
        
        function objND = GetTos(obj)
            objND = mexInetSocketAddress('GetTos', obj.get());
        end
        
        function SetTos(obj, tos)
            mexInetSocketAddress('SetTos', obj.get(), tos.get());
        end
        
        function objND = GetIpv4(obj)
            objND = mexInetSocketAddress('GetIpv4', obj.get());
            objND = Ipv4Address.ip4addrCreationFromUint64(objND);
        end
        
        function obj = InetSocketAddress(varargin)
            % Create an INET socket object from IPv4 adresss and port number. Arguments are IPV4 address object and port number (as an integer) respectively.
            
            switch(length(varargin))
                case 2
                    obj.cppHandle = mexInetSocketAddress('new', varargin{1}.get(), varargin{2});
                case 1
                    obj.cppHandle = mexInetSocketAddress('new', varargin{1}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function SetIpv4(obj, address)
            mexInetSocketAddress('SetIpv4', obj.get(), address.get());
        end
        
        function objND = GetPort(obj)
            objND = mexInetSocketAddress('GetPort', obj.get());
        end
        
        function SetPort(obj, port)
            mexInetSocketAddress('SetPort', obj.get(), port);
        end
        
        function objND = GetAddressOperator(obj)
            % Returns an address object which represents the InetSocketAddress object.
            
            objND = mexInetSocketAddress('GetAddressOperator', obj.get());
            objND = Address.addrCreationFromUint64(objND);
        end
    end
end
