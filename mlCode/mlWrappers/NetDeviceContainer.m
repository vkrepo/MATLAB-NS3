classdef NetDeviceContainer < MlWrapper
    % NetDeviceContainer This object holds a set of network device objects.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_net_device_container.html
    
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
            mexNetDeviceContainer('delete', obj.cppHandle);
        end
        
        function Add(obj, varargin)
            switch(length(varargin))
                case 1
                    mexNetDeviceContainer('Add', obj.get(), varargin{1}.get());
                otherwise
            end
        end
        
        function objND = GetN(obj)
            objND = mexNetDeviceContainer('GetN', obj.get());
        end
        
        function obj = NetDeviceContainer(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexNetDeviceContainer('new');
                case 1
                    obj.cppHandle = mexNetDeviceContainer('new', varargin{1});
                case 2
                    obj.cppHandle = mexNetDeviceContainer('new', varargin{1}.get(), varargin{2}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function objND = Get(obj, i)
            objND = mexNetDeviceContainer('Get', obj.get(), i);
        end
    end
    
    methods (Static)
        function objND = ndcCreationFromUint64 (val)
            % MATLAB wrapper around c++ NetDeviceContainer object.
            
            objND = NetDeviceContainer(0, 0, 0);
            objND.cppHandle = val;
        end
    end
end