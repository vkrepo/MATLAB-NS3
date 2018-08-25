classdef UdpEchoClientHelper < MlWrapper
    % UdpEchoClientHelper This object creates an application which sends a UDP packet and waits for its echo.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_udp_echo_client_helper.html
    
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
            mexUdpEchoClientHelper('delete', obj.cppHandle);
        end
        
        function obj = UdpEchoClientHelper(varargin)
            switch(length(varargin))
                case 2
                    obj.cppHandle = mexUdpEchoClientHelper('new', varargin{1}.get(), varargin{2});
                case 1
                    obj.cppHandle = mexUdpEchoClientHelper('new', varargin{1}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function SetAttribute(obj, name, value)
            mexUdpEchoClientHelper('SetAttribute', obj.get(), name, value.get());
        end
        
        function objND = Install(obj, varargin)
            % Installs UDP echo client application on the given node/node-container.
            
            switch(length(varargin))
                case 1
                    objND = mexUdpEchoClientHelper('Install', obj.get(), varargin{1}.get());
                    objND = ApplicationContainer.appContCreationFromUint64(objND);
                otherwise
                    objND = 0;
            end
        end
    end
end
