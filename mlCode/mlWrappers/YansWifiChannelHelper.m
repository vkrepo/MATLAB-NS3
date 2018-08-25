classdef YansWifiChannelHelper < MlWrapper
    % YansWifiChannelHelper This object is used to create and manage WiFi channel object for the Yans model.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_yans_wifi_channel_helper.html
    
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
            mexYansWifiChannelHelper('delete', obj.cppHandle);
        end
        
        function SetPropagationDelay(obj, name, varargin)
            % Set the channel propagation delay.
            
            narginchk(1, 17);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() };
            opt_args(1:numvarargs) = varargin;
            mexYansWifiChannelHelper('SetPropagationDelay', obj.get(), strcat('ns3::', name), opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get());
        end
        
        function AddPropagationLoss(obj, name, varargin)
            % Set the channel propagation loss.
            
            narginchk(1, 17);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() };
            opt_args(1:numvarargs) = varargin;
            mexYansWifiChannelHelper('AddPropagationLoss', obj.get(), strcat('ns3::', name), opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get());
        end
        
        function obj = YansWifiChannelHelper(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexYansWifiChannelHelper('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
        function objND = Create(obj)
            objND = mexYansWifiChannelHelper('Create', obj.get());
            objND = YansWifiChannel.ywcCreationFromUint64(objND);
        end
    end
    
    methods (Static)
        function objND = Default()
            objND = YansWifiChannelHelper(0);
            objND.cppHandle = mexYansWifiChannelHelper('Default');
        end
        
    end
end
