classdef UdpServerHelper < MlWrapper
    % UdpServerHelper This object creates a server application which waits for input UDP packets and
    % uses their payload to determine delay and packet losses.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_udp_server_helper.html
    
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
            mexUdpServerHelper('delete', obj.cppHandle);
        end
        
        function SetAttribute(obj, name, value)
            mexUdpServerHelper('SetAttribute', obj.get(), name, value.get());
        end
        
        function objND = Install(obj, c)
            % Installs the UDP server application on node/node-container.
            objND = mexUdpServerHelper('Install', obj.get(), c.get());
            objND = ApplicationContainer.appContCreationFromUint64(objND);
        end
        
        function obj = UdpServerHelper(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexUdpServerHelper('new');
                case 1
                    obj.cppHandle = mexUdpServerHelper('new', varargin{1});
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
end
