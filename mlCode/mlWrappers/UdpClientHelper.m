classdef UdpClientHelper < MlWrapper
    % UdpClientHelper This object creates a client application which sends UDP packets.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_udp_client_helper.html
    
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
            mexUdpClientHelper('delete', obj.cppHandle);
        end
        
        function obj = UdpClientHelper(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexUdpClientHelper('new');
                case 2
                    obj.cppHandle = mexUdpClientHelper('new', varargin{1}.get(), varargin{2});
                case 1
                    obj.cppHandle = mexUdpClientHelper('new', varargin{1}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function SetAttribute(obj, name, value)
            mexUdpClientHelper('SetAttribute', obj.get(), name, value.get());
        end
        
        function objND = Install(obj, c)
            % Installs the UDP client application on node/node-container.
            objND = mexUdpClientHelper('Install', obj.get(), c.get());
            objND = ApplicationContainer.appContCreationFromUint64(objND);
        end
    end
end
