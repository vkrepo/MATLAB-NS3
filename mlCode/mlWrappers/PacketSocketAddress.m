classdef PacketSocketAddress < MlWrapper
    % PacketSocketAddress This object models a packet socket address.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_packet_socket_address.html
    
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
            mexPacketSocketAddress('delete', obj.cppHandle);
        end
        
        function SetSingleDevice(obj, arg1, arg2)
            % Set the address to match only a specified netDevice in netdevice container. Arguments being net-device container and index of netdevice in that container respectively.
            
            mexPacketSocketAddress('SetSingleDevice', obj.get(), arg1.get(), arg2);
        end
        
        function SetPhysicalAddress(obj, arg1, arg2)
            % Set the destination MAC address to specified netDevice in netdevice container. Arguments being net-device container and index of netdevice in that container respectively.
            
            mexPacketSocketAddress('SetPhysicalAddress', obj.get(), arg1.get(), arg2);
        end
        
        function objND = GetAddressOperator(obj)
            % Returns an address object which represents the PacketSocketAddress object.
            
            objND = mexPacketSocketAddress('GetAddressOperator', obj.get());
            objND = Address.addrCreationFromUint64(objND);
        end
        
        function obj = PacketSocketAddress()
            obj.cppHandle = mexPacketSocketAddress('new');
        end
        
        function SetProtocol(obj, protocol)
            mexPacketSocketAddress('SetProtocol', obj.get(), protocol);
        end
        
    end
end
