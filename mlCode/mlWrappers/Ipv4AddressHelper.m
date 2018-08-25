classdef Ipv4AddressHelper < MlWrapper
    % Ipv4AddressHelper This object is used to assignment of Ipv4 address to the nodes.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_ipv4_address_helper.html
    
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
            mexIpv4AddressHelper('delete', obj.cppHandle);
        end
        
        function SetBase(obj, network, mask, varargin)
            % Sets the base address. Inputs to be provided as strings in dotted decimal format.
            
            narginchk(2, 3);
            numvarargs = length(varargin);
            opt_args = {'0.0.0.1' };
            opt_args(1:numvarargs) = varargin;
            mexIpv4AddressHelper('SetBase', obj.get(), network, mask, opt_args{1});
        end
        
        function obj = Ipv4AddressHelper(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexIpv4AddressHelper('new');
                case 3
                    obj.cppHandle = mexIpv4AddressHelper('new', varargin{1}.get(), varargin{2}.get(), varargin{3}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function objND = Assign(obj, c)
            objND = mexIpv4AddressHelper('Assign', obj.get(), c.get());
            objND = Ipv4InterfaceContainer.ipv4icCreationFromUint64(objND);
        end
    end
end
