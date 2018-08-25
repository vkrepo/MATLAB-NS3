classdef Ipv4InterfaceContainer < MlWrapper
    % Ipv4InterfaceContainer This object holds a vector of pairs of Ipv4 adress and Interface index.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_ipv4_interface_container.html
    
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
            mexIpv4InterfaceContainer('delete', obj.cppHandle);
        end
        
        function objND = GetAddress(obj, i, varargin)
            narginchk(1, 2);
            numvarargs = length(varargin);
            opt_args = {0 };
            opt_args(1:numvarargs) = varargin;
            objND = mexIpv4InterfaceContainer('GetAddress', obj.get(), i, opt_args{1});
            objND = Ipv4Address.ip4addrCreationFromUint64(objND);
        end
        
        function Add(obj, varargin)
            switch(length(varargin))
                case 1
                    mexIpv4InterfaceContainer('Add', obj.get(), varargin{1});
                case 2
                    mexIpv4InterfaceContainer('Add', obj.get(), varargin{1}, varargin{2});
                otherwise
            end
        end
        
        function obj = Ipv4InterfaceContainer(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexIpv4InterfaceContainer('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function objND = GetN(obj)
            objND = mexIpv4InterfaceContainer('GetN', obj.get());
        end
        
        function SetMetric(obj, i, metric)
            mexIpv4InterfaceContainer('SetMetric', obj.get(), i, metric);
        end
    end
    
    methods (Static)
        function objND = ipv4icCreationFromUint64 (val)
            % MATLAB wrapper around c++ IpveInterfaceContainer object.
            
            objND = Ipv4InterfaceContainer(0);
            objND.cppHandle = val;
        end
    end
end
