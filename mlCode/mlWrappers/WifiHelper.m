classdef WifiHelper < MlWrapper
    % WifiHelper This object creates a WiFi network device and it installs that on a node.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_wifi_helper.html
    
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
            mexWifiHelper('delete', obj.cppHandle);
        end
        
        function SetStandard(obj, standard)
            % Sets the WiFi standard with the given enumation of the WiFi standard.
            
            mexWifiHelper('SetStandard', obj.get(), uint32(standard));
        end
        
        function SetRemoteStationManager(obj, type, varargin)
            narginchk(1, 17);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() };
            opt_args(1:numvarargs) = varargin;
            mexWifiHelper('SetRemoteStationManager', obj.get(), strcat('ns3::', type), opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get());
        end
        
        function obj = WifiHelper()
            obj.cppHandle = mexWifiHelper('new');
        end
        
        function objND = Install(obj, varargin)
            % Installs the WiFi MAC and WiFi PHY on the given node/node-container and returns the netdevice container
            
            switch(length(varargin))
                case 3
                    objND = mexWifiHelper('Install', obj.get(), varargin{1}.get(), varargin{2}.get(), varargin{3}.get());
                    objND = NetDeviceContainer.ndcCreationFromUint64(objND);
                otherwise
                    objND = 0;
            end
        end
    end
    
    methods (Static)
        function EnableLogComponents()
            mexWifiHelper('EnableLogComponents');
        end
    end
end
