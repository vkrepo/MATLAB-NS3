classdef PacketSinkHelper < MlWrapper
    % PacketSinkHelper This object is used for initiating a packet sink application on a set of nodes.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_packet_sink_helper.html
    
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
            mexPacketSinkHelper('delete', obj.cppHandle);
        end
        
        function SetAttribute(obj, name, value)
            mexPacketSinkHelper('SetAttribute', obj.get(), name, value.get());
        end
        
        function obj = PacketSinkHelper(protocol, address)
            % Creates a packet sink application with given protocol (as string) and adress object.
            
            obj.cppHandle = mexPacketSinkHelper('new', strcat('ns3::', protocol), address.get());
        end
        
        function objND = Install(obj, varargin)
            % Installs packet sink application on node/node-container.
            
            switch(length(varargin))
                case 1
                    objND = mexPacketSinkHelper('Install', obj.get(), varargin{1}.get());
                    objND = ApplicationContainer.appContCreationFromUint64(objND);
                otherwise
                    objND = 0;
            end
        end
    end
end
