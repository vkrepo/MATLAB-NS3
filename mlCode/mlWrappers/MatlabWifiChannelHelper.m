classdef MatlabWifiChannelHelper < MlWrapper
    % MatlabWifiChannelHelper This object is used to create and manage WiFi channel object for the MATLAB PHY model.
    
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
            mexMatlabWifiChannelHelper('delete', obj.cppHandle)
        end
        
        function SetPropagationDelay(obj, name, varargin)
            % Sets propagation delay model.
            
            narginchk(1, 17);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() };
            opt_args(1:numvarargs) = varargin;
            mexMatlabWifiChannelHelper('SetPropagationDelay', obj.get(), strcat('ns3::', name), opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get());
        end
        
        function AddPropagationLoss(obj, name, varargin)
            % Sets propagation loss model.
            
            narginchk(1, 17);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() };
            opt_args(1:numvarargs) = varargin;
            mexMatlabWifiChannelHelper('AddPropagationLoss', obj.get(), strcat('ns3::', name), opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get());
        end
        
        function obj = MatlabWifiChannelHelper()
            % Creates MATLAB WiFi channel helper object.
            
            obj.cppHandle = mexMatlabWifiChannelHelper('new');
        end
        
        function objND = Create(obj)
            % Creates MATLAB WiFi channel object.
            
            objND = mexMatlabWifiChannelHelper('Create', obj.get());
            objND = MatlabWifiChannel.mwcCreationFromUint64(objND);
        end
        
        function CallBackRegistration(obj, callback)
            % Register a callback for sending packet from NS3 to MATLAB.
            
            mexMatlabWifiChannelHelper('CallBackRegistration', obj.get(), callback);
        end
    end
    
    methods (Static)
        function objND = Default()
            % Creates MATLAB WiFi default channel.
            
            objND = MatlabWifiChannelHelper();
            mexMatlabWifiChannelHelper('delete', objND.cppHandle);
            objND.cppHandle = mexMatlabWifiChannelHelper('Default');
        end
    end
end
