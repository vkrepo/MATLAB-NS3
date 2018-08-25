classdef WaveHelper < MlWrapper
    % WaveHelper This object creates a WAVE network device and it installs that on a node.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_wave_helper.html
    
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
            mexWaveHelper('delete', obj.cppHandle);
        end
        
        function obj = WaveHelper(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexWaveHelper('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
        function SetChannelScheduler(obj, type, varargin)
            % Sets the channel scheduler.
            
            narginchk(1, 17);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() };
            opt_args(1:numvarargs) = varargin;
            mexWaveHelper('SetChannelScheduler', obj.get(), strcat('ns3::', type), opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get());
        end
        
        function SetRemoteStationManager(obj, type, varargin)
            % Sets the rate control algorithm.
            
            narginchk(1, 17);
            numvarargs = length(varargin);
            opt_args = {'' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() '' EmptyAttributeValue() };
            opt_args(1:numvarargs) = varargin;
            mexWaveHelper('SetRemoteStationManager', obj.get(), strcat('ns3::', type), opt_args{1}, opt_args{2}.get(), opt_args{3}, opt_args{4}.get(), opt_args{5}, opt_args{6}.get(), opt_args{7}, opt_args{8}.get(), opt_args{9}, opt_args{10}.get(), opt_args{11}, opt_args{12}.get(), opt_args{13}, opt_args{14}.get(), opt_args{15}, opt_args{16}.get());
        end
        
        function objND = Install(obj, varargin)
            % Installs WAVE PHY and WAVE MAC on the given node container and returns the net-device container.
            
            switch(length(varargin))
                case 3
                    objND = mexWaveHelper('Install', obj.get(), varargin{1}.get(), varargin{2}.get(), varargin{3}.get());
                    objND = NetDeviceContainer.ndcCreationFromUint64(objND);
                otherwise
                    objND = 0;
            end
        end
        
        function CreatePhys(obj, phys)
            mexWaveHelper('CreatePhys', obj.get(), phys);
        end
    end
    
    methods (Static)
        function objND = Default()
            objND = WaveHelper(0);
            objND.cppHandle = mexWaveHelper('Default');
        end
        
        function EnableLogComponents()
            mexWaveHelper('EnableLogComponents');
        end
    end
end
