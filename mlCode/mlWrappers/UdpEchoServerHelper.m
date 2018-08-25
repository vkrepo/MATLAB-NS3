classdef UdpEchoServerHelper < MlWrapper
    % UdpEchoServerHelper This object creates a server application which waits for UDP packets and sends them back to original sender.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_udp_echo_server_helper.html
    
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
            mexUdpEchoServerHelper('delete', obj.cppHandle);
        end
        
        function SetAttribute(obj, name, value)
            mexUdpEchoServerHelper('SetAttribute', obj.get(), name, value.get());
        end
        
        function obj = UdpEchoServerHelper(port)
            obj.cppHandle = mexUdpEchoServerHelper('new', port);
        end
        
        function objND = Install(obj, varargin)
            % Installs UDP echo server application on the given node/node-container.
            
            switch(length(varargin))
                case 1
                    objND = mexUdpEchoServerHelper('Install', obj.get(), varargin{1}.get());
                    objND = ApplicationContainer.appContCreationFromUint64(objND);
                otherwise
                    objND = 0;
            end
        end
    end
end
