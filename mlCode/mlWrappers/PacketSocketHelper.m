classdef PacketSocketHelper < MlWrapper
    % PacketSocketHelper This object gives packet socket capability to a node.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_packet_socket_helper.html
    
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
            mexPacketSocketHelper('delete', obj.cppHandle);
        end
        
        function obj = PacketSocketHelper()
            obj.cppHandle = mexPacketSocketHelper('new');
        end
        
        function Install(obj, varargin)
            % Aggregates a socket object on the provided node/node-container.
            switch(length(varargin))
                case 1
                    mexPacketSocketHelper('Install', obj.get(), varargin{1}.get());
                otherwise
            end
        end
    end
end